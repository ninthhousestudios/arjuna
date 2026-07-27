// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Per-call cost of [SweFacade.calcAll] vs [SweFacade.calcBodies] for the
/// narrow configs event scans actually use.
///
/// Run with real ephe files — Moshier has a different cost profile and would
/// not measure the thing:
///
///     ARROW_EPHE_PATH=/path/to/ephe dart run \
///         arrow/swe/benchmark/calc_bodies_bench.dart
///
/// The julian day advances every iteration. Reusing one jd would measure the
/// Swiss Ephemeris segment cache rather than the call.
library;

import 'dart:io';

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

const _iterations = 2000;
const _warmup = 200;

const _location = Location(
  latitude: 40.7128,
  longitude: -74.0060,
  altitude: 10.0,
);

/// ~2026-04-14, stepping forward by an hour per iteration.
const _jdStart = 2461145.0;
const _jdStep = 1.0 / 24.0;

typedef _Call = void Function(double jdUt, SweConfig config);

double _timeUs(_Call call, SweConfig config) {
  for (var i = 0; i < _warmup; i++) {
    call(_jdStart + i * _jdStep, config);
  }
  final sw = Stopwatch()..start();
  for (var i = 0; i < _iterations; i++) {
    call(_jdStart + i * _jdStep, config);
  }
  sw.stop();
  return sw.elapsedMicroseconds / _iterations;
}

String? _findEphePath() {
  final env = Platform.environment['ARROW_EPHE_PATH'];
  if (env != null && Directory(env).existsSync()) return env;
  final home = Platform.environment['HOME'] ?? '';
  for (final p in [
    '$home/nhs/soft/astrology/libaditya/libaditya/ephe',
    '$home/.arrow/ephe',
    '/usr/local/share/swisseph',
  ]) {
    if (Directory(p).existsSync()) return p;
  }
  return null;
}

void main() {
  final ephePath = _findEphePath();
  if (ephePath == null) {
    stderr.writeln('no ephe path found; set ARROW_EPHE_PATH');
    exit(1);
  }

  final facade = SweFacade.create(ephePath: ephePath);

  const configs = <String, SweConfig>{
    '1 body  (moon, tropical)': SweConfig(
      bodies: {Body.moon},
      signAyanamsa: Ayanamsa.tropical,
    ),
    '2 bodies (venus+sun, tropical)': SweConfig(
      bodies: {Body.venus, Body.sun},
      signAyanamsa: Ayanamsa.tropical,
    ),
    '2 bodies (venus+sun, lahiri)': SweConfig(
      bodies: {Body.venus, Body.sun},
      signAyanamsa: Ayanamsa.lahiri,
    ),
  };

  stdout
    ..writeln('ephe: $ephePath   iterations: $_iterations\n')
    ..writeln(
      '${'config'.padRight(32)}'
      '${'calcAll'.padLeft(11)}'
      '${'calcBodies'.padLeft(13)}'
      '${'-pheno'.padLeft(11)}'
      '${'speedup'.padLeft(10)}',
    );

  for (final entry in configs.entries) {
    final all = _timeUs(
      (jd, c) => facade.calcAll(jd, _location, c),
      entry.value,
    );
    final bodies = _timeUs(
      (jd, c) => facade.calcBodies(jd, _location, c),
      entry.value,
    );
    final noPheno = _timeUs(
      (jd, c) => facade.calcBodies(jd, _location, c, includePheno: false),
      entry.value,
    );

    stdout.writeln(
      '${entry.key.padRight(32)}'
      '${'${all.toStringAsFixed(1)}us'.padLeft(11)}'
      '${'${bodies.toStringAsFixed(1)}us'.padLeft(13)}'
      '${'${noPheno.toStringAsFixed(1)}us'.padLeft(11)}'
      '${'${(all / noPheno).toStringAsFixed(2)}x'.padLeft(10)}',
    );
  }

  facade.dispose();
}
