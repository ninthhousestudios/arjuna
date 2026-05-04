@Tags(['integration'])
library;

import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph/swisseph.dart';
import 'package:test/test.dart';

import 'helpers/find_ephe_path.dart';

void main() {
  final ephePath = findEphePath();
  final skipReason =
      ephePath == null ? 'no ephe path found; set ARROW_EPHE_PATH' : null;

  group('Ecliptic13 with real star positions', skip: skipReason, () {
    const jdUt = 2451545.0; // J2000
    const loc = Location(latitude: 28.6139, longitude: 77.2090, altitude: 0);

    late SwissEph swe;
    late SweFacade facade;
    late EphSnapshot snap;
    late Ecliptic13 ecliptic;

    setUpAll(() {
      swe = SwissEph.find();
      facade = SweFacade(swe, ephePath: ephePath);

      final testStars = {
        ...boundaryStars,
        Star.aldebaran,
        Star.antares,
        Star.regulus,
      };
      final sweConfig = SweConfig(
        bodies: {},
        stars: testStars,
      );
      snap = facade.calcAll(jdUt, loc, sweConfig);

      ecliptic = buildEcliptic13(snap);
    });

    tearDownAll(() {
      swe.close();
    });

    test('has exactly 13 constellations', () {
      expect(ecliptic.constellations, hasLength(13));
    });

    test('constellation lengths sum to 360°', () {
      final sum = ecliptic.constellations.fold(0.0, (s, c) => s + c.length);
      expect(sum, closeTo(360.0, 0.01));
    });

    test('Aldebaran falls in Taurus', () {
      final aldebLon = snap.stars[Star.aldebaran]!.ecliptic.longitude;
      final result = ecliptic.constellationAt(aldebLon);
      expect(result.id, ConstellationId.taurus);
    });

    test('Antares falls in Scorpio', () {
      final lon = snap.stars[Star.antares]!.ecliptic.longitude;
      final result = ecliptic.constellationAt(lon);
      expect(result.id, ConstellationId.scorpio);
    });

    test('Regulus falls in Leo', () {
      final lon = snap.stars[Star.regulus]!.ecliptic.longitude;
      final result = ecliptic.constellationAt(lon);
      expect(result.id, ConstellationId.leo);
    });

    test('all constellations have positive length', () {
      for (final c in ecliptic.constellations) {
        expect(c.length, greaterThan(0),
            reason: '${c.id.label} has non-positive length');
      }
    });

    test('Sun on 2000-01-01 placed in Sagittarius (true sidereal)', () {
      final sunSweConfig = SweConfig(
        bodies: {Body.sun},
        stars: boundaryStars,
      );
      final sunSnap = facade.calcAll(jdUt, loc, sunSweConfig);

      final sunLon = sunSnap.bodiesEcliptic[Body.sun]!.longitude;
      final e13 = buildEcliptic13(sunSnap);
      final result = e13.constellationAt(sunLon);
      expect(result.id, ConstellationId.sagittarius);
    });
  });
}
