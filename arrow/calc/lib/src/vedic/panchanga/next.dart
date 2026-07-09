// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'karana.dart';
import 'nakshatra.dart';
import 'tithi.dart';
import 'vara.dart';
import 'yoga.dart';

/// Returns the sunrise JD at Yamakoti for a given JD.
typedef SunriseAt = double Function(double jd);

/// Ecliptic positions and speeds at a Julian Day. Speeds in °/day.
typedef EclipticStateAt =
    ({double sun, double moon, double sunSpeed, double moonSpeed}) Function(
      double jd,
    );

/// Sidereal positions and speeds at a Julian Day. Speeds in °/day.
typedef SiderealStateAt =
    ({double sun, double moon, double sunSpeed, double moonSpeed}) Function(
      double jd,
    );

/// Moon sidereal longitude and speed at a Julian Day. Speed in °/day.
typedef MoonSiderealStateAt =
    ({double longitude, double speed}) Function(double jd);

/// Find the JD when the current tithi ends and the next one begins.
///
/// Uses Newton-Raphson with the actual moon–sun relative speed to estimate
/// the boundary, then bisects to refine. Typically 1–2 Newton steps plus
/// ~30 bisection steps for sub-millisecond precision.
({double jd, Tithi tithi}) nextTithi(
  double jd,
  EclipticStateAt stateAt, {
  double toleranceDays = 1e-8,
  int maxNewton = 4,
  int maxBisections = 40,
}) {
  final s0 = stateAt(jd);
  final startNumber = calcTithi(s0.sun, s0.moon).number;

  Tithi tithiAt(double t) {
    final s = stateAt(t);
    return calcTithi(s.sun, s.moon);
  }

  // Phase 1: Newton steps to establish bracket [lo, hi]
  var lo = jd;
  double? hi;
  var current = jd;

  for (var i = 0; i < maxNewton; i++) {
    if (tithiAt(current).number != startNumber) {
      hi = current;
      break;
    }
    lo = current;
    final s = stateAt(current);
    final remaining = calcTithi(s.sun, s.moon).degreesRemaining;
    final relSpeed = s.moonSpeed - s.sunSpeed; // °/day
    if (relSpeed <= 0) break;
    current += remaining / relSpeed;
  }

  var upper =
      hi ??
      ((tithiAt(current).number != startNumber)
          ? current
          : current + 1.0); // generous fallback: 1 day

  // Phase 2: Bisect [lo, upper]
  for (var i = 0; i < maxBisections && (upper - lo) > toleranceDays; i++) {
    final mid = (lo + upper) / 2;
    if (tithiAt(mid).number != startNumber) {
      upper = mid;
    } else {
      lo = mid;
    }
  }

  return (jd: upper, tithi: tithiAt(upper));
}

/// Find the JD when the current karana ends and the next one begins.
({double jd, Karana karana}) nextKarana(
  double jd,
  EclipticStateAt stateAt, {
  double toleranceDays = 1e-8,
  int maxNewton = 4,
  int maxBisections = 40,
}) {
  final s0 = stateAt(jd);
  final startTithi = calcTithi(s0.sun, s0.moon);
  final startName = calcKarana(s0.sun, s0.moon, startTithi).name;

  Karana karanaAt(double t) {
    final s = stateAt(t);
    final tithi = calcTithi(s.sun, s.moon);
    return calcKarana(s.sun, s.moon, tithi);
  }

  var lo = jd;
  double? hi;
  var current = jd;

  for (var i = 0; i < maxNewton; i++) {
    if (karanaAt(current).name != startName) {
      hi = current;
      break;
    }
    lo = current;
    final s = stateAt(current);
    final tithi = calcTithi(s.sun, s.moon);
    final remaining = calcKarana(s.sun, s.moon, tithi).degreesRemaining;
    final relSpeed = s.moonSpeed - s.sunSpeed;
    if (relSpeed <= 0) break;
    current += remaining / relSpeed;
  }

  var upper =
      hi ?? ((karanaAt(current).name != startName) ? current : current + 0.5);

  for (var i = 0; i < maxBisections && (upper - lo) > toleranceDays; i++) {
    final mid = (lo + upper) / 2;
    if (karanaAt(mid).name != startName) {
      upper = mid;
    } else {
      lo = mid;
    }
  }

  return (jd: upper, karana: karanaAt(upper));
}

/// Find the JD when the current nakshatra ends and the next one begins.
({double jd, Nakshatra nakshatra}) nextNakshatra(
  double jd,
  MoonSiderealStateAt stateAt, {
  double toleranceDays = 1e-8,
  int maxNewton = 4,
  int maxBisections = 40,
}) {
  final startIndex = calcNakshatra(stateAt(jd).longitude).index;

  Nakshatra nakAt(double t) => calcNakshatra(stateAt(t).longitude);

  var lo = jd;
  double? hi;
  var current = jd;

  for (var i = 0; i < maxNewton; i++) {
    if (nakAt(current).index != startIndex) {
      hi = current;
      break;
    }
    lo = current;
    final s = stateAt(current);
    final remaining = calcNakshatra(s.longitude).degreesRemaining;
    if (s.speed <= 0) break;
    current += remaining / s.speed;
  }

  var upper =
      hi ?? ((nakAt(current).index != startIndex) ? current : current + 1.5);

  for (var i = 0; i < maxBisections && (upper - lo) > toleranceDays; i++) {
    final mid = (lo + upper) / 2;
    if (nakAt(mid).index != startIndex) {
      upper = mid;
    } else {
      lo = mid;
    }
  }

  return (jd: upper, nakshatra: nakAt(upper));
}

/// Find the JD when the current yoga ends and the next one begins.
({double jd, Yoga yoga}) nextYoga(
  double jd,
  SiderealStateAt stateAt, {
  double toleranceDays = 1e-8,
  int maxNewton = 4,
  int maxBisections = 40,
}) {
  final s0 = stateAt(jd);
  final startNumber = calcYoga(s0.sun, s0.moon).number;

  Yoga yogaAt(double t) {
    final s = stateAt(t);
    return calcYoga(s.sun, s.moon);
  }

  var lo = jd;
  double? hi;
  var current = jd;

  for (var i = 0; i < maxNewton; i++) {
    if (yogaAt(current).number != startNumber) {
      hi = current;
      break;
    }
    lo = current;
    final s = stateAt(current);
    final remaining = calcYoga(s.sun, s.moon).degreesRemaining;
    final combinedSpeed = s.sunSpeed + s.moonSpeed; // °/day
    if (combinedSpeed <= 0) break;
    current += remaining / combinedSpeed;
  }

  var upper =
      hi ?? ((yogaAt(current).number != startNumber) ? current : current + 1.0);

  for (var i = 0; i < maxBisections && (upper - lo) > toleranceDays; i++) {
    final mid = (lo + upper) / 2;
    if (yogaAt(mid).number != startNumber) {
      upper = mid;
    } else {
      lo = mid;
    }
  }

  return (jd: upper, yoga: yogaAt(upper));
}

/// Find the JD of the next vara change (next Yamakoti sunrise) and the
/// vara that begins at that point.
///
/// [sunriseAt] should return the JD of sunrise at Yamakoti for a given JD.
/// A simple approximation: next day's 18:00 UT (equatorial sunrise at
/// Yamakoti ≈ 06:00 local = 18:00 UT).
({double jd, Vara vara}) nextVara(double jd, SunriseAt sunriseAt) {
  final nextSunrise = sunriseAt(jd);
  return (jd: nextSunrise, vara: calcVara(nextSunrise));
}
