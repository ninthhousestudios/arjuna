import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('Nature.of — fixed bodies', () {
    const expected = <Body, Nature>{
      Body.sun: Nature.malefic,
      Body.mars: Nature.malefic,
      Body.saturn: Nature.malefic,
      Body.rahu: Nature.malefic,
      Body.ketu: Nature.malefic,
      Body.mercury: Nature.benefic,
      Body.jupiter: Nature.benefic,
      Body.venus: Nature.benefic,
      Body.uranus: Nature.neutral,
      Body.neptune: Nature.neutral,
      Body.pluto: Nature.neutral,
      Body.chiron: Nature.neutral,
    };

    test('covers every Body enum value except Moon (detects new additions)',
        () {
      final fixedBodies = {...expected.keys, Body.moon};
      expect(fixedBodies, equals(Body.values.toSet()));
    });

    for (final entry in expected.entries) {
      test('${entry.key.name} → ${entry.value.name}', () {
        expect(Nature.of(entry.key), equals(entry.value));
      });
    }
  });

  group('Nature.of — Moon (contextual)', () {
    test('requires sun + moon longitudes', () {
      expect(() => Nature.of(Body.moon), throwsArgumentError);
      expect(() => Nature.of(Body.moon, sunLongitude: 10.0),
          throwsArgumentError);
    });

    test('Shukla paksha (waxing, 0..180°) → benefic', () {
      expect(
          Nature.of(Body.moon, sunLongitude: 0.0, moonLongitude: 5.0),
          Nature.benefic);
      expect(
          Nature.of(Body.moon, sunLongitude: 0.0, moonLongitude: 180.0),
          Nature.benefic);
      expect(
          Nature.of(Body.moon, sunLongitude: 350.0, moonLongitude: 10.0),
          Nature.benefic);
    });

    test('Krishna paksha (waning, 180..360°) → malefic', () {
      expect(
          Nature.of(Body.moon, sunLongitude: 0.0, moonLongitude: 200.0),
          Nature.malefic);
      expect(
          Nature.of(Body.moon, sunLongitude: 0.0, moonLongitude: 350.0),
          Nature.malefic);
      expect(
          Nature.of(Body.moon, sunLongitude: 10.0, moonLongitude: 355.0),
          Nature.malefic);
    });

    test('Nature.ofMoon direct API mirrors Nature.of', () {
      expect(Nature.ofMoon(sunLongitude: 0.0, moonLongitude: 90.0),
          Nature.benefic);
      expect(Nature.ofMoon(sunLongitude: 0.0, moonLongitude: 270.0),
          Nature.malefic);
    });
  });
}
