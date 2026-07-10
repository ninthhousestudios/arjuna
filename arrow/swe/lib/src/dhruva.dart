// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:swisseph_rs/swisseph_rs.dart' as swe;

const double _nakshatraSpan = 360.0 / 27.0;

/// Equatorial RA of the start of Ashvini in the dhruva system at [jdUt].
///
/// Anchored on Sgr A* (Galactic Center) at the midpoint of Mula.
double dhruvaAshviniStart(swe.Ephemeris eph, double jdUt) {
  final gc = eph.fixstar2Ut(
    ',SgrA*',
    swe.JdUt1(jdUt),
    swe.CalcFlags.equatorial,
  );
  final mula = gc.longitude - (_nakshatraSpan / 2);
  return mula - (18 * _nakshatraSpan);
}

/// Degrees from Ashvini start along the equator for body [body].
double dhruvaGcEquatorial(swe.Ephemeris eph, double jdUt, swe.Body body) {
  final ashvini = dhruvaAshviniStart(eph, jdUt);
  final result = eph.calcUt(swe.JdUt1(jdUt), body, swe.CalcFlags.equatorial);
  var equLong = result.longitude;
  if (equLong < ashvini) equLong += 360;
  return equLong - ashvini;
}

/// Degrees from Ashvini start along the equator for fixed star [sweName].
double dhruvaGcEquatorialStar(swe.Ephemeris eph, double jdUt, String sweName) {
  final ashvini = dhruvaAshviniStart(eph, jdUt);
  final result = eph.fixstar2Ut(
    sweName,
    swe.JdUt1(jdUt),
    swe.CalcFlags.equatorial,
  );
  var equLong = result.longitude;
  if (equLong < ashvini) equLong += 360;
  return equLong - ashvini;
}
