import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

import 'package:arrow_calc/src/vedic/nabhasa_yoga.dart';

/// Build a karakasPerHouse with one karaka per house starting at house 1.
Map<int, List<Body>> _scattered() {
  final map = <int, List<Body>>{};
  for (var i = 0; i < Body.karakas.length; i++) {
    map[i + 1] = [Body.karakas[i]];
  }
  return map;
}

/// houseQualities where all 12 houses map to their natural sign quality
/// (lagna = Aries, so house n occupies sign n).
Map<int, Quality> _naturalHouseQualities() => {
      for (var h = 1; h <= 12; h++) h: SignData.quality(h),
    };

void main() {
  // ── houseFrom ────────────────────────────────────────────────────────────────

  group('houseFrom', () {
    test('lagna=1, sign=1 → house 1', () {
      expect(NabhasaYogaCalc.houseFrom(1, 1), 1);
    });

    test('lagna=4, sign=1 → house 10', () {
      expect(NabhasaYogaCalc.houseFrom(4, 1), 10);
    });

    test('lagna=1, sign=12 → house 12', () {
      expect(NabhasaYogaCalc.houseFrom(1, 12), 12);
    });

    test('lagna=12, sign=1 → house 2', () {
      expect(NabhasaYogaCalc.houseFrom(12, 1), 2);
    });

    test('same sign as lagna → house 1', () {
      expect(NabhasaYogaCalc.houseFrom(5, 5), 1);
    });
  });

  // ── Sankhya ──────────────────────────────────────────────────────────────────

  group('sankhyaYogas', () {
    test('4 occupied houses → Kedara has toMove=0, others >0', () {
      final yogas = NabhasaYogaCalc.sankhyaYogas(occupiedHouseCount: 4);
      expect(yogas.length, 7);

      final kedara = yogas.firstWhere((y) => y.name == 'Kedara');
      expect(kedara.toMove, 0);
      expect(kedara.isPresent, isTrue);

      for (final y in yogas) {
        if (y.name != 'Kedara') expect(y.toMove, greaterThan(0));
      }
    });

    test('7 occupied houses → Veena toMove=0', () {
      final yogas = NabhasaYogaCalc.sankhyaYogas(occupiedHouseCount: 7);
      final veena = yogas.firstWhere((y) => y.name == 'Veena');
      expect(veena.toMove, 0);
    });

    test('1 occupied house → Gola toMove=0', () {
      final yogas = NabhasaYogaCalc.sankhyaYogas(occupiedHouseCount: 1);
      final gola = yogas.firstWhere((y) => y.name == 'Gola');
      expect(gola.toMove, 0);
    });
  });

  // ── Ashraya ──────────────────────────────────────────────────────────────────

  group('ashrayaYogas', () {
    test('all 7 karakas in cardinal houses → Rajju toMove=0', () {
      // Cardinal houses with natural qualities (lagna=Aries): 1,4,7,10
      final kph = <int, List<Body>>{
        1: [Body.sun, Body.moon],
        4: [Body.mars, Body.mercury],
        7: [Body.jupiter, Body.venus],
        10: [Body.saturn],
      };
      final yogas = NabhasaYogaCalc.ashrayaYogas(
        karakasPerHouse: kph,
        houseQualities: _naturalHouseQualities(),
      );
      final rajju = yogas.firstWhere((y) => y.name == 'Rajju');
      expect(rajju.toMove, 0);
      expect(rajju.isPresent, isTrue);

      final musala = yogas.firstWhere((y) => y.name == 'Musala');
      expect(musala.toMove, 7);
    });

    test('all 7 karakas in fixed houses → Musala toMove=0', () {
      // Fixed houses: 2,5,8,11
      final kph = <int, List<Body>>{
        2: [Body.sun, Body.moon],
        5: [Body.mars, Body.mercury],
        8: [Body.jupiter, Body.venus],
        11: [Body.saturn],
      };
      final yogas = NabhasaYogaCalc.ashrayaYogas(
        karakasPerHouse: kph,
        houseQualities: _naturalHouseQualities(),
      );
      final musala = yogas.firstWhere((y) => y.name == 'Musala');
      expect(musala.toMove, 0);
    });

    test('all 7 karakas in mutable houses → Nala toMove=0', () {
      // Mutable houses: 3,6,9,12
      final kph = <int, List<Body>>{
        3: [Body.sun, Body.moon],
        6: [Body.mars, Body.mercury],
        9: [Body.jupiter, Body.venus],
        12: [Body.saturn],
      };
      final yogas = NabhasaYogaCalc.ashrayaYogas(
        karakasPerHouse: kph,
        houseQualities: _naturalHouseQualities(),
      );
      final nala = yogas.firstWhere((y) => y.name == 'Nala');
      expect(nala.toMove, 0);
    });
  });

  // ── Dala ─────────────────────────────────────────────────────────────────────

  group('dalaYogas', () {
    test('all benefics in kendras → Mala present', () {
      // Benefics (moon benefic): moon, mercury, jupiter, venus → 4 bodies
      final kph = <int, List<Body>>{
        1: [Body.moon],
        4: [Body.mercury],
        7: [Body.jupiter],
        10: [Body.venus],
        // malefics scattered elsewhere
        2: [Body.sun, Body.mars, Body.saturn],
      };
      final yogas = NabhasaYogaCalc.dalaYogas(
        karakasPerHouse: kph,
        moonIsBenefic: true,
      );
      final mala = yogas.firstWhere((y) => y.name == 'Mala');
      expect(mala.toMove, 0);
      expect(mala.isPresent, isTrue);
    });

    test('all malefics in kendras → Sarpa present', () {
      // Malefics (moon malefic): sun, mars, saturn, moon → 4 bodies
      final kph = <int, List<Body>>{
        1: [Body.sun],
        4: [Body.mars],
        7: [Body.saturn],
        10: [Body.moon],
        2: [Body.mercury, Body.jupiter, Body.venus],
      };
      final yogas = NabhasaYogaCalc.dalaYogas(
        karakasPerHouse: kph,
        moonIsBenefic: false,
      );
      final sarpa = yogas.firstWhere((y) => y.name == 'Sarpa');
      expect(sarpa.toMove, 0);
      expect(sarpa.isPresent, isTrue);
    });
  });

  // ── Panchamahapurusha ─────────────────────────────────────────────────────────

  group('panchamahapurushaYogas', () {
    test('Jupiter in house 1 exalted → Hamsa present', () {
      final yogas = NabhasaYogaCalc.panchamahapurushaYogas(
        karakaHouses: {
          Body.jupiter: 1,
          Body.mars: 2,
          Body.mercury: 3,
          Body.venus: 6,
          Body.saturn: 8,
        },
        karakaDignities: {
          Body.jupiter: DignityType.exalted,
          Body.mars: DignityType.neutral,
          Body.mercury: DignityType.neutral,
          Body.venus: DignityType.neutral,
          Body.saturn: DignityType.neutral,
        },
      );
      final hamsa = yogas.firstWhere((y) => y.name == 'Hamsa');
      expect(hamsa.present, isTrue);
      expect(hamsa.house, 1);
      expect(hamsa.dignity, DignityType.exalted);
    });

    test('Mars in house 2 → Ruchaka not present (not kendra)', () {
      final yogas = NabhasaYogaCalc.panchamahapurushaYogas(
        karakaHouses: {Body.mars: 2},
        karakaDignities: {Body.mars: DignityType.exalted},
      );
      final ruchaka = yogas.firstWhere((y) => y.name == 'Ruchaka');
      expect(ruchaka.present, isFalse);
    });

    test('Mars in kendra but neutral dignity → Ruchaka not present', () {
      final yogas = NabhasaYogaCalc.panchamahapurushaYogas(
        karakaHouses: {Body.mars: 1},
        karakaDignities: {Body.mars: DignityType.neutral},
      );
      final ruchaka = yogas.firstWhere((y) => y.name == 'Ruchaka');
      expect(ruchaka.present, isFalse);
    });

    test('all 5 yogas always returned', () {
      final yogas = NabhasaYogaCalc.panchamahapurushaYogas(
        karakaHouses: {},
        karakaDignities: {},
      );
      expect(yogas.length, 5);
      final names = yogas.map((y) => y.name).toList();
      expect(names, containsAll(['Ruchaka', 'Bhadra', 'Hamsa', 'Malavya', 'Sasa']));
    });

    test('moolatrikona and ownSign also qualify', () {
      for (final dig in [DignityType.moolatrikona, DignityType.ownSign]) {
        final yogas = NabhasaYogaCalc.panchamahapurushaYogas(
          karakaHouses: {Body.venus: 4},
          karakaDignities: {Body.venus: dig},
        );
        final malavya = yogas.firstWhere((y) => y.name == 'Malavya');
        expect(malavya.present, isTrue, reason: '$dig should qualify');
      }
    });
  });

  // ── Solar yogas ──────────────────────────────────────────────────────────────

  group('solarYogas', () {
    test('eligible planet in 2nd from Sun → Vesi present', () {
      // Sun in house 3, Jupiter in house 4 (2nd from Sun)
      final kph = <int, List<Body>>{
        3: [Body.sun],
        4: [Body.jupiter],
      };
      final yogas = NabhasaYogaCalc.solarYogas(
        karakasPerHouse: kph,
        sunHouse: 3,
      );
      final vesi = yogas.firstWhere((y) => y.name == 'Vesi');
      expect(vesi.present, isTrue);
      expect(vesi.planets, contains(Body.jupiter));
    });

    test('eligible planet in 12th from Sun → Vosi present', () {
      // Sun in house 5, Mars in house 4 (12th from Sun = 5-1=4)
      final kph = <int, List<Body>>{
        5: [Body.sun],
        4: [Body.mars],
      };
      final yogas = NabhasaYogaCalc.solarYogas(
        karakasPerHouse: kph,
        sunHouse: 5,
      );
      final vosi = yogas.firstWhere((y) => y.name == 'Vosi');
      expect(vosi.present, isTrue);
    });

    test('eligible planets in both → Ubhayachari present', () {
      // Sun in house 6, Venus in 7 (2nd), Saturn in 5 (12th)
      final kph = <int, List<Body>>{
        6: [Body.sun],
        7: [Body.venus],
        5: [Body.saturn],
      };
      final yogas = NabhasaYogaCalc.solarYogas(
        karakasPerHouse: kph,
        sunHouse: 6,
      );
      final ubhaya = yogas.firstWhere((y) => y.name == 'Ubhayachari');
      expect(ubhaya.present, isTrue);
    });

    test('Sun and Moon not eligible', () {
      // Sun in house 1, Moon in house 2, Sun in house 12
      final kph = <int, List<Body>>{
        1: [Body.sun],
        2: [Body.moon],
        12: [Body.moon],
      };
      final yogas = NabhasaYogaCalc.solarYogas(
        karakasPerHouse: kph,
        sunHouse: 1,
      );
      final vesi = yogas.firstWhere((y) => y.name == 'Vesi');
      expect(vesi.present, isFalse);
    });

    test('3 solar yogas always returned', () {
      final yogas = NabhasaYogaCalc.solarYogas(
        karakasPerHouse: {},
        sunHouse: 1,
      );
      expect(yogas.length, 3);
    });
  });

  // ── Lunar yogas ──────────────────────────────────────────────────────────────

  group('lunarYogas', () {
    test('no eligible planets near Moon → Kemadruma present', () {
      // Moon in house 1, no eligible in 2 or 12
      final kph = <int, List<Body>>{
        1: [Body.moon],
        2: [Body.sun], // not eligible
        12: [Body.rahu], // not eligible
      };
      final yogas = NabhasaYogaCalc.lunarYogas(
        karakasPerHouse: kph,
        moonHouse: 1,
      );
      final kema = yogas.firstWhere((y) => y.name == 'Kemadruma');
      expect(kema.present, isTrue);

      final sunapha = yogas.firstWhere((y) => y.name == 'Sunapha');
      expect(sunapha.present, isFalse);
    });

    test('eligible in 2nd from Moon → Sunapha present, Kemadruma absent', () {
      final kph = <int, List<Body>>{
        1: [Body.moon],
        2: [Body.jupiter],
      };
      final yogas = NabhasaYogaCalc.lunarYogas(
        karakasPerHouse: kph,
        moonHouse: 1,
      );
      final sunapha = yogas.firstWhere((y) => y.name == 'Sunapha');
      expect(sunapha.present, isTrue);
      final kema = yogas.firstWhere((y) => y.name == 'Kemadruma');
      expect(kema.present, isFalse);
    });

    test('eligible in 12th from Moon → Anapha present', () {
      // Moon in house 3, eligible in house 2 (12th from 3)
      final kph = <int, List<Body>>{
        3: [Body.moon],
        2: [Body.venus],
      };
      final yogas = NabhasaYogaCalc.lunarYogas(
        karakasPerHouse: kph,
        moonHouse: 3,
      );
      final anapha = yogas.firstWhere((y) => y.name == 'Anapha');
      expect(anapha.present, isTrue);
    });

    test('eligible in both → Durudhara present', () {
      final kph = <int, List<Body>>{
        5: [Body.moon],
        6: [Body.mercury],
        4: [Body.saturn],
      };
      final yogas = NabhasaYogaCalc.lunarYogas(
        karakasPerHouse: kph,
        moonHouse: 5,
      );
      final duru = yogas.firstWhere((y) => y.name == 'Durudhara');
      expect(duru.present, isTrue);
    });

    test('4 lunar yogas always returned', () {
      final yogas = NabhasaYogaCalc.lunarYogas(
        karakasPerHouse: {},
        moonHouse: 1,
      );
      expect(yogas.length, 4);
    });
  });

  // ── Akriti ───────────────────────────────────────────────────────────────────

  group('akritiYogas', () {
    test('all 7 karakas in kendras → Kamala present', () {
      final kph = <int, List<Body>>{
        1: [Body.sun, Body.moon],
        4: [Body.mars, Body.mercury],
        7: [Body.jupiter, Body.venus],
        10: [Body.saturn],
      };
      final yogas = NabhasaYogaCalc.akritiYogas(
        karakasPerHouse: kph,
        moonIsBenefic: true,
      );
      final kamala = yogas.firstWhere((y) => y.name == 'Kamala');
      expect(kamala.toMove, 0);
      expect(kamala.isPresent, isTrue);
    });

    test('all 7 karakas in trines → Sringataka present', () {
      final kph = <int, List<Body>>{
        1: [Body.sun, Body.moon, Body.mars],
        5: [Body.mercury, Body.jupiter],
        9: [Body.venus, Body.saturn],
      };
      final yogas = NabhasaYogaCalc.akritiYogas(
        karakasPerHouse: kph,
        moonIsBenefic: true,
      );
      final sringa = yogas.firstWhere((y) => y.name == 'Sringataka');
      expect(sringa.toMove, 0);
    });

    test('scattered karakas → Chakra uses tmDist', () {
      // All 7 in odd houses 1,3,5,7,9,11 — Chakra should have toMove=0
      final kph = <int, List<Body>>{
        1: [Body.sun, Body.moon],
        3: [Body.mars],
        5: [Body.mercury],
        7: [Body.jupiter],
        9: [Body.venus],
        11: [Body.saturn],
      };
      final yogas = NabhasaYogaCalc.akritiYogas(
        karakasPerHouse: kph,
        moonIsBenefic: true,
      );
      final chakra = yogas.firstWhere((y) => y.name == 'Chakra');
      expect(chakra.toMove, 0);
    });

    test('akriti returns expected yoga names', () {
      final yogas = NabhasaYogaCalc.akritiYogas(
        karakasPerHouse: _scattered(),
        moonIsBenefic: true,
      );
      final names = yogas.map((y) => y.name).toList();
      expect(names, contains('Kamala'));
      expect(names, contains('Sringataka'));
      expect(names, contains('Vajra'));
      expect(names, contains('Yava'));
      expect(names, contains('Chakra'));
      expect(names, contains('Samudra'));
      expect(names, contains('Nauka'));
      expect(names, contains('ArdhaChandra1'));
      expect(names, contains('ArdhaChandra8'));
    });
  });

  // ── nabhasaYogas integration ──────────────────────────────────────────────────

  group('nabhasaYogas', () {
    test('returns all four categories', () {
      final kph = _scattered();
      final yogas = NabhasaYogaCalc.nabhasaYogas(
        karakasPerHouse: kph,
        houseQualities: _naturalHouseQualities(),
        moonIsBenefic: true,
      );
      final categories = yogas.map((y) => y.category).toSet();
      expect(categories, containsAll(['Ashraya', 'Dala', 'Sankhya', 'Akriti']));
    });

    test('isPresent matches toMove==0', () {
      final kph = _scattered();
      final yogas = NabhasaYogaCalc.nabhasaYogas(
        karakasPerHouse: kph,
        houseQualities: _naturalHouseQualities(),
        moonIsBenefic: false,
      );
      for (final y in yogas) {
        expect(y.isPresent, y.toMove == 0);
      }
    });
  });

  // ── toMove edge cases ──────────────────────────────────────────────────────────

  group('toMove scoring', () {
    test('tm: karakas outside required houses counted correctly', () {
      // 3 karakas in houses [1,7], 4 outside → toMove = 4
      final kph = <int, List<Body>>{
        1: [Body.sun, Body.moon],
        7: [Body.mars],
        2: [Body.mercury, Body.jupiter, Body.venus, Body.saturn],
      };
      final yogas = NabhasaYogaCalc.akritiYogas(
        karakasPerHouse: kph,
        moonIsBenefic: true,
      );
      final sakata = yogas.firstWhere((y) => y.name == 'Sakata');
      expect(sakata.toMove, 4);
    });

    test('tmDist: covers both outside and empty-house penalties', () {
      // All 7 in house 1 only; Chakra requires [1,3,5,7,9,11].
      // outside=0 (all 7 in house 1 which is in Chakra), emptyRequired=5
      // → tmDist = max(0, 5) = 5
      final kph = <int, List<Body>>{
        1: List.of(Body.karakas),
      };
      final yogas = NabhasaYogaCalc.akritiYogas(
        karakasPerHouse: kph,
        moonIsBenefic: true,
      );
      final chakra = yogas.firstWhere((y) => y.name == 'Chakra');
      expect(chakra.toMove, 5);
    });
  });
}
