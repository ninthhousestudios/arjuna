// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_calc/arrow_calc.dart';
import 'package:test/test.dart';

// Linear motion model for next_* tests.
// Sun: 1°/day.  Moon: 13.2°/day.  Both constant speed.
// Relative (moon−sun): 12.2°/day.  Combined (sun+moon): 14.2°/day.
// With a linear model Newton is exact in one step, so bisection
// refines to floating-point precision.

({double sun, double moon, double sunSpeed, double moonSpeed}) _linearEcliptic(
  double jd,
) => (
  sun: (jd * 1.0) % 360,
  moon: (jd * 13.2) % 360,
  sunSpeed: 1.0,
  moonSpeed: 13.2,
);

// Sidereal — same values (pretend zero ayanamsa).
({double sun, double moon, double sunSpeed, double moonSpeed}) _linearSidereal(
  double jd,
) => _linearEcliptic(jd);

({double longitude, double speed}) _linearMoonSidereal(double jd) =>
    (longitude: (jd * 13.2) % 360, speed: 13.2);

void main() {
  group('Tithi', () {
    test('new moon (conjunction) is tithi 30', () {
      final t = calcTithi(100.0, 99.5);
      expect(t.number, 30);
      expect(t.type, 'pūrṇa');
    });

    test('full moon (opposition) is tithi 15', () {
      final t = calcTithi(0.0, 180.0);
      expect(t.number, 16);
      final t2 = calcTithi(0.0, 179.0);
      expect(t2.number, 15);
    });

    test('tithi type cycles', () {
      expect(calcTithi(0.0, 1.0).type, 'nanda');
      expect(calcTithi(0.0, 13.0).type, 'bhadra');
      expect(calcTithi(0.0, 25.0).type, 'jāya');
      expect(calcTithi(0.0, 37.0).type, 'ṛkta');
      expect(calcTithi(0.0, 49.0).type, 'pūrṇa');
      expect(calcTithi(0.0, 61.0).type, 'nanda');
    });

    test('elapsed + remaining = 12', () {
      final t = calcTithi(45.0, 123.4);
      expect(t.degreesElapsed + t.degreesRemaining, closeTo(12.0, 1e-10));
    });
  });

  group('Karana', () {
    test('first karana of tithi 1', () {
      final t = calcTithi(0.0, 1.0);
      final k = calcKarana(0.0, 1.0, t);
      expect(t.number, 1);
      expect(k.name, 'kiṃtughna');
      expect(k.half, 0);
    });

    test('second karana of tithi 1', () {
      final t = calcTithi(0.0, 10.0);
      final k = calcKarana(0.0, 10.0, t);
      expect(t.number, 1);
      expect(k.name, 'bava');
      expect(k.half, 1);
    });

    test('elapsed + remaining = 6', () {
      final t = calcTithi(10.0, 77.7);
      final k = calcKarana(10.0, 77.7, t);
      expect(k.degreesElapsed + k.degreesRemaining, closeTo(6.0, 1e-10));
    });
  });

  group('Nakshatra', () {
    test('0° sidereal is aśvinī', () {
      final n = calcNakshatra(0.5);
      expect(n.name, 'aśvinī');
      expect(n.number, 1);
    });

    test('nakshatra at 30° sidereal', () {
      final n = calcNakshatra(30.0);
      expect(n.name, 'kṛttikā');
      expect(n.number, 3);
    });

    test('pada calculation', () {
      expect(calcNakshatra(1.0).pada, 1);
      expect(calcNakshatra(4.0).pada, 2);
      expect(calcNakshatra(7.0).pada, 3);
      expect(calcNakshatra(11.0).pada, 4);
    });

    test('elapsed + remaining = nakshatraSpan', () {
      final n = calcNakshatra(222.2);
      expect(
        n.degreesElapsed + n.degreesRemaining,
        closeTo(nakshatraSpan, 1e-10),
      );
    });

    test('wraps around at 360', () {
      final n = calcNakshatra(361.0);
      expect(n.name, calcNakshatra(1.0).name);
    });
  });

  group('nextTithi', () {
    test('finds the next tithi boundary', () {
      final result = nextTithi(0.0, _linearEcliptic);
      expect(result.tithi.number, 2);
      expect(result.jd, greaterThan(0.0));
    });

    test('boundary JD matches theoretical value to high precision', () {
      final expected = 12.0 / 12.2;
      final result = nextTithi(0.0, _linearEcliptic);
      expect(result.jd, closeTo(expected, 1e-6));
    });

    test('advances through successive boundaries', () {
      final first = nextTithi(0.0, _linearEcliptic);
      final second = nextTithi(first.jd, _linearEcliptic);
      expect(second.tithi.number, 3);
      expect(second.jd, closeTo(24.0 / 12.2, 1e-6));
    });
  });

  group('nextKarana', () {
    test('finds the next karana boundary', () {
      final result = nextKarana(0.0, _linearEcliptic);
      expect(result.karana.name, 'bava');
      expect(result.jd, greaterThan(0.0));
    });

    test('boundary JD matches theoretical value to high precision', () {
      final expected = 6.0 / 12.2;
      final result = nextKarana(0.0, _linearEcliptic);
      expect(result.jd, closeTo(expected, 1e-6));
    });
  });

  group('nextNakshatra', () {
    test('finds the next nakshatra boundary', () {
      final result = nextNakshatra(0.0, _linearMoonSidereal);
      expect(result.nakshatra.index, 1);
      expect(result.nakshatra.name, 'bharaṇī');
      expect(result.jd, greaterThan(0.0));
    });

    test('boundary JD matches theoretical value to high precision', () {
      final expected = nakshatraSpan / 13.2;
      final result = nextNakshatra(0.0, _linearMoonSidereal);
      expect(result.jd, closeTo(expected, 1e-6));
    });
  });

  group('nextYoga', () {
    test('finds the next yoga boundary', () {
      final result = nextYoga(0.0, _linearSidereal);
      expect(result.yoga.number, 2);
      expect(result.yoga.name, 'prīti');
      expect(result.jd, greaterThan(0.0));
    });

    test('boundary JD matches theoretical value to high precision', () {
      final expected = yogaSpan / 14.2;
      final result = nextYoga(0.0, _linearSidereal);
      expect(result.jd, closeTo(expected, 1e-6));
    });

    test('advances through successive boundaries', () {
      final first = nextYoga(0.0, _linearSidereal);
      final second = nextYoga(first.jd, _linearSidereal);
      expect(second.yoga.number, 3);
      expect(second.jd, closeTo(2 * yogaSpan / 14.2, 1e-6));
    });
  });

  group('Vara', () {
    test('known date: 2024-01-01 00:00 UT is Monday', () {
      final v = calcVara(2460310.5);
      expect(v.name, 'somavāra');
      expect(v.index, 1);
    });

    test('vara changes at 18:00 UT (Yamakoti sunrise)', () {
      final before = calcVara(2460310.5 + 17.99 / 24.0);
      expect(before.index, 1);

      final after = calcVara(2460310.5 + 18.01 / 24.0);
      expect(after.index, 2);
    });

    test('vara index cycles 0-6', () {
      for (var i = 0; i < 7; i++) {
        final day = calcVara(2460309.5 + i);
        expect(day.index, i, reason: 'day offset $i should be index $i');
      }
    });

    test('abbreviation matches index', () {
      final v = calcVara(2460310.5);
      expect(v.abbreviation, 'som');
    });
  });

  group('nextVara', () {
    test('finds next vara change with mock sunrise', () {
      double mockSunrise(double jd) => jd + 0.5;
      final result = nextVara(2460310.5, mockSunrise);
      expect(result.jd, 2460311.0);
      expect(result.vara.index, isNonNegative);
    });

    test('returns correct vara at the sunrise point', () {
      double mockSunrise(double jd) => 2460310.5 + 18.01 / 24.0;
      final result = nextVara(2460310.5, mockSunrise);
      expect(result.vara.name, 'maṅgalavāra');
    });
  });

  group('vedangaJyotishaEcliptic', () {
    test('offset is 23°20\'', () {
      final sid = vedangaJyotishaEcliptic(0.0);
      expect(sid, closeTo(23.0 + 20.0 / 60.0, 1e-10));
    });

    test('1° past winter solstice is in Dhaniṣṭhā', () {
      final sid = vedangaJyotishaEcliptic(271.0);
      final nak = calcNakshatra(sid);
      expect(nak.name, 'dhaniṣṭhā');
    });

    test('wraps around at 360', () {
      final a = vedangaJyotishaEcliptic(350.0);
      final b = vedangaJyotishaEcliptic(350.0 + 360.0);
      expect(a, closeTo(b, 1e-10));
    });
  });

  group('Yoga', () {
    test('yoga at sum = 0 is viṣkambha', () {
      final y = calcYoga(0.0, 0.5);
      expect(y.name, 'viṣkambha');
      expect(y.number, 1);
    });

    test('yoga at sum ≈ 13°20\' is prīti', () {
      final y = calcYoga(7.0, 7.0);
      expect(y.name, 'prīti');
      expect(y.number, 2);
    });

    test('elapsed + remaining = yogaSpan', () {
      final y = calcYoga(100.0, 200.0);
      expect(y.degreesElapsed + y.degreesRemaining, closeTo(yogaSpan, 1e-10));
    });

    test('wraps at 360', () {
      final y1 = calcYoga(180.0, 185.0);
      final y2 = calcYoga(0.0, 5.0);
      expect(y1.name, y2.name);
    });
  });
}
