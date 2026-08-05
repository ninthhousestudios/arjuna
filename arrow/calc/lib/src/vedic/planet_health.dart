// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';

import 'lajjitaadi.dart';

/// Virupa weights for the Lajjitaadi point system.
///
/// A virupa is 1/60 of a rupa — the standard Vedic strength unit, and the
/// same unit [Aspect.strength] already speaks (60 = a full aspect). Each
/// avastha carries a signed virupa value; the four afflicted states are
/// negative, the three healthy states positive.
///
/// The default ladder follows Laura's affliction/health ordering
/// (shamed worst → thirsty least bad; proud best → delighted least good),
/// spaced so shamed/proud carry a full rupa and each step down drops 15:
///
/// | State     | Virupas |
/// |-----------|---------|
/// | shamed    | -60     |
/// | starved   | -45     |
/// | agitated  | -30     |
/// | thirsty   | -15     |
/// | delighted | +30     |
/// | healthy   | +45     |
/// | proud     | +60     |
///
/// Every field is overridable so the ladder can be retuned without touching
/// the scorer.
class LajjitaadiWeights {
  final double shamed;
  final double starved;
  final double agitated;
  final double thirsty;
  final double delighted;
  final double healthy;
  final double proud;

  /// Strength (0..60) attributed to each compound shame trigger.
  ///
  /// The Sun/Mars/Saturn conjunctions that fire shame already carry a
  /// strength of 60; the [ShameCondition] factors carry none, because
  /// libaditya records them as bare conditions. These weights supply it,
  /// grading shame by *how* it was caused — a node conjunction is a hard
  /// hit, a 5th-cusp contact is a degree-exact one, mere residence in the
  /// 5th sign is the softest.
  final double conjunctNodesStrength;
  final double conjunctFifthCuspStrength;
  final double inFifthSignStrength;

  const LajjitaadiWeights({
    this.shamed = -60,
    this.starved = -45,
    this.agitated = -30,
    this.thirsty = -15,
    this.delighted = 30,
    this.healthy = 45,
    this.proud = 60,
    this.conjunctNodesStrength = 60,
    this.conjunctFifthCuspStrength = 45,
    this.inFifthSignStrength = 30,
  });

  static const defaults = LajjitaadiWeights();

  double virupasFor(LajjitaadiState state) => switch (state) {
    LajjitaadiState.shamed => shamed,
    LajjitaadiState.starved => starved,
    LajjitaadiState.agitated => agitated,
    LajjitaadiState.thirsty => thirsty,
    LajjitaadiState.delighted => delighted,
    LajjitaadiState.healthy => healthy,
    LajjitaadiState.proud => proud,
  };

  double strengthFor(ShameCondition condition) => switch (condition) {
    ShameCondition.conjunctNodes => conjunctNodesStrength,
    ShameCondition.conjunctFifthCusp => conjunctFifthCuspStrength,
    ShameCondition.inFifthSign => inFifthSignStrength,
  };
}

/// One [LajjitaadiFactor] with its virupa contribution resolved.
class ScoredFactor {
  final LajjitaadiState state;
  final LajjitaadiFactor factor;

  /// Strength 0..60 actually used. Conjunction/sign/dignity factors are 60,
  /// aspect factors carry the Parashara degree-based strength, and
  /// [ShameCondition] factors take their value from [LajjitaadiWeights].
  final double strength;

  /// `virupasFor(state) * strength / 60` — signed.
  final double virupas;

  const ScoredFactor({
    required this.state,
    required this.factor,
    required this.strength,
    required this.virupas,
  });

  @override
  String toString() =>
      '${state.libadityaName} ${factor.source}'
      '${factor.planet != null ? ' ${factor.planet!.name}' : ''}'
      '${factor.lord != null ? ' lord=${factor.lord!.name}' : ''}'
      '${factor.dignity != null ? ' ${factor.dignity}' : ''}'
      '${factor.detail != null ? ' (${factor.detail})' : ''}'
      ' @${strength.toStringAsFixed(1)} → ${virupas.toStringAsFixed(1)}v';
}

/// The summed Lajjitaadi health of one karaka, in virupas.
class PlanetHealthScore {
  final Body body;

  /// Sum of every [ScoredFactor.virupas]. Positive = net healthy.
  final double virupas;

  /// Per-state subtotals, so a total can be read back to its causes.
  final Map<LajjitaadiState, double> byState;

  /// Every scored factor, deduplicated, in state order.
  final List<ScoredFactor> factors;

  const PlanetHealthScore({
    required this.body,
    required this.virupas,
    required this.byState,
    required this.factors,
  });

  /// The states present at all, regardless of sign or weight.
  Iterable<LajjitaadiState> get states => byState.keys;

  bool has(LajjitaadiState state) => byState.containsKey(state);

  bool get isShamed => has(LajjitaadiState.shamed);
  bool get isProud => has(LajjitaadiState.proud);

  @override
  String toString() =>
      'PlanetHealthScore(${body.name}, ${virupas.toStringAsFixed(1)}v)';
}

/// A ranked karaka together with the beings it activates.
///
/// The being is only as healthy as the planet activating it, so this pairs
/// the avastha score with the Aditya-system lookup: which Aditya the planet
/// sits in, which side of the mountain ([hora]), and which of the 84 beings
/// the Trimsamsa segment hands it.
class BeingHealth {
  /// 1 = healthiest. Ties share a rank (competition ranking).
  final int rank;

  final PlanetHealthScore score;

  /// Sign number 1..12 in the configured [Circle] — an Aditya number when
  /// the chart uses [Circle.aditya].
  final int sign;

  final Hora hora;

