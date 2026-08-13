// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'canon_iri.dart';
import 'chart_identity.dart';
import 'computed_view.dart';
import 'iri.dart';
import 'iri_minter.dart';
import 'nquads.dart';
import 'rdf_term.dart';
import 'view_spec.dart';

const Iri _rdfType = Iri('${Namespaces.rdf}type');
const Iri _rdfsLabel = Iri('${Namespaces.rdfs}label');
const Iri _chartClass = Iri.term(Namespaces.chart, 'Chart');
const Iri _viewClass = Iri.term(Namespaces.chart, 'View');
const Iri _placementClass = Iri.term(Namespaces.chart, 'Placement');

Iri _c(String local) => Iri.term(Namespaces.chart, local);

/// The chart-RDF serializer — ARP-4 tracer scope: **Chart identity + one
/// placements View** (the two layers chart.ttl v0 defines). Owns IRI minting,
/// canon mapping (I2), graph partitioning (I5), and deterministic ordering (I3).
///
/// Pure: no SWE, no clock, no I/O. Feed it a [ComputedView] and it is a total
/// function to [NQuadsDocument] — which is what lets the golden test run with no
/// ephemeris and makes byte-equality a real determinism check.
///
/// Out of scope (ARP-4b, gated on ontology v1 / vidya ARP-2b): the raw-positions
/// named graph (I8) and full calc provenance (I9). The v0 View carries only the
/// minimal provenance stub the ontology can name.
final class ChartRdfSerializer {
  final IriMinter minter;
  const ChartRdfSerializer({this.minter = const IriMinter()});

  /// Serialize one chart under one view into named-graph N-Quads:
  ///
  /// - **identity graph** (named by the chart IRI) — `chart:Chart` with OACF
  ///   fields incl. rodden + tags;
  /// - **view graph** (named by the view IRI) — `chart:View` (config +
  ///   provenance stub, `chart:lagna`) and its `chart:Placement`s, with
  ///   body/sign/house as canon IRIs (I2) mapped from the single-source
  ///   [ComputedPlacement] (no sign arithmetic here — arrow already projected
  ///   it, circle-aware).
  ///
  /// Total: a well-formed [ComputedView] always serializes. Malformed inputs
  /// (sign/house out of 1..12, a non-graha body) surface as [ArgumentError]
  /// from the canon mapping — invariant violations, not expected failures, so
  /// there is no sealed result type.
  NQuadsDocument serialize({
    required ChartIdentity chart,
    required ViewSpec view,
    required ComputedView computed,
  }) {
    final chartIri = minter.chartIri(
      jd: chart.jd,
      lat: chart.lat,
      lon: chart.lon,
      name: chart.name,
    );
    final viewIri = minter.viewIri(chart: chartIri, view: view);
    final quads = <Quad>[];

    // ── Identity graph (named by the chart IRI) ──
    void identity(Iri predicate, RdfTerm object) => quads.add(
      Quad(
        subject: chartIri,
        predicate: predicate,
        object: object,
        graph: chartIri,
      ),
    );

    identity(_rdfType, const IriTerm(_chartClass));
    identity(_rdfsLabel, StringLiteral(chart.name));
    identity(_c('chartName'), StringLiteral(chart.name));
    final gender = chart.gender;
    if (gender != null) {
      identity(_c('gender'), StringLiteral(gender));
    }
    final rodden = chart.rodden;
    if (rodden != null) {
      identity(_c('rodden'), StringLiteral(rodden));
    }
    identity(_c('jd'), DoubleLiteral(chart.jd));
    identity(_c('lat'), DoubleLiteral(chart.lat));
    identity(_c('lon'), DoubleLiteral(chart.lon));
    final placename = chart.placename;
    if (placename != null) {
      identity(_c('placename'), StringLiteral(placename));
    }
    final country = chart.country;
    if (country != null) {
      identity(_c('country'), StringLiteral(country));
    }
    final civilDate = chart.civilDate;
    if (civilDate != null) {
      identity(_c('civilDate'), StringLiteral(civilDate));
    }
    final civilTime = chart.civilTime;
    if (civilTime != null) {
      identity(_c('civilTime'), StringLiteral(civilTime));
    }
    final utcOffset = chart.utcOffset;
    if (utcOffset != null) {
      identity(_c('utcOffset'), DoubleLiteral(utcOffset));
    }
    for (final tag in <String>[...chart.tags]..sort()) {
      identity(_c('tags'), StringLiteral(tag));
    }
    identity(_c('hasView'), IriTerm(viewIri));

    // ── View graph (named by the view IRI) ──
    void view0(Iri subject, Iri predicate, RdfTerm object) => quads.add(
      Quad(
        subject: subject,
        predicate: predicate,
        object: object,
        graph: viewIri,
      ),
    );

    view0(viewIri, _rdfType, const IriTerm(_viewClass));
    view0(
      viewIri,
      _rdfsLabel,
      StringLiteral(
        '${chart.name} · ${view.ontologyAyanamsa ?? view.ontologyCircle}'
        ' · ${view.ontologyHouseSystem}',
      ),
    );
    view0(viewIri, _c('circle'), StringLiteral(view.ontologyCircle));
    final ayanamsa = view.ontologyAyanamsa;
    if (ayanamsa != null) {
      view0(viewIri, _c('ayanamsa'), StringLiteral(ayanamsa));
    }
    view0(viewIri, _c('houseSystem'), StringLiteral(view.ontologyHouseSystem));
    view0(viewIri, _c('lagna'), IriTerm(CanonIri.rashi(computed.lagnaSign)));
    view0(viewIri, _c('engine'), StringLiteral(view.provenance.engine));
    view0(
      viewIri,
      _c('engineVersion'),
      StringLiteral(view.provenance.engineVersion),
    );
    view0(viewIri, _c('ephemeris'), StringLiteral(view.provenance.ephemeris));

    for (final placement in computed.placements) {
      final placeIri = minter.placementIri(view: viewIri, body: placement.body);
      view0(viewIri, _c('hasPlacement'), IriTerm(placeIri));
      view0(placeIri, _rdfType, const IriTerm(_placementClass));
      view0(placeIri, _c('body'), IriTerm(CanonIri.graha(placement.body)));
      view0(placeIri, _c('sign'), IriTerm(CanonIri.rashi(placement.sign)));
      view0(placeIri, _c('house'), IriTerm(CanonIri.bhava(placement.house)));
      view0(placeIri, _c('longitude'), DoubleLiteral(placement.longitude));
      if (placement.retrograde) {
        view0(placeIri, _c('retrograde'), const BooleanLiteral(true));
      }
    }

    return NQuadsDocument(quads);
  }
}
