// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'panchanga_names.dart' as names;

/// Span of one nakshatra in degrees: 13°20' = 13 + 20/60.
const double nakshatraSpan = 13.0 + (20.0 / 60.0);

/// Result of a nakshatra calculation.
///
/// Distinct from `arrow_core`'s [NakshatraData] static lookup — this is a
/// per-position result with elapsed/remaining degrees.
class Nakshatra {
  /// 0-based nakshatra index (0–26).
  final int index;

  /// 1-based nakshatra number (1–27).
  int get number => index + 1;

  /// IAST name of this nakshatra.
  final String name;

  /// Degrees elapsed within this nakshatra (0–13°20').
  final double degreesElapsed;

  /// Degrees remaining in this nakshatra (0–13°20').
  final double degreesRemaining;

  /// The pada (quarter) within the nakshatra (1–4).
  int get pada =>
      ((degreesElapsed / (nakshatraSpan / 4)).toInt() + 1).clamp(1, 4);

  const Nakshatra({
    required this.index,
    required this.name,
    required this.degreesElapsed,
    required this.degreesRemaining,
  });

  /// Fraction elapsed (0.0–1.0).
  double get fractionElapsed => degreesElapsed / nakshatraSpan;

  /// Fraction remaining (0.0–1.0).
  double get fractionRemaining => degreesRemaining / nakshatraSpan;

  @override
  String toString() => '$name ($number)';
}

/// Calculate the nakshatra for a given sidereal longitude.
///
/// The longitude should be measured from the start of Ashvini (0°).
Nakshatra calcNakshatra(double siderealLongitude) {
  final normalized = siderealLongitude % 360;
  final raw = normalized / nakshatraSpan;
  final index = raw.toInt();
  final remainder = raw - index;
  final elapsed = remainder * nakshatraSpan;
  final remaining = nakshatraSpan - elapsed;

  return Nakshatra(
    index: index,
    name: names.nakshatras[index],
    degreesElapsed: elapsed,
    degreesRemaining: remaining,
  );
}
