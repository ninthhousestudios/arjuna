// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_rdf/arrow_rdf.dart';
import 'package:test/test.dart';

/// AC3: same input -> same IRI; distinct natural key/name or config -> distinct
/// IRI. Idempotency (I3) of the whole pipeline hangs on this.
void main() {
  const minter = IriMinter();
  const view = ViewSpec(
    circle: Circle.zodiac,
    signAyanamsa: Ayanamsa.lahiri,
    houseSystem: HouseSystem.wholeSigns,
    provenance: Provenance(
      engine: 'arrow',
      engineVersion: '0.1.0',
      ephemeris: 'swiss',
    ),
  );
  Iri chart({
    double jd = 2447679.3388888887,
    double lat = 40.0,
    double lon = -86.0,
    String name = 'Josh',
  }) => minter.chartIri(jd: jd, lat: lat, lon: lon, name: name);

  group('chartIri', () {
    test('is deterministic for identical input', () {
      expect(chart(), chart());
    });

    test('differs on distinct name (same-moment different subject)', () {
      expect(chart(name: 'Josh'), isNot(chart(name: 'Jane')));
    });

    test('differs on distinct natural key', () {
      expect(chart(jd: 2447679.3388888887), isNot(chart(jd: 2447679.34)));
      expect(chart(lat: 40.0), isNot(chart(lat: 40.1)));
      expect(chart(lon: -86.0), isNot(chart(lon: -86.1)));
    });

    test('mints under the corpus data namespace', () {
      expect(chart().value, startsWith('${Namespaces.corpus}chart/'));
    });
  });

  group('viewIri', () {
    test('is deterministic and per-chart', () {
      final c = chart();
      expect(
        minter.viewIri(chart: c, view: view),
        minter.viewIri(chart: c, view: view),
      );
    });

    test('differs when the chart differs', () {
      expect(
        minter.viewIri(
          chart: chart(name: 'Josh'),
          view: view,
        ),
        isNot(
          minter.viewIri(
            chart: chart(name: 'Jane'),
            view: view,
          ),
        ),
      );
    });

    test('differs when the config differs; provenance does not identify', () {
      const otherConfig = ViewSpec(
        circle: Circle.zodiac,
        signAyanamsa: Ayanamsa.tropical,
        houseSystem: HouseSystem.wholeSigns,
        provenance: Provenance(
          engine: 'arrow',
          engineVersion: '0.1.0',
          ephemeris: 'swiss',
        ),
      );
      const sameConfigOtherProv = ViewSpec(
        circle: Circle.zodiac,
        signAyanamsa: Ayanamsa.lahiri,
        houseSystem: HouseSystem.wholeSigns,
        provenance: Provenance(
          engine: 'other',
          engineVersion: '9.9.9',
          ephemeris: 'moshier',
        ),
      );
      final c = chart();
      expect(
        minter.viewIri(chart: c, view: view),
        isNot(minter.viewIri(chart: c, view: otherConfig)),
      );
      expect(
        minter.viewIri(chart: c, view: view),
        minter.viewIri(chart: c, view: sameConfigOtherProv),
      );
    });
  });

  group('placementIri', () {
    test('is distinct per body and nested under the view', () {
      final v = minter.viewIri(chart: chart(), view: view);
      final surya = minter.placementIri(view: v, body: Body.sun);
      final mangala = minter.placementIri(view: v, body: Body.mars);
      expect(surya, isNot(mangala));
      expect(surya.value, '${v.value}/surya');
    });

    test('rejects a non-graha body (invariant)', () {
      final v = minter.viewIri(chart: chart(), view: view);
      expect(
        () => minter.placementIri(view: v, body: Body.uranus),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
