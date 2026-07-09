// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:io';

import 'package:charts_dart/charts_dart.dart';
import 'package:quiver_embedded/quiver_embedded.dart';

import 'ast.dart';
import 'error.dart';
import 'types/chart.dart';
import 'types/config.dart';
import 'types/value.dart';

class ReplSession {
  final Map<String, NockValue> variables = {};
  final Vayu vayu;
  NockConfig config;

  ReplSession({required this.vayu, NockConfig? config})
    : config = config ?? NockConfig();
}

class Evaluator {
  final ReplSession session;

  Evaluator(this.session);

  Future<NockValue?> execute(Stmt stmt) async => switch (stmt) {
    ExprStmt(:final expr) => await _eval(expr),
    Assignment(:final name, :final value) => await _assign(name, value),
  };

  Future<NockValue> _eval(Expr expr) async => switch (expr) {
    NumberLit(:final value) => NockNumber(value),
    StringLit(:final value) => NockString(value),
    Ident(:final name) => _resolveIdent(name),
    Call(:final name, :final positional, :final named) => await _call(
      name,
      positional,
      named,
    ),
    Access(:final object, :final field) => (await _eval(object)).access(field),
    MethodCall(:final object, :final method, :final positional, :final named) =>
      await (await _eval(
        object,
      )).call(method, await _evalList(positional), await _evalNamed(named)),
  };

  NockValue _resolveIdent(String name) {
    if (name == 'help') return _help();
    if (name == 'vars') return _vars();

    final value = session.variables[name];
    if (value != null) return value;

    throw NockError('undefined: $name');
  }

  Future<NockValue> _call(
    String name,
    List<Expr> positional,
    Map<String, Expr> named,
  ) async {
    return switch (name) {
      'chart' => await _chartFn(positional, named),
      'config' => await _configFn(named),
      'now' => await _nowFn(named),
      'read' => await _readFn(positional),
      _ => throw NockError('unknown function: $name'),
    };
  }

  Future<NockValue> _chartFn(
    List<Expr> positional,
    Map<String, Expr> named,
  ) async {
    if (positional.length < 3 || positional.length > 4) {
      throw NockError(
        'chart() takes 3 or 4 arguments: date, lat, lon [, config]',
      );
    }

    final dateStr = _expectString(await _eval(positional[0]), 'chart() date');
    final lat = _expectNumber(await _eval(positional[1]), 'chart() lat');
    final lon = _expectNumber(await _eval(positional[2]), 'chart() lon');

    NockConfig cfg = session.config;
    if (positional.length == 4) {
      cfg = _expectConfig(await _eval(positional[3]), 'chart() config');
    }

    final dt = _parseDate(dateStr);
    final location = Location(latitude: lat, longitude: lon);
    final options = cfg.toArrowOptions();
    final chart = session.vayu.calculateChart(dt, location, options);

    return NockChart(chart, session.vayu);
  }

  Future<NockValue> _configFn(Map<String, Expr> named) async {
    final args = <String, String>{};
    for (final entry in named.entries) {
      args[entry.key] = _expectString(
        await _eval(entry.value),
        'config() ${entry.key}',
      );
    }
    final cfg = NockConfig(
      ayanamsa: args['ayanamsa'] ?? session.config.ayanamsa,
      houses: args['houses'] ?? session.config.houses,
      circle: args['circle'] ?? session.config.circle,
      node: args['node'] ?? session.config.node,
    );
    session.config = cfg;
    return cfg;
  }

  Future<NockValue> _nowFn(Map<String, Expr> named) async {
    if (named.containsKey('lat') && named.containsKey('lon')) {
      final lat = _expectNumber(await _eval(named['lat']!), 'now() lat');
      final lon = _expectNumber(await _eval(named['lon']!), 'now() lon');
      final dt = DateTime.now().toUtc();
      final location = Location(latitude: lat, longitude: lon);
      final options = session.config.toArrowOptions();
      final chart = session.vayu.calculateChart(dt, location, options);
      return NockChart(chart, session.vayu);
    }
    throw NockError('now() requires lat: and lon: arguments');
  }

