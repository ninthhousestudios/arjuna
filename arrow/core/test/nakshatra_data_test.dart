// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

import 'package:arrow_core/src/nakshatra_data.dart';

void main() {
  group('NakshatraData', () {
    test('all 27 lords defined', () {
      for (var i = 1; i <= 27; i++) {
        expect(NakshatraData.lords.containsKey(i), isTrue);
      }
    });

    test('vimshottari lord cycle: Ke Ve Su Mo Ma Ra Ju Sa Me', () {
      // First cycle (1-9)
      expect(NakshatraData.lord(1), Body.ketu);
      expect(NakshatraData.lord(2), Body.venus);
      expect(NakshatraData.lord(3), Body.sun);
      expect(NakshatraData.lord(4), Body.moon);
      expect(NakshatraData.lord(5), Body.mars);
      expect(NakshatraData.lord(6), Body.rahu);
      expect(NakshatraData.lord(7), Body.jupiter);
      expect(NakshatraData.lord(8), Body.saturn);
      expect(NakshatraData.lord(9), Body.mercury);
      // Second cycle starts at 10
      expect(NakshatraData.lord(10), Body.ketu);
      expect(NakshatraData.lord(11), Body.venus);
      expect(NakshatraData.lord(18), Body.mercury);
      // Third cycle starts at 19
      expect(NakshatraData.lord(19), Body.ketu);
      expect(NakshatraData.lord(27), Body.mercury);
    });

    test('all 27 deities defined', () {
      for (var i = 1; i <= 27; i++) {
        expect(NakshatraData.deities.containsKey(i), isTrue);
        expect(NakshatraData.deity(i), isNotEmpty);
      }
    });

    test('specific deities', () {
      expect(NakshatraData.deity(1), 'Ashvini Kumaras');
      expect(NakshatraData.deity(3), 'Agni');
      expect(NakshatraData.deity(6), 'Rudra');
      expect(NakshatraData.deity(22), 'Vishnu');
      expect(NakshatraData.deity(27), 'Pushan');
    });

    test('all 27 names defined', () {
      for (var i = 1; i <= 27; i++) {
        expect(NakshatraData.names.containsKey(i), isTrue);
      }
    });

    test('specific names', () {
      expect(NakshatraData.name(1), 'Ashwini');
      expect(NakshatraData.name(14), 'Chitra');
      expect(NakshatraData.name(19), 'Mula');
      expect(NakshatraData.name(27), 'Revati');
    });
  });
}
