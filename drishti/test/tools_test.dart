import 'package:quiver_embedded/quiver_embedded.dart';
import 'package:test/test.dart';

import 'package:drishti/src/formatting/chart_formatter.dart';
import 'package:drishti/src/tools/calculate_chart.dart';

void main() {
  late Vayu vayu;

  setUpAll(() {
    vayu = Vayu();
  });

  tearDownAll(() {
    vayu.dispose();
  });

  group('formatChart', () {
    late Chart chart;

    setUpAll(() {
      chart = vayu.calculateChart(
        DateTime.utc(2000, 1, 1, 12),
        const Location(latitude: 28.6139, longitude: 77.2090),
        ArrowPresets.ernst,
      );
    });

    test('has summary, planets, and houses keys', () {
      final result = formatChart(chart);
      expect(result, contains('summary'));
      expect(result, contains('planets'));
      expect(result, contains('houses'));
    });

    test('summary contains jd, ayanamsa, ascendant, mc', () {
      final result = formatChart(chart);
      final summary = result['summary'] as Map<String, dynamic>;
      expect(summary, contains('jd'));
      expect(summary, contains('ayanamsa'));
      expect(summary, contains('ascendant'));
      expect(summary, contains('mc'));
      expect(summary['jd'], isA<double>());
    });

    test('planets list has 9 entries for ernst preset', () {
      final result = formatChart(chart);
      final planets = result['planets'] as List;
      // Ernst is Vedic: Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu
      expect(planets.length, equals(9));
    });

    test('each planet has required fields', () {
      final result = formatChart(chart);
      final planets = result['planets'] as List;
      for (final planet in planets) {
        final p = planet as Map<String, dynamic>;
        expect(p, contains('name'));
        expect(p, contains('longitude'));
        expect(p, contains('sign'));
        expect(p, contains('sign_name'));
        expect(p, contains('degrees_in_sign'));
        expect(p, contains('nakshatra'));
        expect(p, contains('nakshatra_name'));
        expect(p, contains('pada'));
        expect(p, contains('is_retrograde'));
        expect(p, contains('speed_class'));
      }
    });

    test('karakas have dignity field', () {
      final result = formatChart(chart);
      final planets = result['planets'] as List;

      // Find Sun (a Karaka) and verify it has dignity.
      final sun = planets.firstWhere(
        (p) => (p as Map<String, dynamic>)['name'] == 'sun',
      ) as Map<String, dynamic>;
      expect(sun, contains('dignity'));
      expect(sun, contains('is_combust'));
    });

    test('rahu/ketu do not have dignity field', () {
      final result = formatChart(chart);
      final planets = result['planets'] as List;

      final rahu = planets.firstWhere(
        (p) => (p as Map<String, dynamic>)['name'] == 'rahu',
      ) as Map<String, dynamic>;
      expect(rahu, isNot(contains('dignity')));
    });

    test('houses list has 12 entries', () {
      final result = formatChart(chart);
      final houses = result['houses'] as List;
      expect(houses.length, equals(12));
    });

    test('each house has required fields', () {
      final result = formatChart(chart);
      final houses = result['houses'] as List;
      for (var i = 0; i < houses.length; i++) {
        final h = houses[i] as Map<String, dynamic>;
        expect(h['number'], equals(i + 1));
        expect(h, contains('sign'));
        expect(h, contains('sign_name'));
        expect(h, contains('longitude'));
      }
    });

    test('sign names are valid', () {
      final result = formatChart(chart);
      final planets = result['planets'] as List;
      const validSigns = [
        'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
        'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
      ];
      for (final planet in planets) {
        final p = planet as Map<String, dynamic>;
        expect(validSigns, contains(p['sign_name']));
      }
    });

    test('sign numbers are in 1-12 range', () {
      final result = formatChart(chart);
      final planets = result['planets'] as List;
      for (final planet in planets) {
        final p = planet as Map<String, dynamic>;
        expect(p['sign'] as int, greaterThanOrEqualTo(1));
        expect(p['sign'] as int, lessThanOrEqualTo(12));
      }
    });

    test('nakshatra numbers are in 1-27 range', () {
      final result = formatChart(chart);
      final planets = result['planets'] as List;
      for (final planet in planets) {
        final p = planet as Map<String, dynamic>;
        expect(p['nakshatra'] as int, greaterThanOrEqualTo(1));
        expect(p['nakshatra'] as int, lessThanOrEqualTo(27));
      }
    });

    test('pada numbers are in 1-4 range', () {
      final result = formatChart(chart);
      final planets = result['planets'] as List;
      for (final planet in planets) {
        final p = planet as Map<String, dynamic>;
        expect(p['pada'] as int, greaterThanOrEqualTo(1));
        expect(p['pada'] as int, lessThanOrEqualTo(4));
      }
    });
  });

  group('formatChart with western preset', () {
    test('planets list has 10 entries for western preset', () {
      final chart = vayu.calculateChart(
        DateTime.utc(2000, 1, 1, 12),
        const Location(latitude: 28.6139, longitude: 77.2090),
        ArrowPresets.westernTropical,
      );
      final result = formatChart(chart);
      final planets = result['planets'] as List;
      // Western: Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto
      expect(planets.length, equals(10));
    });
  });

  group('handleCalculateChart error paths', () {
    test('missing date returns error', () {
      final result = handleCalculateChart(
        {'latitude': 28.6, 'longitude': 77.2},
        vayu,
      );
      expect(result.isError, isTrue);
    });

    test('invalid date format returns error', () {
      final result = handleCalculateChart(
        {'date': 'not-a-date', 'latitude': 28.6, 'longitude': 77.2},
        vayu,
      );
      expect(result.isError, isTrue);
    });

    test('latitude out of range returns error', () {
      final result = handleCalculateChart(
        {'date': '2000-01-01T12:00:00Z', 'latitude': 91.0, 'longitude': 77.2},
        vayu,
      );
      expect(result.isError, isTrue);
    });

    test('longitude out of range returns error', () {
      final result = handleCalculateChart(
        {'date': '2000-01-01T12:00:00Z', 'latitude': 28.6, 'longitude': 181.0},
        vayu,
      );
      expect(result.isError, isTrue);
    });

    test('unknown preset returns error', () {
      final result = handleCalculateChart(
        {
          'date': '2000-01-01T12:00:00Z',
          'latitude': 28.6,
          'longitude': 77.2,
          'preset': 'vedic',
        },
        vayu,
      );
      expect(result.isError, isTrue);
    });

    test('valid request succeeds', () {
      final result = handleCalculateChart(
        {
          'date': '2000-01-01T12:00:00Z',
          'latitude': 28.6,
          'longitude': 77.2,
        },
        vayu,
      );
      expect(result.isError, isFalse);
    });
  });
}
