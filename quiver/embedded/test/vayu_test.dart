import 'package:arrow_options/arrow_options.dart';
import 'package:quiver_embedded/quiver_embedded.dart';
import 'package:test/test.dart';

void main() {
  late Vayu vayu;

  // New Delhi, 2000-01-01 12:00 UTC.
  final testDate = DateTime.utc(2000, 1, 1, 12, 0, 0);
  final testLocation = Location(latitude: 28.6139, longitude: 77.2090);
  final testOptions = ArrowPresets.aditya;

  setUpAll(() {
    vayu = Vayu();
  });

  tearDownAll(() {
    vayu.dispose();
  });

  group('calculateChart', () {
    test('returns a Chart with grahas for a known date/location', () {
      final chart = vayu.calculateChart(testDate, testLocation, testOptions);

      // Chart should have a rashi with planets populated.
      expect(chart.rashi, isNotNull);
      // Sun should exist and have a sign.
      expect(chart.sun, isNotNull);
      expect(chart.sun.sign, isNotNull);
    });
  });

  group('calculateSnapshot', () {
    test('returns an EphSnapshot', () {
      final snapshot = vayu.calculateSnapshot(
        testDate,
        testLocation,
        testOptions,
      );
      expect(snapshot.jdUt, closeTo(2451545.0, 0.01));
      expect(snapshot.bodiesEcliptic, isNotEmpty);
    });
  });

  group('recalculate', () {
    test('reuses the same snapshot with a different CalcConfig', () {
      final snapshot = vayu.calculateSnapshot(
        testDate,
        testLocation,
        testOptions,
      );

      final config1 = testOptions.calcConfig;
      final config2 = config1.copyWith(circle: Circle.zodiac);

      final chart1 = vayu.recalculate(snapshot, config1);
      final chart2 = vayu.recalculate(snapshot, config2);

      // Both charts derive from the same snapshot.
      expect(chart1.snapshot, same(snapshot));
      expect(chart2.snapshot, same(snapshot));

      // Config objects differ.
      expect(chart2.config.circle, Circle.zodiac);
    });
  });

  group('dispose', () {
    test('prevents subsequent calls with StateError', () {
      final disposable = Vayu();
      disposable.dispose();

      expect(
        () => disposable.calculateChart(testDate, testLocation, testOptions),
        throwsStateError,
      );
      expect(
        () => disposable.calculateSnapshot(testDate, testLocation, testOptions),
        throwsStateError,
      );
      expect(
        () => disposable.recalculate(
          vayu.calculateSnapshot(testDate, testLocation, testOptions),
          testOptions.calcConfig,
        ),
        throwsStateError,
      );
    });
  });
}
