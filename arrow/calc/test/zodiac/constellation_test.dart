import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('constellationStarMap', () {
    test('has exactly 13 entries', () {
      expect(constellationStarMap, hasLength(13));
    });

    test('every ConstellationId is present', () {
      for (final id in ConstellationId.values) {
        expect(constellationStarMap.containsKey(id), isTrue,
            reason: '${id.label} missing from star map');
      }
    });

    test('all boundary stars are distinct', () {
      final all = constellationStarMap.values
          .expand((e) => [e.first, e.last])
          .toList();
      final unique = all.toSet();
      expect(unique.length, all.length,
          reason: 'duplicate boundary star found');
    });
  });

  group('boundaryStars', () {
    test('contains all first and last stars', () {
      for (final entry in constellationStarMap.values) {
        expect(boundaryStars, contains(entry.first));
        expect(boundaryStars, contains(entry.last));
      }
    });
  });

  group('Constellation', () {
    test('length is end - beginning mod 360', () {
      final c = Constellation(
        id: ConstellationId.aries,
        firstStar: Star.mesarthim,
        lastStar: Star.botein,
        beginning: 10.0,
        end: 40.0,
      );
      expect(c.length, closeTo(30.0, 0.001));
    });

    test('length wraps around 360°', () {
      final c = Constellation(
        id: ConstellationId.pisces,
        firstStar: Star.gammaPiscium,
        lastStar: Star.alrescha,
        beginning: 350.0,
        end: 10.0,
      );
      expect(c.length, closeTo(20.0, 0.001));
    });

    test('contains checks non-wrapping range', () {
      final c = Constellation(
        id: ConstellationId.leo,
        firstStar: Star.kappaLeonis,
        lastStar: Star.denebola,
        beginning: 120.0,
        end: 150.0,
      );
      expect(c.contains(130.0), isTrue);
      expect(c.contains(110.0), isFalse);
      expect(c.contains(150.0), isFalse);
    });

    test('contains checks wrapping range', () {
      final c = Constellation(
        id: ConstellationId.pisces,
        firstStar: Star.gammaPiscium,
        lastStar: Star.alrescha,
        beginning: 350.0,
        end: 10.0,
      );
      expect(c.contains(355.0), isTrue);
      expect(c.contains(5.0), isTrue);
      expect(c.contains(340.0), isFalse);
      expect(c.contains(15.0), isFalse);
    });
  });
}
