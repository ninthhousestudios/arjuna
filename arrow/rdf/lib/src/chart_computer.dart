// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:charts_dart/charts_dart.dart' as oacf;

import 'chart_identity.dart';
import 'computed_view.dart';
import 'view_spec.dart';

/// Bridges a charts_dart [oacf.ChartData] to the serializer's neutral inputs by
/// running arrow's ephemeris + domain compute. This is the ONLY SWE-touching
/// piece — isolated so the serializer stays pure and golden tests need no
/// ephemeris. Holds a [SweFacade]; the caller owns its lifecycle (`dispose`).
final class ChartComputer {
  final SweFacade _facade;
  const ChartComputer(this._facade);

  /// The OACF identity, neutralised. Uses `ChartData.julianDay` when present,
  /// else derives jd from the civil time (OACF §6). jd is canonical (I1).
  ChartIdentity identity(oacf.ChartData chart) {
    final jd = chart.julianDay ?? julianDay(chart.utcDateTime);
    final location = chart.birthLocation;
    return ChartIdentity(
      jd: jd,
      lat: location.latitude,
      lon: location.longitude,
      name: chart.name,
      gender: _genderString(chart.gender),
      rodden: chart.roddenRating,
      tags: chart.tags ?? const <String>[],
      placename: location.city.isEmpty ? null : location.city,
      country: location.country.isEmpty ? null : location.country,
      civilDate: _civilDate(chart.dateTime),
      civilTime: _civilTime(chart.dateTime),
      utcOffset: chart.utcOffsetHours,
    );
  }

  /// Compute the placements View for [chart] under [view]: one SWE call
  /// ([SweFacade.calcAll]) → arrow `Chart` → the 9 grahas' longitude / sign /
  /// retrograde, plus the lagna sign. Whole-sign house =
  /// ((sign - lagnaSign) mod 12) + 1.
  ComputedView compute(oacf.ChartData chart, ViewSpec view) {
    final id = identity(chart);
    final location = Location(latitude: id.lat, longitude: id.lon);
    final snapshot = _facade.calcAll(id.jd, location, view.toSweConfig());
    final arrowChart = Chart(snapshot, view.toCalcConfig());
    final lagnaSign = arrowChart.cusp(1).sign;
    final placements = <ComputedPlacement>[
      for (final graha in arrowChart.grahas)
        ComputedPlacement(
          body: graha.body,
          longitude: graha.rawLongitude,
          sign: graha.sign,
          house: wholeSignHouse(graha.sign, lagnaSign),
          retrograde: graha.isRetrograde,
        ),
    ];
    return ComputedView(lagnaSign: lagnaSign, placements: placements);
  }

  static String? _genderString(oacf.Gender? gender) => switch (gender) {
    oacf.Gender.male => 'male',
    oacf.Gender.female => 'female',
    oacf.Gender.unknown => null,
    null => null,
  };

  static String _civilDate(DateTime dt) =>
      '${_pad(dt.year, 4)}-${_pad(dt.month, 2)}-${_pad(dt.day, 2)}';

  static String _civilTime(DateTime dt) =>
      '${_pad(dt.hour, 2)}:${_pad(dt.minute, 2)}:${_pad(dt.second, 2)}';

  static String _pad(int value, int width) =>
      value.toString().padLeft(width, '0');
}