  Future<NockValue> _readFn(List<Expr> positional) async {
    if (positional.length != 1) {
      throw NockError('read() takes 1 argument: file path');
    }
    final path = _expectString(await _eval(positional[0]), 'read() path');

    final file = File(path);
    if (!file.existsSync()) {
      throw NockError('file not found: "$path"');
    }

    final ext = path.contains('.') ? '.${path.split('.').last}' : '';
    const supported = {'.chtk', '.jhd', '.toml'};
    if (!supported.contains(ext)) {
      throw NockError(
        'unsupported format: "$ext" (supported: ${supported.join(", ")})',
      );
    }

    final ChartData data;
    try {
      data = ChartIO.read(path);
    } on Exception catch (e) {
      throw NockError('failed to read "$path": $e');
    }

    final raw = data.utcDateTime;
    final utcDt = raw.isUtc
        ? raw
        : DateTime.utc(
            raw.year,
            raw.month,
            raw.day,
            raw.hour,
            raw.minute,
            raw.second,
          );
    final location = Location(
      latitude: data.birthLocation.latitude,
      longitude: data.birthLocation.longitude,
    );
    final options = session.config.toArrowOptions();
    final chart = session.vayu.calculateChart(utcDt, location, options);

    final nockChart = NockChart(chart, session.vayu);
    nockChart.label = data.name;
    return nockChart;
  }

  Future<NockValue?> _assign(String name, Expr value) async {
    const reserved = {'config', 'help', 'vars', 'quit', 'chart', 'now', 'read'};
    if (reserved.contains(name)) {
      throw NockError('cannot assign to reserved name "$name"');
    }
    final result = await _eval(value);
    session.variables[name] = result;

    if (result is NockChart) result.label = name;

    return result;
  }

  Future<List<NockValue>> _evalList(List<Expr> exprs) async {
    final results = <NockValue>[];
    for (final expr in exprs) {
      results.add(await _eval(expr));
    }
    return results;
  }

  Future<Map<String, NockValue>> _evalNamed(Map<String, Expr> named) async {
    final results = <String, NockValue>{};
    for (final entry in named.entries) {
      results[entry.key] = await _eval(entry.value);
    }
    return results;
  }

  DateTime _parseDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      if (dt.isUtc) return dt;
      // No timezone specified — treat the literal values as UTC, not local.
      return DateTime.utc(
        dt.year,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        dt.second,
      );
    } on FormatException {
      throw NockError(
        'invalid date: "$dateStr" (expected YYYY-MM-DD or YYYY-MM-DD HH:MM)',
      );
    }
  }

  String _expectString(NockValue value, String context) {
    if (value is NockString) return value.value;
    throw NockError('$context: expected string, got ${value.typeName()}');
  }

  double _expectNumber(NockValue value, String context) {
    if (value is NockNumber) return value.value;
    throw NockError('$context: expected number, got ${value.typeName()}');
  }

  NockConfig _expectConfig(NockValue value, String context) {
    if (value is NockConfig) return value;
    throw NockError('$context: expected config, got ${value.typeName()}');
  }

  NockValue _help() => NockString('''
  Variables:    name = expr
  Chart:        chart("YYYY-MM-DD HH:MM", lat, lon)
                chart("YYYY-MM-DD HH:MM", lat, lon, config)
  Read:         read("path/to/chart.chtk")
                read("path/to/chart.jhd")
                read("path/to/chart.toml")
  Config:       config(ayanamsa: "...", houses: "...", ...)
  Properties:   .sun .moon .mars .mercury .jupiter .venus .saturn
                .rahu .ketu
                .asc .mc .houses .planets .grahas .karakas
  Planet:       .longitude .sign .nakshatra .dignity .house
                .speed .retrograde .pada .combust
  Methods:      .navamsa() .varga(n)
  Functions:    now(lat: n, lon: n)
  Session:      vars  help  quit''');

  NockValue _vars() {
    if (session.variables.isEmpty) return NockString('  (no variables)');
    final lines = session.variables.entries.map((e) {
      return '  ${e.key}: ${e.value.typeName()}';
    });
    return NockString(lines.join('\n'));
  }
}
