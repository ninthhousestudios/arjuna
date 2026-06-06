import 'package:arrow_calc/src/vedic/jaimini.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

import '../helpers/stub_varga.dart';

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
      expect(Jaimini.pada(1, 1), equals(10));
    });

    test('lord 7 signs away (apart=7) → 10th from ref', () {
      expect(Jaimini.pada(1, 7), equals(10));
    });

    test('lord 4 signs away (apart=4) → 4th from ref', () {
      expect(Jaimini.pada(1, 4), equals(4));
    });

    test('lord 10 signs away (apart=10) → 4th from ref', () {
      expect(Jaimini.pada(1, 10), equals(4));
    });

    test('special cases wrap around correctly', () {
      expect(Jaimini.pada(5, 5), equals(2));
      expect(Jaimini.pada(5, 11), equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // pada — normal case
  // ---------------------------------------------------------------------------
  group('Jaimini.pada — normal case', () {
    test('lord 3 signs away → signsForward(lordSign, 3)', () {
      expect(Jaimini.pada(1, 3), equals(5));
    });

    test('lord 5 signs away → signsForward(lordSign, 5)', () {
      expect(Jaimini.pada(1, 5), equals(9));
    });

    test('lord 2 signs away → signsForward(lordSign, 2)', () {
      expect(Jaimini.pada(3, 4), equals(5));
    });

    test('wraps around the zodiac', () {
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
    test('computes all 12 padas from varga', () {
      // Place lords at known positions. Mars in sign 1 → lords sign 1 (apart=1)
      // and sign 8 (apart=6). Jupiter in sign 9 → lords sign 9 (apart=1)
      // and sign 12 (apart=10, special).
      final v = stubVarga(longitudes: {
        Body.sun: 135.0, // sign 5
        Body.moon: 105.0, // sign 4
        Body.mars: 15.0, // sign 1
        Body.mercury: 75.0, // sign 3
        Body.jupiter: 255.0, // sign 9
        Body.venus: 45.0, // sign 2
        Body.saturn: 285.0, // sign 10
      });
      final result = Jaimini.allPadas(v);
      expect(result.length, equals(12));
      // Verify a few known values:
      // Sign 1: lord=Mars in sign 1. pada(1,1) → apart=1 → signsForward(1,10)=10
      expect(result[1], equals(10));
      // Sign 5: lord=Sun in sign 5. pada(5,5) → apart=1 → signsForward(5,10)=2
      expect(result[5], equals(2));
      // Sign 8: lord=Mars in sign 1. pada(8,1) → apart=6 → signsForward(1,6)=6
      expect(result[8], equals(6));
      // Sign 12: lord=Jupiter in sign 9. pada(12,9) → apart=10 → special → signsForward(12,4)=3
      expect(result[12], equals(3));
    });
  });

  // ---------------------------------------------------------------------------
  // Third Strength
  // ---------------------------------------------------------------------------
  group('Jaimini.thirdStrength', () {
    test('lord in own sign (distance 1) → kendra', () {
      // Mars in Aries (sign 1): lord of sign 1 in sign 1 → apart=1 → kendra.
      final v = stubVarga(longitudes: {
        Body.mars: 15.0, // sign 1
        Body.sun: 135.0,
        Body.moon: 105.0,
        Body.mercury: 75.0,
        Body.jupiter: 255.0,
        Body.venus: 45.0,
        Body.saturn: 285.0,
      });
      final result = Jaimini.thirdStrength(v);
      expect(result[1]!.strength, equals(2));
      expect(result[1]!.label, equals('kendra'));
    });

    test('lord 4 signs away → kendra (4 % 3 = 1)', () {
      // Lord of sign 1 = Mars. Mars in sign 4 → apart=4 → kendra.
      final v = stubVarga(longitudes: {
        Body.mars: 105.0, // sign 4
        Body.sun: 135.0,
        Body.moon: 225.0,
        Body.mercury: 75.0,
        Body.jupiter: 255.0,
        Body.venus: 45.0,
        Body.saturn: 285.0,
      });
      final result = Jaimini.thirdStrength(v);
      expect(result[1]!.strength, equals(2));
    });

    test('lord 2 signs away → panapara', () {
      // Lord of sign 1 = Mars. Mars in sign 2 → apart=2 → panapara.
      final v = stubVarga(longitudes: {
        Body.mars: 45.0, // sign 2
        Body.sun: 135.0,
        Body.moon: 105.0,
        Body.mercury: 75.0,
        Body.jupiter: 255.0,
        Body.venus: 195.0,
        Body.saturn: 285.0,
      });
      final result = Jaimini.thirdStrength(v);
      expect(result[1]!.strength, equals(1));
      expect(result[1]!.label, equals('panapara'));
    });

    test('lord 3 signs away → apoklima', () {
      // Lord of sign 1 = Mars. Mars in sign 3 → apart=3 → apoklima.
      final v = stubVarga(longitudes: {
        Body.mars: 75.0, // sign 3
        Body.sun: 135.0,
        Body.moon: 105.0,
        Body.mercury: 165.0,
        Body.jupiter: 255.0,
        Body.venus: 45.0,
        Body.saturn: 285.0,
      });
      final result = Jaimini.thirdStrength(v);
      expect(result[1]!.strength, equals(0));
      expect(result[1]!.label, equals('apoklima'));
    });

    test('all 12 signs classified', () {
      final v = stubVarga();
      final result = Jaimini.thirdStrength(v);
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
    test('matching non-zero counts on symmetric pair → yoga present', () {
      // lagnaSign=1. Signs 2 and 12 each have 1 graha.
      // Keep Rahu/Ketu away from symmetric pairs.
      final v = stubVarga(longitudes: {
        Body.jupiter: 45.0, // sign 2
        Body.venus: 345.0, // sign 12
        Body.sun: 135.0, // sign 5
        Body.moon: 135.5, // sign 5
        Body.mars: 136.0, // sign 5
        Body.mercury: 136.5, // sign 5
        Body.saturn: 137.0, // sign 5
        Body.rahu: 135.5, // sign 5
        Body.ketu: 315.5, // sign 11 (Rahu+180)
      });
      final yogas = Jaimini.bandhanaYogas(v);
      // Pairs from lagna=1: (2,12),(3,11),(4,10),(5,9),(6,8)
      // Sign 2: [Jupiter], Sign 12: [Venus] → match
      // Sign 11: [Ketu] only → sign 3: empty → no match (unequal)
      // Sign 5 has many but no symmetric partner with same count
      expect(yogas.length, equals(1));
      expect(yogas.first.$1, equals([Body.jupiter]));
      expect(yogas.first.$2, equals([Body.venus]));
    });

    test('unequal counts → no yoga', () {
      // Signs 2 has 2 grahas, sign 12 has 1.
      final v = stubVarga(longitudes: {
        Body.jupiter: 45.0, // sign 2
        Body.sun: 50.0, // sign 2
        Body.venus: 345.0, // sign 12
        Body.moon: 135.0, // sign 5
        Body.mars: 136.0, // sign 5
        Body.mercury: 137.0, // sign 5
        Body.saturn: 138.0, // sign 5
        Body.rahu: 135.5, // sign 5
        Body.ketu: 315.5, // sign 11
      });
      final yogas = Jaimini.bandhanaYogas(v);
      // (2,12): 2 vs 1 → no. (3,11): 0 vs 1(Ketu) → no. Others: mismatched.
      expect(yogas, isEmpty);
    });

    test('no grahas in symmetric positions → no yoga', () {
      // All 9 grahas in sign 1 (lagna itself is not a symmetric pair member).
      final v = stubVarga(longitudes: {
        Body.sun: 1.0, Body.moon: 2.0, Body.mars: 3.0,
        Body.mercury: 4.0, Body.jupiter: 5.0,
        Body.venus: 6.0, Body.saturn: 7.0,
        Body.rahu: 8.0, Body.ketu: 188.0,
      });
      // lagnaSign=1. Pairs: (2,12),(3,11),(4,10),(5,9),(6,8). All empty.
      final yogas = Jaimini.bandhanaYogas(v);
      expect(yogas, isEmpty);
    });

    test('multiple pairs can match', () {
      // lagnaSign=1. Signs 3/11 each have 1, signs 4/10 each have 1.
      final v = stubVarga(longitudes: {
        Body.sun: 75.0, // sign 3
        Body.moon: 315.0, // sign 11
        Body.mars: 105.0, // sign 4
        Body.jupiter: 285.0, // sign 10
        Body.mercury: 15.0, // sign 1
        Body.venus: 16.0, // sign 1
        Body.saturn: 17.0, // sign 1
        Body.rahu: 15.5, // sign 1
        Body.ketu: 195.5, // sign 7
      });
      // (3,11): [Sun] vs [Moon] → 1==1 ✓
      // (4,10): [Mars] vs [Jupiter] → 1==1 ✓
      // (6,8): 0 vs 0 → no (empty)
      final yogas = Jaimini.bandhanaYogas(v);
      expect(yogas.length, equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // Argala
  // ---------------------------------------------------------------------------
  group('Jaimini.argala', () {
    test('single graha in 2nd from target → unobstructed 2nd argala', () {
      // Target=1. Sun in sign 2 (2nd from target). Keep all others in sign 7
      // (not any argala/virodhina position from target=1).
      // Argala offsets: 2→sign2, 11→sign11, 4→sign4, 9→sign9.
      // Virodhina: 12→sign12, 3→sign3, 10→sign10, 5→sign5. 3rd malefic: sign3.
      // Sign 7 is safe. Ketu must NOT be in sign 1 (target).
      final v = stubVarga(longitudes: {
        Body.sun: 45.0, // sign 2 — the argala
        Body.moon: 195.0, // sign 7
        Body.mars: 196.0, // sign 7
        Body.mercury: 197.0, // sign 7
        Body.jupiter: 198.0, // sign 7
        Body.venus: 199.0, // sign 7
        Body.saturn: 200.0, // sign 7
        Body.rahu: 195.5, // sign 7
        Body.ketu: 195.6, // sign 7
      });
      final result = Jaimini.argala(v, targetSign: 1);
      expect(result.unobstructed[2], contains(Body.sun));
      expect(result.obstructed, isEmpty);
    });

    test('malefics outnumber benefics in 3rd → third-malefic argala', () {
      // Target=1. Sun (malefic) + Mars (malefic) in sign 3.
      final v = stubVarga(longitudes: {
        Body.sun: 75.0, // sign 3
        Body.mars: 76.0, // sign 3
        Body.moon: 195.0, // sign 7
        Body.mercury: 196.0, // sign 7
        Body.jupiter: 197.0, // sign 7
        Body.venus: 198.0, // sign 7
        Body.saturn: 199.0, // sign 7
        Body.rahu: 195.5, // sign 7
        Body.ketu: 195.6, // sign 7
      });
      final result = Jaimini.argala(v, targetSign: 1);
      expect(result.thirdMaleficArgala, containsAll([Body.sun, Body.mars]));
    });

    test('equal malefic/benefic in 3rd → no third-malefic argala', () {
      // Target=1. Sun (malefic) + Jupiter (benefic) in sign 3.
      final v = stubVarga(longitudes: {
        Body.sun: 75.0, // sign 3
        Body.jupiter: 76.0, // sign 3
        Body.moon: 195.0, // sign 7
        Body.mars: 196.0, // sign 7
        Body.mercury: 197.0, // sign 7
        Body.venus: 198.0, // sign 7
        Body.saturn: 199.0, // sign 7
        Body.rahu: 195.5, // sign 7
        Body.ketu: 195.6, // sign 7
      });
      final result = Jaimini.argala(v, targetSign: 1);
      expect(result.thirdMaleficArgala, isEmpty);
    });

    test('Ketu in targetSign reverses offsets', () {
      // Target=1, Ketu in sign 1. Reversed 2nd offset: (-2)%12=10 →
      // signsForward(1,10)=10. Put Moon in sign 10.
      // Keep everything else in sign 7 (safe from all reversed offsets).
      final v = stubVarga(longitudes: {
        Body.moon: 285.0, // sign 10 — reversed 2nd argala
        Body.sun: 195.0, // sign 7
        Body.mars: 196.0, // sign 7
        Body.mercury: 197.0, // sign 7
        Body.jupiter: 198.0, // sign 7
        Body.venus: 199.0, // sign 7
        Body.saturn: 200.0, // sign 7
        Body.rahu: 195.5, // sign 7 → Ketu at 15.5° = sign 1
        Body.ketu: 15.5, // sign 1 (target)
      });
      final result = Jaimini.argala(v, targetSign: 1);
      expect(result.unobstructed[2], contains(Body.moon));
    });
  });

  // ---------------------------------------------------------------------------
  // First Strength
  // ---------------------------------------------------------------------------
  group('Jaimini.firstStrength', () {
    test('returns all 12 signs', () {
      final result = Jaimini.firstStrength(stubVarga());
      expect(result.length, equals(12));
      expect(result.toSet().length, equals(12));
    });

    test('level 0: sign with more karakas ranks higher', () {
      // Sign 3: Sun, Moon, Mars (3 karakas). Sign 7: Jupiter (1). Sign 10: empty.
      final v = stubVarga(longitudes: {
        Body.sun: 75.0, Body.moon: 76.0, Body.mars: 77.0, // sign 3
        Body.jupiter: 195.0, // sign 7
        Body.mercury: 165.0, // sign 6
        Body.venus: 45.0, // sign 2
        Body.saturn: 345.0, // sign 12
      });
      final result = Jaimini.firstStrength(v);
      final rank3 = result.indexOf(3);
      final rank7 = result.indexOf(7);
      final rank10 = result.indexOf(10); // empty
      expect(rank3, lessThan(rank7));
      expect(rank7, lessThan(rank10));
    });

    test('level 1: equal karaka count, higher dignity wins', () {
      // Sun in sign 1 (Aries) → exalted. Mars in sign 4 (Cancer) → debilitated.
      final v = stubVarga(longitudes: {
        Body.sun: 15.0, // sign 1, exalted
        Body.mars: 105.0, // sign 4, debilitated
        Body.moon: 225.0,
        Body.mercury: 165.0,
        Body.jupiter: 255.0,
        Body.venus: 45.0,
        Body.saturn: 315.0,
      });
      final result = Jaimini.firstStrength(v);
      final rank1 = result.indexOf(1);
      final rank4 = result.indexOf(4);
      expect(rank1, lessThan(rank4));
    });

    test('level 2: dual sign beats fixed beats cardinal among empty signs', () {
      // All karakas in sign 5 (Leo, fixed). Empty signs sort by modality.
      final v = stubVarga(longitudes: {
        Body.sun: 125.0, Body.moon: 126.0, Body.mars: 127.0,
        Body.mercury: 128.0, Body.jupiter: 129.0,
        Body.venus: 130.0, Body.saturn: 131.0,
      });
      final result = Jaimini.firstStrength(v);
      // Sign 5 has all karakas → ranks first.
      expect(result.indexOf(5), equals(0));
      // Among empty signs: mutable > fixed > cardinal.
      final rank3 = result.indexOf(3); // mutable (Gemini)
      final rank2 = result.indexOf(2); // fixed (Taurus)
      final rank1 = result.indexOf(1); // cardinal (Aries)
      expect(rank3, lessThan(rank2));
      expect(rank2, lessThan(rank1));
    });

    test('stable: deterministic output', () {
      final v = stubVarga();
      final r1 = Jaimini.firstStrength(v);
      final r2 = Jaimini.firstStrength(v);
      expect(r1, equals(r2));
    });

    test('knRao tiebreaker uses lord in-sign longitude', () {
      // Signs 3 (mutable) and 9 (mutable) both empty. Lords: Mercury (sign 3)
      // and Jupiter (sign 9). Mercury at 5° in-sign, Jupiter at 25° in-sign.
      // Both lord signs are fixed (sign 5, sign 11).
      // Put Mercury in sign 5 at 125° (5° in-sign) and Jupiter in sign 11 at
      // 325° (25° in-sign). No karakas in sign 3, 5, 9, or 11 (other than
      // Mercury/Jupiter themselves).
      final v = stubVarga(longitudes: {
        Body.mercury: 125.0, // sign 5, 5° in-sign
        Body.jupiter: 325.0, // sign 11, 25° in-sign
        Body.sun: 15.0, // sign 1
        Body.moon: 195.0, // sign 7
        Body.mars: 225.0, // sign 8
        Body.venus: 255.0, // sign 9
        Body.saturn: 285.0, // sign 10
      });
      final resultKnRao = Jaimini.firstStrength(v, knRao: true);
      // In KN Rao mode, sign 9's lord (Jupiter, 25° in-sign) beats
      // sign 3's lord (Mercury, 5° in-sign).
      final rank3Rao = resultKnRao.indexOf(3);
      final rank9Rao = resultKnRao.indexOf(9);
      expect(rank9Rao, lessThan(rank3Rao));
    });
  });
}
