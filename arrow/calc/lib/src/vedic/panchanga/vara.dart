// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'panchanga_names.dart';

/// Yamakoti — the reference meridian for vara (savana day) transitions.
/// Sunrise here marks the change of vara for the entire world.
const double yamakotiLat = 0.0;
const double yamakotiLon = 165.76666666666668;
const double yamakotiUtcOffset = 12.0;

/// Result of a vara calculation.
class Vara {
  /// 0 = Sunday (ravivāra) through 6 = Saturday (śanivāra).
  final int index;

  /// Full IAST name from [varas].
  String get name => varas[index];

  /// Abbreviated name from [varasAbbreviated].
  String get abbreviation => varasAbbreviated[index];

  const Vara(this.index);

  @override
  String toString() => 'Vara($index, $name)';
}

/// Calculate the vara (weekday) at a given Julian Day (UT).
///
/// The vara changes at sunrise at Yamakoti (equator, 165.767°E).
/// Sunrise at the equator ≈ 06:00 local. Yamakoti is UTC+12, so
/// sunrise ≈ 18:00 UT. The vara that starts at 18:00 UT corresponds
/// to the next calendar day's weekday at Yamakoti.
///
/// The standard JD weekday formula is `(floor(JD + 1.5)) % 7` with
/// 0=Sunday, using midnight UT as the day boundary. We shift to an
/// 18:00 UT boundary and advance one day for the Yamakoti date:
/// `(floor(JD + 1.75)) % 7`.
Vara calcVara(double jdUt) {
  final index = (jdUt + 1.75).floor() % 7;
  return Vara(index);
}
