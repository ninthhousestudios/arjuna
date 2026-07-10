// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:convert';

import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

/// Smoke: PhenoData covers the five fields from swisseph_rs's Phenomena.
void main() {
  group('PhenoData', () {
    test('construction and field access', () {
      const p = PhenoData(
        phaseAngle: 1.0,
        phase: 0.5,
        elongation: 45.0,
        apparentDiameter: 0.01,
        apparentMagnitude: -4.0,
      );
      expect(p.phaseAngle, 1.0);
      expect(p.phase, 0.5);
      expect(p.elongation, 45.0);
      expect(p.apparentDiameter, 0.01);
      expect(p.apparentMagnitude, -4.0);
    });

    test('JSON round-trip', () {
      const p = PhenoData(
        phaseAngle: 1.0,
        phase: 0.5,
        elongation: 45.0,
        apparentDiameter: 0.01,
        apparentMagnitude: -4.0,
      );
      final json = jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>;
      final restored = PhenoData.fromJson(json);
      expect(restored, equals(p));
    });
  });
}
