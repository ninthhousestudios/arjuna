// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

/// Build a minimal EphSnapshot for testing.
///
/// Sun at 45°, Moon at 120°, Mars at 200° (retrograde), Mercury at 55°,
/// Jupiter at 280°, Venus at 30°, Saturn at 310°, Rahu at 100°, Ketu at 280°.
EphSnapshot stubSnapshot() {
  const location = Location(latitude: 40.0, longitude: -74.0);

  final bodies = <Body, BodyPosition>{
    Body.sun: const BodyPosition(
      longitude: 45.0,
      latitude: 0.5,
      distance: 1.0,
      speedLongitude: 0.98,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.moon: const BodyPosition(
      longitude: 120.0,
      latitude: -1.2,
      distance: 0.0025,
      speedLongitude: 13.2,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.mars: const BodyPosition(
      longitude: 200.0,
      latitude: 1.5,
      distance: 1.8,
      speedLongitude: -0.3,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.mercury: const BodyPosition(
      longitude: 55.0,
      latitude: -0.2,
      distance: 0.9,
      speedLongitude: 1.5,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.jupiter: const BodyPosition(
      longitude: 280.0,
      latitude: 0.3,
      distance: 5.2,
      speedLongitude: 0.08,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.venus: const BodyPosition(
      longitude: 30.0,
      latitude: -0.5,
      distance: 0.7,
      speedLongitude: 1.2,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.saturn: const BodyPosition(
      longitude: 310.0,
      latitude: 0.1,
      distance: 9.5,
      speedLongitude: 0.03,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.rahu: const BodyPosition(
      longitude: 100.0,
      latitude: 0.0,
      distance: 0.0,
      speedLongitude: -0.05,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.ketu: const BodyPosition(
      longitude: 280.0,
      latitude: 0.0,
      distance: 0.0,
      speedLongitude: -0.05,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
  };

  final nakLons = bodies.map((k, v) => MapEntry(k, v.longitude));

  return EphSnapshot(
    jdUt: 2460000.5,
    location: location,
    sweConfig: const SweConfig(),
    bodiesEcliptic: bodies,
    bodiesEquatorial: bodies,
    phenoData: const {},
    cusps: List.generate(12, (i) => (i * 30.0 + 10.0) % 360),
    ascmc: const AscMcPoints(
      ascendant: 10.0,
      mc: 280.0,
      armc: 280.0,
      vertex: 190.0,
      equatorialAscendant: 10.0,
      coAscendantKoch: 10.0,
      coAscendantMunkasey: 10.0,
      polarAscendant: 190.0,
    ),
    sunTimes: const SunTimes(sunrise: 2460000.75, sunset: 2460001.25),
    ayanamsaValue: 0.0,
    bodiesNakEclLon: nakLons,
    bodiesNakEquLon: nakLons,
  );
}
