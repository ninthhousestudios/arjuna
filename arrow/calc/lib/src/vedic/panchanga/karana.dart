// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'panchanga_names.dart' as names;
import 'tithi.dart';

/// Result of a karana calculation.
class Karana {
  /// The name of this karana.
  final String name;

  /// 0-based index into the tithi (0 = first half, 1 = second half).
  final int half;

  /// 0-based tithi index this karana belongs to.
  final int tithiIndex;

  /// Degrees elapsed within this karana (0–6).
  final double degreesElapsed;

  /// Degrees remaining in this karana (0–6).
  final double degreesRemaining;

  const Karana({
    required this.name,
    required this.half,
    required this.tithiIndex,
    required this.degreesElapsed,
    required this.degreesRemaining,
  });

  /// Fraction elapsed (0.0–1.0).
  double get fractionElapsed => degreesElapsed / 6.0;

  /// Fraction remaining (0.0–1.0).
  double get fractionRemaining => degreesRemaining / 6.0;

  @override
  String toString() => name;
}

/// Calculate the karana from sun and moon ecliptic longitudes.
///
/// Each karana spans 6° of moon-sun elongation. There are two karanas per
/// tithi. The [tithi] is needed to determine which half of the tithi we're in.
Karana calcKarana(double sunLongitude, double moonLongitude, Tithi tithi) {
  final raw = ((moonLongitude - sunLongitude) % 360) / 6.0;
  final remainder = raw % 1;
  final elapsed = remainder * 6.0;
  final remaining = 6.0 - elapsed;

  // Which half of the tithi: if more than 6° remain in the tithi,
  // we're in the first karana (index 0), otherwise the second (index 1).
  final half = tithi.degreesRemaining > 6.0 ? 0 : 1;
  final tithiIdx = tithi.number - 1;
  final name = names.karanas[tithiIdx][half];

  return Karana(
    name: name,
    half: half,
    tithiIndex: tithiIdx,
    degreesElapsed: elapsed,
    degreesRemaining: remaining,
  );
}
