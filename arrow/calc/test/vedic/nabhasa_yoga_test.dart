import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

import 'package:arrow_calc/src/vedic/nabhasa_yoga.dart';

import '../helpers/stub_varga.dart';

/// One karaka per house 1-7, Moon benefic (ahead of Sun).
Varga _scattered() => stubVarga(longitudes: {
      Body.sun: 15.0, // house 1
      Body.moon: 45.0, // house 2
      Body.mars: 75.0, // house 3
      Body.mercury: 105.0, // house 4
      Body.jupiter: 135.0, // house 5
      Body.venus: 165.0, // house 6
      Body.saturn: 195.0, // house 7
    });

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
      final v = stubVarga(longitudes: {
        Body.sun: 15.0, Body.moon: 20.0, // sign 1, house 1
        Body.mars: 105.0, Body.mercury: 110.0, // sign 4, house 4
        Body.jupiter: 195.0, Body.venus: 200.0, // sign 7, house 7
        Body.saturn: 285.0, // sign 10, house 10
      });
      final yogas = NabhasaYogaCalc.ashrayaYogas(v);
      final rajju = yogas.firstWhere((y) => y.name == 'Rajju');
      expect(rajju.toMove, 0);
      expect(rajju.isPresent, isTrue);

      final musala = yogas.firstWhere((y) => y.name == 'Musala');
      expect(musala.toMove, 7);
    });

    test('all 7 karakas in fixed houses → Musala toMove=0', () {
      final v = stubVarga(longitudes: {
        Body.sun: 45.0, Body.moon: 50.0, // sign 2, house 2
        Body.mars: 135.0, Body.mercury: 140.0, // sign 5, house 5
        Body.jupiter: 225.0, Body.venus: 230.0, // sign 8, house 8
        Body.saturn: 315.0, // sign 11, house 11
      });
      final yogas = NabhasaYogaCalc.ashrayaYogas(v);
      final musala = yogas.firstWhere((y) => y.name == 'Musala');
      expect(musala.toMove, 0);
    });

    test('all 7 karakas in mutable houses → Nala toMove=0', () {
      final v = stubVarga(longitudes: {
        Body.sun: 75.0, Body.moon: 80.0, // sign 3, house 3
        Body.mars: 165.0, Body.mercury: 170.0, // sign 6, house 6
        Body.jupiter: 255.0, Body.venus: 260.0, // sign 9, house 9
        Body.saturn: 345.0, // sign 12, house 12
      });
      final yogas = NabhasaYogaCalc.ashrayaYogas(v);
      final nala = yogas.firstWhere((y) => y.name == 'Nala');
      expect(nala.toMove, 0);
    });
  });

  // ── Dala ─────────────────────────────────────────────────────────────────────

  group('dalaYogas', () {
    test('all benefics in kendras → Mala present', () {
      // Moon benefic: moonLon(15) - sunLon(345) = 30 ≤ 180 → benefic.
      final v = stubVarga(longitudes: {
        Body.moon: 15.0, // house 1 (kendra)
        Body.mercury: 105.0, // house 4 (kendra)
        Body.jupiter: 195.0, // house 7 (kendra)
        Body.venus: 285.0, // house 10 (kendra)
        Body.sun: 345.0, // house 12
        Body.mars: 350.0, // house 12
        Body.saturn: 355.0, // house 12
      });
      final yogas = NabhasaYogaCalc.dalaYogas(v);
      final mala = yogas.firstWhere((y) => y.name == 'Mala');
      expect(mala.toMove, 0);
      expect(mala.isPresent, isTrue);
    });

    test('all malefics in kendras → Sarpa present', () {
      // Moon malefic: moonLon(285) - sunLon(15) = 270 > 180 → malefic.
      final v = stubVarga(longitudes: {
        Body.sun: 15.0, // house 1 (kendra)
        Body.mars: 105.0, // house 4 (kendra)
        Body.saturn: 195.0, // house 7 (kendra)
        Body.moon: 285.0, // house 10 (kendra)
        Body.mercury: 45.0, // house 2
        Body.jupiter: 50.0, // house 2
        Body.venus: 55.0, // house 2
      });
      final yogas = NabhasaYogaCalc.dalaYogas(v);
      final sarpa = yogas.firstWhere((y) => y.name == 'Sarpa');
      expect(sarpa.toMove, 0);
      expect(sarpa.isPresent, isTrue);
    });
  });

  // ── Panchamahapurusha ─────────────────────────────────────────────────────────

  group('panchamahapurushaYogas', () {
    test('Jupiter exalted in kendra → Hamsa present', () {
      // Jupiter at 100° = Cancer (sign 4), exalted. lagnaSign=4 → house 1.
      final v = stubVarga(
        longitudes: {
          Body.jupiter: 100.0,
          Body.sun: 45.0,
          Body.moon: 135.0,
          Body.mars: 165.0,
          Body.mercury: 255.0,
          Body.venus: 315.0,
          Body.saturn: 225.0,
        },
        cusps: List.generate(12, (i) => (95.0 + i * 30.0) % 360),
      );
      final yogas = NabhasaYogaCalc.panchamahapurushaYogas(v);
      final hamsa = yogas.firstWhere((y) => y.name == 'Hamsa');
      expect(hamsa.present, isTrue);
      expect(hamsa.house, 1);
      expect(hamsa.dignity, DignityType.exalted);
    });

    test('Mars not in kendra → Ruchaka not present', () {
      // Mars at 45° = Taurus (sign 2), house 2 with lagnaSign=1. Not a kendra.
      final v = stubVarga(longitudes: {Body.mars: 45.0});
      final yogas = NabhasaYogaCalc.panchamahapurushaYogas(v);
      final ruchaka = yogas.firstWhere((y) => y.name == 'Ruchaka');
      expect(ruchaka.present, isFalse);
    });

    test('Mars in kendra without strong dignity → Ruchaka not present', () {
      // Mars at 195° = Libra (sign 7), house 7 (kendra). Mars in Libra = enemy.
      final v = stubVarga(longitudes: {Body.mars: 195.0});
      final yogas = NabhasaYogaCalc.panchamahapurushaYogas(v);
      final ruchaka = yogas.firstWhere((y) => y.name == 'Ruchaka');
      expect(ruchaka.present, isFalse);
    });

    test('all 5 yogas always returned', () {
      final v = stubVarga();
      final yogas = NabhasaYogaCalc.panchamahapurushaYogas(v);
      expect(yogas.length, 5);
      final names = yogas.map((y) => y.name).toList();
      expect(
          names, containsAll(['Ruchaka', 'Bhadra', 'Hamsa', 'Malavya', 'Sasa']));
    });

    test('moolatrikona and ownSign also qualify', () {
      // Venus moolatrikona: Libra 0-15°. At 181° = sign 7, 1° in-sign. House 7 (kendra).
      final vMt = stubVarga(longitudes: {Body.venus: 181.0});
      final mtYogas = NabhasaYogaCalc.panchamahapurushaYogas(vMt);
      final malavyaMt = mtYogas.firstWhere((y) => y.name == 'Malavya');
      expect(malavyaMt.present, isTrue,
          reason: 'moolatrikona should qualify');

      // Venus ownSign: Libra ≥15°. At 196° = sign 7, 16° in-sign. House 7 (kendra).
      final vOwn = stubVarga(longitudes: {Body.venus: 196.0});
      final ownYogas = NabhasaYogaCalc.panchamahapurushaYogas(vOwn);
      final malavyaOwn = ownYogas.firstWhere((y) => y.name == 'Malavya');
      expect(malavyaOwn.present, isTrue, reason: 'ownSign should qualify');
    });
  });

  // ── Solar yogas ──────────────────────────────────────────────────────────────

  group('solarYogas', () {
    test('eligible planet in 2nd from Sun → Vesi present', () {
      // Sun in house 3, Jupiter in house 4 (2nd from Sun).
      final v = stubVarga(longitudes: {
        Body.sun: 75.0, // house 3
        Body.jupiter: 105.0, // house 4 (2nd from Sun)
        Body.moon: 195.0,
        Body.mars: 255.0,
        Body.mercury: 315.0,
        Body.venus: 135.0,
        Body.saturn: 165.0,
      });
      final yogas = NabhasaYogaCalc.solarYogas(v);
      final vesi = yogas.firstWhere((y) => y.name == 'Vesi');
      expect(vesi.present, isTrue);
      expect(vesi.planets, contains(Body.jupiter));
    });

    test('eligible planet in 12th from Sun → Vosi present', () {
      // Sun in house 5, Mars in house 4 (12th from Sun).
      final v = stubVarga(longitudes: {
        Body.sun: 135.0, // house 5
        Body.mars: 105.0, // house 4 (12th from Sun)
        Body.moon: 15.0,
        Body.mercury: 255.0,
        Body.jupiter: 285.0,
        Body.venus: 315.0,
        Body.saturn: 345.0,
      });
      final yogas = NabhasaYogaCalc.solarYogas(v);
      final vosi = yogas.firstWhere((y) => y.name == 'Vosi');
      expect(vosi.present, isTrue);
    });

    test('eligible planets in both → Ubhayachari present', () {
      // Sun in house 6, Venus in 7 (2nd), Saturn in 5 (12th).
      final v = stubVarga(longitudes: {
        Body.sun: 165.0, // house 6
        Body.venus: 195.0, // house 7 (2nd from Sun)
        Body.saturn: 135.0, // house 5 (12th from Sun)
        Body.moon: 15.0,
        Body.mars: 255.0,
        Body.mercury: 285.0,
        Body.jupiter: 315.0,
      });
      final yogas = NabhasaYogaCalc.solarYogas(v);
      final ubhaya = yogas.firstWhere((y) => y.name == 'Ubhayachari');
      expect(ubhaya.present, isTrue);
    });

    test('Sun and Moon not eligible', () {
      // Sun in house 1, Moon in house 2 (2nd from Sun) — not eligible.
      final v = stubVarga(longitudes: {
        Body.sun: 15.0, // house 1
        Body.moon: 45.0, // house 2, not eligible
        Body.mars: 105.0,
        Body.mercury: 195.0,
        Body.jupiter: 255.0,
        Body.venus: 285.0,
        Body.saturn: 315.0,
      });
      final yogas = NabhasaYogaCalc.solarYogas(v);
      final vesi = yogas.firstWhere((y) => y.name == 'Vesi');
      expect(vesi.present, isFalse);
    });

    test('3 solar yogas always returned', () {
      final yogas = NabhasaYogaCalc.solarYogas(stubVarga());
      expect(yogas.length, 3);
    });
  });

  // ── Lunar yogas ──────────────────────────────────────────────────────────────

  group('lunarYogas', () {
    test('no eligible planets near Moon → Kemadruma present', () {
      // Moon in house 1. No eligible in house 2 (2nd) or house 12 (12th).
      final v = stubVarga(longitudes: {
        Body.moon: 15.0, // house 1
        Body.sun: 45.0, // house 2, not eligible
        Body.mars: 105.0, // house 4
        Body.mercury: 135.0, // house 5
        Body.jupiter: 195.0, // house 7
        Body.venus: 255.0, // house 9
        Body.saturn: 285.0, // house 10
      });
      final yogas = NabhasaYogaCalc.lunarYogas(v);
      final kema = yogas.firstWhere((y) => y.name == 'Kemadruma');
      expect(kema.present, isTrue);

      final sunapha = yogas.firstWhere((y) => y.name == 'Sunapha');
      expect(sunapha.present, isFalse);
    });

    test('eligible in 2nd from Moon → Sunapha present, Kemadruma absent', () {
      // Moon in house 1, Jupiter in house 2 (2nd from Moon).
      final v = stubVarga(longitudes: {
        Body.moon: 15.0, // house 1
        Body.jupiter: 45.0, // house 2 (2nd from Moon)
        Body.sun: 105.0,
        Body.mars: 135.0,
        Body.mercury: 195.0,
        Body.venus: 255.0,
        Body.saturn: 285.0,
      });
      final yogas = NabhasaYogaCalc.lunarYogas(v);
      final sunapha = yogas.firstWhere((y) => y.name == 'Sunapha');
      expect(sunapha.present, isTrue);
      final kema = yogas.firstWhere((y) => y.name == 'Kemadruma');
      expect(kema.present, isFalse);
    });

    test('eligible in 12th from Moon → Anapha present', () {
      // Moon in house 3, Venus in house 2 (12th from house 3).
      final v = stubVarga(longitudes: {
        Body.moon: 75.0, // house 3
        Body.venus: 45.0, // house 2 (12th from Moon)
        Body.sun: 135.0,
        Body.mars: 195.0,
        Body.mercury: 255.0,
        Body.jupiter: 285.0,
        Body.saturn: 315.0,
      });
      final yogas = NabhasaYogaCalc.lunarYogas(v);
      final anapha = yogas.firstWhere((y) => y.name == 'Anapha');
      expect(anapha.present, isTrue);
    });

    test('eligible in both → Durudhara present', () {
      // Moon in house 5, Mercury in house 6 (2nd), Saturn in house 4 (12th).
      final v = stubVarga(longitudes: {
        Body.moon: 135.0, // house 5
        Body.mercury: 165.0, // house 6 (2nd from Moon)
        Body.saturn: 105.0, // house 4 (12th from Moon)
        Body.sun: 15.0,
        Body.mars: 225.0,
        Body.jupiter: 285.0,
        Body.venus: 315.0,
      });
      final yogas = NabhasaYogaCalc.lunarYogas(v);
      final duru = yogas.firstWhere((y) => y.name == 'Durudhara');
      expect(duru.present, isTrue);
    });

    test('4 lunar yogas always returned', () {
      final yogas = NabhasaYogaCalc.lunarYogas(stubVarga());
      expect(yogas.length, 4);
    });
  });

  // ── Akriti ───────────────────────────────────────────────────────────────────

  group('akritiYogas', () {
    test('all 7 karakas in kendras → Kamala present', () {
      final v = stubVarga(longitudes: {
        Body.sun: 15.0, Body.moon: 20.0, // house 1
        Body.mars: 105.0, Body.mercury: 110.0, // house 4
        Body.jupiter: 195.0, Body.venus: 200.0, // house 7
        Body.saturn: 285.0, // house 10
      });
      final yogas = NabhasaYogaCalc.akritiYogas(v);
      final kamala = yogas.firstWhere((y) => y.name == 'Kamala');
      expect(kamala.toMove, 0);
      expect(kamala.isPresent, isTrue);
    });

    test('all 7 karakas in trines → Sringataka present', () {
      final v = stubVarga(longitudes: {
        Body.sun: 5.0, Body.moon: 10.0, Body.mars: 15.0, // house 1
        Body.mercury: 125.0, Body.jupiter: 130.0, // house 5
        Body.venus: 245.0, Body.saturn: 250.0, // house 9
      });
      final yogas = NabhasaYogaCalc.akritiYogas(v);
      final sringa = yogas.firstWhere((y) => y.name == 'Sringataka');
      expect(sringa.toMove, 0);
    });

    test('scattered karakas → Chakra uses tmDist', () {
      // All 7 in odd houses 1,3,5,7,9,11 — Chakra should have toMove=0.
      final v = stubVarga(longitudes: {
        Body.sun: 5.0, Body.moon: 10.0, // house 1
        Body.mars: 75.0, // house 3
        Body.mercury: 135.0, // house 5
        Body.jupiter: 195.0, // house 7
        Body.venus: 255.0, // house 9
        Body.saturn: 315.0, // house 11
      });
      final yogas = NabhasaYogaCalc.akritiYogas(v);
      final chakra = yogas.firstWhere((y) => y.name == 'Chakra');
      expect(chakra.toMove, 0);
    });

    test('akriti returns expected yoga names', () {
      final yogas = NabhasaYogaCalc.akritiYogas(_scattered());
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
      final yogas = NabhasaYogaCalc.nabhasaYogas(_scattered());
      final categories = yogas.map((y) => y.category).toSet();
      expect(categories, containsAll(['Ashraya', 'Dala', 'Sankhya', 'Akriti']));
    });

    test('isPresent matches toMove==0', () {
      final yogas = NabhasaYogaCalc.nabhasaYogas(_scattered());
      for (final y in yogas) {
        expect(y.isPresent, y.toMove == 0);
      }
    });
  });

  // ── toMove edge cases ──────────────────────────────────────────────────────────

  group('toMove scoring', () {
    test('tm: karakas outside required houses counted correctly', () {
      // 3 karakas in houses [1,7], 4 outside → toMove = 4 for Sakata.
      final v = stubVarga(longitudes: {
        Body.sun: 5.0, Body.moon: 10.0, // house 1
        Body.mars: 195.0, // house 7
        Body.mercury: 35.0, Body.jupiter: 40.0, // house 2
        Body.venus: 45.0, Body.saturn: 50.0, // house 2
      });
      final yogas = NabhasaYogaCalc.akritiYogas(v);
      final sakata = yogas.firstWhere((y) => y.name == 'Sakata');
      expect(sakata.toMove, 4);
    });

    test('tmDist: covers both outside and empty-house penalties', () {
      // All 7 in house 1 only; Chakra requires [1,3,5,7,9,11].
      // outside=0 (all 7 in house 1 which is in Chakra), emptyRequired=5
      // → tmDist = max(0, 5) = 5
      final v = stubVarga(longitudes: {
        Body.sun: 1.0, Body.moon: 3.0, Body.mars: 5.0,
        Body.mercury: 7.0, Body.jupiter: 9.0,
        Body.venus: 11.0, Body.saturn: 13.0,
      });
      final yogas = NabhasaYogaCalc.akritiYogas(v);
      final chakra = yogas.firstWhere((y) => y.name == 'Chakra');
      expect(chakra.toMove, 5);
    });
  });
}
