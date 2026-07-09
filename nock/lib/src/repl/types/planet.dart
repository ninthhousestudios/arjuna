// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';

import '../../format/planet.dart';
import '../error.dart';
import 'astro.dart';
import 'value.dart';

class NockPlanet extends NockValue {
  final Planet planet;
  final Chart chart;

  NockPlanet(this.planet, this.chart);

  @override
  String display() => formatPlanetOneLiner(planet);

  @override
  NockValue access(String field) => switch (field) {
    'longitude' => NockNumber(planet.rawLongitude),
    'latitude' => NockNumber(planet.position.latitude),
    'speed' => NockNumber(planet.position.speedLongitude),
    'sign' => NockSign(planet.sign, planet.longitude),
    'nakshatra' => NockNakshatra(planet.nakshatra, planet.pada),
    'house' => NockNumber(_houseNumber().toDouble()),
    'dignity' => _resolveDignity(),
    'retrograde' => NockBool(planet.isRetrograde),
    'pada' => NockNumber(planet.pada.toDouble()),
    'combust' => _resolveCombust(),
    _ => throw NockError('planet has no property "$field"'),
  };

  /// Whole-sign house: ascendant sign = house 1.
  int _houseNumber() {
    final ascSign = Longitude(
      chart.ascendant,
      chart.ascendant,
      VargaType.rashi,
      chart.config,
    ).sign;
    return ((planet.sign - ascSign) % 12) + 1;
  }

  NockValue _resolveDignity() {
    if (planet is! Karaka) {
      throw NockError('${planet.body.name} has no dignity (not a karaka)');
    }
    return NockDignity((planet as Karaka).dignity);
  }

  NockValue _resolveCombust() {
    if (planet is! Karaka) {
      throw NockError('${planet.body.name} has no combustion (not a karaka)');
    }
    return NockBool((planet as Karaka).isCombust);
  }

  @override
  String typeName() => 'planet';
}
