import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_calc/src/vedic/shadbala.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // virupasBetween
  // ---------------------------------------------------------------------------

  group('ShadbalaCalc.virupasBetween', () {
    test('same point → 60', () {
      expect(ShadbalaCalc.virupasBetween(45.0, 45.0), closeTo(60.0, 1e-9));
      expect(ShadbalaCalc.virupasBetween(0.0, 0.0), closeTo(60.0, 1e-9));
    });

    test('opposite (180° apart) → 0', () {
      expect(ShadbalaCalc.virupasBetween(0.0, 180.0), closeTo(0.0, 1e-9));
      expect(ShadbalaCalc.virupasBetween(90.0, 270.0), closeTo(0.0, 1e-9));
    });

    test('90° apart → 30', () {
      expect(ShadbalaCalc.virupasBetween(0.0, 90.0), closeTo(30.0, 1e-9));
      expect(ShadbalaCalc.virupasBetween(90.0, 0.0), closeTo(30.0, 1e-9));
    });

    test('45° apart → 45', () {
      expect(ShadbalaCalc.virupasBetween(0.0, 45.0), closeTo(45.0, 1e-9));
      expect(ShadbalaCalc.virupasBetween(45.0, 0.0), closeTo(45.0, 1e-9));
    });

    test('wraps across 360', () {
      // 350° to 10° = 20° apart → (1 - 20/180) * 60 ≈ 53.33
      expect(ShadbalaCalc.virupasBetween(350.0, 10.0), closeTo((1.0 - 20.0 / 180.0) * 60.0, 1e-9));
    });
  });

  // ---------------------------------------------------------------------------
  // uccaBala
  // ---------------------------------------------------------------------------

  group('ShadbalaCalc.uccaBala', () {
    test('Sun at exaltation point (10°) → 60', () {
      expect(ShadbalaCalc.uccaBala(Body.sun, 10.0), closeTo(60.0, 1e-9));
    });

    test('Sun at debilitation (190°, opposite of 10°) → 0', () {
      expect(ShadbalaCalc.uccaBala(Body.sun, 190.0), closeTo(0.0, 1e-9));
    });

    test('Moon in exaltation range (31°) → 60', () {
      expect(ShadbalaCalc.uccaBala(Body.moon, 31.0), closeTo(60.0, 1e-9));
    });

    test('Moon in debilitation range (211°) → 0', () {
      expect(ShadbalaCalc.uccaBala(Body.moon, 211.0), closeTo(0.0, 1e-9));
    });

    test('Moon at exaltation boundary (30°) → 60', () {
      expect(ShadbalaCalc.uccaBala(Body.moon, 30.0), closeTo(60.0, 1e-9));
    });

    test('Mercury in exaltation range (160°) → 60', () {
      expect(ShadbalaCalc.uccaBala(Body.mercury, 160.0), closeTo(60.0, 1e-9));
    });

    test('Mercury in debilitation range (340°) → 0', () {
      expect(ShadbalaCalc.uccaBala(Body.mercury, 340.0), closeTo(0.0, 1e-9));
    });

    test('Saturn at exaltation point (200°) → 60', () {
      expect(ShadbalaCalc.uccaBala(Body.saturn, 200.0), closeTo(60.0, 1e-9));
    });

    test('Saturn at debilitation (20°, opposite of 200°) → 0', () {
      expect(ShadbalaCalc.uccaBala(Body.saturn, 20.0), closeTo(0.0, 1e-9));
    });
  });

  // ---------------------------------------------------------------------------
  // kendradiBala
  // ---------------------------------------------------------------------------

  group('ShadbalaCalc.kendradiBala', () {
    test('kendra houses (1,4,7,10) → 60', () {
      expect(ShadbalaCalc.kendradiBala(1), closeTo(60.0, 1e-9));
      expect(ShadbalaCalc.kendradiBala(4), closeTo(60.0, 1e-9));
      expect(ShadbalaCalc.kendradiBala(7), closeTo(60.0, 1e-9));
      expect(ShadbalaCalc.kendradiBala(10), closeTo(60.0, 1e-9));
    });

    test('panaphara houses (2,5,8,11) → 30', () {
      expect(ShadbalaCalc.kendradiBala(2), closeTo(30.0, 1e-9));
      expect(ShadbalaCalc.kendradiBala(5), closeTo(30.0, 1e-9));
      expect(ShadbalaCalc.kendradiBala(8), closeTo(30.0, 1e-9));
      expect(ShadbalaCalc.kendradiBala(11), closeTo(30.0, 1e-9));
    });

    test('apoklima houses (3,6,9,12) → 15', () {
      expect(ShadbalaCalc.kendradiBala(3), closeTo(15.0, 1e-9));
      expect(ShadbalaCalc.kendradiBala(6), closeTo(15.0, 1e-9));
      expect(ShadbalaCalc.kendradiBala(9), closeTo(15.0, 1e-9));
      expect(ShadbalaCalc.kendradiBala(12), closeTo(15.0, 1e-9));
    });
  });

  // ---------------------------------------------------------------------------
  // samaVisamaBala
  // ---------------------------------------------------------------------------

  group('ShadbalaCalc.samaVisamaBala', () {
    test('Sun (male) in sign 1 (odd=male) rashi, sign 2 (even=female) navamsha → 15', () {
      expect(ShadbalaCalc.samaVisamaBala(Body.sun, 1, 2), closeTo(15.0, 1e-9));
    });

    test('Sun (male) in sign 2 (female) rashi → 0 from rashi, 0 from navamsha', () {
      expect(ShadbalaCalc.samaVisamaBala(Body.sun, 2, 4), closeTo(0.0, 1e-9));
    });

    test('Sun (male) in odd rashi AND odd navamsha → 30', () {
      expect(ShadbalaCalc.samaVisamaBala(Body.sun, 1, 3), closeTo(30.0, 1e-9));
    });

    test('Moon (female) in sign 2 (even=female) → 15 from rashi', () {
      expect(ShadbalaCalc.samaVisamaBala(Body.moon, 2, 1), closeTo(15.0, 1e-9));
    });

    test('Mercury (neutral) matches male (odd) signs', () {
      expect(ShadbalaCalc.samaVisamaBala(Body.mercury, 1, 1), closeTo(30.0, 1e-9));
      expect(ShadbalaCalc.samaVisamaBala(Body.mercury, 2, 2), closeTo(0.0, 1e-9));
    });
  });

  // ---------------------------------------------------------------------------
  // drekkanaBala
  // ---------------------------------------------------------------------------

  group('ShadbalaCalc.drekkanaBala', () {
    test('Sun (male) at 5° — 1st decan (male) → 15', () {
      expect(ShadbalaCalc.drekkanaBala(Body.sun, 5.0), closeTo(15.0, 1e-9));
    });

    test('Sun (male) at 15° — 2nd decan (neutral) → 0', () {
      expect(ShadbalaCalc.drekkanaBala(Body.sun, 15.0), closeTo(0.0, 1e-9));
    });

    test('Sun (male) at 25° — 3rd decan (female) → 0', () {
      expect(ShadbalaCalc.drekkanaBala(Body.sun, 25.0), closeTo(0.0, 1e-9));
    });

    test('Venus (female) at 25° — 3rd decan (female) → 15', () {
      expect(ShadbalaCalc.drekkanaBala(Body.venus, 25.0), closeTo(15.0, 1e-9));
    });

    test('Mercury (neutral) at 15° — 2nd decan (neutral) → 15', () {
      expect(ShadbalaCalc.drekkanaBala(Body.mercury, 15.0), closeTo(15.0, 1e-9));
    });
  });

  // ---------------------------------------------------------------------------
  // digBala
  // ---------------------------------------------------------------------------

  group('ShadbalaCalc.digBala', () {
    test('planet at its digbala cusp → 60', () {
      // Just wraps virupasBetween
      expect(ShadbalaCalc.digBala(Body.sun, 100.0, 100.0), closeTo(60.0, 1e-9));
    });

    test('planet at opposite of digbala cusp → 0', () {
      expect(ShadbalaCalc.digBala(Body.sun, 280.0, 100.0), closeTo(0.0, 1e-9));
    });

    test('planet 90° from digbala cusp → 30', () {
      expect(ShadbalaCalc.digBala(Body.moon, 90.0, 0.0), closeTo(30.0, 1e-9));
    });
  });

  // ---------------------------------------------------------------------------
  // ayanaBala
  // ---------------------------------------------------------------------------

  group('ShadbalaCalc.ayanaBala', () {
    test('Sun at 90° (Cancer solstice) → 60', () {
      expect(ShadbalaCalc.ayanaBala(Body.sun, 90.0), closeTo(60.0, 1e-9));
    });

    test('Sun at 270° (Capricorn solstice, opposite) → 0', () {
      expect(ShadbalaCalc.ayanaBala(Body.sun, 270.0), closeTo(0.0, 1e-9));
    });

    test('Mars at 90° → 60 (same rule as Sun)', () {
      expect(ShadbalaCalc.ayanaBala(Body.mars, 90.0), closeTo(60.0, 1e-9));
    });

    test('Saturn at 270° (Capricorn) → 60', () {
      expect(ShadbalaCalc.ayanaBala(Body.saturn, 270.0), closeTo(60.0, 1e-9));
    });

    test('Moon at 90° → 0 (Moon peaks at Capricorn)', () {
      expect(ShadbalaCalc.ayanaBala(Body.moon, 90.0), closeTo(0.0, 1e-9));
    });

    test('Mercury at 90° → 60 (max of Cancer/Capricorn)', () {
      expect(ShadbalaCalc.ayanaBala(Body.mercury, 90.0), closeTo(60.0, 1e-9));
    });

    test('Mercury at 180° → 30 (equidistant from both solstices)', () {
      expect(ShadbalaCalc.ayanaBala(Body.mercury, 180.0), closeTo(30.0, 1e-9));
    });
  });

  // ---------------------------------------------------------------------------
  // drigBala
  // ---------------------------------------------------------------------------

  group('ShadbalaCalc.drigBala', () {
    // Jupiter at 180° from body → full 7th-house aspect (strength=60).
    // Jupiter is full benefic → +60.
    test('Jupiter aspecting full (180°) → positive contribution', () {
      const bodyLon = 0.0;
      const jupiterLon = 180.0;
      final lons = {
        Body.sun: 90.0,
        Body.moon: 45.0,
        Body.mars: 30.0, // within 30° of body → strength=0 (same sign check)
        Body.mercury: 60.0,
        Body.jupiter: jupiterLon,
        Body.venus: 120.0,
        Body.saturn: 90.0,
      };
      final result = ShadbalaCalc.drigBala(
        Body.moon, // body being assessed
        bodyLon,
        lons,
        sunLon: 90.0,
        moonLon: 45.0,
      );
      // Jupiter at 180° has strength 60; contribution = +60.
      // Other planets will add/subtract, but jupiter's contribution is positive.
      expect(result, greaterThan(0.0));
    });

    // Saturn at 180° from body → full aspect, malefic → −strength/4.
    test('Saturn alone aspecting → negative contribution', () {
      const bodyLon = 0.0;
      final lons = {
        Body.sun: 5.0,    // same sign as body → 0 strength
        Body.moon: 5.0,   // same sign as body → 0 strength
        Body.mars: 5.0,   // same sign as body → 0 strength
        Body.mercury: 5.0, // same sign → 0
        Body.jupiter: 5.0, // same sign → 0
        Body.venus: 5.0,   // same sign → 0
        Body.saturn: 180.0, // opposite → strength=60
      };
      // waxing moon (moon=5, sun=5 → distance=0 ≤180 → benefic)
      final result = ShadbalaCalc.drigBala(
        Body.sun,
        bodyLon,
        lons,
        sunLon: 5.0,
        moonLon: 5.0,
      );
      // Saturn: strength=60, malefic → -60/4 = -15
      expect(result, closeTo(-15.0, 1e-9));
    });
  });

  // ---------------------------------------------------------------------------
  // cheshtaBala
  // ---------------------------------------------------------------------------

  group('ShadbalaCalc.cheshtaBala', () {
    // J2000.0 epoch: JD 2451545.0 → T = 0.0
    const j2000 = 2451545.0;

    test('Sun at 90° (Cancer) → same as ayanaBala → 60', () {
      expect(
        ShadbalaCalc.cheshtaBala(Body.sun, 90.0, j2000),
        closeTo(60.0, 1e-9),
      );
    });

    test('Sun at 270° (Capricorn) → 0', () {
      expect(
        ShadbalaCalc.cheshtaBala(Body.sun, 270.0, j2000),
        closeTo(0.0, 1e-9),
      );
    });

    test('Moon at full opposition from Sun → peak (60)', () {
      // sunLon = 0°, moon at 180° → opposition = peak cheshta
      expect(
        ShadbalaCalc.cheshtaBala(Body.moon, 180.0, j2000, sunEclipticLon: 0.0),
        closeTo(60.0, 1e-9),
      );
    });

    test('Moon conjunct Sun → 0', () {
      expect(
        ShadbalaCalc.cheshtaBala(Body.moon, 10.0, j2000, sunEclipticLon: 10.0),
        closeTo(0.0, 1e-9),
      );
    });

    test('Moon 90° from opposition → 30', () {
      // sunLon = 0° → opposition = 180°. Moon at 90° is 90° from opposition.
      expect(
        ShadbalaCalc.cheshtaBala(Body.moon, 90.0, j2000, sunEclipticLon: 0.0),
        closeTo(30.0, 1e-9),
      );
    });

    test('inner planet (Mercury) returns bounded 0-60 value', () {
      final result = ShadbalaCalc.cheshtaBala(Body.mercury, 160.0, j2000);
      expect(result, greaterThanOrEqualTo(0.0));
      expect(result, lessThanOrEqualTo(60.0));
    });

    test('inner planet (Venus) returns bounded 0-60 value', () {
      final result = ShadbalaCalc.cheshtaBala(Body.venus, 200.0, j2000);
      expect(result, greaterThanOrEqualTo(0.0));
      expect(result, lessThanOrEqualTo(60.0));
    });

    test('outer planet (Mars) returns bounded 0-60 value', () {
      final result = ShadbalaCalc.cheshtaBala(Body.mars, 300.0, j2000);
      expect(result, greaterThanOrEqualTo(0.0));
      expect(result, lessThanOrEqualTo(60.0));
    });

    test('outer planet (Jupiter) returns bounded 0-60 value', () {
      final result = ShadbalaCalc.cheshtaBala(Body.jupiter, 35.0, j2000);
      expect(result, greaterThanOrEqualTo(0.0));
      expect(result, lessThanOrEqualTo(60.0));
    });

    test('outer planet (Saturn) returns bounded 0-60 value', () {
      final result = ShadbalaCalc.cheshtaBala(Body.saturn, 50.0, j2000);
      expect(result, greaterThanOrEqualTo(0.0));
      expect(result, lessThanOrEqualTo(60.0));
    });

    test('Rahu returns 0 (not a karaka)', () {
      expect(
        ShadbalaCalc.cheshtaBala(Body.rahu, 100.0, j2000),
        closeTo(0.0, 1e-9),
      );
    });

    test('different JD produces different result for outer planet', () {
      // 10 years after J2000
      const jd2 = j2000 + 3652.5;
      final r1 = ShadbalaCalc.cheshtaBala(Body.mars, 300.0, j2000);
      final r2 = ShadbalaCalc.cheshtaBala(Body.mars, 300.0, jd2);
      expect(r1, isNot(closeTo(r2, 1e-3)));
    });
  });

  // ---------------------------------------------------------------------------
  // saptavargajaBala
  // ---------------------------------------------------------------------------

  group('ShadbalaCalc.saptavargajaBala', () {
    test('all moolatrikona → 7 × 45 = 315', () {
      final vargas = List.generate(
        7,
        (_) => (sign: 1, dignity: DignityType.moolatrikona),
      );
      expect(
        ShadbalaCalc.saptavargajaBala(Body.sun, vargas),
        closeTo(315.0, 1e-9),
      );
    });

    test('all greatEnemy → 7 × 2 = 14', () {
      final vargas = List.generate(
        7,
        (_) => (sign: 1, dignity: DignityType.greatEnemy),
      );
      expect(
        ShadbalaCalc.saptavargajaBala(Body.sun, vargas),
        closeTo(14.0, 1e-9),
      );
    });

    test('mixed dignities sum correctly', () {
      final vargas = [
        (sign: 1, dignity: DignityType.moolatrikona), // 45
        (sign: 5, dignity: DignityType.ownSign),       // 30
        (sign: 3, dignity: DignityType.friend),         // 15
        (sign: 7, dignity: DignityType.neutral),        // 10
        (sign: 9, dignity: DignityType.enemy),          // 4
        (sign: 2, dignity: DignityType.greatFriend),    // 20
        (sign: 4, dignity: DignityType.greatEnemy),     // 2
      ];
      expect(
        ShadbalaCalc.saptavargajaBala(Body.jupiter, vargas),
        closeTo(45 + 30 + 15 + 10 + 4 + 20 + 2, 1e-9),
      );
    });

    test('exalted dignity uses natural friendship fallback', () {
      // Sun exalted in Aries (sign 1). Lord of Aries = Mars.
      // Sun-Mars natural friendship = friend → 15 points.
      final vargas = [
        (sign: 1, dignity: DignityType.exalted),
        ...List.generate(6, (_) => (sign: 1, dignity: DignityType.neutral)),
      ];
      // exalted varga: Sun in sign 1 (lord=Mars). Sun-Mars are natural friends → 15.
      // 6 × neutral = 60. Total = 75.
      expect(
        ShadbalaCalc.saptavargajaBala(Body.sun, vargas),
        closeTo(15.0 + 60.0, 1e-9),
      );
    });

    test('debilitated dignity uses natural friendship fallback', () {
      // Sun debilitated in Libra (sign 7). Lord of Libra = Venus.
      // Sun-Venus natural friendship = enemy → 4 points.
      final vargas = [
        (sign: 7, dignity: DignityType.debilitated),
        ...List.generate(6, (_) => (sign: 1, dignity: DignityType.neutral)),
      ];
      expect(
        ShadbalaCalc.saptavargajaBala(Body.sun, vargas),
        closeTo(4.0 + 60.0, 1e-9),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Shadbala result type
  // ---------------------------------------------------------------------------

  group('Shadbala', () {
    test('sthanaBala sums five sub-balas', () {
      const s = Shadbala(
        uccaBala: 30.0,
        saptavargajaBala: 100.0,
        samaVisamaBala: 15.0,
        kendradiBala: 60.0,
        drekkanaBala: 15.0,
        digBala: 40.0,
        ayanaBala: 20.0,
        cheshtaBala: 25.0,
        drigBala: -5.0,
      );
      expect(s.sthanaBala, closeTo(220.0, 1e-9));
      expect(s.totalVirupas, closeTo(300.0, 1e-9));
      expect(s.totalRupas, closeTo(5.0, 1e-9));
    });
  });
}
