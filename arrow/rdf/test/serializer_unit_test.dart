// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_rdf/arrow_rdf.dart';
import 'package:test/test.dart';

/// Unit coverage the ARP-2 seed can't give (it carries no rodden/tags): the full
/// identity surface and the I2 canon-IRI contract (AC4).
void main() {
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
  const identity = ChartIdentity(
    jd: 2447679.3388888887,
    lat: 40.0,
    lon: -86.0,
    name: 'Subject',
    gender: 'female',
    rodden: 'AA',
    tags: <String>['vedic', 'criminals'],
    placename: 'Somewhere',
    country: 'USA',
  );
  const computed = ComputedView(
    lagnaSign: 6,
    placements: <ComputedPlacement>[
      ComputedPlacement(
        body: Body.mars,
        longitude: 20.0,
        sign: 1,
        house: 8,
        retrograde: false,
      ),
      ComputedPlacement(
        body: Body.saturn,
        longitude: 252.0,
        sign: 9,
        house: 4,
        retrograde: true,
      ),
    ],
  );

  final quads = const ChartRdfSerializer()
      .serialize(chart: identity, view: view, computed: computed)
      .quads;

  RdfTerm? objectOf(String predicateLocal, {String? subject}) {
    for (final q in quads) {
      if (q.predicate.value == '${Namespaces.chart}$predicateLocal' &&
          (subject == null || q.subject.value == subject)) {
        return q.object;
      }
    }
    return null;
  }

  test('emits rodden as a string literal', () {
    expect(objectOf('rodden'), const StringLiteral('AA'));
  });

  test('emits one chart:tags triple per tag, sorted', () {
    final tags = quads
        .where((q) => q.predicate.value == '${Namespaces.chart}tags')
        .map((q) => (q.object as StringLiteral).value)
        .toList();
    expect(tags, <String>['criminals', 'vedic']);
  });

  test('body/sign/house/lagna are canon IRIs, never string literals (I2)', () {
    for (final local in <String>['body', 'sign', 'house', 'lagna']) {
      final matches = quads.where(
        (q) => q.predicate.value == '${Namespaces.chart}$local',
      );
      expect(matches, isNotEmpty, reason: 'no $local emitted');
      for (final q in matches) {
        expect(q.object, isA<IriTerm>(), reason: '$local must be an IRI');
        final iri = (q.object as IriTerm).iri.value;
        expect(
          iri,
          startsWith(Namespaces.jyotish),
          reason: '$local must be a jyotish canon IRI',
        );
      }
    }
  });

  test('retrograde emitted only when true', () {
    final marsPlace = quads.firstWhere(
      (q) =>
          q.object is IriTerm &&
          (q.object as IriTerm).iri.value.endsWith('/mangala') &&
          q.predicate.value == '${Namespaces.chart}hasPlacement',
    );
    final marsRetro = quads.where(
      (q) =>
          q.subject.value == (marsPlace.object as IriTerm).iri.value &&
          q.predicate.value == '${Namespaces.chart}retrograde',
    );
    expect(
      marsRetro,
      isEmpty,
      reason: 'direct Mars should have no retrograde triple',
    );
  });

  test('circle/ayanamsa translate arrow -> ontology (sidereal + lahiri)', () {
    expect(objectOf('circle'), const StringLiteral('sidereal'));
    expect(objectOf('ayanamsa'), const StringLiteral('lahiri'));
    expect(objectOf('houseSystem'), const StringLiteral('whole-sign'));
  });
}
