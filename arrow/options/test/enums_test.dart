// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('Body', () {
    test('karakas has 7 bodies', () {
      expect(Body.karakas, hasLength(7));
      expect(Body.karakas, contains(Body.sun));
      expect(Body.karakas, contains(Body.saturn));
      expect(Body.karakas, isNot(contains(Body.rahu)));
    });

    test('grahas has 9 bodies', () {
      expect(Body.grahas, hasLength(9));
      expect(Body.grahas, contains(Body.rahu));
      expect(Body.grahas, contains(Body.ketu));
      expect(Body.grahas, isNot(contains(Body.uranus)));
      expect(Body.grahas, isNot(contains(Body.chiron)));
    });
  });

  group('Ayanamsa', () {
    test('sweCodes are distinct for standard ayanamsas', () {
      final standard = Ayanamsa.values.where((a) => a.isStandard).toList();
      final codes = standard.map((a) => a.sweCode).toSet();
      expect(codes.length, standard.length);
    });

    test('tropical has no SWE code', () {
      expect(Ayanamsa.tropical.isTropical, isTrue);
      expect(Ayanamsa.tropical.sweCode, -1);
    });

    test('dhruva is custom code 98', () {
      expect(Ayanamsa.dhruva.sweCode, 98);
      expect(Ayanamsa.dhruva.isStandard, isFalse);
    });

    test('lahiri is standard code 1', () {
      expect(Ayanamsa.lahiri.sweCode, 1);
      expect(Ayanamsa.lahiri.isStandard, isTrue);
    });

    test('ushashashi is SWE code 4 (not J2000 at 18)', () {
      expect(Ayanamsa.ushashashi.sweCode, 4);
    });

    test('djwhalKhul is SWE code 6 (not ushashashi at 4)', () {
      expect(Ayanamsa.djwhalKhul.sweCode, 6);
    });

    test('j2000 / j1900 / b1950 epoch frames present', () {
      expect(Ayanamsa.j2000.sweCode, 18);
      expect(Ayanamsa.j1900.sweCode, 19);
      expect(Ayanamsa.b1950.sweCode, 20);
    });

    test('galalignMardyks is SWE code 34', () {
      expect(Ayanamsa.galalignMardyks.sweCode, 34);
    });

    test('all standard SWE codes 0..46 are covered', () {
      final stdCodes = Ayanamsa.values
          .where((a) => a.isStandard)
          .map((a) => a.sweCode)
          .toSet();
      for (var c = 0; c <= 46; c++) {
        expect(stdCodes, contains(c), reason: 'missing SWE sid code $c');
      }
    });

    test('labels are non-empty and distinct', () {
      final labels = Ayanamsa.values.map((a) => a.label).toList();
      expect(labels.toSet().length, labels.length);
      for (final l in labels) {
        expect(l, isNotEmpty);
      }
    });
  });

  group('HouseSystem', () {
    test('sweChars are single characters', () {
      for (final hs in HouseSystem.values) {
        expect(hs.sweChar.length, 1, reason: '${hs.name} sweChar');
      }
    });

    test('sweChars are unique', () {
      final chars = HouseSystem.values.map((h) => h.sweChar).toSet();
      expect(chars.length, HouseSystem.values.length);
    });

    test('key house systems have correct chars', () {
      expect(HouseSystem.placidus.sweChar, 'P');
      expect(HouseSystem.wholeSigns.sweChar, 'W');
      expect(HouseSystem.campanus.sweChar, 'C');
      expect(HouseSystem.equalAsc.sweChar, 'A');
    });
  });

  group('Circle', () {
    test('has two values', () {
      expect(Circle.values, hasLength(2));
    });
  });

  group('Tradition', () {
    test('has vedic', () {
      expect(Tradition.values, contains(Tradition.vedic));
    });
  });

  group('VargaType', () {
    test('rashi has amsha 1 and is not parivritti', () {
      expect(VargaType.rashi.amsha, 1);
      expect(VargaType.rashi.isParivritti, isFalse);
    });

    test('navamsha is parivritti with amsha 9', () {
      expect(VargaType.navamsha.amsha, 9);
      expect(VargaType.navamsha.isParivritti, isTrue);
    });

    test('hora vs horaParivritti share amsha but differ in method', () {
      expect(VargaType.hora.amsha, 2);
      expect(VargaType.hora.isParivritti, isFalse);
      expect(VargaType.horaParivritti.amsha, 2);
      expect(VargaType.horaParivritti.isParivritti, isTrue);
    });

    test('dashamsha vs dashamshaReversed share amsha', () {
      expect(VargaType.dashamsha.amsha, 10);
      expect(VargaType.dashamshaReversed.amsha, 10);
      expect(VargaType.dashamsha.isParivritti, isFalse);
      expect(VargaType.dashamshaReversed.isParivritti, isFalse);
    });

    test('parasharaChaturvimshamsha vs siddhamsha share amsha 24', () {
      expect(VargaType.parasharaChaturvimshamsha.amsha, 24);
      expect(VargaType.siddhamsha.amsha, 24);
    });

    test('all VargaType values have positive amsha', () {
      for (final vt in VargaType.values) {
        expect(vt.amsha, greaterThan(0), reason: '${vt.name} amsha');
      }
    });
  });

  group('DignityType', () {
    test('has all 9 levels', () {
      expect(DignityType.values, hasLength(9));
    });
  });

  group('FriendshipLevel', () {
    test('has 5 levels', () {
      expect(FriendshipLevel.values, hasLength(5));
    });
  });
}
