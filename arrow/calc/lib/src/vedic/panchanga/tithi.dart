// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'panchanga_names.dart' as names;

/// Result of a tithi calculation.
class Tithi {
  /// 1-based tithi number (1–30).
  final int number;

  /// Degrees elapsed within this tithi (0–12).
  final double degreesElapsed;

  /// Degrees remaining in this tithi (0–12).
  final double degreesRemaining;

  const Tithi({
    required this.number,
    required this.degreesElapsed,
    required this.degreesRemaining,
  });

  /// The cyclic type of this tithi (nanda, bhadra, jāya, ṛkta, pūrṇa).
  String get type => names.tithiTypes[(number - 1) % 5];

  /// Tithi relative to the current paksha (1–15).
  int get relative => number > 15 ? number - 15 : number;

  /// Fraction elapsed (0.0–1.0).
  double get fractionElapsed => degreesElapsed / 12.0;

  /// Fraction remaining (0.0–1.0).
  double get fractionRemaining => degreesRemaining / 12.0;

  @override
  String toString() => '$number ($type)';
}

/// Calculate the tithi from sun and moon ecliptic longitudes (tropical or
/// sidereal — as long as both use the same reference).
///
/// Each tithi spans 12° of the moon-sun elongation (0–360°).
Tithi calcTithi(double sunLongitude, double moonLongitude) {
  final raw = ((moonLongitude - sunLongitude) % 360) / 12.0;
  final remainder = raw % 1;
  final elapsed = remainder * 12.0;
  final remaining = 12.0 - elapsed;
  return Tithi(
    number: raw.toInt() + 1,
    degreesElapsed: elapsed,
    degreesRemaining: remaining,
  );
}
