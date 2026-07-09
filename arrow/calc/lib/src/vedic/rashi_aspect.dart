// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

/// Rashi (sign-to-sign) aspects, ported from libaditya.
///
/// Three modes exist:
/// - **quadrant** (default): aspects based on quadrant relationships.
/// - **element**: aspects based on elemental affinities.
/// - **conventional**: the classical Jaimini formulation.
///
/// An empty sign does NOT cast a rashi aspect — use [doesAspectWithOccupants]
/// or [mutual] to enforce the occupancy requirement.
class RashiAspect {
  const RashiAspect._();

  static const Map<int, List<int>> _quadrant = {
    1: [2, 5, 8],
    2: [7, 10, 1],
    3: [6, 9, 12],
    4: [5, 8, 11],
    5: [10, 1, 4],
    6: [9, 12, 3],
    7: [8, 11, 2],
    8: [1, 4, 7],
    9: [12, 3, 6],
    10: [11, 2, 5],
    11: [4, 7, 10],
    12: [3, 6, 9],
  };

  static const Map<int, List<int>> _element = {
    1: [2, 8, 11],
    2: [7, 4, 1],
    3: [6, 9, 12],
    4: [5, 2, 11],
    5: [7, 10, 4],
    6: [9, 12, 3],
    7: [8, 11, 5],
    8: [1, 10, 7],
    9: [12, 3, 6],
    10: [11, 2, 8],
    11: [4, 1, 10],
    12: [3, 6, 9],
  };

  static const Map<int, List<int>> _conventional = {
    1: [5, 8, 11],
    2: [4, 7, 10],
    3: [6, 9, 12],
    4: [8, 11, 2],
    5: [7, 10, 1],
    6: [9, 12, 3],
    7: [11, 2, 5],
    8: [10, 1, 4],
    9: [12, 3, 6],
    10: [2, 5, 8],
    11: [1, 4, 7],
    12: [3, 6, 9],
  };

  static Map<int, List<int>> _tableFor(RashiAspectMode mode) {
    return switch (mode) {
      RashiAspectMode.quadrant => _quadrant,
      RashiAspectMode.element => _element,
      RashiAspectMode.conventional => _conventional,
    };
  }

  static bool doesAspect(
    int fromSign,
    int toSign, [
    RashiAspectMode mode = RashiAspectMode.quadrant,
  ]) {
    return _tableFor(mode)[fromSign]!.contains(toSign);
  }

  static bool doesAspectWithOccupants(
    int fromSign,
    int toSign,
    bool fromHasGrahas, [
    RashiAspectMode mode = RashiAspectMode.quadrant,
  ]) {
    return fromHasGrahas && doesAspect(fromSign, toSign, mode);
  }

  /// Mutual aspect status between two signs.
  ///
  /// Returns:
  /// - 0 — no aspect in either direction
  /// - 1 — sign1 aspects sign2 only
  /// - 2 — sign2 aspects sign1 only
  /// - 3 — mutual (both directions, both signs occupied)
  static int mutual(
    int sign1,
    int sign2,
    bool sign1HasGrahas,
    bool sign2HasGrahas, [
    RashiAspectMode mode = RashiAspectMode.quadrant,
  ]) {
    final oneToTwo = doesAspectWithOccupants(
      sign1,
      sign2,
      sign1HasGrahas,
      mode,
    );
    final twoToOne = doesAspectWithOccupants(
      sign2,
      sign1,
      sign2HasGrahas,
      mode,
    );
    if (oneToTwo && twoToOne) return 3;
    if (oneToTwo) return 1;
    if (twoToOne) return 2;
    return 0;
  }
}
