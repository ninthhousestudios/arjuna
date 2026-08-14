// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_rdf/arrow_rdf.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

/// The corpus pipeline (ARP-6) folds a chart's per-view serializations into one
/// canonical .nq by [NQuadsDocument.merge]. This pins the invariant 805ce43
/// restored — identity payload once, every view's chart:hasView kept — directly
/// on the merge, SWE-free (the serializer is pure). Regression guard for the
/// exact logic that already broke once.
void main() {
  const hasView = '${Namespaces.chart}hasView';
  const prov = Provenance(
    engine: 'arrow',
    engineVersion: '0.1.0',
    ephemeris: 'swiss-ephemeris',
  );
  // The ARP-6 slate: two whole-sign cells that differ only by circle, so they
  // mint distinct view IRIs (hence distinct view graphs and hasView objects)
  // while sharing one identity graph.
  const aditya = ViewSpec(
    circle: Circle.aditya,
    signAyanamsa: Ayanamsa.tropical,
    houseSystem: HouseSystem.wholeSigns,
    provenance: prov,
  );
  const zodiac = ViewSpec(
    circle: Circle.zodiac,
    signAyanamsa: Ayanamsa.tropical,
    houseSystem: HouseSystem.wholeSigns,
    provenance: prov,
  );

  final fixture = GoldenFixture.load(
    'test/fixtures/josh-lahiri-wholesign.json',
  );
  final identity = fixture.identity;
  // Reuse one computed placement set for both views — physically a fib, but the
  // merge invariant is about graph/hasView structure, not placement values.
  final computed = fixture.computed;

  const serializer = ChartRdfSerializer();
  const minter = IriMinter();
  final chartGraph = minter.chartGraphIri(
    chart: minter.chartIri(
      jd: identity.jd,
      lat: identity.lat,
      lon: identity.lon,
      name: identity.name,
    ),
  );

  final docA = serializer.serialize(
    chart: identity,
    view: aditya,
    computed: computed,
  );
  final docZ = serializer.serialize(
    chart: identity,
    view: zodiac,
    computed: computed,
  );
  final merged = NQuadsDocument.merge(<NQuadsDocument>[docA, docZ]);

  group('Quad value equality', () {
    test('byte-identical quads compare equal and collapse in a Set', () {
      final a = Quad(
        subject: chartGraph,
        predicate: const Iri(hasView),
        object: const StringLiteral('x'),
        graph: chartGraph,
      );
      final b = Quad(
        subject: chartGraph,
        predicate: const Iri(hasView),
        object: const StringLiteral('x'),
        graph: chartGraph,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(<Quad>{a, b}, hasLength(1));
    });

    test('a differing position breaks equality', () {
      final a = Quad(
        subject: chartGraph,
        predicate: const Iri(hasView),
        object: const StringLiteral('x'),
        graph: chartGraph,
      );
      final b = Quad(
        subject: chartGraph,
        predicate: const Iri(hasView),
        object: const StringLiteral('y'),
        graph: chartGraph,
      );
      expect(a, isNot(b));
    });
  });

  group('NQuadsDocument.merge', () {
    test('keeps every view\'s chart:hasView (the 805ce43 invariant)', () {
      final hasViews = merged.quads
          .where((q) => q.predicate.value == hasView)
          .toList();
      expect(hasViews, hasLength(2), reason: 'one hasView per view');
      expect(
        hasViews.map((q) => q.object).toSet(),
        hasLength(2),
        reason: 'each view names a distinct view IRI',
      );
      for (final q in hasViews) {
        expect(q.graph, chartGraph);
      }
    });

    test('emits the identity payload exactly once', () {
      bool isIdentityPayload(Quad q) =>
          q.graph == chartGraph && q.predicate.value != hasView;
      final mergedPayload = merged.quads.where(isIdentityPayload).toList();
      final singlePayload = docA.quads.where(isIdentityPayload).toList();

      // No duplication vs. a single view, and no dup lurking within.
      expect(mergedPayload, hasLength(singlePayload.length));
      expect(mergedPayload.toSet(), hasLength(mergedPayload.length));
    });

    test('is the exact set-union of the inputs — no drops, no dups', () {
      final union = <Quad>{...docA.quads, ...docZ.quads};
      expect(merged.quads.toSet(), union);
      expect(merged.quads, hasLength(union.length));
      // Merging genuinely collapsed the re-emitted identity graph.
      expect(
        merged.quads.length,
        lessThan(docA.quads.length + docZ.quads.length),
      );
    });
  });
}
