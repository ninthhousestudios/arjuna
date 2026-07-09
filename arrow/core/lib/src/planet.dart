// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'celestial_body.dart';
import 'motion_state.dart';

/// A planet with motion + synodic state derived from ephemeris data.
class Planet extends CelestialBody {
  Planet(super.body, super.snapshot, super.config, super.vargaType);

  /// Whether this planet is retrograde (negative ecliptic speed).
  ///
  /// Sun and Moon are never retrograde; Rahu/Ketu always move in mean
  /// retrograde but that's their natural motion, not "retrograde" in the
  /// astrological sense. This getter reports raw speed sign.
  bool get isRetrograde => position.speedLongitude < 0;

  /// Direction of motion classified against the body's station threshold.
  Direction get direction => directionOf(body, position.speedLongitude);

  /// Speed magnitude classified against the body's mean daily motion.
  SpeedClass get speedClass => classifySpeed(body, position.speedLongitude);

  /// Solar-phase data. Null for the lunar nodes (Rahu/Ketu) — mathematical
  /// points have no `swe_pheno_ut` output. Consumers must handle null.
  PhenoData? get pheno => snapshot.phenoData[body];

  /// Synodic state (elongation category + waxing flag). Null when [pheno]
  /// is null (Rahu/Ketu).
  SynodicState? get synodicState {
    final p = pheno;
    if (p == null) return null;
    final sun = snapshot.bodiesEcliptic[Body.sun];
    if (sun == null) return null;
    return SynodicState.from(
      body: body,
      bodyLongitude: position.longitude,
      sunLongitude: sun.longitude,
      pheno: p,
    );
  }
}
