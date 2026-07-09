// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:convert';

import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

void main() {
  group('CardinalPoints', () {
    const cp = CardinalPoints(
      ascendingEquinox: 2460755.5,
      northernSolstice: 2460848.2,
      descendingEquinox: 2460941.7,
      southernSolstice: 2461034.8,
    );

    test('construction', () {
      expect(cp.ascendingEquinox, closeTo(2460755.5, 1e-9));
      expect(cp.northernSolstice, closeTo(2460848.2, 1e-9));
      expect(cp.descendingEquinox, closeTo(2460941.7, 1e-9));
      expect(cp.southernSolstice, closeTo(2461034.8, 1e-9));
    });

    test('chronological order', () {
      expect(cp.ascendingEquinox, lessThan(cp.northernSolstice));
      expect(cp.northernSolstice, lessThan(cp.descendingEquinox));
      expect(cp.descendingEquinox, lessThan(cp.southernSolstice));
    });

    test('JSON round-trip', () {
      final json = jsonDecode(jsonEncode(cp.toJson())) as Map<String, dynamic>;
      final r = CardinalPoints.fromJson(json);
      expect(r.ascendingEquinox, closeTo(cp.ascendingEquinox, 1e-9));
      expect(r.northernSolstice, closeTo(cp.northernSolstice, 1e-9));
      expect(r.descendingEquinox, closeTo(cp.descendingEquinox, 1e-9));
      expect(r.southernSolstice, closeTo(cp.southernSolstice, 1e-9));
    });
  });
}
