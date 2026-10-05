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
/// The default ladder follows Laura's affliction/health ordering. The four
/// afflictions occupy the full −60/−45/−30/−15 rungs; the three healthy
/// states are shifted one rung *down* the same ladder (+45/+30/+15) so that
/// afflictions weigh more than health. Laura settled this in review: "healthy
/// planets just act like they are supposed to… afflictions are what screw up
/// our lives, so afflictions should have more value." The rung-shift is the
/// chosen reading of that — not a literal halving.
///
/// | State     | Virupas |
/// |-----------|---------|
/// | shamed    | -60     |
/// | starved   | -45     |
/// | agitated  | -30     |
/// | thirsty   | -15     |
/// | delighted | +15     |
/// | healthy   | +30     |
/// | proud     | +45     |
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
  /// libaditya records them as bare conditions. These weights supply it.
  ///
  /// Laura settled the grading in review: shame ranks equally whether the
  /// trigger is conjunction with the nodes or residence in the 5th whole
  /// sign, so both carry full strength (60). Cusps are not used for shame —
  /// it is a whole-sign phenomenon like yogas — so [conjunctFifthCuspStrength]
  /// defaults to 0. The condition is still detected in [Lajjitaadi] and the
  /// [ShameCondition.conjunctFifthCusp] enum value is retained; it simply
  /// contributes nothing here. Raise it to re-enable degree-exact cusp shame.
  final double conjunctNodesStrength;
  final double conjunctFifthCuspStrength;
  final double inFifthSignStrength;

  const LajjitaadiWeights({
    this.shamed = -60,
    this.starved = -45,
    this.agitated = -30,
    this.thirsty = -15,
    this.delighted = 15,
    this.healthy = 30,
    this.proud = 45,
    this.conjunctNodesStrength = 60,
    this.conjunctFifthCuspStrength = 0,
    this.inFifthSignStrength = 60,
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

  /// Sum of every [ScoredFactor.virupas]. Positive = net healthy. This is
  /// the primary ranking key (see [PlanetHealth.rank]).
  final double virupas;

  /// Sum of the non-aspect factors: dignity, sign placement, sign lord,
  /// conjunction, and the shame conditions. Reported so a total can be read
  /// back to sign-level vs aspect-level causes; not a ranking key.
  final double strongVirupas;

  /// Sum of the aspect factors, each prorated by Parashara aspect strength.
  /// Weighted the same as [strongVirupas] in [virupas].
  final double aspectVirupas;

  /// Per-state subtotals, so a total can be read back to its causes.
  final Map<LajjitaadiState, double> byState;

  /// Every scored factor, deduplicated, in state order.
  final List<ScoredFactor> factors;

  const PlanetHealthScore({
    required this.body,
    required this.virupas,
    required this.strongVirupas,
    required this.aspectVirupas,
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
  /// 1 = healthiest. Always distinct — equal totals are broken by dignity,
  /// then [PlanetHealth.tieBreakOrder].
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
/// 4. Sum every factor into the planet's total, and rank by that total.
/// 5. Break ties by dignity (better [DignityType] ranks higher), then by
///    [tieBreakOrder]. Every planet gets a distinct rank.
///
/// Aspects are not discounted beyond their Parashara strength: a full (60/60)
/// aspect that starves costs −45, the same as starvation by sign or
/// conjunction; a half-strength (30/60) aspect costs half that. A malefic
/// enemy's aspect both starves and agitates, and both count. The total is
/// still split into *strong* (dignity, sign, sign lord, conjunction, shame
/// conditions) and *aspect* subtotals for reporting.
///
/// The score is additive — no state trumps another, a planet can be both
/// proud and shamed, and multiple malefics stack. The full picture is
/// preserved in [PlanetHealthScore.byState] and [PlanetHealthScore.factors].
class PlanetHealth {
  const PlanetHealth._();

  /// Final tie-break when two planets have the same total *and* the same
  /// dignity: earlier in this list ranks higher (Laura's order).
  static const tieBreakOrder = [
    Body.jupiter,
    Body.venus,
    Body.mercury,
    Body.moon,
    Body.sun,
    Body.mars,
    Body.saturn,
  ];

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
        final byTotal = scores[b.body]!.virupas.compareTo(
          scores[a.body]!.virupas,
        );
        if (byTotal != 0) return byTotal;
        // DignityType is declared best-first, so a lower index is better.
        final byDignity = a.dignity.index.compareTo(b.dignity.index);
        if (byDignity != 0) return byDignity;
        return tieBreakOrder
            .indexOf(a.body)
            .compareTo(tieBreakOrder.indexOf(b.body));
      });

    return [
      for (var i = 0; i < ordered.length; i++)
        BeingHealth(
          rank: i + 1,
          score: scores[ordered[i].body]!,
          sign: ordered[i].sign,
          hora: ordered[i].hora,
          trimsamsaBeing: ordered[i].trimsamsaBeing,
          horaBeing: ordered[i].horaBeing,
          aditya: BeingData.forSign(ordered[i].sign, BeingType.aditya),
        ),
    ];
  }

  static PlanetHealthScore _scoreOne(
    Body body,
    LajjitaadiResult? result,
    LajjitaadiWeights weights,
  ) {
    final factors = <ScoredFactor>[];
    final byState = <LajjitaadiState, double>{};
    var strong = 0.0;
    var aspect = 0.0;

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
        if (factor.source == 'aspect') {
          aspect += virupas;
        } else {
          strong += virupas;
        }
      }
      byState[state] = stateTotal;
    }

    return PlanetHealthScore(
      body: body,
      virupas: strong + aspect,
      strongVirupas: strong,
      aspectVirupas: aspect,
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
