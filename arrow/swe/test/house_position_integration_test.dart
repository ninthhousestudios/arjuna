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

  group('SweFacade.housePosition', skip: skipReason, () {
    // 2000-01-01 12:00 UT, New York — mid-latitude, no polar degeneracy.
    const jdUt = 2451545.0;
    const location = Location(latitude: 40.7128, longitude: -74.0060);
    const tropical = SweConfig(houseSystem: HouseSystem.campanus);
    const sidereal = SweConfig(
      signAyanamsa: Ayanamsa.lahiri,
      houseSystem: HouseSystem.campanus,
    );

    late SweFacade facade;

    setUp(() {
      facade = SweFacade.create(ephePath: ephePath);
    });

    tearDown(() {
      facade.dispose();
    });

    test('ascendant is house 1.0 and MC is house 10.0 (Campanus)', () {
      final snap = facade.calcAll(jdUt, location, tropical);
      expect(
        facade.housePosition(
          jdUt,
          location,
          tropical,
          longitude: snap.ascmc.ascendant,
        ),
        closeTo(1.0, 1e-4),
      );
      expect(
        facade.housePosition(
          jdUt,
          location,
          tropical,
          longitude: snap.ascmc.mc,
        ),
        closeTo(10.0, 1e-4),
      );
    });

    test('houseSystem override is honoured', () {
      final snap = facade.calcAll(jdUt, location, tropical);
      // Placidus and Campanus share the Ascendant as cusp 1 but split the
      // quadrants differently, so a mid-quadrant point lands elsewhere.
      final mid = (snap.ascmc.ascendant + 45.0) % 360.0;
      final campanus = facade.housePosition(
        jdUt,
        location,
        tropical,
        longitude: mid,
      );
      final placidus = facade.housePosition(
        jdUt,
        location,
        tropical,
        longitude: mid,
        houseSystem: HouseSystem.placidus,
      );
      expect(placidus, isNot(closeTo(campanus, 1e-6)));
    });

    test('sidereal and tropical configs agree for the same physical point', () {
      final snap = facade.calcAll(jdUt, location, tropical);
      final tropLon = snap.bodiesEcliptic[Body.mars]!.longitude;
      final sidLon =
          (tropLon - facade.getAyanamsaUt(jdUt, Ayanamsa.lahiri) + 360.0) %
          360.0;

      final fromTropical = facade.housePosition(
        jdUt,
        location,
        tropical,
        longitude: tropLon,
      );
      final fromSidereal = facade.housePosition(
        jdUt,
        location,
        sidereal,
        longitude: sidLon,
      );
      expect(fromSidereal, closeTo(fromTropical, 1e-9));
    });

    test('matches a raw swisseph_rs housePos call', () {
      final raw = swe.Ephemeris(
        swe.EphemerisConfig(
          ephemerisSource: swe.EphemerisSource.swiss,
          ephePath: ephePath,
        ),
      );
      final jd = swe.JdUt1(jdUt);
      final hsys = swe.HouseSystem.fromCharCode('C'.codeUnitAt(0))!;
      final armc = raw
          .housesEx2(
            jd,
            swe.CalcFlags.none,
            location.latitude,
            location.longitude,
            hsys,
          )
          .ascmc
          .armc;
      final eps = raw
          .calcUt(jd, swe.Body.eclipticNutation, swe.CalcFlags.none)
          .longitude;
      raw.close();

      // Guards the SE_ECL_NUT assumption: component 0 is the true obliquity.
      expect(eps, closeTo(23.44, 0.01));

      const lon = 100.0;
      final expected = swe.housePos(
        armc,
        location.latitude,
        eps,
        hsys,
        lon,
        0.0,
      );
      expect(
        facade.housePosition(jdUt, location, tropical, longitude: lon),
        closeTo(expected, 1e-12),
      );
    });

    test('ecliptic latitude is passed through', () {
      final flat = facade.housePosition(
        jdUt,
        location,
        tropical,
        longitude: 100.0,
      );
      final tilted = facade.housePosition(
        jdUt,
        location,
        tropical,
        longitude: 100.0,
        latitude: 5.0,
      );
      expect(tilted, isNot(closeTo(flat, 1e-6)));
    });

    // swe_house_pos only fails for Sunshine/APC, neither of which Arrow
    // exposes; degenerate geometry still yields a value.
    test('Placidus above the polar circle still yields a position', () {
      const polar = Location(latitude: 78.0, longitude: 15.0);
      const placidus = SweConfig(houseSystem: HouseSystem.placidus);
      expect(
        facade.housePosition(jdUt, polar, placidus, longitude: 100.0),
        inInclusiveRange(1.0, 13.0),
      );
    });

    test('every Arrow house system yields a position', () {
      for (final hsys in HouseSystem.values) {
        expect(
          facade.housePosition(
            jdUt,
            location,
            tropical,
            longitude: 100.0,
            houseSystem: hsys,
          ),
          inInclusiveRange(1.0, 13.0),
          reason: 'house system ${hsys.label}',
        );
      }
    });

    test('non-standard sign ayanamsa throws', () {
      const dhruvaSigns = SweConfig(signAyanamsa: Ayanamsa.dhruva);
      expect(
        () =>
            facade.housePosition(jdUt, location, dhruvaSigns, longitude: 100.0),
        throwsArgumentError,
      );
    });
  });
}
