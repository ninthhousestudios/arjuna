// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:quiver_embedded/quiver_embedded.dart';

import '../../format/chart.dart';
import '../error.dart';
import 'astro.dart';
import 'cusp.dart';
import 'planet.dart';
import 'value.dart';
import 'varga.dart';

class NockChart extends NockValue {
  final Chart chart;
  final Vayu vayu;
  String? label;

  NockChart(this.chart, this.vayu);

  @override
  String display() => formatChart(chart, label: label);

  @override
  NockValue access(String field) => switch (field) {
    'sun' => NockPlanet(chart.sun, chart),
    'moon' => NockPlanet(chart.moon, chart),
    'mars' => NockPlanet(chart.mars, chart),
    'mercury' => NockPlanet(chart.mercury, chart),
    'jupiter' => NockPlanet(chart.jupiter, chart),
    'venus' => NockPlanet(chart.venus, chart),
    'saturn' => NockPlanet(chart.saturn, chart),
    'rahu' => NockPlanet(chart.rahu, chart),
    'ketu' => NockPlanet(chart.ketu, chart),
    'asc' => _ascendant(),
    'mc' => _midheaven(),
    'houses' => NockList(chart.cusps.map(NockCusp.new).toList()),
    'planets' => NockList(
      chart.planets.map((p) => NockPlanet(p, chart)).toList(),
    ),
    'grahas' => NockList(
      chart.grahas.map((g) => NockPlanet(g, chart)).toList(),
    ),
    'karakas' => NockList(
      chart.karakas.map((k) => NockPlanet(k, chart)).toList(),
    ),
    _ => throw NockError('chart has no property "$field"'),
  };

  @override
  Future<NockValue> call(
    String method,
    List<NockValue> positional,
    Map<String, NockValue> named,
  ) async => switch (method) {
    'navamsa' => _varga(VargaType.navamsha),
    'varga' => _vargaFromArg(positional),
    _ => throw NockError('chart has no method "$method"'),
  };

  NockValue _ascendant() {
    final lon = Longitude(
      chart.ascendant,
      chart.ascendant,
      VargaType.rashi,
      chart.config,
    );
    return NockSign(lon.sign, lon);
  }

  NockValue _midheaven() {
    final lon = Longitude(chart.mc, chart.mc, VargaType.rashi, chart.config);
    return NockSign(lon.sign, lon);
  }

  NockValue _varga(VargaType type) {
    final v = chart.varga(type);
    return NockVarga(v, chart);
  }

  NockValue _vargaFromArg(List<NockValue> positional) {
    if (positional.length != 1 || positional[0] is! NockNumber) {
      throw NockError('varga() takes one numeric argument (division number)');
    }
    final n = (positional[0] as NockNumber).value.toInt();
    final type = VargaType.values.where((v) => v.amsha == n).firstOrNull;
    if (type == null) {
      throw NockError('unknown varga division: D$n');
    }
    return _varga(type);
  }

  @override
  String typeName() => 'chart';
}
