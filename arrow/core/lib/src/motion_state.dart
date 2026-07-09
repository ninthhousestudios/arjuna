// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'body_motion.dart';

/// Direction of motion in ecliptic longitude.
enum Direction { direct, stationary, retrograde }

/// Classification of a body's instantaneous longitudinal speed relative to
/// its long-term mean daily motion.
///
/// Magnitude-only — direction is captured separately by [Direction]. A body
/// whose speed magnitude is at or below its [stationThreshold] returns
/// [SpeedClass.stationary] regardless of direction.
enum SpeedClass { fast, mean, slow, stationary }

/// Fraction of mean daily motion below which magnitude is "slow".
/// Symmetric with [_fastBand] — values land in the "mean" band between.
const double _slowBand = 0.8;

/// Fraction of mean daily motion above which magnitude is "fast".
const double _fastBand = 1.2;

/// Direction of motion for [body] at instantaneous longitudinal [speed]
/// (°/day). Uses [stationThreshold] for the stationary band.
Direction directionOf(Body body, double speed) {
  final t = stationThreshold[body] ?? 0.0;
  if (speed.abs() <= t) return Direction.stationary;
  return speed < 0 ? Direction.retrograde : Direction.direct;
}

/// Speed classification for [body] at longitudinal [speed] (°/day).
///
/// Magnitude-only. Bands (as fractions of [meanDailyMotion]):
/// - `|speed| <= stationThreshold` → [SpeedClass.stationary]
/// - `|speed| < 0.8 * mean`        → [SpeedClass.slow]
/// - `0.8 * mean <= |speed| <= 1.2 * mean` → [SpeedClass.mean]
/// - `|speed| > 1.2 * mean`        → [SpeedClass.fast]
///
/// 0.8/1.2 bands are a heuristic — libaditya has no speed classifier so
/// there is no reference to match. Wide enough to absorb normal variation,
/// narrow enough that a body near a station reads `slow` before reading
/// `stationary`.
SpeedClass classifySpeed(Body body, double speed) {
  final t = stationThreshold[body] ?? 0.0;
  if (speed.abs() <= t) return SpeedClass.stationary;
  final mean = meanDailyMotion[body];
  if (mean == null) return SpeedClass.mean;
  final mag = speed.abs();
  if (mag < mean * _slowBand) return SpeedClass.slow;
  if (mag > mean * _fastBand) return SpeedClass.fast;
  return SpeedClass.mean;
}

/// Tradition-agnostic elongation bucket derived from the Sun-planet
/// angular separation (`PhenoData.elongation`, always `[0, 180]`).
///
/// Uniform across Moon + planets. For outer planets (Jupiter/Saturn) the
/// full range is reachable; for inner planets (Mercury/Venus) only
/// [conjunction]..[quadrature] are reachable (max elongation ~28°/47°);
/// [gibbous] and [opposition] are Moon+outers only.
///
/// Boundaries:
/// - `conjunction`     — |elongation| < 5°
/// - `nearConjunction` — 5° ≤ |elongation| < 20°
/// - `earlyElongation` — 20° ≤ |elongation| < 60°
/// - `quadrature`      — 60° ≤ |elongation| < 120°
/// - `gibbous`         — 120° ≤ |elongation| < 150°
/// - `opposition`      — |elongation| ≥ 150°
enum ElongationCategory {
  conjunction,
  nearConjunction,
  earlyElongation,
  quadrature,
  gibbous,
  opposition;

  static ElongationCategory of(double elongation) {
    final e = elongation.abs();
    if (e < 5.0) return ElongationCategory.conjunction;
    if (e < 20.0) return ElongationCategory.nearConjunction;
    if (e < 60.0) return ElongationCategory.earlyElongation;
    if (e < 120.0) return ElongationCategory.quadrature;
    if (e < 150.0) return ElongationCategory.gibbous;
    return ElongationCategory.opposition;
  }
}

/// Derived synodic state for one body — wraps the raw [PhenoData] with a
/// tradition-agnostic [ElongationCategory] and a waxing flag.
class SynodicState {
  /// Raw pheno pass-through.
  final PhenoData pheno;

  /// Bucket derived from [PhenoData.elongation].
  final ElongationCategory category;

  /// Whether illumination is increasing since last conjunction.
  ///
  /// Derived from the Sun-body ecliptic longitude difference
  /// `Δλ = (bodyLongitude - sunLongitude) mod 360`:
  ///
  /// - Moon: waxing iff `Δλ ∈ (0°, 180°)` — east of the Sun, evening
  ///   object between new and full.
  /// - Inner planets (Mercury, Venus): waxing iff `Δλ ∈ (180°, 360°)` —
  ///   west of the Sun, morning star between inferior and superior
  ///   conjunction.
  /// - Sun and outer planets (Mars and beyond): `null`. Sun has no phase
  ///   relative to itself; outer planets have a max phase angle of
  ///   ~12° (Mars) and are effectively always full.
  ///
  /// Phase angle alone (`PhenoData.phaseAngle`) cannot distinguish
  /// waxing from waning: Swe returns it in `[0°, 180°]` via `acos`, and
  /// the same value occurs once on each side of the synodic cycle.
  final bool? isWaxing;

  const SynodicState({
    required this.pheno,
    required this.category,
    required this.isWaxing,
  });

  factory SynodicState.from({
    required Body body,
    required double bodyLongitude,
    required double sunLongitude,
    required PhenoData pheno,
  }) {
    return SynodicState(
      pheno: pheno,
      category: ElongationCategory.of(pheno.elongation),
      isWaxing: _waxingFor(body, bodyLongitude, sunLongitude),
    );
  }

  static bool? _waxingFor(Body body, double bodyLong, double sunLong) {
    final delta = ((bodyLong - sunLong) % 360.0 + 360.0) % 360.0;
    switch (body) {
      case Body.moon:
        return delta > 0.0 && delta < 180.0;
      case Body.mercury:
      case Body.venus:
        return delta > 180.0 && delta < 360.0;
      default:
        return null;
    }
  }
}
