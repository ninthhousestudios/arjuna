// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:convert';

import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph/swisseph.dart';
import 'package:test/test.dart';

/// Smoke: PhenoData mirrors swisseph.dart's PhenoResult. If this fails,
/// the upstream API changed — stop and fix before proceeding.
void main() {
  group('PhenoData shape matches swisseph PhenoResult', () {
    test('field parity', () {
      const p = PhenoData(
        phaseAngle: 1.0,
        phase: 0.5,
        elongation: 45.0,
        apparentDiameter: 0.01,
        apparentMagnitude: -4.0,
      );
      const r = PhenoResult(
        phaseAngle: 1.0,
        phase: 0.5,
        elongation: 45.0,
        apparentDiameter: 0.01,
        apparentMagnitude: -4.0,
      );
      expect(p.phaseAngle, r.phaseAngle);
      expect(p.phase, r.phase);
      expect(p.elongation, r.elongation);
      expect(p.apparentDiameter, r.apparentDiameter);
      expect(p.apparentMagnitude, r.apparentMagnitude);
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
