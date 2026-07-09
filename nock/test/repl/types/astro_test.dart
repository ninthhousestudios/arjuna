// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:nock/src/repl/types/astro.dart';
import 'package:test/test.dart';

void main() {
  group('NockSign', () {
    test('display shows name and glyph', () {
      final lon = Longitude(84.2, 84.2, VargaType.rashi, CalcConfig());
      final sign = NockSign(lon.sign, lon);
      final d = sign.display();
      expect(d, contains(SignData.name(lon.sign)));
    });
  });

  group('NockNakshatra', () {
    test('display shows name, pada, and lord', () {
      final nak = NockNakshatra(7, 2);
      final d = nak.display();
      expect(d, contains('Punarvasu'));
      expect(d, contains('2'));
      expect(d, contains('jupiter'));
    });
  });

  group('NockDignity', () {
    test('display exalted', () {
      expect(NockDignity(DignityType.exalted).display(), 'Exalted');
    });

    test('display debilitated', () {
      expect(NockDignity(DignityType.debilitated).display(), 'Debilitated');
    });

    test('display own sign', () {
      expect(NockDignity(DignityType.ownSign).display(), 'Own Sign');
    });

    test('display great friend', () {
      expect(NockDignity(DignityType.greatFriend).display(), 'Great Friend');
    });

    test('display all types', () {
      for (final dt in DignityType.values) {
        expect(NockDignity(dt).display(), isNotEmpty);
      }
    });
  });
}
