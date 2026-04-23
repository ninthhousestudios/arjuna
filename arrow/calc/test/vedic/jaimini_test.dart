import 'package:arrow_calc/src/vedic/jaimini.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // signsForward
  // ---------------------------------------------------------------------------
  group('Jaimini.signsForward', () {
    test('forward(s, 1) == s (self)', () {
      expect(Jaimini.signsForward(1, 1), equals(1));
      expect(Jaimini.signsForward(7, 1), equals(7));
      expect(Jaimini.signsForward(12, 1), equals(12));
    });

    test('forward(s, 2) == next sign', () {
      expect(Jaimini.signsForward(1, 2), equals(2));
      expect(Jaimini.signsForward(12, 2), equals(1)); // wraps
    });

    test('forward(s, 12) == previous sign', () {
      expect(Jaimini.signsForward(1, 12), equals(12));
      expect(Jaimini.signsForward(5, 12), equals(4));
    });

    test('forward wraps at 12', () {
      expect(Jaimini.signsForward(11, 4), equals(2));
      expect(Jaimini.signsForward(10, 5), equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // signsApart
  // ---------------------------------------------------------------------------
  group('Jaimini.signsApart', () {
    test('same sign → 1', () {
      expect(Jaimini.signsApart(1, 1), equals(1));
      expect(Jaimini.signsApart(7, 7), equals(1));
    });

    test('next sign → 2', () {
      expect(Jaimini.signsApart(1, 2), equals(2));
      expect(Jaimini.signsApart(12, 1), equals(2));
    });

    test('7th → 7', () {
      expect(Jaimini.signsApart(1, 7), equals(7));
      expect(Jaimini.signsApart(6, 12), equals(7));
    });

    test('previous sign → 12', () {
      expect(Jaimini.signsApart(2, 1), equals(12));
      expect(Jaimini.signsApart(1, 12), equals(12));
    });
  });

  // ---------------------------------------------------------------------------
  // pada — special cases
  // ---------------------------------------------------------------------------
  group('Jaimini.pada — special cases', () {
    test('lord in same sign (apart=1) → 10th from ref', () {
      // refSign=1, lordSign=1 → apart=1 → signsForward(1, 10) = 10
      expect(Jaimini.pada(1, 1), equals(10));
    });

    test('lord 7 signs away (apart=7) → 10th from ref', () {
      // refSign=1, lordSign=7 → apart=7 → signsForward(1, 10) = 10
      expect(Jaimini.pada(1, 7), equals(10));
    });

    test('lord 4 signs away (apart=4) → 4th from ref', () {
      // refSign=1, lordSign=4 → apart=4 → signsForward(1, 4) = 4
      expect(Jaimini.pada(1, 4), equals(4));
    });

    test('lord 10 signs away (apart=10) → 4th from ref', () {
      // refSign=1, lordSign=10 → apart=10 → signsForward(1, 4) = 4
      expect(Jaimini.pada(1, 10), equals(4));
    });

    test('special cases wrap around correctly', () {
      // refSign=5, lordSign=5 → apart=1 → signsForward(5, 10) = 14%12+1 = 2
      expect(Jaimini.pada(5, 5), equals(2));
      // refSign=5, lordSign=11 → apart=7 → signsForward(5, 10) = 2
      expect(Jaimini.pada(5, 11), equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // pada — normal case
  // ---------------------------------------------------------------------------
  group('Jaimini.pada — normal case', () {
    test('lord 3 signs away → signsForward(lordSign, 3)', () {
      // refSign=1, lordSign=3 → apart=3 → signsForward(3, 3) = 5
      expect(Jaimini.pada(1, 3), equals(5));
    });

    test('lord 5 signs away → signsForward(lordSign, 5)', () {
      // refSign=1, lordSign=5 → apart=5 → signsForward(5, 5) = 9
      expect(Jaimini.pada(1, 5), equals(9));
    });

    test('lord 2 signs away → signsForward(lordSign, 2)', () {
      // refSign=3, lordSign=4 → apart=2 → signsForward(4, 2) = 5
      expect(Jaimini.pada(3, 4), equals(5));
    });

    test('wraps around the zodiac', () {
      // refSign=11, lordSign=2 → apart=4 (special) → signsForward(11, 4) = 2
      expect(Jaimini.pada(11, 2), equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // arudhaLagna / upapada
  // ---------------------------------------------------------------------------
  group('Jaimini.arudhaLagna and upapada', () {
    test('arudhaLagna delegates to pada', () {
      expect(Jaimini.arudhaLagna(1, 3), equals(Jaimini.pada(1, 3)));
    });

    test('upapada delegates to pada', () {
      expect(Jaimini.upapada(12, 4), equals(Jaimini.pada(12, 4)));
    });
  });

  // ---------------------------------------------------------------------------
  // allPadas
  // ---------------------------------------------------------------------------
  group('Jaimini.allPadas', () {
    test('computes all 12 padas from a sign-to-lord map', () {
      // Simple config: each sign's lord is 3 signs away
      final signToLord = {for (var s = 1; s <= 12; s++) s: ((s + 1) % 12) + 1};
      final result = Jaimini.allPadas(signToLord);
      expect(result.length, equals(12));
      for (var s = 1; s <= 12; s++) {
        expect(result[s], equals(Jaimini.pada(s, signToLord[s]!)));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Third Strength
  // ---------------------------------------------------------------------------
  group('Jaimini.thirdStrength', () {
    test('distance 1 (same sign) → kendra (strength 2)', () {
      // apart = signsApart(s, s) = 1; 1 % 3 = 1 → kendra
      final result = Jaimini.thirdStrength(signToLordSign: {1: 1});
      expect(result[1]!.strength, equals(2));
      expect(result[1]!.label, equals('kendra'));
    });

    test('distance 4 → kendra (4 % 3 = 1)', () {
      final result = Jaimini.thirdStrength(signToLordSign: {1: 4});
      expect(result[1]!.strength, equals(2));
      expect(result[1]!.label, equals('kendra'));
    });

    test('distance 2 → panapara (2 % 3 = 2)', () {
      // signsApart(1, 2) = 2
      final result = Jaimini.thirdStrength(signToLordSign: {1: 2});
      expect(result[1]!.strength, equals(1));
      expect(result[1]!.label, equals('panapara'));
    });

    test('distance 5 → panapara (5 % 3 = 2)', () {
      final result = Jaimini.thirdStrength(signToLordSign: {1: 5});
      expect(result[1]!.strength, equals(1));
      expect(result[1]!.label, equals('panapara'));
    });

    test('distance 3 → apoklima (3 % 3 = 0)', () {
      // signsApart(1, 3) = 3
      final result = Jaimini.thirdStrength(signToLordSign: {1: 3});
      expect(result[1]!.strength, equals(0));
      expect(result[1]!.label, equals('apoklima'));
    });

    test('distance 6 → apoklima (6 % 3 = 0)', () {
      final result = Jaimini.thirdStrength(signToLordSign: {1: 6});
      expect(result[1]!.strength, equals(0));
      expect(result[1]!.label, equals('apoklima'));
    });

    test('all 12 signs classified', () {
      final signToLordSign = {for (var s = 1; s <= 12; s++) s: ((s + 2) % 12) + 1};
      final result = Jaimini.thirdStrength(signToLordSign: signToLordSign);
      expect(result.length, equals(12));
      for (var s = 1; s <= 12; s++) {
        expect(result[s], isNotNull);
        expect([0, 1, 2], contains(result[s]!.strength));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Bandhana Yogas
  // ---------------------------------------------------------------------------
  group('Jaimini.bandhanaYogas', () {
    test('matching non-zero counts on 2/12 → yoga present', () {
      // Lagna in sign 1. Signs 2 and 12 each have 1 planet.
      final grahas = <int, List<Body>>{
        2: [Body.jupiter],
        12: [Body.venus],
      };
      final yogas = Jaimini.bandhanaYogas(lagnaSign: 1, grahasPerSign: grahas);
      expect(yogas.length, equals(1));
      expect(yogas.first.$1, equals([Body.jupiter]));
      expect(yogas.first.$2, equals([Body.venus]));
    });

    test('unequal counts → no yoga', () {
      final grahas = <int, List<Body>>{
        2: [Body.jupiter, Body.sun],
        12: [Body.venus],
      };
      final yogas = Jaimini.bandhanaYogas(lagnaSign: 1, grahasPerSign: grahas);
      expect(yogas, isEmpty);
    });

    test('both sides empty → no yoga', () {
      final yogas = Jaimini.bandhanaYogas(
          lagnaSign: 1, grahasPerSign: const {});
      expect(yogas, isEmpty);
    });

    test('multiple pairs can match', () {
      // Lagna=1. Signs 3/11 each have 1, signs 4/10 each have 2.
      final grahas = <int, List<Body>>{
        3: [Body.sun],
        11: [Body.moon],
        4: [Body.mars, Body.jupiter],
        10: [Body.venus, Body.saturn],
      };
      final yogas = Jaimini.bandhanaYogas(lagnaSign: 1, grahasPerSign: grahas);
      expect(yogas.length, equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // Argala
  // ---------------------------------------------------------------------------
  group('Jaimini.argala', () {
    // Build a simple ranking: signs 1-12 in order (1=strongest).
    final ranking = List.generate(12, (i) => i + 1);

    test('single planet in 2nd → unobstructed 2nd argala', () {
      // Target = sign 1. Sun in sign 2 (2nd from 1). Nothing in 12th.
      final grahas = <int, List<Body>>{
        2: [Body.sun],
      };
      final result = Jaimini.argala(
        targetSign: 1,
        grahasPerSign: grahas,
        ketuSign: 6,
        firstStrengthRanking: ranking,
      );
      expect(result.unobstructed[2], equals([Body.sun]));
      expect(result.obstructed, isEmpty);
    });

    test('virodhina cancels argala when more planets', () {
      // Target=1. 2nd sign=2 has 1 planet, 12th sign=12 has 2 → obstructed.
      final grahas = <int, List<Body>>{
        2: [Body.jupiter],
        12: [Body.mars, Body.saturn],
      };
      final result = Jaimini.argala(
        targetSign: 1,
        grahasPerSign: grahas,
        ketuSign: 6,
        firstStrengthRanking: ranking,
      );
      expect(result.unobstructed.containsKey(2), isFalse);
      expect(result.obstructed[2], equals([Body.jupiter]));
    });

    test('equal counts: argala sign ranks higher → unobstructed', () {
      // Target=1. Sign 2 (argala) has 1 planet. Sign 12 (virodhina) has 1.
      // Ranking: sign 2 at index 1, sign 12 at index 11 → sign 2 stronger.
      final grahas = <int, List<Body>>{
        2: [Body.venus],
        12: [Body.mercury],
      };
      final result = Jaimini.argala(
        targetSign: 1,
        grahasPerSign: grahas,
        ketuSign: 6,
        firstStrengthRanking: ranking, // sign 2 (idx 1) < sign 12 (idx 11)
      );
      expect(result.unobstructed[2], equals([Body.venus]));
    });

    test('malefics outnumber benefics in 3rd → third-malefic argala', () {
      // Target=1. Sign 3 has Sun (malefic) + Mars (malefic), no benefics.
      final grahas = <int, List<Body>>{
        3: [Body.sun, Body.mars],
      };
      final result = Jaimini.argala(
        targetSign: 1,
        grahasPerSign: grahas,
        ketuSign: 6,
        firstStrengthRanking: ranking,
      );
      expect(result.thirdMaleficArgala, containsAll([Body.sun, Body.mars]));
    });

    test('equal malefic/benefic in 3rd → no third-malefic argala', () {
      final grahas = <int, List<Body>>{
        3: [Body.sun, Body.jupiter], // 1 malefic, 1 benefic
      };
      final result = Jaimini.argala(
        targetSign: 1,
        grahasPerSign: grahas,
        ketuSign: 6,
        firstStrengthRanking: ranking,
      );
      expect(result.thirdMaleficArgala, isEmpty);
    });

    test('Ketu in targetSign reverses offsets', () {
      // Target=1, Ketu also in 1. offset(-2) % 12 = 10.
      // So the "2nd argala" sign becomes signsForward(1, 10) = 10.
      // Put a planet in sign 10 and check it shows as 2nd argala.
      final grahas = <int, List<Body>>{
        10: [Body.moon],
      };
      final result = Jaimini.argala(
        targetSign: 1,
        grahasPerSign: grahas,
        ketuSign: 1, // Ketu in target
        firstStrengthRanking: ranking,
      );
      expect(result.unobstructed[2], equals([Body.moon]));
    });
  });

  // ---------------------------------------------------------------------------
  // First Strength
  // ---------------------------------------------------------------------------
  group('Jaimini.firstStrength', () {
    // All signs neutral dignity, empty — only karaka count matters.
    final emptyKarakas = <int, List<Body>>{
      for (var s = 1; s <= 12; s++) s: const [],
    };
    final neutralDignities = <Body, DignityType>{
      for (final b in Body.karakas) b: DignityType.neutral,
    };
    final zeroLons = <Body, double>{
      for (final b in Body.karakas) b: 0.0,
    };
    // Lord map: standard sign → lord-sign placement (all lords in their own sign)
    final ownSignLords = <int, int>{
      for (var s = 1; s <= 12; s++) s: s,
    };

    test('returns all 12 signs', () {
      final result = Jaimini.firstStrength(
        karakasPerSign: emptyKarakas,
        dignities: neutralDignities,
        signToLordSign: ownSignLords,
        inSignLongitudes: zeroLons,
      );
      expect(result.length, equals(12));
      expect(result.toSet().length, equals(12));
    });

    test('level 0: sign with more karakas ranks higher', () {
      final karakas = Map<int, List<Body>>.from(emptyKarakas);
      karakas[3] = [Body.sun, Body.moon, Body.mars];
      karakas[7] = [Body.jupiter];
      karakas[10] = [];

      final result = Jaimini.firstStrength(
        karakasPerSign: karakas,
        dignities: neutralDignities,
        signToLordSign: ownSignLords,
        inSignLongitudes: zeroLons,
      );
      final rank3 = result.indexOf(3);
      final rank7 = result.indexOf(7);
      final rank10 = result.indexOf(10);
      expect(rank3, lessThan(rank7));
      expect(rank7, lessThan(rank10));
    });

    test('level 1: equal karaka count, higher dignity wins', () {
      final karakas = Map<int, List<Body>>.from(emptyKarakas);
      karakas[1] = [Body.sun];
      karakas[2] = [Body.moon];

      final dignities = Map<Body, DignityType>.from(neutralDignities);
      dignities[Body.sun] = DignityType.exalted;
      dignities[Body.moon] = DignityType.debilitated;

      final result = Jaimini.firstStrength(
        karakasPerSign: karakas,
        dignities: dignities,
        signToLordSign: ownSignLords,
        inSignLongitudes: zeroLons,
      );
      final rank1 = result.indexOf(1);
      final rank2 = result.indexOf(2);
      expect(rank1, lessThan(rank2));
    });

    test('level 2: equal karakas and dignity, dual sign beats fixed beats cardinal', () {
      // Put one karaka with neutral dignity in each of signs 1 (cardinal),
      // 2 (fixed), 3 (mutable/dual).
      final karakas = Map<int, List<Body>>.from(emptyKarakas);
      karakas[1] = [Body.sun];
      karakas[2] = [Body.moon];
      karakas[3] = [Body.mars];

      final result = Jaimini.firstStrength(
        karakasPerSign: karakas,
        dignities: neutralDignities,
        signToLordSign: ownSignLords,
        inSignLongitudes: zeroLons,
      );
      final rank1 = result.indexOf(1); // cardinal
      final rank2 = result.indexOf(2); // fixed
      final rank3 = result.indexOf(3); // mutable (dual)
      expect(rank3, lessThan(rank2));
      expect(rank2, lessThan(rank1));
    });

    test('stable: deterministic output for identical input', () {
      final karakas = Map<int, List<Body>>.from(emptyKarakas);
      karakas[5] = [Body.venus, Body.jupiter];
      karakas[9] = [Body.saturn];

      final r1 = Jaimini.firstStrength(
        karakasPerSign: karakas,
        dignities: neutralDignities,
        signToLordSign: ownSignLords,
        inSignLongitudes: zeroLons,
      );
      final r2 = Jaimini.firstStrength(
        karakasPerSign: karakas,
        dignities: neutralDignities,
        signToLordSign: ownSignLords,
        inSignLongitudes: zeroLons,
      );
      expect(r1, equals(r2));
    });

    test('knRao tiebreaker uses lord in-sign longitude', () {
      // Two signs with identical everything except lord longitude.
      // Signs 3 and 9 are both mutable, put 1 karaka each with neutral dignity.
      final karakas = Map<int, List<Body>>.from(emptyKarakas);
      karakas[3] = [Body.sun];
      karakas[9] = [Body.moon];

      // Lord of 3 = Mercury, Lord of 9 = Jupiter.
      // Give Jupiter higher in-sign longitude → sign 9 should rank higher in KN Rao mode.
      final lons = Map<Body, double>.from(zeroLons);
      lons[Body.mercury] = 5.0;
      lons[Body.jupiter] = 25.0;

      final resultKnRao = Jaimini.firstStrength(
        karakasPerSign: karakas,
        dignities: neutralDignities,
        signToLordSign: ownSignLords,
        inSignLongitudes: lons,
        knRao: true,
      );
      final resultDefault = Jaimini.firstStrength(
        karakasPerSign: karakas,
        dignities: neutralDignities,
        signToLordSign: ownSignLords,
        inSignLongitudes: lons,
        knRao: false,
      );
      // In KN Rao mode, higher lord lon wins → sign 9 (Jupiter=25°) beats sign 3 (Mercury=5°)
      final rank3Rao = resultKnRao.indexOf(3);
      final rank9Rao = resultKnRao.indexOf(9);
      expect(rank9Rao, lessThan(rank3Rao));

      // Default mode uses sign number — sign 9 > sign 3, so sign 9 still wins.
      // (Both modes agree here since sign 9 > sign 3.)
      final rank3Def = resultDefault.indexOf(3);
      final rank9Def = resultDefault.indexOf(9);
      expect(rank9Def, lessThan(rank3Def));
    });
  });
}
