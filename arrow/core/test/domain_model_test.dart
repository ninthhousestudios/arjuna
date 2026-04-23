import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:test/test.dart';

import 'helpers/stub_snapshot.dart';

void main() {
  final snapshot = stubSnapshot();
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
    test('inherits from Planet', () {
      final graha = Graha(Body.mercury, snapshot, config, VargaType.rashi);
      expect(graha.body, Body.mercury);
      expect(graha.rawLongitude, 55.0);
      final planet = Planet(Body.mercury, snapshot, config, VargaType.rashi);
      expect(graha.sign, planet.sign);
      expect(graha.isRetrograde, planet.isRetrograde);
    });

    test('varga works', () {
      final graha = Graha(Body.jupiter, snapshot, config, VargaType.rashi);
      final nav = graha.varga(VargaType.navamsha);
      expect(nav.vargaType, VargaType.navamsha);
    });
  });

  group('Karaka', () {
    test('extends Graha', () {
      final karaka = Karaka(Body.sun, snapshot, config, VargaType.rashi);
      expect(karaka.body, Body.sun);
      final planet = Planet(Body.sun, snapshot, config, VargaType.rashi);
      expect(karaka.sign, planet.sign);
    });

    test('provides inSignLongitude for sorting', () {
      final karaka = Karaka(Body.sun, snapshot, config, VargaType.rashi);
      // Sun at 45° → inSignLongitude = 45 % 30 = 15.0
      expect(karaka.inSignLongitude, 15.0);
    });

    test('karakas can be sorted by inSignLongitude', () {
      final karakas = Body.karakas
          .map((b) => Karaka(b, snapshot, config, VargaType.rashi))
          .toList();

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
