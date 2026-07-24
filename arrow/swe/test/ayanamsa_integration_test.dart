// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

@Tags(['integration'])
library;

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph_rs/swisseph_rs.dart' as swe;
import 'package:test/test.dart';

import 'helpers/find_ephe_path.dart';

void main() {
  final ephePath = findEphePath();
  final skipReason = ephePath == null
      ? 'no ephe path found; set ARROW_EPHE_PATH'
      : null;

  group('SweFacade.getAyanamsa', skip: skipReason, () {
    const jdUt = 2451545.0; // J2000
    const jdEt = 2451545.0;

    late SweFacade facade;

    setUp(() {
      facade = SweFacade.create(ephePath: ephePath);
    });

    tearDown(() {
      facade.dispose();
    });

    test('tropical returns 0.0', () {
      expect(facade.getAyanamsa(jdEt, Ayanamsa.tropical), equals(0.0));
      expect(facade.getAyanamsaUt(jdUt, Ayanamsa.tropical), equals(0.0));
    });

    test('Lahiri at J2000 matches raw Ephemeris call', () {
      final raw = swe.Ephemeris(
        swe.EphemerisConfig(
          ephemerisSource: swe.EphemerisSource.swiss,
          ephePath: ephePath,
          siderealMode: swe.SiderealMode.lahiri,
        ),
      );
      final expected = raw
          .getAyanamsaEx(swe.JdTt(jdEt), swe.CalcFlags.none)
          .ayanamsa;
      raw.close();
      expect(
        facade.getAyanamsa(jdEt, Ayanamsa.lahiri),
        closeTo(expected, 1e-9),
      );
    });

    test('UT and ET variants differ by ~delta-T worth of precession', () {
      final ut = facade.getAyanamsaUt(jdUt, Ayanamsa.lahiri);
      final et = facade.getAyanamsa(jdEt, Ayanamsa.lahiri);
      expect(et, closeTo(ut, 0.001));
    });

    test('Dhruva returns the equatorial Ashvini-start offset', () {
      final a = facade.getAyanamsaUt(jdUt, Ayanamsa.dhruva);
      expect(a, inInclusiveRange(0.0, 360.0));

      // Same offset calcDhruvaLongitude subtracts: the Sun's equatorial
      // longitude minus its dhruva longitude is exactly the Ashvini start.
      final dhruvaLon = facade.calcDhruvaLongitude(jdUt, 0); // SE_SUN
      final raw = swe.Ephemeris(
        swe.EphemerisConfig(
          ephemerisSource: swe.EphemerisSource.swiss,
          ephePath: ephePath,
        ),
      );
      final sunEqu = raw
          .calcUt(swe.JdUt1(jdUt), swe.Body.sun, swe.CalcFlags.equatorial)
          .longitude;
      raw.close();

      expect((sunEqu - dhruvaLon + 360.0) % 360.0, closeTo(a, 1e-9));
    });

    test('Dhruva is rejected by the ephemeris-time variant', () {
      expect(
        () => facade.getAyanamsa(jdEt, Ayanamsa.dhruva),
        throwsArgumentError,
      );
    });

    test('custom non-standard ayanamsas throw', () {
      for (final a in [
        Ayanamsa.trueSidereal,
        Ayanamsa.eclipticVedangaJyotisha,
        Ayanamsa.equal28Nakshatras,
      ]) {
        expect(() => facade.getAyanamsaUt(jdUt, a), throwsArgumentError);
        expect(() => facade.getAyanamsa(jdEt, a), throwsArgumentError);
      }
    });

    test('switching between ayanamsas is stateless from caller view', () {
      final lahiri = facade.getAyanamsa(jdEt, Ayanamsa.lahiri);
      final fagan = facade.getAyanamsa(jdEt, Ayanamsa.fagan);
      final lahiriAgain = facade.getAyanamsa(jdEt, Ayanamsa.lahiri);
      expect(lahiriAgain, closeTo(lahiri, 1e-9));
      expect(fagan, isNot(closeTo(lahiri, 0.01)));
    });
  });
}
