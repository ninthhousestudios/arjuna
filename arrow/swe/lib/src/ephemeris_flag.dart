// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:swisseph_rs/swisseph_rs.dart' as swe;

/// Map an [EphemerisSource] to its SWE calc flag bit.
swe.CalcFlags ephemerisFlag(EphemerisSource source) => switch (source) {
  EphemerisSource.swissEph => swe.CalcFlags.swiEph,
  EphemerisSource.moshier => swe.CalcFlags.mosEph,
  EphemerisSource.jplEph => swe.CalcFlags.jplEph,
};
