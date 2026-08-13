// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

import 'iri.dart';

/// Maps arrow's calculation-domain values to canon (jyotish) IRIs. This is the
/// I2 contract in code: every body/sign/house in the emitted data is a canon
/// IRI, never a string literal. The tables are the single source of the mapping;
/// a value with no canon IRI is an invariant violation, not a silent skip.
final class CanonIri {
  CanonIri._();

  static const Map<Body, String> _graha = <Body, String>{
    Body.sun: 'surya',
    Body.moon: 'chandra',
    Body.mars: 'mangala',
    Body.mercury: 'budha',
    Body.jupiter: 'guru',
    Body.venus: 'shukra',
    Body.saturn: 'shani',
    Body.rahu: 'rahu',
    Body.ketu: 'ketu',
  };

  static const List<String> _rashi = <String>[
    'mesha',
    'vrishabha',
    'mithuna',
    'karka',
    'simha',
    'kanya',
    'tula',
    'vrischika',
    'dhanus',
    'makara',
    'kumbha',
    'mina',
  ];

  /// Canon local name for a graha (e.g. [Body.mars] -> `mangala`). Throws
  /// [ArgumentError] for a non-graha [Body] — the tracer emits the 9 grahas
  /// only, and a stray body is a programmer error, not a data case.
  static String grahaLocalName(Body body) {
    final name = _graha[body];
    if (name == null) {
      throw ArgumentError.value(body, 'body', 'invariant: not a graha');
    }
    return name;
  }

  /// Canon graha IRI (e.g. [Body.mars] -> `jyotish:mangala`).
  static Iri graha(Body body) =>
      Iri.term(Namespaces.jyotish, grahaLocalName(body));

  /// Canon rashi IRI for a sign in 1..12 (1 -> `jyotish:mesha`, 12 ->
  /// `jyotish:mina`). Throws [ArgumentError] outside 1..12 (invariant: sign is a
  /// projection of a bounded longitude).
  static Iri rashi(int sign) {
    if (sign < 1 || sign > 12) {
      throw ArgumentError.value(sign, 'sign', 'invariant: sign out of 1..12');
    }
    return Iri.term(Namespaces.jyotish, _rashi[sign - 1]);
  }

  /// Canon bhava IRI for a house in 1..12 (1 -> `jyotish:bhava-1`). Throws
  /// [ArgumentError] outside 1..12 (invariant).
  static Iri bhava(int house) {
    if (house < 1 || house > 12) {
      throw ArgumentError.value(
        house,
        'house',
        'invariant: house out of 1..12',
      );
    }
    return Iri.term(Namespaces.jyotish, 'bhava-$house');
  }
}
