// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

import 'nakshatra_data.dart';
import 'planet.dart';

/// A nakshatra in the context of a chart — knows which planets occupy it.
///
/// Only meaningful for rashi (D1); divisional charts don't track nakshatras.
class Nakshatra {
  /// Nakshatra number (1-27).
  final int number;

  final List<Planet> _planets;

  Nakshatra(this.number, this._planets);

  Body get lord => NakshatraData.lord(number);
  String get deity => NakshatraData.deity(number);
  String get name => NakshatraData.name(number);

  /// Planets occupying this nakshatra.
  List<Planet> get planets => List.unmodifiable(_planets);

  @override
  String toString() => 'Nakshatra($number, $name)';
}
