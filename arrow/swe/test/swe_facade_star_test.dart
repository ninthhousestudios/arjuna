@Tags(['integration'])
library;

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph/swisseph.dart';
import 'package:test/test.dart';

import 'helpers/find_ephe_path.dart';

void main() {
  final ephePath = findEphePath();
  final skipReason =
      ephePath == null ? 'no ephe path found; set ARROW_EPHE_PATH' : null;

  group('SweFacade fixed stars', skip: skipReason, () {
    const jdUt = 2451545.0; // J2000

    late SwissEph swe;
    late SweFacade facade;

    setUp(() {
      swe = SwissEph.find();
      facade = SweFacade(swe, ephePath: ephePath);
    });

    tearDown(() {
      swe.close();
    });

    test('empty stars set produces empty star maps', () {
      const sweConfig = SweConfig();
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);
      expect(snap.starsEcliptic, isEmpty);
      expect(snap.starsEquatorial, isEmpty);
    });

    test('Aldebaran ecliptic longitude near 69° at J2000 (tropical)', () {
      final sweConfig = SweConfig(stars: {Star.aldebaran});
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);

      expect(snap.starsEcliptic, contains(Star.aldebaran));
      expect(snap.starsEquatorial, contains(Star.aldebaran));

      final eclPos = snap.starsEcliptic[Star.aldebaran]!;
      // Aldebaran tropical ecliptic longitude is ~69.8° at J2000.
      expect(eclPos.longitude, closeTo(69.8, 0.5));
      expect(eclPos.latitude, closeTo(-5.47, 0.2));
    });

    test('multiple stars are all populated', () {
      final sweConfig = SweConfig(stars: {
        Star.aldebaran,
        Star.spica,
        Star.regulus,
      });
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);

      expect(snap.starsEcliptic, hasLength(3));
      expect(snap.starsEquatorial, hasLength(3));

      for (final s in [Star.aldebaran, Star.spica, Star.regulus]) {
        expect(snap.starsEcliptic.containsKey(s), isTrue,
            reason: '${s.label} missing from ecliptic');
        expect(snap.starsEquatorial.containsKey(s), isTrue,
            reason: '${s.label} missing from equatorial');
      }
    });

    test('Galactic Center is computable', () {
      final sweConfig = SweConfig(stars: {Star.galacticCenter});
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);
      expect(snap.starsEcliptic, contains(Star.galacticCenter));
      // GC tropical longitude is ~266° at J2000.
      final gcLon = snap.starsEcliptic[Star.galacticCenter]!.longitude;
      expect(gcLon, closeTo(266.6, 1.0));
    });

    test('Spica ecliptic longitude near 203° at J2000 (tropical)', () {
      final sweConfig = SweConfig(stars: {Star.spica});
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);
      final eclPos = snap.starsEcliptic[Star.spica]!;
      // Spica tropical ecliptic longitude ~203.8° at J2000.
      expect(eclPos.longitude, closeTo(203.8, 0.5));
    });

    test('star positions unaffected by empty body set', () {
      final sweConfig = SweConfig(
        bodies: {},
        stars: {Star.sirius},
      );
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);
      expect(snap.bodiesEcliptic, isEmpty);
      expect(snap.starsEcliptic, hasLength(1));
      expect(snap.starsEcliptic, contains(Star.sirius));
    });
  });

  group('SweFacade custom star names', skip: skipReason, () {
    const jdUt = 2451545.0;

    late SwissEph swe;
    late SweFacade facade;

    setUp(() {
      swe = SwissEph.find();
      facade = SweFacade(swe, ephePath: ephePath);
    });

    tearDown(() {
      swe.close();
    });

    test('exact custom name resolves', () {
      final sweConfig = SweConfig(
        bodies: {},
        customStarNames: {'Sirius'},
      );
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);
      expect(snap.customStarsEcliptic, contains('Sirius'));
      expect(snap.customStarsEquatorial, contains('Sirius'));
    });

    test('wildcard fallback resolves partial name', () {
      final sweConfig = SweConfig(
        bodies: {},
        customStarNames: {',alfCMa'},
      );
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);
      expect(snap.customStarsEcliptic, contains(',alfCMa'));
    });

    test('invalid custom name is omitted without exception', () {
      final sweConfig = SweConfig(
        bodies: {},
        customStarNames: {'xyz_not_a_star'},
      );
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);
      expect(snap.customStarsEcliptic, isEmpty);
      expect(snap.customStarsEquatorial, isEmpty);
    });

    test('empty customStarNames produces empty maps', () {
      const sweConfig = SweConfig();
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);
      expect(snap.customStarsEcliptic, isEmpty);
      expect(snap.customStarsEquatorial, isEmpty);
    });
  });

  group('SweFacade star data', skip: skipReason, () {
    const jdUt = 2451545.0;

    late SwissEph swe;
    late SweFacade facade;

    setUp(() {
      swe = SwissEph.find();
      facade = SweFacade(swe, ephePath: ephePath);
    });

    tearDown(() {
      swe.close();
    });

    test('includeStarData=false produces empty starData', () {
      final sweConfig = SweConfig(
        stars: {Star.aldebaran},
      );
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig);
      expect(snap.starsEcliptic, contains(Star.aldebaran));
      expect(snap.starData, isEmpty);
    });

    test('includeStarData=true populates magnitude and rise/set', () {
      final sweConfig = SweConfig(
        bodies: {},
        stars: {Star.aldebaran, Star.sirius},
      );
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig,
          includeStarData: true);

      expect(snap.starData, hasLength(2));

      final aldeb = snap.starData[Star.aldebaran]!;
      expect(aldeb.apparentMagnitude, isNotNull);
      expect(aldeb.apparentMagnitude!, closeTo(0.87, 0.1));
      expect(aldeb.riseJd, isNotNull);
      expect(aldeb.setJd, isNotNull);
      expect(aldeb.riseJd!, greaterThan(jdUt));
      expect(aldeb.setJd!, greaterThan(jdUt));

      final sirius = snap.starData[Star.sirius]!;
      expect(sirius.apparentMagnitude, isNotNull);
      expect(sirius.apparentMagnitude!, closeTo(-1.46, 0.1));
      expect(sirius.riseJd, isNotNull);
      expect(sirius.setJd, isNotNull);
    });

    test('custom star data populated when includeStarData is true', () {
      final sweConfig = SweConfig(
        bodies: {},
        customStarNames: {'Sirius'},
      );
      final snap = facade.calcAll(jdUt, _testLocation, sweConfig,
          includeStarData: true);
      expect(snap.customStarData, contains('Sirius'));
      expect(snap.customStarData['Sirius']!.apparentMagnitude, isNotNull);
    });
  });
}

const _testLocation = Location(
  latitude: 28.6139,
  longitude: 77.2090,
  altitude: 0.0,
);
