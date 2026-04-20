import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:test/test.dart';

/// Build a minimal EphSnapshot for testing.
EphSnapshot _stubSnapshot() {
  const location = Location(latitude: 40.0, longitude: -74.0);
  const options = ArrowOptions();

  // Sun at 45° (15° Taurus → sign 3 aditya), Moon at 120° (0° Leo → sign 6),
  // Mars at 200° (20° Libra, retrograde → sign 8), Mercury at 55°,
  // Jupiter at 280°, Venus at 30°, Saturn at 310°,
  // Rahu at 100°, Ketu at 280°
  final bodies = <Body, BodyPosition>{
    Body.sun: const BodyPosition(
      longitude: 45.0, latitude: 0.5, distance: 1.0,
      speedLongitude: 0.98, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.moon: const BodyPosition(
      longitude: 120.0, latitude: -1.2, distance: 0.0025,
      speedLongitude: 13.2, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.mars: const BodyPosition(
      longitude: 200.0, latitude: 1.5, distance: 1.8,
      speedLongitude: -0.3, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.mercury: const BodyPosition(
      longitude: 55.0, latitude: -0.2, distance: 0.9,
      speedLongitude: 1.5, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.jupiter: const BodyPosition(
      longitude: 280.0, latitude: 0.3, distance: 5.2,
      speedLongitude: 0.08, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.venus: const BodyPosition(
      longitude: 30.0, latitude: -0.5, distance: 0.7,
      speedLongitude: 1.2, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.saturn: const BodyPosition(
      longitude: 310.0, latitude: 0.1, distance: 9.5,
      speedLongitude: 0.03, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.rahu: const BodyPosition(
      longitude: 100.0, latitude: 0.0, distance: 0.0,
      speedLongitude: -0.05, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.ketu: const BodyPosition(
      longitude: 280.0, latitude: 0.0, distance: 0.0,
      speedLongitude: -0.05, speedLatitude: 0.0, speedDistance: 0.0,
    ),
  };

  return EphSnapshot(
    jdUt: 2460000.5,
    location: location,
    options: options,
    bodiesEcliptic: bodies,
    bodiesEquatorial: bodies,
    phenoData: const {},
    cusps: List.generate(12, (i) => (i * 30.0 + 10.0) % 360),
    ascmc: const AscMcPoints(
      ascendant: 10.0, mc: 280.0, armc: 280.0, vertex: 190.0,
      equatorialAscendant: 10.0, coAscendantKoch: 10.0,
      coAscendantMunkasey: 10.0, polarAscendant: 190.0,
    ),
    sunTimes: const SunTimes(sunrise: 2460000.75, sunset: 2460001.25),
    ayanamsaValue: 0.0,
  );
}

void main() {
  final snapshot = _stubSnapshot();
  const config = CalcConfig();

  group('Chart', () {
    test('rashi access gives correct sign', () {
      final chart = Chart(snapshot, config);
      // Sun at 45° with aditya: signIndex = (1+1)%12 = 2, sign = 3
      expect(chart.rashi.sun.sign, 3);
    });

    test('sign occupants are correct', () {
      final chart = Chart(snapshot, config);
      // Find which sign Sun is in, check it appears in that sign's planets
      final sunSign = chart.rashi.sun.sign;
      final sign = chart.rashi.signs[sunSign]!;
      expect(sign.planets.any((p) => p.body == Body.sun), isTrue);
    });

    test('signOf returns correct Sign', () {
      final chart = Chart(snapshot, config);
      final marsSign = chart.rashi.signOf(chart.rashi.mars);
      expect(marsSign.number, chart.rashi.mars.sign);
    });

    test('sign has lord, element, quality, gender', () {
      final chart = Chart(snapshot, config);
      final sign1 = chart.rashi.signs[1]!;
      expect(sign1.lord, Body.mars); // Aries
      expect(sign1.element, Element.fire);
      expect(sign1.quality, Quality.cardinal);
      expect(sign1.gender, Gender.male);
    });

    test('nakshatra occupants are correct', () {
      final chart = Chart(snapshot, config);
      final moonNak = chart.rashi.moon.nakshatra;
      final nak = chart.rashi.nakshatras[moonNak]!;
      expect(nak.planets.any((p) => p.body == Body.moon), isTrue);
    });

    test('nakshatraOf returns correct Nakshatra', () {
      final chart = Chart(snapshot, config);
      final moonNak = chart.rashi.nakshatraOf(chart.rashi.moon);
      expect(moonNak.number, chart.rashi.moon.nakshatra);
    });

    test('nakshatra has lord and deity', () {
      final chart = Chart(snapshot, config);
      final nak1 = chart.rashi.nakshatras[1]!;
      expect(nak1.lord, isNotNull);
      expect(nak1.deity, isNotEmpty);
    });

    test('varga access gives different signs', () {
      final chart = Chart(snapshot, config);
      final rashiSign = chart.rashi.sun.sign;
      final navSign = chart.varga(VargaType.navamsha).sun.sign;
      // Navamsha sign should differ from rashi for Sun at 45°
      expect(navSign, isNot(equals(rashiSign)));
    });

    test('varga caching returns same instance', () {
      final chart = Chart(snapshot, config);
      final nav1 = chart.varga(VargaType.navamsha);
      final nav2 = chart.varga(VargaType.navamsha);
      expect(identical(nav1, nav2), isTrue);
    });

    test('rashi is in varga cache', () {
      final chart = Chart(snapshot, config);
      final fromCache = chart.varga(VargaType.rashi);
      expect(identical(fromCache, chart.rashi), isTrue);
    });

    test('all 12 signs exist', () {
      final chart = Chart(snapshot, config);
      for (var s = 1; s <= 12; s++) {
        expect(chart.rashi.signs.containsKey(s), isTrue);
      }
    });

    test('all 27 nakshatras exist', () {
      final chart = Chart(snapshot, config);
      for (var n = 1; n <= 27; n++) {
        expect(chart.rashi.nakshatras.containsKey(n), isTrue);
      }
    });

    test('planet identity is consistent', () {
      final chart = Chart(snapshot, config);
      final sunFromRashi = chart.rashi.sun;
      final sunSign = chart.rashi.signs[sunFromRashi.sign]!;
      final sunFromSign = sunSign.planets.firstWhere((p) => p.body == Body.sun);
      expect(identical(sunFromRashi, sunFromSign), isTrue);
    });

    test('named planet accessors work', () {
      final chart = Chart(snapshot, config);
      expect(chart.rashi.sun.body, Body.sun);
      expect(chart.rashi.moon.body, Body.moon);
      expect(chart.rashi.mars.body, Body.mars);
      expect(chart.rashi.mercury.body, Body.mercury);
      expect(chart.rashi.jupiter.body, Body.jupiter);
      expect(chart.rashi.venus.body, Body.venus);
      expect(chart.rashi.saturn.body, Body.saturn);
      expect(chart.rashi.rahu.body, Body.rahu);
      expect(chart.rashi.ketu.body, Body.ketu);
    });

    test('karakas are accessible from varga', () {
      final chart = Chart(snapshot, config);
      final karakas = chart.rashi.karakas;
      // 7 karaka-eligible bodies (Sun through Saturn, no Rahu/Ketu)
      expect(karakas.length, 7);
    });

    test('retrograde detection through chart', () {
      final chart = Chart(snapshot, config);
      expect(chart.rashi.mars.isRetrograde, isTrue);
      expect(chart.rashi.sun.isRetrograde, isFalse);
    });
  });
}