  /// The being the Trimsamsa segment activates: Gandharva, Rakshasa, Rishi,
  /// Yaksha, or Apsara.
  final Being trimsamsaBeing;

  /// The Hora being — the Aditya itself (Sun hora) or its Naga (Moon hora).
  final Being horaBeing;

  /// The parent Aditya of [sign], regardless of hora.
  final Being aditya;

  const BeingHealth({
    required this.rank,
    required this.score,
    required this.sign,
    required this.hora,
    required this.trimsamsaBeing,
    required this.horaBeing,
    required this.aditya,
  });

  Body get body => score.body;
  double get virupas => score.virupas;

  @override
  String toString() =>
      'BeingHealth(#$rank ${body.name} ${virupas.toStringAsFixed(1)}v '
      '${trimsamsaBeing.name}/${horaBeing.name})';
}

/// Ranks the seven embodied planets from healthiest to least healthy by
/// summing weighted Lajjitaadi avastha points.
///
/// The algorithm, in full:
///
/// 1. Compute Lajjitaadi for all seven karakas ([Lajjitaadi.compute]).
/// 2. Drop duplicate factors — libaditya can record the same physical fact
///    twice (Saturn conjunct a planet it is also the natural enemy of fires
///    both the "enemy conjunction starves" and "Saturn conjunction always
///    starves" rules; a friendly Jupiter conjunction likewise delights
///    twice). One cause, one score.
/// 3. Score each remaining factor as `virupasFor(state) * strength / 60`,
///    so conjunction/sign/dignity factors land at full weight and aspect
///    factors are prorated by Parashara aspect strength.
/// 4. Sum. Most virupas = healthiest.
///
/// The model is deliberately purely additive: no state trumps another, and
/// a planet can be both proud and shamed. That is visible in the output
/// rather than resolved by the scorer — [PlanetHealthScore.byState] and
/// [PlanetHealthScore.factors] preserve the whole picture.
class PlanetHealth {
  const PlanetHealth._();

  /// Score every karaka in [varga]. Karakas Lajjitaadi omits (no factors in
  /// any state) score 0.
  static Map<Body, PlanetHealthScore> score(
    Varga varga, {
    LajjitaadiWeights weights = LajjitaadiWeights.defaults,
  }) {
    final lajjitaadi = Lajjitaadi.compute(varga);
    return {
      for (final karaka in varga.karakas)
        karaka.body: _scoreOne(karaka.body, lajjitaadi[karaka.body], weights),
    };
  }

  /// Rank every karaka in [varga], healthiest first, annotated with the
  /// beings it activates.
  static List<BeingHealth> rank(
    Varga varga, {
    LajjitaadiWeights weights = LajjitaadiWeights.defaults,
  }) {
    final scores = score(varga, weights: weights);
    final ordered = varga.karakas.toList()
      ..sort((a, b) {
        final byVirupas = scores[b.body]!.virupas.compareTo(
          scores[a.body]!.virupas,
        );
        // Dart's sort is not stable — fall back to karaka order for ties.
        return byVirupas != 0
            ? byVirupas
            : a.body.index.compareTo(b.body.index);
      });

    final ranked = <BeingHealth>[];
    for (var i = 0; i < ordered.length; i++) {
      final karaka = ordered[i];
      final score = scores[karaka.body]!;
      final tiedWithPrevious =
          i > 0 && scores[ordered[i - 1].body]!.virupas == score.virupas;
      ranked.add(
        BeingHealth(
          rank: tiedWithPrevious ? ranked[i - 1].rank : i + 1,
          score: score,
          sign: karaka.sign,
          hora: karaka.hora,
          trimsamsaBeing: karaka.trimsamsaBeing,
          horaBeing: karaka.horaBeing,
          aditya: BeingData.forSign(karaka.sign, BeingType.aditya),
        ),
      );
    }
    return ranked;
  }

  static PlanetHealthScore _scoreOne(
    Body body,
    LajjitaadiResult? result,
    LajjitaadiWeights weights,
  ) {
    final factors = <ScoredFactor>[];
    final byState = <LajjitaadiState, double>{};
    var total = 0.0;

    for (final state in LajjitaadiState.values) {
      final raw = result?.avasthas[state];
      if (raw == null || raw.isEmpty) continue;

      final seen = <String>{};
      var stateTotal = 0.0;
      for (final factor in raw) {
        if (!seen.add(_dedupeKey(factor))) continue;
        final strength = _strengthOf(factor, weights);
        final virupas = weights.virupasFor(state) * strength / 60.0;
        factors.add(
          ScoredFactor(
            state: state,
            factor: factor,
            strength: strength,
            virupas: virupas,
          ),
        );
        stateTotal += virupas;
      }
      byState[state] = stateTotal;
      total += stateTotal;
    }

    return PlanetHealthScore(
      body: body,
      virupas: total,
      byState: byState,
      factors: factors,
    );
  }

  /// A factor's effective strength on the 0..60 virupa scale. Bare
  /// [ShameCondition] factors carry no strength of their own, so the weights
  /// supply one; anything else without a strength counts as a full hit.
  static double _strengthOf(LajjitaadiFactor factor, LajjitaadiWeights w) {
    final condition = factor.condition;
    if (condition != null) return w.strengthFor(condition);
    return factor.strength ?? 60.0;
  }

  /// Identity of a factor for deduplication: same cause, same score, once.
  static String _dedupeKey(LajjitaadiFactor f) => [
    f.source,
    f.planet?.name ?? '',
    f.lord?.name ?? '',
    f.dignity ?? '',
    f.condition?.name ?? '',
    f.strength?.toStringAsFixed(4) ?? '',
  ].join('|');
}
