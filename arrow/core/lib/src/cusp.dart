// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

import 'longitude.dart';

/// A house cusp with its number and longitude.
class Cusp {
  /// House number (1-12).
  final int house;

  /// The cusp longitude.
  final Longitude longitude;

  Cusp(
    this.house,
    double eclipticLongitude,
    CalcConfig config, {
    double? nakLongitude,
  }) : longitude = Longitude(
         eclipticLongitude,
         VargaType.rashi,
         config,
         nakLongitude: nakLongitude,
       );

  int get sign => longitude.sign;
  int get nakshatra => longitude.nakshatra;
  int get pada => longitude.pada;

  @override
  String toString() =>
      'Cusp($house, ${longitude.eclipticLongitude.toStringAsFixed(2)}°)';
}
