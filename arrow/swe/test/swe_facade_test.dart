// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:convert';

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

void main() {
  // ---------- BodyPosition ----------

  group('BodyPosition', () {
    final bp = BodyPosition(
      longitude: 123.456,
      latitude: -1.23,
      distance: 1.0,
      speedLongitude: 0.98,
      speedLatitude: 0.01,
      speedDistance: 0.0,
    );

    test('construction', () {
      expect(bp.longitude, closeTo(123.456, 1e-9));
      expect(bp.latitude, closeTo(-1.23, 1e-9));
      expect(bp.distance, closeTo(1.0, 1e-9));
      expect(bp.speedLongitude, closeTo(0.98, 1e-9));
      expect(bp.speedLatitude, closeTo(0.01, 1e-9));
      expect(bp.speedDistance, closeTo(0.0, 1e-9));
    });

    test('JSON round-trip', () {
      final json = jsonDecode(jsonEncode(bp.toJson())) as Map<String, dynamic>;
      final restored = BodyPosition.fromJson(json);
      expect(restored.longitude, closeTo(bp.longitude, 1e-9));
      expect(restored.latitude, closeTo(bp.latitude, 1e-9));
      expect(restored.distance, closeTo(bp.distance, 1e-9));
      expect(restored.speedLongitude, closeTo(bp.speedLongitude, 1e-9));
      expect(restored.speedLatitude, closeTo(bp.speedLatitude, 1e-9));
      expect(restored.speedDistance, closeTo(bp.speedDistance, 1e-9));
    });
  });

  // ---------- AscMcPoints ----------

  group('AscMcPoints', () {
    final asc = AscMcPoints(
      ascendant: 10.0,
      mc: 100.0,
      armc: 99.0,
      vertex: 200.0,
      equatorialAscendant: 15.0,
      coAscendantKoch: 20.0,
      coAscendantMunkasey: 25.0,
      polarAscendant: 30.0,
    );

    test('construction', () {
      expect(asc.ascendant, closeTo(10.0, 1e-9));
      expect(asc.mc, closeTo(100.0, 1e-9));
      expect(asc.armc, closeTo(99.0, 1e-9));
      expect(asc.vertex, closeTo(200.0, 1e-9));
      expect(asc.equatorialAscendant, closeTo(15.0, 1e-9));
      expect(asc.coAscendantKoch, closeTo(20.0, 1e-9));
      expect(asc.coAscendantMunkasey, closeTo(25.0, 1e-9));
      expect(asc.polarAscendant, closeTo(30.0, 1e-9));
    });

    test('JSON round-trip', () {
      final json = jsonDecode(jsonEncode(asc.toJson())) as Map<String, dynamic>;
      final restored = AscMcPoints.fromJson(json);
      expect(restored.ascendant, closeTo(asc.ascendant, 1e-9));
      expect(restored.mc, closeTo(asc.mc, 1e-9));
      expect(restored.polarAscendant, closeTo(asc.polarAscendant, 1e-9));
    });
  });

  // ---------- SunTimes ----------

  group('SunTimes', () {
    test('construction with values', () {
      final st = SunTimes(sunrise: 2451545.25, sunset: 2451545.75);
      expect(st.sunrise, closeTo(2451545.25, 1e-9));
      expect(st.sunset, closeTo(2451545.75, 1e-9));
    });

    test('construction with nulls', () {
      const st = SunTimes();
      expect(st.sunrise, isNull);
      expect(st.sunset, isNull);
    });

    test('JSON round-trip with values', () {
      final st = SunTimes(sunrise: 2451545.25, sunset: 2451545.75);
      final json = jsonDecode(jsonEncode(st.toJson())) as Map<String, dynamic>;
      final restored = SunTimes.fromJson(json);
      expect(restored.sunrise, closeTo(st.sunrise!, 1e-9));
      expect(restored.sunset, closeTo(st.sunset!, 1e-9));
    });

    test('JSON round-trip with nulls', () {
      const st = SunTimes();
      final json = jsonDecode(jsonEncode(st.toJson())) as Map<String, dynamic>;
      final restored = SunTimes.fromJson(json);
      expect(restored.sunrise, isNull);
      expect(restored.sunset, isNull);
    });
  });

  // ---------- EphSnapshot ----------

  final testBp = BodyPosition(
    longitude: 45.0,
    latitude: 0.5,
    distance: 1.0,
    speedLongitude: 1.0,
    speedLatitude: 0.0,
    speedDistance: 0.0,
  );

  final testAscmc = AscMcPoints(
    ascendant: 90.0,
    mc: 0.0,
    armc: 359.0,
    vertex: 270.0,
    equatorialAscendant: 91.0,
    coAscendantKoch: 92.0,
    coAscendantMunkasey: 93.0,
    polarAscendant: 94.0,
  );

  final testSunTimes = SunTimes(sunrise: 2451545.25, sunset: 2451545.75);

  final testLocation = Location(
    latitude: 28.6,
    longitude: 77.2,
    altitude: 216.0,
  );

  final testSweConfig = SweConfig();

  final testEcl = {Body.sun: testBp, Body.moon: testBp};
  final testEqu = {Body.sun: testBp, Body.moon: testBp};
  final testCusps = List<double>.generate(12, (i) => i * 30.0);

  group('EphSnapshot', () {
    test('construction', () {
      final snap = EphSnapshot(
        jdUt: 2451545.0,
        location: testLocation,
        sweConfig: testSweConfig,
        bodiesEcliptic: testEcl,
        bodiesEquatorial: testEqu,
        phenoData: const {},
        cusps: testCusps,
        ascmc: testAscmc,
        sunTimes: testSunTimes,
        ayanamsaValue: 23.85,
      );

      expect(snap.jdUt, closeTo(2451545.0, 1e-9));
      expect(snap.bodiesEcliptic[Body.sun]!.longitude, closeTo(45.0, 1e-9));
      expect(snap.cusps.length, 12);
      expect(snap.ayanamsaValue, closeTo(23.85, 1e-9));
    });

    test('JSON round-trip', () {
      final snap = EphSnapshot(
        jdUt: 2451545.0,
        location: testLocation,
        sweConfig: testSweConfig,
        bodiesEcliptic: testEcl,
        bodiesEquatorial: testEqu,
        phenoData: const {},
        cusps: testCusps,
        ascmc: testAscmc,
        sunTimes: testSunTimes,
        ayanamsaValue: 23.85,
      );

      // Force full Map conversion through JSON encode/decode before fromJson.
      final json =
          jsonDecode(jsonEncode(snap.toJson())) as Map<String, dynamic>;
      final restored = EphSnapshot.fromJson(json);

      expect(restored.jdUt, closeTo(snap.jdUt, 1e-9));
      expect(restored.ayanamsaValue, closeTo(snap.ayanamsaValue, 1e-9));
      expect(restored.cusps.length, 12);
      expect(restored.bodiesEcliptic[Body.sun]!.longitude, closeTo(45.0, 1e-9));
      expect(
        restored.bodiesEquatorial[Body.moon]!.latitude,
        closeTo(0.5, 1e-9),
      );
      expect(restored.sunTimes.sunrise, closeTo(2451545.25, 1e-9));
    });
  });

  // ---------- Ketu computation ----------

  group('Ketu from Rahu', () {
    BodyPosition ketuFrom(BodyPosition rahu) => BodyPosition(
      longitude: (rahu.longitude + 180.0) % 360.0,
      latitude: -rahu.latitude,
      distance: rahu.distance,
      speedLongitude: rahu.speedLongitude,
      speedLatitude: -rahu.speedLatitude,
      speedDistance: rahu.speedDistance,
    );

    test('Rahu at 45° → Ketu at 225°', () {
      final rahu = BodyPosition(
        longitude: 45.0,
        latitude: 1.0,
        distance: 1.0,
        speedLongitude: -0.05,
        speedLatitude: 0.0,
        speedDistance: 0.0,
      );
      final ketu = ketuFrom(rahu);
      expect(ketu.longitude, closeTo(225.0, 1e-9));
      expect(ketu.latitude, closeTo(-1.0, 1e-9));
    });

    test('Rahu at 200° → Ketu at 20°', () {
      final rahu = BodyPosition(
        longitude: 200.0,
        latitude: -0.5,
        distance: 1.0,
        speedLongitude: -0.05,
        speedLatitude: 0.0,
        speedDistance: 0.0,
      );
      final ketu = ketuFrom(rahu);
      expect(ketu.longitude, closeTo(20.0, 1e-9));
      expect(ketu.latitude, closeTo(0.5, 1e-9));
    });

    test('Rahu at 0° → Ketu at 180°', () {
      final rahu = BodyPosition(
        longitude: 0.0,
        latitude: 0.0,
        distance: 1.0,
        speedLongitude: -0.05,
        speedLatitude: 0.0,
        speedDistance: 0.0,
      );
      final ketu = ketuFrom(rahu);
      expect(ketu.longitude, closeTo(180.0, 1e-9));
    });

    test('Rahu at 180° → Ketu at 0°', () {
      final rahu = BodyPosition(
        longitude: 180.0,
        latitude: 0.0,
        distance: 1.0,
        speedLongitude: -0.05,
        speedLatitude: 0.0,
        speedDistance: 0.0,
      );
      final ketu = ketuFrom(rahu);
      expect(ketu.longitude, closeTo(0.0, 1e-9));
    });
  });
}
