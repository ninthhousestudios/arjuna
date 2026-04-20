import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:test/test.dart';

/// Build a minimal EphSnapshot for testing.
EphSnapshot _stubSnapshot() {
  const location = Location(latitude: 40.0, longitude: -74.0);
  const options = ArrowOptions();

  // Sun at 45° ecl (15° Taurus zodiac), Moon at 120° (0° Leo zodiac),
  // Mars at 200° (20° Libra zodiac, retrograde), Rahu at 100°
  final bodies = <Body, BodyPosition>{
    Body.sun: const BodyPosition(
      longitude: 45.0,
      latitude: 0.5,
      distance: 1.0,
      speedLongitude: 0.98,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.moon: const BodyPosition(
      longitude: 120.0,
      latitude: -1.2,
      distance: 0.0025,
      speedLongitude: 13.2,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.mars: const BodyPosition(
      longitude: 200.0,
      latitude: 1.5,
      distance: 1.8,
      speedLongitude: -0.3, // retrograde
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.mercury: const BodyPosition(
      longitude: 55.0,
      latitude: -0.2,
      distance: 0.9,
      speedLongitude: 1.5,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.jupiter: const BodyPosition(
      longitude: 280.0,
      latitude: 0.3,
      distance: 5.2,
      speedLongitude: 0.08,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.venus: const BodyPosition(
      longitude: 30.0,
      latitude: -0.5,
      distance: 0.7,
      speedLongitude: 1.2,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.saturn: const BodyPosition(
      longitude: 310.0,
      latitude: 0.1,
      distance: 9.5,
      speedLongitude: 0.03,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.rahu: const BodyPosition(
      longitude: 100.0,
      latitude: 0.0,
      distance: 0.0,
      speedLongitude: -0.05,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
    Body.ketu: const BodyPosition(
      longitude: 280.0,
      latitude: 0.0,
      distance: 0.0,
      speedLongitude: -0.05,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    ),
  };

  // Use same positions for equatorial (simplified for testing)
  return EphSnapshot(
    jdUt: 2460000.5,
    location: location,
    options: options,
    bodiesEcliptic: bodies,
    bodiesEquatorial: bodies,
    phenoData: const {},
    cusps: List.generate(12, (i) => (i * 30.0 + 10.0) % 360),
    ascmc: const AscMcPoints(
      ascendant: 10.0,
      mc: 280.0,
      armc: 280.0,
      vertex: 190.0,
      equatorialAscendant: 10.0,
      coAscendantKoch: 10.0,
      coAscendantMunkasey: 10.0,
      polarAscendant: 190.0,
    ),
    sunTimes: const SunTimes(sunrise: 2460000.75, sunset: 2460001.25),
    ayanamsaValue: 0.0,
  );
}

void main() {
  final snapshot = _stubSnapshot();
  const config = CalcConfig();

  group('CelestialBody', () {
    test('provides raw longitude from snapshot', () {
      final sun = CelestialBody(Body.sun, snapshot, config, VargaType.rashi);
      expect(sun.rawLongitude, 45.0);
    });

    test('provides sign via Longitude', () {
      final sun = CelestialBody(Body.sun, snapshot, config, VargaType.rashi);
      // 45° with Aditya circle: signIndex = (1+1)%12=2, sign=3
      expect(sun.sign, 3);
    });

    test('varga() returns different varga longitude', () {
      final sun = CelestialBody(Body.sun, snapshot, config, VargaType.rashi);
      final navamshaLon = sun.varga(VargaType.navamsha);
      expect(navamshaLon.vargaType, VargaType.navamsha);
      // Navamsha sign should differ from rashi sign
      expect(navamshaLon.sign, isNot(equals(sun.sign)));
    });
  });

  group('Planet', () {
    test('detects retrograde from negative speed', () {
      final mars = Planet(Body.mars, snapshot, config, VargaType.rashi);
      expect(mars.isRetrograde, isTrue);
    });

    test('detects direct motion', () {
      final sun = Planet(Body.sun, snapshot, config, VargaType.rashi);
      expect(sun.isRetrograde, isFalse);
    });

    test('inherits CelestialBody sign/nakshatra', () {
      final moon = Planet(Body.moon, snapshot, config, VargaType.rashi);
      expect(moon.rawLongitude, 120.0);
      // 120° Aditya: signIndex = (4+1)%12=5, sign=6
      expect(moon.sign, 6);
    });
  });

  group('Graha', () {
    test('delegates to Planet', () {
      final planet = Planet(Body.mercury, snapshot, config, VargaType.rashi);
      final graha = Graha(planet);
      expect(graha.body, Body.mercury);
      expect(graha.rawLongitude, 55.0);
      expect(graha.sign, planet.sign);
      expect(graha.isRetrograde, planet.isRetrograde);
    });

    test('varga delegation works', () {
      final planet = Planet(Body.jupiter, snapshot, config, VargaType.rashi);
      final graha = Graha(planet);
      final nav = graha.varga(VargaType.navamsha);
      expect(nav.vargaType, VargaType.navamsha);
    });
  });

  group('Karaka', () {
    test('extends Graha', () {
      final planet = Planet(Body.sun, snapshot, config, VargaType.rashi);
      final karaka = Karaka(planet);
      expect(karaka.body, Body.sun);
      expect(karaka.sign, planet.sign);
    });

    test('provides inSignLongitude for sorting', () {
      final planet = Planet(Body.sun, snapshot, config, VargaType.rashi);
      final karaka = Karaka(planet);
      // Sun at 45° → inSignLongitude = 45 % 30 = 15.0
      expect(karaka.inSignLongitude, 15.0);
    });

    test('karakas can be sorted by inSignLongitude', () {
      final karakas = Body.karakas.map((b) {
        final planet = Planet(b, snapshot, config, VargaType.rashi);
        return Karaka(planet);
      }).toList();

      karakas.sort(
          (a, b) => b.inSignLongitude.compareTo(a.inSignLongitude));

      // Highest inSignLongitude is Atmakaraka
      expect(karakas.first.inSignLongitude,
          greaterThanOrEqualTo(karakas.last.inSignLongitude));
    });
  });

  group('Cusp', () {
    test('holds house number and longitude', () {
      final cusp = Cusp(1, 10.0, config);
      expect(cusp.house, 1);
      expect(cusp.longitude.eclipticLongitude, 10.0);
    });

    test('sign is derived from longitude', () {
      // 10° with Aditya: signIndex = (0+1)%12=1, sign=2
      final cusp = Cusp(1, 10.0, config);
      expect(cusp.sign, 2);
    });

    test('all 12 cusps from snapshot', () {
      final cusps = List.generate(12, (i) {
        return Cusp(i + 1, snapshot.cusps[i], config);
      });
      expect(cusps, hasLength(12));
      expect(cusps[0].house, 1);
      expect(cusps[11].house, 12);
    });
  });
}
