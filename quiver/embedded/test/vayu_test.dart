import 'package:quiver_embedded/quiver_embedded.dart';
import 'package:test/test.dart';

void main() {
  late Vayu vayu;

  // New Delhi, 2000-01-01 12:00 UTC.
  final testDate = DateTime.utc(2000, 1, 1, 12, 0, 0);
  final testLocation = Location(latitude: 28.6139, longitude: 77.2090);
  const testPreset = CalculationPreset.ADITYA_PRESET;

  setUpAll(() {
    vayu = Vayu();
  });

  tearDownAll(() {
    vayu.dispose();
  });

  group('calculateChart', () {
    test('returns a Chart with grahas for a known date/location', () {
      final chart = vayu.calculateChart(testDate, testLocation, testPreset);

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
        testPreset,
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
        testPreset,
      );

      final config1 = RequestMapper.resolvePreset(testPreset).calcConfig;
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

  group('preset resolution', () {
    test('different presets produce different chart configs', () {
      final aditya = vayu.calculateChart(
        testDate,
        testLocation,
        CalculationPreset.ADITYA_PRESET,
      );
      final western = vayu.calculateChart(
        testDate,
        testLocation,
        CalculationPreset.WESTERN_PRESET,
      );

      expect(aditya.config.circle, isNot(western.config.circle));
    });
  });

  group('dispose', () {
    test('prevents subsequent calls with StateError', () {
      final disposable = Vayu();
      disposable.dispose();

      expect(
        () => disposable.calculateChart(testDate, testLocation, testPreset),
        throwsStateError,
      );
      expect(
        () => disposable.calculateSnapshot(testDate, testLocation, testPreset),
        throwsStateError,
      );
      expect(
        () => disposable.recalculate(
          vayu.calculateSnapshot(testDate, testLocation, testPreset),
          RequestMapper.resolvePreset(testPreset).calcConfig,
        ),
        throwsStateError,
      );
    });
  });
}
