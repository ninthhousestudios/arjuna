// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// An absolute IRI. A zero-cost newtype over [String] so raw strings can't be
/// mixed with minted IRIs, and so the namespace bases live in exactly one
/// place. Equality/hashing delegate to the underlying string, so an [Iri] is a
/// sound [Map] key and sorts by its string value.
extension type const Iri(String value) {
  /// An IRI in [base] with local name [local], e.g. `Iri.term(Namespaces.jyotish, 'mesha')`.
  const Iri.term(String base, String local) : value = '$base$local';
}

/// The namespace base IRIs. Two tiers, never colliding (I13):
/// - ontology vocabulary (`chart:`, `jyotish:`) — stable schema;
/// - corpus data (`corpus/…`) — minted instances.
final class Namespaces {
  Namespaces._();

  /// Chart ontology vocabulary (I13). Ontology-level, parallel to `vidya:`.
  static const String chart = 'http://vidya.ninthhouse.studio/ontology/chart/';

  /// Jyotish canon vocabulary — grahas, rashis, bhavas (the I2 join target).
  static const String jyotish =
      'http://vidya.ninthhouse.studio/domain/jyotish/';

  /// Corpus instance data — Charts, Views, Placements are minted here (I13).
  static const String corpus = 'http://vidya.ninthhouse.studio/corpus/';

  static const String rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
  static const String rdfs = 'http://www.w3.org/2000/01/rdf-schema#';
  static const String xsd = 'http://www.w3.org/2001/XMLSchema#';
}
