// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:convert';
import 'dart:io';

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph_rs/swisseph_rs.dart' as swe;

const _adityaNames = <int, String>{
  1: 'dhata',
  2: 'aryama',
  3: 'mitra',
  4: 'varuna',
  5: 'indra',
  6: 'vivasvan',
  7: 'tvashta',
  8: 'vishnu',
  9: 'amshu',
  10: 'bhaga',
  11: 'pusha',
  12: 'parjanya',
};

int _adityaSign(double tropicalLon) {
  final raw = (tropicalLon % 360) ~/ 30;
  return (raw.toInt() + 1) % 12 + 1;
}

BeingType _trimsamsaType(int sign, double inSignDeg) {
  if (sign.isOdd) {
    if (inSignDeg < 5) return BeingType.gandharva;
    if (inSignDeg < 10) return BeingType.rakshasa;
    if (inSignDeg < 18) return BeingType.rishi;
    if (inSignDeg < 25) return BeingType.yaksha;
    return BeingType.apsara;
  } else {
    if (inSignDeg < 5) return BeingType.apsara;
    if (inSignDeg < 12) return BeingType.yaksha;
    if (inSignDeg < 20) return BeingType.rishi;
    if (inSignDeg < 25) return BeingType.rakshasa;
    return BeingType.gandharva;
  }
}

class _SolarBeing {
  final int sign;
  final String aditya;
  final String beingName;
  final BeingType beingType;
  final String beingSlug;

  _SolarBeing(double tropicalLon)
    : sign = _adityaSign(tropicalLon),
      aditya = _adityaNames[_adityaSign(tropicalLon)]!,
      beingName = BeingData.forSign(
        _adityaSign(tropicalLon),
        _trimsamsaType(_adityaSign(tropicalLon), tropicalLon % 30),
      ).name,
      beingType = _trimsamsaType(_adityaSign(tropicalLon), tropicalLon % 30),
      beingSlug =
          '${_adityaNames[_adityaSign(tropicalLon)]!}-'
          '${_trimsamsaType(_adityaSign(tropicalLon), tropicalLon % 30).name}';

  bool sameAs(_SolarBeing other) =>
      sign == other.sign && beingType == other.beingType;
}

double _sunLongitude(swe.Ephemeris eph, double jdUt) {
  final result = eph.calcUtWithConfig(
    swe.JdUt1(jdUt),
    swe.Body.sun,
    swe.CalcFlags.mosEph | swe.CalcFlags.speed,
    swe.EphemerisConfig(),
  );
  return result.longitude;
}

_SolarBeing _beingAt(swe.Ephemeris eph, double jdUt) =>
    _SolarBeing(_sunLongitude(eph, jdUt));

double _bisect(swe.Ephemeris eph, double jd1, double jd2, _SolarBeing from) {
  while ((jd2 - jd1) > 1.0 / 86400) {
    final mid = (jd1 + jd2) / 2;
    final midBeing = _beingAt(eph, mid);
    if (!from.sameAs(midBeing)) {
      jd2 = mid;
    } else {
      jd1 = mid;
    }
  }
  return jd2;
}

void main() {
  final eph = swe.Ephemeris(
    swe.EphemerisConfig(ephemerisSource: swe.EphemerisSource.moshier),
  );

  final start = DateTime.utc(2026);
  final end = DateTime.utc(2036);
  final startJd = julianDay(start);
  final endJd = julianDay(end);

  const stepDays = 0.5; // 12 hours — Sun moves ~0.5°/day

  final entries = <Map<String, String>>[];
  var currentJd = startJd;
  var current = _beingAt(eph, currentJd);
  var segmentStartJd = currentJd;

  var t = currentJd + stepDays;
  while (t <= endJd) {
    final next = _beingAt(eph, t);
    if (!current.sameAs(next)) {
      final crossJd = _bisect(eph, t - stepDays, t, current);
      final crossDt = fromJulianDay(crossJd);
      final segStartDt = fromJulianDay(segmentStartJd);

      entries.add({
        'start': segStartDt.toIso8601String(),
        'end': crossDt.toIso8601String(),
        'aditya': current.aditya,
        'being_name': current.beingName,
        'being_type': current.beingType.name,
        'being_slug': current.beingSlug,
      });

      segmentStartJd = crossJd;
      current = _beingAt(eph, crossJd);
    }
    t += stepDays;
  }

  // Final segment to the end boundary.
  entries.add({
    'start': fromJulianDay(segmentStartJd).toIso8601String(),
    'end': fromJulianDay(endJd).toIso8601String(),
    'aditya': current.aditya,
    'being_name': current.beingName,
    'being_type': current.beingType.name,
    'being_slug': current.beingSlug,
  });

  eph.close();

  final json = const JsonEncoder.withIndent('  ').convert(entries);
  stdout.writeln(json);
}
