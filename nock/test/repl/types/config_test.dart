import 'package:arrow_options/arrow_options.dart';
import 'package:nock/src/repl/error.dart';
import 'package:nock/src/repl/types/config.dart';
import 'package:nock/src/repl/types/value.dart';
import 'package:test/test.dart';

void main() {
  group('NockConfig', () {
    test('default values', () {
      final cfg = NockConfig();
      expect(cfg.ayanamsa, 'tropical');
      expect(cfg.houses, 'campanus');
      expect(cfg.circle, 'aditya');
      expect(cfg.node, 'true');
    });

    test('display shows key-value table', () {
      final cfg = NockConfig();
      final d = cfg.display();
      expect(d, contains('ayanamsa : tropical'));
      expect(d, contains('houses   : campanus'));
      expect(d, contains('circle   : aditya'));
      expect(d, contains('node     : true'));
    });

    test('access returns string values', () {
      final cfg = NockConfig(ayanamsa: 'lahiri');
      final v = cfg.access('ayanamsa');
      expect(v, isA<NockString>());
      expect((v as NockString).value, 'lahiri');
    });

    test('access unknown field throws', () {
      expect(
        () => NockConfig().access('foo'),
        throwsA(isA<NockError>()),
      );
    });

    test('unknown ayanamsa throws', () {
      expect(
        () => NockConfig(ayanamsa: 'garbage'),
        throwsA(isA<NockError>()),
      );
    });

    test('unknown house system throws', () {
      expect(
        () => NockConfig(houses: 'garbage'),
        throwsA(isA<NockError>()),
      );
    });

    test('unknown circle throws', () {
      expect(
        () => NockConfig(circle: 'garbage'),
        throwsA(isA<NockError>()),
      );
    });

    test('unknown node type throws', () {
      expect(
        () => NockConfig(node: 'garbage'),
        throwsA(isA<NockError>()),
      );
    });

    test('toArrowOptions produces correct SweConfig', () {
      final cfg = NockConfig(
        ayanamsa: 'lahiri',
        houses: 'wholeSigns',
        node: 'mean',
      );
      final opts = cfg.toArrowOptions();
      expect(opts.sweConfig.signAyanamsa, Ayanamsa.lahiri);
      expect(opts.sweConfig.houseSystem, HouseSystem.wholeSigns);
      expect(opts.sweConfig.trueNode, false);
    });

    test('toArrowOptions produces correct CalcConfig', () {
      final cfg = NockConfig(circle: 'zodiac');
      final opts = cfg.toArrowOptions();
      expect(opts.calcConfig.circle, Circle.zodiac);
    });

    test('valid ayanamsa names accepted', () {
      for (final name in ['tropical', 'lahiri', 'raman', 'dhruva', 'fagan']) {
        expect(() => NockConfig(ayanamsa: name), returnsNormally);
      }
    });

    test('valid house system names accepted', () {
      for (final name in ['placidus', 'wholeSigns', 'campanus', 'koch']) {
        expect(() => NockConfig(houses: name), returnsNormally);
      }
    });
  });
}
