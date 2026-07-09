// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:math' as math;

import 'package:arrow_options/arrow_options.dart';

/// Dasha years per lord index (0=Ketu … 8=Mercury).
const _dashaYears = [7.0, 20.0, 6.0, 10.0, 7.0, 18.0, 16.0, 19.0, 17.0];

/// Vimshottari lord sequence by index.
const _lordOrder = [
  Body.ketu,
  Body.venus,
  Body.sun,
  Body.moon,
  Body.mars,
  Body.rahu,
  Body.jupiter,
  Body.saturn,
  Body.mercury,
];

const _nakSize = 360.0 / 27.0;

/// One contiguous dasha period at any level of the hierarchy.
class DashaPeriod {
  final double startJd;
  final double durationDays;

  /// Lord chain from outermost (mahadasha) to this level.
  final List<Body> lords;

  double get endJd => startJd + durationDays;

  const DashaPeriod({
    required this.startJd,
    required this.durationDays,
    required this.lords,
  });

  @override
  String toString() =>
      'DashaPeriod(lords=${lords.map((b) => b.name).join('-')}, '
      'start=$startJd, dur=$durationDays)';
}

/// Vimshottari dasha engine, ported from `libaditya/calc/vimshottari.py`.
class Vimshottari {
  const Vimshottari._();

  /// Duration in days of a period identified by a chain of lord indices.
  ///
  /// [lordIndices] is a list of 0-based indices into [_dashaYears].
  /// General: product / 120^(n-1).
  static double periodDuration(List<int> lordIndices, double yrlen) {
    var years = 1.0;
    for (final li in lordIndices) {
      years *= _dashaYears[li];
    }
    final n = lordIndices.length;
    years /= math.pow(120.0, n - 1);
    return years * yrlen;
  }

  /// Compute the dasha seed from Moon's sidereal longitude and birth JD.
  ///
  /// Returns the lord index (0-8) of the first mahadasha and the JD at which
  /// that mahadasha started (usually before birth).
  static ({int firstIndex, double dashaStartJd}) seed(
    double moonSiderealLon,
    double birthJd,
    double yrlen,
  ) {
    final nindex = (moonSiderealLon / _nakSize).floor();
    final elapsed = moonSiderealLon - nindex * _nakSize;
    final elapsedFraction = elapsed / _nakSize;
    final firstIndex = nindex % 9;
    final yearsElapsed = _dashaYears[firstIndex] * elapsedFraction;
    final dashaStartJd = birthJd - yearsElapsed * yrlen;
    return (firstIndex: firstIndex, dashaStartJd: dashaStartJd);
  }

  /// Find the active dasha period at [nowJd] down to [levels] levels.
  ///
  /// Returns one [DashaPeriod] per level (length == levels), ordered from
  /// mahadasha to the innermost active period.
  static List<DashaPeriod> currentDasha({
    required double moonSiderealLon,
    required double birthJd,
    required double nowJd,
    int levels = 3,
    DashaYearLength yrlen = DashaYearLength.saura,
  }) {
    final s = seed(moonSiderealLon, birthJd, yrlen.days);
    return _calcCurrent(
      dlist: [s.firstIndex],
      periodStartJd: s.dashaStartJd,
      nowJd: nowJd,
      level: 0,
      maxLevel: levels,
      yrlen: yrlen.days,
      lordChain: [],
    );
  }

  /// Find the start JD and duration of a specific dasha period without
  /// building the full tree.
  ///
  /// [lords] is a list of [Body] values from mahadasha inward, e.g.
  /// `[Body.sun, Body.moon]` for Sun mahadasha → Moon antardasha.
  static DashaPeriod specificPeriod({
    required double moonSiderealLon,
    required double birthJd,
    required List<Body> lords,
    DashaYearLength yrlen = DashaYearLength.saura,
  }) {
    final days = yrlen.days;
    final s = seed(moonSiderealLon, birthJd, days);
    var currentJd = s.dashaStartJd;
    final targetIndices = lords.map(_lordIndex).toList();

    for (var level = 0; level < lords.length; level++) {
      final target = targetIndices[level];
      final startLord = level == 0 ? s.firstIndex : targetIndices[level - 1];
      var thisLord = startLord;
      var count = 0;
      while (thisLord != target && count < 9) {
        final trialIndices = [...targetIndices.sublist(0, level), thisLord];
        currentJd += periodDuration(trialIndices, days);
        thisLord = (thisLord + 1) % 9;
        count++;
      }
    }
    final duration = periodDuration(targetIndices, days);
    return DashaPeriod(
      startJd: currentJd,
      durationDays: duration,
      lords: lords,
    );
  }

