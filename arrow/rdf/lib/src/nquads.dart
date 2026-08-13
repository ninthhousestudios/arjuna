// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'iri.dart';
import 'rdf_term.dart';

/// A set of N-Quads across named graphs. [write] is the only way out, and it is
/// canonical: quad lines are sorted by a total (lexicographic) order and emitted
/// one per line, so byte-equality is a meaningful golden assertion (I3,
/// developer story 20). There are no blank nodes, so no relabelling is needed.
final class NQuadsDocument {
  final List<Quad> quads;
  const NQuadsDocument(this.quads);

  /// Canonical N-Quads text (LF-terminated lines, sorted, UTF-8). Deterministic.
  String write() {
    final lines = quads.map(_line).toList()..sort();
    final buffer = StringBuffer();
    for (final line in lines) {
      buffer
        ..write(line)
        ..write('\n');
    }
    return buffer.toString();
  }

  static String _line(Quad q) =>
      '${_iri(q.subject)} ${_iri(q.predicate)} ${_object(q.object)} '
      '${_iri(q.graph)} .';

  static String _iri(Iri iri) => '<${_escapeIri(iri.value)}>';

  static String _object(RdfTerm term) => switch (term) {
    IriTerm(:final iri) => _iri(iri),
    StringLiteral(:final value) => '"${_escapeLiteral(value)}"',
    DoubleLiteral(:final value) =>
      '"${canonicalDouble(value)}"^^${_iri(Xsd.xdouble)}',
    BooleanLiteral(:final value) => '"$value"^^${_iri(Xsd.xboolean)}',
  };

  /// Escape the characters an IRIREF may not contain literally (RDF 1.1
  /// N-Quads §7). Our IRIs are clean ASCII URLs, so this is a safety net.
  static String _escapeIri(String value) {
    final out = StringBuffer();
    for (final unit in value.codeUnits) {
      if (unit <= 0x20 ||
          unit == 0x3C || // <
          unit == 0x3E || // >
          unit == 0x22 || // "
          unit == 0x7B || // {
          unit == 0x7D || // }
          unit == 0x7C || // |
          unit == 0x5E || // ^
          unit == 0x60 || // `
          unit == 0x5C) {
        // \
        out.write('\\u${unit.toRadixString(16).toUpperCase().padLeft(4, '0')}');
      } else {
        out.writeCharCode(unit);
      }
    }
    return out.toString();
  }

  /// Escape a string literal's content (RDF 1.1 N-Quads §7 STRING_LITERAL_QUOTE).
  static String _escapeLiteral(String value) => value
      .replaceAll('\\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('\t', r'\t');
}

/// The canonical lexical form of an `xsd:double` value — the crux of
/// cross-run/cross-platform determinism for jd/lat/lon/longitude.
///
/// Dart's `double.toString()` is the shortest string that round-trips to the
/// same bits (a spec-defined algorithm, stable across versions/platforms). For
/// this project's value ranges (jd ~2.4e6, coords, degrees [0,360)) it never
/// reaches exponent notation and matches the hand-authored ARP-2 golden's
/// lexical form exactly. A value extreme enough to fall to exponent form would
/// be out-of-domain, so it throws rather than emit an unstable lexical form.
String canonicalDouble(double value) {
  if (value.isNaN || value.isInfinite) {
    throw ArgumentError.value(
      value,
      'value',
      'invariant: non-finite xsd:double',
    );
  }
  final text = value.toString();
  if (text.contains('e') || text.contains('E')) {
    throw ArgumentError.value(
      value,
      'value',
      'invariant: xsd:double lexical form fell to exponent notation ($text) — '
          'out of the project value domain',
    );
  }
  return text;
}
