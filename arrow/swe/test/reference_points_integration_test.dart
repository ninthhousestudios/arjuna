// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

@Tags(['integration'])
library;

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

import 'helpers/find_ephe_path.dart';

void main() {
  final ephePath = findEphePath();
  final skipReason = ephePath == null
      ? 'no ephe path found; set ARROW_EPHE_PATH'
      : null;

  group('reference points — integration', skip: skipReason, () {
    // JD 2026-04-14 12:00 UTC per docs/reference-points.md §Verified numbers.
    const jdUt = 2461145.0;
    const location = Location(latitude: 0.0, longitude: 0.0, altitude: 0.0);

    late SweFacade facade;

    setUp(() {
      facade = SweFacade.create(ephePath: ephePath);
    });

    tearDown(() {
      facade.dispose();
    });

    test('barycentric Sun matches verified values (SwissEph, tropical)', () {
      const sweConfig = SweConfig(
        bodies: {Body.sun},
        signAyanamsa: Ayanamsa.tropical,
        ephemerisSource: EphemerisSource.swissEph,
        extraFrames: {ReferencePoint.barycentric},
      );

      final snap = facade.calcAll(jdUt, location, sweConfig);
      final bary = snap.bodiesEclipticBarycentric;
      expect(bary, isNotNull);
      final sun = bary![Body.sun]!;

      // Verified numbers: bary Sun ~247.21°, distance ~0.00594 AU.
      expect(sun.longitude, closeTo(247.21, 0.05));
      expect(sun.distance, lessThan(0.01));
      expect(sun.distance, greaterThan(0.001));

      // Geocentric ≠ barycentric.
      final geoSun = snap.bodiesEcliptic[Body.sun]!;
      expect((sun.longitude - geoSun.longitude).abs(), greaterThan(1.0));
      expect(geoSun.longitude, closeTo(24.55, 0.05));
    });

    test('Moshier + barycentric throws ArgumentError naming both', () {
      const sweConfig = SweConfig(
        bodies: {Body.sun},
        ephemerisSource: EphemerisSource.moshier,
        extraFrames: {ReferencePoint.barycentric},
      );

      expect(
        () => facade.calcAll(jdUt, location, sweConfig),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString().toLowerCase(),
            'message',
            allOf(contains('barycentric'), contains('moshier')),
          ),
        ),
      );
    });

    test('heliocentric omits Sun (always at origin)', () {
      const sweConfig = SweConfig(
        bodies: {Body.sun, Body.mars, Body.jupiter},
        ephemerisSource: EphemerisSource.swissEph,
        extraFrames: {ReferencePoint.heliocentric},
      );

      final snap = facade.calcAll(jdUt, location, sweConfig);
      final helio = snap.bodiesEclipticHeliocentric;
      expect(helio, isNotNull);
      expect(helio!.containsKey(Body.sun), isFalse);
      expect(helio.containsKey(Body.mars), isTrue);
      expect(helio.containsKey(Body.jupiter), isTrue);
    });

    test('ayanamsa applies identically to geo and bary frames', () {
      const tropCfg = SweConfig(
        bodies: {Body.sun},
        signAyanamsa: Ayanamsa.tropical,
        ephemerisSource: EphemerisSource.swissEph,
        extraFrames: {ReferencePoint.barycentric},
      );
      const sidCfg = SweConfig(
        bodies: {Body.sun},
        signAyanamsa: Ayanamsa.lahiri,
        ephemerisSource: EphemerisSource.swissEph,
        extraFrames: {ReferencePoint.barycentric},
      );

      final trop = facade.calcAll(jdUt, location, tropCfg);
      final sid = facade.calcAll(jdUt, location, sidCfg);

      double wrap(double x) => ((x % 360) + 360) % 360;

      final geoDelta = wrap(
        trop.bodiesEcliptic[Body.sun]!.longitude -
            sid.bodiesEcliptic[Body.sun]!.longitude,
      );
      final baryDelta = wrap(
        trop.bodiesEclipticBarycentric![Body.sun]!.longitude -
            sid.bodiesEclipticBarycentric![Body.sun]!.longitude,
      );

      expect(baryDelta, closeTo(geoDelta, 1e-6));
    });

    test('Ketu mirrors Rahu in every frame', () {
      const sweConfig = SweConfig(
        bodies: {Body.rahu, Body.ketu},
        ephemerisSource: EphemerisSource.swissEph,
        extraFrames: {ReferencePoint.barycentric, ReferencePoint.heliocentric},
      );

      final snap = facade.calcAll(jdUt, location, sweConfig);

      double wrap(double x) => ((x % 360) + 360) % 360;

      final rahuBary = snap.bodiesEclipticBarycentric![Body.rahu]!;
      final ketuBary = snap.bodiesEclipticBarycentric![Body.ketu]!;
      expect(
        ketuBary.longitude,
        closeTo(wrap(rahuBary.longitude + 180.0), 1e-9),
      );
      expect(ketuBary.latitude, closeTo(-rahuBary.latitude, 1e-9));

      final rahuHelio = snap.bodiesEclipticHeliocentric![Body.rahu]!;
      final ketuHelio = snap.bodiesEclipticHeliocentric![Body.ketu]!;
      expect(
        ketuHelio.longitude,
        closeTo(wrap(rahuHelio.longitude + 180.0), 1e-9),
      );
    });

    test('default config leaves extra-frame maps null', () {
      const sweConfig = SweConfig(
        bodies: {Body.sun},
        ephemerisSource: EphemerisSource.swissEph,
      );

      final snap = facade.calcAll(jdUt, location, sweConfig);
      expect(snap.bodiesEclipticBarycentric, isNull);
      expect(snap.bodiesEclipticHeliocentric, isNull);
    });
  });
}
