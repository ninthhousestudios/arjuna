import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('Ecliptic13', () {
    late Ecliptic13 ecliptic;
    late Map<Star, double> longitudes;

    setUp(() {
      // Synthetic boundary star longitudes spaced ~27.7° apart.
      // First stars get even spacing; last stars sit 20° after first.
      longitudes = {};
      final ordered = ConstellationId.values;
      for (int i = 0; i < ordered.length; i++) {
        final entry = constellationStarMap[ordered[i]]!;
        final baseLon = (i * 27.692) % 360;
        longitudes[entry.first] = baseLon;
        longitudes[entry.last] = (baseLon + 20.0) % 360;
      }

      ecliptic = Ecliptic13.build(starLongitudes: longitudes);
    });

    test('has exactly 13 constellations', () {
      expect(ecliptic.constellations, hasLength(13));
    });

    test('constellation lengths sum to 360°', () {
      final sum =
          ecliptic.constellations.fold(0.0, (s, c) => s + c.length);
      expect(sum, closeTo(360.0, 0.01));
    });

    test('every ConstellationId accessible via []', () {
      for (final id in ConstellationId.values) {
        expect(ecliptic[id].id, id);
      }
    });

    test('constellationAt finds correct constellation', () {
      for (final c in ecliptic.constellations) {
        // A point in the middle of each constellation should resolve to it.
        final mid = (c.beginning + c.length / 2) % 360;
        final found = ecliptic.constellationAt(mid);
        expect(found.id, c.id,
            reason: '${mid.toStringAsFixed(1)}° should be in ${c.id.label}');
      }
    });

    test('longitudeToConstellation returns degrees and percentage', () {
      final first = ecliptic.constellations.first;
      final testLon = (first.beginning + 5.0) % 360;
      final result = ecliptic.longitudeToConstellation(testLon);

      expect(result.constellation.id, first.id);
      expect(result.degreesInto, closeTo(5.0, 0.01));
      expect(result.percent, greaterThan(0));
      expect(result.percent, lessThan(100));
    });

    test('missing boundary star throws StateError', () {
      final incomplete = Map<Star, double>.from(longitudes);
      incomplete.remove(incomplete.keys.first);

      expect(
        () => Ecliptic13.build(starLongitudes: incomplete),
        throwsStateError,
      );
    });
  });
}
