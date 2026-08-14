// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:math' as math;

import 'package:arrow_rdf/arrow_rdf.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

/// The ARP-4 serializer golden (AC2): a hermetic re-serialization of the ARP-2
/// seed chart. The fixture's computed placements were captured from a real SWE
/// run (`tool/gen_golden.dart`); here the PURE serializer must reproduce the
/// committed byte golden exactly — that is the determinism (I3) spec.
void main() {
  final fixture = GoldenFixture.load(
    'test/fixtures/josh-lahiri-wholesign.json',
  );
  final doc = const ChartRdfSerializer().serialize(
    chart: fixture.identity,
    view: fixture.view,
    computed: fixture.computed,
  );

  test('matches the committed N-Quads golden byte-for-byte', () {
    final golden = packageFile(
      'test/golden/josh-lahiri-wholesign.nq',
    ).readAsStringSync();
    expect(doc.write(), golden);
  });

  test('serialization is deterministic across runs', () {
    expect(
      doc.write(),
      const ChartRdfSerializer()
          .serialize(
            chart: fixture.identity,
            view: fixture.view,
            computed: fixture.computed,
          )
          .write(),
    );
  });

  // ARP-2 review invariant (vidya/astrology-research/3), asserted on the EMITTED
  // quads: for every placement, chart:sign is floor(chart:longitude / 30) mapped
  // to the canon rashi — the two never disagree because they share one source.
  test('every emitted sign == floor(longitude/30) as a canon rashi', () {
    final signOf = <String, String>{};
    final lonOf = <String, double>{};
    for (final q in doc.quads) {
      final object = q.object;
      switch (q.predicate.value) {
        case '${Namespaces.chart}sign' when object is IriTerm:
          signOf[q.subject.value] = object.iri.value;
        case '${Namespaces.chart}longitude' when object is DoubleLiteral:
          lonOf[q.subject.value] = object.value;
      }
    }
    expect(signOf, isNotEmpty);
    expect(signOf.keys, everyElement(isIn(lonOf.keys)));
    signOf.forEach((subject, signIri) {
      final lon = lonOf[subject]!;
      final expected = CanonIri.rashi((lon / 30).floor() + 1).value;
      expect(signIri, expected, reason: 'sign/longitude disagree for $subject');
    });
  });

  // The loader contract (vidya ARP-5 I7): every named graph must live under the
  // disjoint `…/corpus/graph/*` namespace, or `load-corpus` rejects the whole
  // payload. Pin it here at the serializer boundary — this is the seam ARP-6
  // exposed.
  test('every quad names a graph under the corpus/graph namespace', () {
    final graphs = doc.quads.map((q) => q.graph.value).toSet();
    expect(graphs, isNotEmpty);
    expect(
      graphs,
      everyElement(startsWith('${Namespaces.corpus}graph/')),
      reason: 'load-corpus rejects any graph outside …/corpus/graph/*',
    );
  });

  test('golden covers the full 9-graha view + identity', () {
    final placements = doc.quads
        .where((q) => q.predicate.value == '${Namespaces.chart}hasPlacement')
        .length;
    expect(placements, 9);
  });

  // Guard the canonicalDouble tripwire indirectly: no emitted double is extreme
  // enough to reach exponent notation (would break the golden).
  test('no emitted longitude reaches exponent notation', () {
    for (final q in doc.quads) {
      final object = q.object;
      if (object is DoubleLiteral) {
        expect(canonicalDouble(object.value), isNot(contains('e')));
        expect(object.value.abs(), lessThan(math.pow(10, 7)));
      }
    }
  });
}
