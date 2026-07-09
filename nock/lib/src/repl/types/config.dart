// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

import '../error.dart';
import 'value.dart';

class NockConfig extends NockValue {
  final String ayanamsa;
  final String houses;
  final String circle;
  final String node;

  NockConfig({
    this.ayanamsa = 'tropical',
    this.houses = 'campanus',
    this.circle = 'aditya',
    this.node = 'true',
  }) {
    _resolveAyanamsa(ayanamsa);
    _resolveHouseSystem(houses);
    _resolveCircle(circle);
    if (node != 'true' && node != 'mean') {
      throw NockError('unknown node type: "$node" (expected "true" or "mean")');
    }
  }

  @override
  String display() {
    final lines = [
      '  ayanamsa : $ayanamsa',
      '  houses   : $houses',
      '  circle   : $circle',
      '  node     : $node',
    ];
    return lines.join('\n');
  }

  @override
  NockValue access(String field) => switch (field) {
    'ayanamsa' => NockString(ayanamsa),
    'houses' => NockString(houses),
    'circle' => NockString(circle),
    'node' => NockString(node),
    _ => throw NockError('config has no property "$field"'),
  };

  ArrowOptions toArrowOptions() => ArrowOptions(
    sweConfig: SweConfig(
      signAyanamsa: _resolveAyanamsa(ayanamsa),
      houseSystem: _resolveHouseSystem(houses),
      trueNode: node == 'true',
    ),
    calcConfig: CalcConfig(circle: _resolveCircle(circle)),
  );

  @override
  String typeName() => 'config';
}

Ayanamsa _resolveAyanamsa(String name) {
  for (final a in Ayanamsa.values) {
    if (a.name == name) return a;
  }
  throw NockError(
    'unknown ayanamsa: "$name" (try: tropical, lahiri, raman, dhruva, ...)',
  );
}

HouseSystem _resolveHouseSystem(String name) {
  final normalized = name.toLowerCase().replaceAll('_', '');
  for (final h in HouseSystem.values) {
    if (h.name.toLowerCase() == normalized) return h;
  }
  // Common aliases
  return switch (normalized) {
    'wholesign' || 'wholesigns' => HouseSystem.wholeSigns,
    'equal' => HouseSystem.equalAsc,
    _ => throw NockError(
      'unknown house system: "$name" (try: placidus, wholeSigns, campanus, ...)',
    ),
  };
}

Circle _resolveCircle(String name) => switch (name) {
  'aditya' => Circle.aditya,
  'zodiac' => Circle.zodiac,
  _ => throw NockError(
    'unknown circle: "$name" (expected "aditya" or "zodiac")',
  ),
};
