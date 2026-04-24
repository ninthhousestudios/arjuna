import 'package:swisseph/swisseph.dart';

const double _nakshatraSpan = 360.0 / 27.0;

/// Dhruva GC Equatorial ayanamsa (libaditya ayanamsa 98).
///
/// Anchors the nakshatra system equatorially on Sgr A* (the Galactic Center),
/// placing it at the midpoint of Mula. Ashvini begins 18 nakshatras before
/// the Mula midpoint. All coordinates are equatorial (right ascension).
///
/// Returns the number of degrees from the beginning of Ashvini, measured
/// along the equator, for the body [planet] at Julian day [jdUt].
double dhruvaGcEquatorial(SwissEph swe, double jdUt, int planet) {
  final gc = swe.fixstar2Ut(',SgrA*', jdUt, seFlgEquatorial);
  final gcEqu = gc.longitude;

  final mula = gcEqu - (_nakshatraSpan / 2);
  final ashvini = mula - (18 * _nakshatraSpan);

  final result = swe.calcUt(jdUt, planet, seFlgEquatorial);
  var equLong = result.longitude;

  if (equLong < ashvini) {
    equLong += 360;
  }
  return equLong - ashvini;
}
