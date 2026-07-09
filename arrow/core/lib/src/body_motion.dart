// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

/// Mean daily motion in tropical longitude (°/day).
///
/// Values are geocentric apparent mean motions, rounded from long-term
/// ephemeris averages. Source: Astronomical Almanac (2020), mean synodic
/// rates; Moon from the sidereal month (27.3217 d → 360/27.3217 ≈ 13.1764).
/// Sun from the tropical year (365.2422 d → 360/365.2422 ≈ 0.9856).
///
/// Outers (Uranus/Neptune/Pluto) included for completeness. Nodes are
/// retrograde in mean motion; magnitude is given here. Classification
/// against these is magnitude-only (see [meanDailyMotion] users in
/// arrow_calc).
const Map<Body, double> meanDailyMotion = {
  Body.moon: 13.1764,
  Body.mercury: 1.383,
  Body.venus: 1.2,
  Body.sun: 0.9856,
  Body.mars: 0.524,
  Body.jupiter: 0.0831,
  Body.saturn: 0.0335,
  Body.uranus: 0.0117,
  Body.neptune: 0.006,
  Body.pluto: 0.004,
  // Chiron: ~50-year orbit → 360/(50*365.25) ≈ 0.0197°/day mean geocentric;
  // empirical geocentric mean ≈ 0.026°/day including retrograde loops.
  Body.chiron: 0.026,
  // Mean node motion ≈ -0.0529°/day (retrograde); magnitude here.
  Body.rahu: 0.0529,
  Body.ketu: 0.0529,
};

/// Station threshold (°/day) below which a body is considered stationary.
///
/// Heuristic: 10% of mean daily motion. No authoritative single source —
/// libaditya only checks `speed < 0` for retrograde and does not detect
/// stations. Revisit if fletch's station detection diverges.
///
/// For outers this lands at very small values (~0.001°/day) — acceptable
/// since station classification rarely matters for them.
final Map<Body, double> stationThreshold = {
  for (final e in meanDailyMotion.entries) e.key: e.value * 0.1,
};
