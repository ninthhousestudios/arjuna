// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

Chart _stubChart({
  Map<Body, double> longitudes = const {},
  CalcConfig config = const CalcConfig(circle: Circle.zodiac),
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
        speedLongitude: 1.0,
        speedLatitude: 0.0,
        speedDistance: 0.0,
      ),
    ),
  );

  final cusps = List.generate(12, (i) => (i * 30.0 + 10.0) % 360);
  final nakLons = merged;

  final snapshot = EphSnapshot(
    jdUt: 2460000.5,
    location: const Location(latitude: 40.0, longitude: -74.0),
    sweConfig: const SweConfig(),
    bodiesEcliptic: bodies,
    bodiesEquatorial: bodies,
    phenoData: const {},
    cusps: cusps,
    ascmc: AscMcPoints(
      ascendant: cusps[0],
      mc: cusps[9],
      armc: cusps[9],
      vertex: 190.0,
      equatorialAscendant: cusps[0],
      coAscendantKoch: cusps[0],
      coAscendantMunkasey: cusps[0],
      polarAscendant: 190.0,
    ),
    sunTimes: const SunTimes(sunrise: 2460000.75, sunset: 2460001.25),
    ayanamsaValue: 0.0,
    bodiesNakEclLon: nakLons,
    bodiesNakEquLon: nakLons,
  );

  return Chart(snapshot, config);
}

void main() {
  group('computeBeingUncertainty', () {
    test('single chart returns none', () {
      final chart = _stubChart();
      final result = computeBeingUncertainty([chart]);
      expect(result.trimsamsaOptions, isEmpty);
      expect(result.horaOptions, isEmpty);
    });

    test('identical charts return no uncertainty', () {
      final chart1 = _stubChart();
      final chart2 = _stubChart();
      final result = computeBeingUncertainty([chart1, chart2]);
      expect(result.trimsamsaOptions, isEmpty);
      expect(result.horaOptions, isEmpty);
    });

    test('planet crossing sign boundary produces trimsamsa uncertainty', () {
      // Sun at 29° (sign 1) vs Sun at 31° (sign 2) — different signs, different beings
      final chart1 = _stubChart(longitudes: {Body.sun: 29.0});
      final chart2 = _stubChart(longitudes: {Body.sun: 31.0});
      final result = computeBeingUncertainty([chart1, chart2]);

      expect(result.isTrimsamsaUncertain(Body.sun), isTrue);
      expect(result.trimsamsaOptions[Body.sun]!.length, greaterThan(1));
      // Other planets unchanged — no uncertainty
      expect(result.isUncertain(Body.moon), isFalse);
    });

    test('planet crossing hora boundary produces hora uncertainty', () {
      // Venus at 30° (sign 2, inSign 0° → first half) vs Venus at 45° (sign 2, inSign 15° → boundary)
      // Sign 2 is even: first half = moon hora, second half = sun hora
      // 30° → inSign 0° (first half, moon hora)
      // 44° → inSign 14° (first half, moon hora)
      // 45° → inSign 15° (second half, sun hora)
      final chart1 = _stubChart(longitudes: {Body.venus: 30.0});
      final chart2 = _stubChart(longitudes: {Body.venus: 45.0});
      final result = computeBeingUncertainty([chart1, chart2]);

      expect(result.isHoraUncertain(Body.venus), isTrue);
      expect(result.horaOptions[Body.venus]!.length, greaterThan(1));
    });

    test('isUncertain combines trimsamsa and hora', () {
      final chart1 = _stubChart(longitudes: {Body.sun: 29.0});
      final chart2 = _stubChart(longitudes: {Body.sun: 31.0});
      final result = computeBeingUncertainty([chart1, chart2]);

      expect(result.isUncertain(Body.sun), isTrue);
      expect(result.isUncertain(Body.jupiter), isFalse);
    });

    test('empty chart list returns none', () {
      final result = computeBeingUncertainty([]);
      expect(result.trimsamsaOptions, isEmpty);
      expect(result.horaOptions, isEmpty);
    });
  });
}
