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

bool _isMoonHora(int sign, double inSignDeg) {
  final firstHalf = inSignDeg < 15;
  return firstHalf != sign.isOdd;
}

class _SolarBeing {
  final int sign;
  final String aditya;
  final String beingName;
  final BeingType beingType;
  final String beingSlug;
  final bool moonHora;

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
          '${_trimsamsaType(_adityaSign(tropicalLon), tropicalLon % 30).name}',
      moonHora = _isMoonHora(_adityaSign(tropicalLon), tropicalLon % 30);

  bool sameAs(_SolarBeing other) =>
      sign == other.sign &&
      beingType == other.beingType &&
      moonHora == other.moonHora;
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

  Map<String, String> _entry(_SolarBeing b, String start, String end) {
    final e = <String, String>{
      'start': start,
      'end': end,
      'aditya': b.aditya,
      'being_name': b.beingName,
      'being_type': b.beingType.name,
      'being_slug': b.beingSlug,
      'hora': b.moonHora ? 'moon' : 'sun',
    };
    if (b.moonHora) {
      final naga = BeingData.forSign(b.sign, BeingType.naga);
      e['naga_name'] = naga.name;
      e['naga_slug'] = '${b.aditya}-naga';
    }
    return e;
  }

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

      entries.add(
        _entry(
          current,
          segStartDt.toIso8601String(),
          crossDt.toIso8601String(),
        ),
      );

      segmentStartJd = crossJd;
      current = _beingAt(eph, crossJd);
    }
    t += stepDays;
  }

  // Final segment to the end boundary.
  entries.add(
    _entry(
      current,
      fromJulianDay(segmentStartJd).toIso8601String(),
      fromJulianDay(endJd).toIso8601String(),
    ),
  );

  eph.close();

  final json = const JsonEncoder.withIndent('  ').convert(entries);
  stdout.writeln(json);
}
