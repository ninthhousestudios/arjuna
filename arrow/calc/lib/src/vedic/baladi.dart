// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:math' as math;

/// Baladi Avastha — age/strength of a planet based on its position in its
/// sign. Ported from `libaditya/calc/avasthas.py:215-231`.
///
/// States in order: Bala (infant), Kumara (youth), Yuva (adult),
/// Vriddha (old), Mrita (dead). Libaditya convention: states are 0-indexed
/// by `floor(inSignDeg / 6)` in odd signs and reversed in even signs.
enum BaladiState {
  bala,
  kumara,
  yuva,
  vriddha,
  mrita;

  static const _names = ['Bala', 'Kumara', 'Yuva', 'Vriddha', 'Mrita'];

  /// Libaditya-compatible title-case name (e.g. `"Bala"`). Used for golden
  /// fixture comparison.
  String get libadityaName => _names[index];
}

class Baladi {
  const Baladi._();

  /// Compute Baladi state from [sign] (1–12) and [inSignDegree] (0–30, the
  /// degree within the sign). Even signs reverse the state order.
  static BaladiState of(int sign, double inSignDegree) {
    var b = math.min(4, (inSignDegree / 6.0).floor());
    if (sign % 2 == 0) b = 4 - b;
    return BaladiState.values[b];
  }
}
