// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:convert';

import 'package:arrow_options/arrow_options.dart';
import 'package:crypto/crypto.dart';

import 'canon_iri.dart';
import 'iri.dart';
import 'nquads.dart';
import 'view_spec.dart';

/// Deterministic IRI minting (I3) — the small, isolated module the whole
/// pipeline's idempotency hangs on. Every method is a pure function of its
/// inputs: same input -> same IRI; distinct natural key/name or config ->
/// distinct IRI. No clock, no counter, no ambient state.
///
/// Floats in the natural key are hashed via their canonical lexical form
/// ([canonicalDouble]), never raw bit patterns, so IRI identity tracks the value
/// a human sees in the OACF file.
final class IriMinter {
  const IriMinter();

  /// Chart IRI from the OACF natural key (jd, lat, lon) + name (I1 semantics:
  /// the key identifies the moment; name distinguishes same-moment subjects).
  Iri chartIri({
    required double jd,
    required double lat,
    required double lon,
    required String name,
  }) {
    final key =
        '${canonicalDouble(jd)}|${canonicalDouble(lat)}|'
        '${canonicalDouble(lon)}|$name';
    return Iri('${Namespaces.corpus}chart/${_hash16(key)}');
  }

  /// View IRI: the chart's hash (per-chart, since it owns this chart's
  /// placements) plus the readable config [ViewSpec.slug].
  Iri viewIri({required Iri chart, required ViewSpec view}) =>
      Iri('${Namespaces.corpus}view/${_chartId(chart)}/${view.slug}');

  /// Placement IRI: the view path plus the body's canon local name.
  Iri placementIri({required Iri view, required Body body}) =>
      Iri('${view.value}/${CanonIri.grahaLocalName(body)}');

  /// Named-graph IRI for a chart's identity graph — distinct from the chart
  /// *subject* IRI. Corpus named graphs live under the disjoint
  /// `…/corpus/graph/*` namespace so vidya's instance-vs-canon classification
  /// (I7) is a clean prefix check that never collides with subject IRIs
  /// (`…/corpus/chart|view/*`). Identity is its own per-chart graph so
  /// `drop-view` can remove a single view without destroying the Chart the
  /// corpus's other views still reference.
  Iri chartGraphIri({required Iri chart}) =>
      Iri('${Namespaces.corpus}graph/${_chartId(chart)}/identity');

  /// Named-graph IRI for one view of a chart (graph-per-view, per I5). Under
  /// `…/corpus/graph/*` like [chartGraphIri]; this is the IRI that
  /// `vidya drop-view` targets.
  Iri viewGraphIri({required Iri chart, required ViewSpec view}) =>
      Iri('${Namespaces.corpus}graph/${_chartId(chart)}/${view.slug}');

  static String _chartId(Iri chart) => chart.value.split('/').last;

  static String _hash16(String input) =>
      sha256.convert(utf8.encode(input)).toString().substring(0, 16);
}