  /// Build the complete dasha tree to [levels] levels.
  ///
  /// Returns a flat list of [DashaPeriod] with full [lords] chains.
  /// At levels=1: 9 mahadashas covering the full 120-year cycle from seed.
  static List<DashaPeriod> fullTree({
    required double moonSiderealLon,
    required double birthJd,
    int levels = 2,
    DashaYearLength yrlen = DashaYearLength.saura,
  }) {
    final s = seed(moonSiderealLon, birthJd, yrlen.days);
    return _buildTree(
      dlist: [s.firstIndex],
      periodStartJd: s.dashaStartJd,
      level: 0,
      maxLevel: levels,
      yrlen: yrlen.days,
      lordChain: [],
    );
  }

  // ── private helpers ────────────────────────────────────────────────────────

  static List<DashaPeriod> _calcCurrent({
    required List<int> dlist,
    required double periodStartJd,
    required double nowJd,
    required int level,
    required int maxLevel,
    required double yrlen,
    required List<Body> lordChain,
  }) {
    if (level + 1 > maxLevel) return [];

    var thisDasha = dlist[level] % 9;
    var thisStartJd = periodStartJd;

    for (var n = 0; n < 9; n++) {
      final durationDays = _durationDays(dlist, thisDasha, level, yrlen);
      final nextStartJd = thisStartJd + durationDays;

      if (nextStartJd > nowJd) {
        final chain = [...lordChain, _lordOrder[thisDasha]];
        final thisPeriod = DashaPeriod(
          startJd: thisStartJd,
          durationDays: durationDays,
          lords: chain,
        );
        final sub = _calcCurrent(
          dlist: [...dlist, thisDasha],
          periodStartJd: thisStartJd,
          nowJd: nowJd,
          level: level + 1,
          maxLevel: maxLevel,
          yrlen: yrlen,
          lordChain: chain,
        );
        return [thisPeriod, ...sub];
      }

      thisDasha = (thisDasha + 1) % 9;
      thisStartJd = nextStartJd;
    }
    return [];
  }

  static List<DashaPeriod> _buildTree({
    required List<int> dlist,
    required double periodStartJd,
    required int level,
    required int maxLevel,
    required double yrlen,
    required List<Body> lordChain,
  }) {
    if (level + 1 > maxLevel) return [];

    var thisDasha = dlist[level] % 9;
    var thisStartJd = periodStartJd;
    final result = <DashaPeriod>[];

    for (var d = 0; d < 9; d++) {
      final durationDays = _durationDays(dlist, thisDasha, level, yrlen);
      final chain = [...lordChain, _lordOrder[thisDasha]];
      final period = DashaPeriod(
        startJd: thisStartJd,
        durationDays: durationDays,
        lords: chain,
      );
      result.add(period);

      if (level + 1 < maxLevel) {
        result.addAll(
          _buildTree(
            dlist: [...dlist, thisDasha],
            periodStartJd: thisStartJd,
            level: level + 1,
            maxLevel: maxLevel,
            yrlen: yrlen,
            lordChain: chain,
          ),
        );
      }

      thisStartJd += durationDays;
      thisDasha = (thisDasha + 1) % 9;
    }
    return result;
  }

  static int _lordIndex(Body b) => _lordOrder.indexOf(b);

  static double _durationDays(
    List<int> dlist,
    int thisDasha,
    int level,
    double yrlen,
  ) {
    var years = 1.0;
    for (var i = 1; i < dlist.length; i++) {
      years *= _dashaYears[dlist[i]];
    }
    years *= _dashaYears[thisDasha];
    years /= math.pow(120.0, level);
    return years * yrlen;
  }
}
