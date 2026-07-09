// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

@Tags(['integration'])
library;

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph/swisseph.dart';
import 'package:test/test.dart';

import 'helpers/find_ephe_path.dart';

void main() {
  final ephePath = findEphePath();
  final skipReason = ephePath == null
      ? 'no ephe path found; set ARROW_EPHE_PATH'
      : null;

  group('sidereal nakshatra integration', skip: skipReason, () {
    const jdUt = 2451545.0; // J2000
    const location = Location(latitude: 40.0, longitude: -74.0);

    late SwissEph swe;
    late SweFacade facade;

    setUp(() {
      swe = SwissEph.find();
      facade = SweFacade(swe, ephePath: ephePath);
    });

    tearDown(() {
      swe.close();
    });

    test('nak longitudes match sign longitudes when nak==sign ayanamsa', () {
      const sweConfig = SweConfig(
        signAyanamsa: Ayanamsa.lahiri,
        nakAyanamsa: Ayanamsa.lahiri,
      );
      final snap = facade.calcAll(jdUt, location, sweConfig);

      for (final body in sweConfig.bodies) {
        final eclLon = snap.bodiesEcliptic[body]!.longitude;
        final nakEclLon = snap.bodiesNakEclLon[body]!;
        expect(
          nakEclLon,
          closeTo(eclLon, 1e-6),
          reason: '${body.name} nak ecl lon should match sign ecl lon',
        );
      }
    });

    test('Chart nakshatras consistent with nak longitudes (Lahiri)', () {
      const sweConfig = SweConfig(
        signAyanamsa: Ayanamsa.lahiri,
        nakAyanamsa: Ayanamsa.lahiri,
      );
      final snap = facade.calcAll(jdUt, location, sweConfig);
      const calcConfig = CalcConfig(
        circle: Circle.zodiac,
        nakEquatorial: false,
      );
      final chart = Chart(snap, calcConfig);

      for (final body in sweConfig.bodies) {
        final planet = chart.rashi.planet(body);
        final nakLon = snap.bodiesNakEclLon[body]!;
        final expectedNak = ((nakLon % 360) / (360 / 27)).floor() + 1;
        expect(
          planet.nakshatra,
          expectedNak,
          reason: '${body.name} at ${nakLon.toStringAsFixed(2)}°',
        );
      }
    });

    test('tropical signs + Lahiri nak: difference matches ayanamsa', () {
      const sweConfig = SweConfig(
        signAyanamsa: Ayanamsa.tropical,
        nakAyanamsa: Ayanamsa.lahiri,
      );
      final snap = facade.calcAll(jdUt, location, sweConfig);
      final ayanamsa = facade.getAyanamsaUt(jdUt, Ayanamsa.lahiri);

      for (final body in sweConfig.bodies) {
        final eclLon = snap.bodiesEcliptic[body]!.longitude;
        final nakEclLon = snap.bodiesNakEclLon[body]!;
        final diff = (eclLon - nakEclLon) % 360;
        expect(
          diff,
          closeTo(ayanamsa, 0.01),
          reason: '${body.name} tropical−sidereal diff',
        );
      }
    });

    test('body at sidereal 0° gets nakshatra 1 (Ashvini)', () {
      const config = CalcConfig(circle: Circle.zodiac, nakEquatorial: false);
      // 0.5° nak → Ashvini (span = 360/27 ≈ 13.333°)
      expect(
        Longitude(100.0, VargaType.rashi, config, nakLongitude: 0.5).nakshatra,
        1,
      );
      // 13.0° → still Ashvini
      expect(
        Longitude(100.0, VargaType.rashi, config, nakLongitude: 13.0).nakshatra,
        1,
      );
      // 13.5° → Bharani
      expect(
        Longitude(100.0, VargaType.rashi, config, nakLongitude: 13.5).nakshatra,
        2,
      );
      // 359.9° → Revati
      expect(
        Longitude(
          100.0,
          VargaType.rashi,
          config,
          nakLongitude: 359.9,
        ).nakshatra,
        27,
      );
    });

    test('cusp nak longitudes computed when nak != sign ayanamsa', () {
      const sweConfig = SweConfig(
        signAyanamsa: Ayanamsa.tropical,
        nakAyanamsa: Ayanamsa.lahiri,
      );
      final snap = facade.calcAll(jdUt, location, sweConfig);
      expect(snap.cuspsNakLon, hasLength(12));

      final ayanamsa = facade.getAyanamsaUt(jdUt, Ayanamsa.lahiri);
      for (var i = 0; i < 12; i++) {
        final diff = (snap.cusps[i] - snap.cuspsNakLon[i]) % 360;
        expect(
          diff,
          closeTo(ayanamsa, 0.01),
          reason: 'cusp ${i + 1} tropical−sidereal diff',
        );
      }
    });

    test('cusp nak longitudes reuse sign cusps when nak == sign', () {
      const sweConfig = SweConfig(
        signAyanamsa: Ayanamsa.lahiri,
        nakAyanamsa: Ayanamsa.lahiri,
      );
      final snap = facade.calcAll(jdUt, location, sweConfig);
      expect(snap.cuspsNakLon, hasLength(12));
      for (var i = 0; i < 12; i++) {
        expect(
          snap.cuspsNakLon[i],
          snap.cusps[i],
          reason: 'cusp ${i + 1} nak should equal sign cusp',
        );
      }
    });
  });
}
