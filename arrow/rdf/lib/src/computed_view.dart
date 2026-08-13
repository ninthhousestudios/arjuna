// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

/// One body's view-scoped placement as computed by arrow — the neutral boundary
/// between the ephemeris/domain compute (ChartComputer) and the pure serializer.
///
/// [sign] and [longitude] are BOTH read from the same arrow `Longitude` object,
/// so they share a single source and cannot disagree. Sign is computed exactly
/// once — by arrow, circle-aware (a naive floor(longitude / 30) would be wrong
/// for Circle.aditya). The serializer does no sign arithmetic; it maps [sign] to
/// a canon rashi IRI. The ARP-2 review invariant (vidya/astrology-research/3)
/// lives as a golden-test assertion over the emitted quads, not a second path.
final class ComputedPlacement {
  final Body body;

  /// Ecliptic longitude in degrees [0, 360) within the view's circle/ayanamsa.
  final double longitude;

  /// Sign 1..12, circle-aware, from arrow's `Longitude.sign` — the sole source
  /// of the emitted `chart:sign` and of the whole-sign house derivation.
  final int sign;

  /// Whole-sign house 1..12: ((sign - lagnaSign) mod 12) + 1.
  final int house;

  final bool retrograde;

  const ComputedPlacement({
    required this.body,
    required this.longitude,
    required this.sign,
    required this.house,
    required this.retrograde,
  });
}

/// The computed placements View for one Chart under one [ViewSpec].
final class ComputedView {
  /// Ascendant sign 1..12 — whole-sign houses derive from it.
  final int lagnaSign;

  /// The grahas' placements, in [Body.grahas] order.
  final List<ComputedPlacement> placements;

  const ComputedView({required this.lagnaSign, required this.placements});
}

/// Whole-sign house of a body from its [bodySign] and the [lagnaSign] (both
/// 1..12), result 1..12: `((bodySign - lagnaSign) mod 12) + 1`. Pure and
/// SWE-free so it is unit-testable without an ephemeris. Relies on Dart's `%`
/// yielding a non-negative result for a positive divisor (e.g. `-4 % 12 == 8`),
/// so a body in a sign earlier than the lagna wraps forward correctly.
int wholeSignHouse(int bodySign, int lagnaSign) =>
    (bodySign - lagnaSign) % 12 + 1;
