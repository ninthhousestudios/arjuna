// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'iri.dart';

/// An RDF object term. Sealed so the N-Quads writer switches exhaustively over
/// exactly the four shapes this serializer emits — no blank nodes (their
/// canonicalisation would defeat determinism, I3), no language-tagged strings.
sealed class RdfTerm {
  const RdfTerm();
}

/// An IRI-valued object (bodies/signs/houses are canon IRIs per I2; also the
/// object of `chart:hasView` / `chart:hasPlacement`).
final class IriTerm extends RdfTerm {
  final Iri iri;
  const IriTerm(this.iri);

  @override
  bool operator ==(Object other) => other is IriTerm && other.iri == iri;
  @override
  int get hashCode => iri.hashCode;
}

/// An `xsd:string` literal (name, gender, rodden, placename, …).
final class StringLiteral extends RdfTerm {
  final String value;
  const StringLiteral(this.value);

  @override
  bool operator ==(Object other) =>
      other is StringLiteral && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

/// An `xsd:double` literal (jd, lat, lon, longitude). Lexical form is
/// canonicalised at write time — see `canonicalDouble` in nquads.dart.
final class DoubleLiteral extends RdfTerm {
  final double value;
  const DoubleLiteral(this.value);

  @override
  bool operator ==(Object other) =>
      other is DoubleLiteral && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

/// An `xsd:boolean` literal (retrograde).
final class BooleanLiteral extends RdfTerm {
  final bool value;
  const BooleanLiteral(this.value);

  @override
  bool operator ==(Object other) =>
      other is BooleanLiteral && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

/// One N-Quad. Subjects and predicates are always IRIs in this data (no blank
/// nodes); [graph] is always a named graph (there is no default-graph output —
/// the three-layer partitioning, I5, is expressed entirely through named graphs).
final class Quad {
  final Iri subject;
  final Iri predicate;
  final RdfTerm object;
  final Iri graph;
  const Quad({
    required this.subject,
    required this.predicate,
    required this.object,
    required this.graph,
  });

  /// Value equality over all four positions, so byte-identical quads collapse in
  /// a [Set]. This is what lets the corpus pipeline merge a chart's views by
  /// set-union: the identity graph each view re-emits is identical (and
  /// collapses), while each view's distinct `chart:hasView` differs by object
  /// and is kept. [Iri] and every [RdfTerm] already delegate equality to their
  /// underlying value.
  @override
  bool operator ==(Object other) =>
      other is Quad &&
      other.subject == subject &&
      other.predicate == predicate &&
      other.object == object &&
      other.graph == graph;

  @override
  int get hashCode => Object.hash(subject, predicate, object, graph);
}

/// XSD datatype IRIs used in literal serialization. String literals carry no
/// datatype IRI — a bare `"…"` N-Quads literal is `xsd:string` by definition
/// (RDF 1.1 §3.3), so an explicit `^^xsd:string` would be redundant.
final class Xsd {
  Xsd._();
  static const Iri xdouble = Iri('${Namespaces.xsd}double');
  static const Iri xboolean = Iri('${Namespaces.xsd}boolean');
}
