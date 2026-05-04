import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_core/src/longitude.dart';
import 'package:test/test.dart';

void main() {
  const defaultConfig = CalcConfig();
  const zodiacConfig = CalcConfig(circle: Circle.zodiac);

  group('Sign calculation', () {
    test('Aditya circle: 0deg = sign 2', () {
      final lon = Longitude(0.0, 0.0, VargaType.rashi, defaultConfig);
      expect(lon.sign, 2);
    });

    test('Aditya circle: 330deg = sign 1', () {
      final lon = Longitude(330.0, 330.0, VargaType.rashi, defaultConfig);
      expect(lon.sign, 1);
    });

    test('Zodiac circle: 0deg = sign 1', () {
      final lon = Longitude(0.0, 0.0, VargaType.rashi, zodiacConfig);
      expect(lon.sign, 1);
    });

    test('Zodiac circle: 45deg = sign 2 (Taurus)', () {
      final lon = Longitude(45.0, 45.0, VargaType.rashi, zodiacConfig);
      expect(lon.sign, 2);
    });

    test('Zodiac circle: 90deg = sign 4 (Cancer)', () {
      final lon = Longitude(90.0, 90.0, VargaType.rashi, zodiacConfig);
      expect(lon.sign, 4);
    });

    test('Zodiac circle: 359deg = sign 12', () {
      final lon = Longitude(359.0, 359.0, VargaType.rashi, zodiacConfig);
      expect(lon.sign, 12);
    });
  });

  group('inSignLongitude', () {
    test('45deg = 15deg in sign', () {
      final lon = Longitude(45.0, 45.0, VargaType.rashi, defaultConfig);
      expect(lon.inSignLongitude, 15.0);
    });

    test('0deg = 0deg in sign', () {
      final lon = Longitude(0.0, 0.0, VargaType.rashi, defaultConfig);
      expect(lon.inSignLongitude, 0.0);
    });

    test('30deg = 0deg in sign', () {
      final lon = Longitude(30.0, 30.0, VargaType.rashi, defaultConfig);
      expect(lon.inSignLongitude, 0.0);
    });
  });

  group('degreesApart', () {
    test('0deg to 90deg = 90deg', () {
      final lon = Longitude(0.0, 0.0, VargaType.rashi, defaultConfig);
      expect(lon.degreesApart(90.0), 90.0);
    });

    test('350deg to 10deg = 20deg (wraps)', () {
      final lon = Longitude(350.0, 350.0, VargaType.rashi, defaultConfig);
      expect(lon.degreesApart(10.0), 20.0);
    });

    test('90deg to 90deg = 0deg', () {
      final lon = Longitude(90.0, 90.0, VargaType.rashi, defaultConfig);
      expect(lon.degreesApart(90.0), 0.0);
    });
  });

  group('signsApart', () {
    test('sign 1 to sign 4 = 3', () {
      final lon = Longitude(0.0, 0.0, VargaType.rashi, zodiacConfig);
      expect(lon.signsApart(4), 3);
    });

    test('sign 12 to sign 1 = 1 (wraps)', () {
      // 330deg zodiac = sign 12
      final lon = Longitude(330.0, 330.0, VargaType.rashi, zodiacConfig);
      expect(lon.sign, 12);
      expect(lon.signsApart(1), 1);
    });
  });

  group('isBetween', () {
    test('normal range', () {
      final lon = Longitude(45.0, 45.0, VargaType.rashi, defaultConfig);
      expect(lon.isBetween(30.0, 60.0), isTrue);
      expect(lon.isBetween(50.0, 90.0), isFalse);
    });

    test('wrap-around range', () {
      final lon = Longitude(350.0, 350.0, VargaType.rashi, defaultConfig);
      expect(lon.isBetween(340.0, 10.0), isTrue);
    });

    test('not in wrap-around range', () {
      final lon = Longitude(180.0, 180.0, VargaType.rashi, defaultConfig);
      expect(lon.isBetween(340.0, 10.0), isFalse);
    });
  });

  group('Rashi (D1)', () {
    test('rashi returns ecliptic longitude unchanged', () {
      final lon = Longitude(123.456, 123.456, VargaType.rashi, defaultConfig);
      expect(lon.amshaLongitude, 123.456);
      expect(lon.deity, isNull);
    });
  });

  group('Nakshatra', () {
    test('0deg = nakshatra 1', () {
      final lon = Longitude(0.0, 0.0, VargaType.rashi, defaultConfig);
      expect(lon.nakshatra, 1);
    });

    test('180deg = nakshatra 14', () {
      // 180 / (360/27) = 180 / 13.333... = 13.5 -> floor + 1 = 14
      final lon = Longitude(180.0, 180.0, VargaType.rashi, defaultConfig);
      expect(lon.nakshatra, 14);
    });

    test('ayanamsa offset shifts nakshatra (regression for #6)', () {
      // 24deg tropical, with a 24deg ayanamsa, lands at sidereal 0deg = Ashvini.
      final tropical =
          Longitude(24.0, 24.0, VargaType.rashi, defaultConfig);
      expect(tropical.nakshatra, 2,
          reason: 'tropical 24° is in Bharani (nakshatra 2)');

      final sidereal = Longitude(
        24.0,
        24.0,
        VargaType.rashi,
        defaultConfig,
        nakAyanamsaValue: 24.0,
      );
      expect(sidereal.nakshatra, 1,
          reason: 'with 24° ayanamsa, sidereal 0° is Ashvini (nakshatra 1)');
    });

    test('ayanamsa offset wraps below zero', () {
      // 5deg tropical with 24deg ayanamsa: sidereal 341deg → Uttara Bhadrapada.
      final lon = Longitude(
        5.0,
        5.0,
        VargaType.rashi,
        defaultConfig,
        nakAyanamsaValue: 24.0,
      );
      expect(lon.nakshatra, 26);
    });
  });

  group('Pada', () {
    test('0deg = pada 1', () {
      final lon = Longitude(0.0, 0.0, VargaType.rashi, defaultConfig);
      expect(lon.pada, 1);
    });

    test('ayanamsa offset shifts pada', () {
      // 27deg tropical, 24deg ayanamsa → sidereal 3deg → Ashvini pada 1.
      final lon = Longitude(
        27.0,
        27.0,
        VargaType.rashi,
        defaultConfig,
        nakAyanamsaValue: 24.0,
      );
      expect(lon.nakshatra, 1);
      expect(lon.pada, 1);
    });
  });
}
