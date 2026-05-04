import 'dart:convert';

import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('SweConfig', () {
    test('defaults', () {
      const config = SweConfig();
      expect(config.signAyanamsa, Ayanamsa.tropical);
      expect(config.houseSystem, HouseSystem.campanus);
      expect(config.trueNode, isTrue);
      expect(config.topocentric, isFalse);
      expect(config.bodies, contains(Body.sun));
      expect(config.bodies, contains(Body.ketu));
    });

    test('copyWith changes one field', () {
      const config = SweConfig();
      final sidereal = config.copyWith(signAyanamsa: Ayanamsa.lahiri);
      expect(sidereal.signAyanamsa, Ayanamsa.lahiri);
      expect(sidereal.houseSystem, HouseSystem.campanus);
    });
  });

  group('CalcConfig', () {
    test('defaults', () {
      const config = CalcConfig();
      expect(config.circle, Circle.aditya);
      expect(config.nakEquatorial, isTrue);
      expect(config.traditions, contains(Tradition.vedic));
      expect(config.vedic.charaKarakaCount, 7);
    });

    test('copyWith changes circle', () {
      const config = CalcConfig();
      final zodiac = config.copyWith(circle: Circle.zodiac);
      expect(zodiac.circle, Circle.zodiac);
      expect(zodiac.nakEquatorial, isTrue);
    });
  });

  group('VedicConfig', () {
    test('default charaKarakaCount is 7', () {
      const config = VedicConfig();
      expect(config.charaKarakaCount, 7);
    });

    test('can set to 8 karakas', () {
      const config = VedicConfig(charaKarakaCount: 8);
      expect(config.charaKarakaCount, 8);
    });
  });

  group('ArrowOptions', () {
    test('defaults use ernst-like config', () {
      const options = ArrowOptions();
      expect(options.sweConfig.signAyanamsa, Ayanamsa.tropical);
      expect(options.sweConfig.nakAyanamsa, Ayanamsa.dhruva);
      expect(options.calcConfig.circle, Circle.aditya);
    });
  });

  group('Location', () {
    test('altitude defaults to 0', () {
      const loc = Location(latitude: 40.0, longitude: -74.0);
      expect(loc.altitude, 0.0);
    });

    test('copyWith', () {
      const loc = Location(latitude: 40.0, longitude: -74.0);
      final moved = loc.copyWith(latitude: 41.0);
      expect(moved.latitude, 41.0);
      expect(moved.longitude, -74.0);
    });
  });

  group('ArrowPresets', () {
    test('ernst preset', () {
      const ernst = ArrowPresets.ernst;
      expect(ernst.sweConfig.signAyanamsa, Ayanamsa.tropical);
      expect(ernst.sweConfig.nakAyanamsa, Ayanamsa.dhruva);
      expect(ernst.calcConfig.circle, Circle.aditya);
      expect(ernst.calcConfig.nakEquatorial, isTrue);
    });

    test('lahiriVedic preset', () {
      const lv = ArrowPresets.lahiriVedic;
      expect(lv.sweConfig.signAyanamsa, Ayanamsa.lahiri);
      expect(lv.sweConfig.nakAyanamsa, Ayanamsa.lahiri);
      expect(lv.calcConfig.circle, Circle.zodiac);
      expect(lv.calcConfig.nakEquatorial, isFalse);
    });

    test('westernTropical preset', () {
      const wt = ArrowPresets.westernTropical;
      expect(wt.sweConfig.signAyanamsa, Ayanamsa.tropical);
      expect(wt.calcConfig.circle, Circle.zodiac);
      expect(wt.sweConfig.bodies, contains(Body.uranus));
      expect(wt.sweConfig.bodies, contains(Body.pluto));
      expect(wt.calcConfig.traditions, isEmpty);
    });
  });

  group('JSON round-trip', () {
    test('ArrowOptions', () {
      const original = ArrowOptions();
      final jsonString = jsonEncode(original.toJson());
      final restored = ArrowOptions.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
      expect(restored, original);
    });

    test('ArrowPresets.ernst', () {
      const original = ArrowPresets.ernst;
      final jsonString = jsonEncode(original.toJson());
      final restored = ArrowOptions.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
      expect(restored, original);
    });

    test('Location', () {
      const loc = Location(latitude: 40.7128, longitude: -74.006);
      final jsonString = jsonEncode(loc.toJson());
      final restored = Location.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
      expect(restored, loc);
    });

    test('SweConfig', () {
      const config = SweConfig(signAyanamsa: Ayanamsa.lahiri);
      final jsonString = jsonEncode(config.toJson());
      final restored = SweConfig.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
      expect(restored, config);
    });

    test('CalcConfig', () {
      const config = CalcConfig(circle: Circle.zodiac);
      final jsonString = jsonEncode(config.toJson());
      final restored = CalcConfig.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
      expect(restored, config);
    });
  });
}
