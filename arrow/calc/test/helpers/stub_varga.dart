// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

Varga stubVarga({
  Map<Body, double> longitudes = const {},
  Map<Body, double> speeds = const {},
  List<double>? cusps,
  CalcConfig config = const CalcConfig(circle: Circle.zodiac),
  VargaType vargaType = VargaType.rashi,
}) {
  final defaultLons = {
    Body.sun: 45.0,
    Body.moon: 120.0,
    Body.mars: 200.0,
    Body.mercury: 55.0,
    Body.jupiter: 280.0,
    Body.venus: 30.0,
    Body.saturn: 310.0,
    Body.rahu: 100.0,
    Body.ketu: 280.0,
  };
  final merged = {...defaultLons, ...longitudes};

  final bodies = merged.map(
    (body, lon) => MapEntry(
      body,
      BodyPosition(
        longitude: lon,
        latitude: 0.0,
        distance: 1.0,
        speedLongitude: speeds[body] ?? 1.0,
        speedLatitude: 0.0,
        speedDistance: 0.0,
      ),
    ),
  );

  final cuspList = cusps ?? List.generate(12, (i) => (i * 30.0 + 10.0) % 360);
  final nakLons = merged;

  final snapshot = EphSnapshot(
    jdUt: 2460000.5,
    location: const Location(latitude: 40.0, longitude: -74.0),
    sweConfig: const SweConfig(),
    bodiesEcliptic: bodies,
    bodiesEquatorial: bodies,
    phenoData: const {},
    cusps: cuspList,
    ascmc: AscMcPoints(
      ascendant: cuspList[0],
      mc: cuspList[9],
      armc: cuspList[9],
      vertex: 190.0,
      equatorialAscendant: cuspList[0],
      coAscendantKoch: cuspList[0],
      coAscendantMunkasey: cuspList[0],
      polarAscendant: 190.0,
    ),
    sunTimes: const SunTimes(sunrise: 2460000.75, sunset: 2460001.25),
    ayanamsaValue: 0.0,
    bodiesNakEclLon: nakLons,
    bodiesNakEquLon: nakLons,
  );

  return Varga(vargaType, snapshot, config);
}
