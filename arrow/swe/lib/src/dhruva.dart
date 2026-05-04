import 'package:swisseph/swisseph.dart';

const double _nakshatraSpan = 360.0 / 27.0;

/// Equatorial RA of the start of Ashvini in the dhruva system at [jdUt].
///
/// Anchored on Sgr A* (Galactic Center) at the midpoint of Mula.
double dhruvaAshviniStart(SwissEph swe, double jdUt) {
  final gc = swe.fixstar2Ut(',SgrA*', jdUt, seFlgEquatorial);
  final mula = gc.longitude - (_nakshatraSpan / 2);
  return mula - (18 * _nakshatraSpan);
}

/// Degrees from Ashvini start along the equator for body [planet].
double dhruvaGcEquatorial(SwissEph swe, double jdUt, int planet) {
  final ashvini = dhruvaAshviniStart(swe, jdUt);
  final result = swe.calcUt(jdUt, planet, seFlgEquatorial);
  var equLong = result.longitude;
  if (equLong < ashvini) equLong += 360;
  return equLong - ashvini;
}

/// Degrees from Ashvini start along the equator for fixed star [sweName].
double dhruvaGcEquatorialStar(SwissEph swe, double jdUt, String sweName) {
  final ashvini = dhruvaAshviniStart(swe, jdUt);
  final result = swe.fixstar2Ut(sweName, jdUt, seFlgEquatorial);
  var equLong = result.longitude;
  if (equLong < ashvini) equLong += 360;
  return equLong - ashvini;
}
