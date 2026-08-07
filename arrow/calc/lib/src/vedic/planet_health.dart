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
  /// the whole picture for display; ranking uses [strongVirupas] then
  /// [aspectVirupas], not this total (see [PlanetHealth.rank]).
  final double virupas;

  /// Sum of the non-aspect factors: dignity, sign placement, sign lord,
  /// conjunction, and the shame conditions. Laura's precedence rule — "the
  /// LA of the planet in a Sign is always stronger than the aspect… the only
  /// time this does not apply is with conjunctions" — makes these the primary
  /// ranking key.
  final double strongVirupas;

  /// Sum of the aspect factors, each prorated by Parashara aspect strength.
  /// Subordinate to [strongVirupas]: aspects only order planets whose strong
  /// totals are equal.
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
/// 4. Split each planet's total into a *strong* subtotal (dignity, sign, sign
///    lord, conjunction, shame conditions) and an *aspect* subtotal.
/// 5. Rank by strong subtotal first; the aspect subtotal only orders planets
///    whose strong subtotals are equal.
///
/// Step 5 is Laura's precedence rule: "the LA of the planet in a Sign is
/// always stronger than the aspect… if Saturn is exalted but also aspected by
/// Mars, the exaltation is stronger… the only time this does not apply is with
/// conjunctions." So sign- and conjunction-caused avasthas rank a planet, and
/// aspects — however many pile on — can only break ties among planets those
/// stronger causes leave level. This is what keeps an exalted-but-aspect-
/// afflicted planet (Josh's Saturn, starved *and* agitated by Sun/Moon/Mars)
/// from being dragged below planets with genuinely worse dignity: its aspect
/// pile lives in the subordinate tier.
///
/// Within each tier the score stays additive — no state trumps another, a
/// planet can be both proud and shamed, and multiple malefics stack. The full
/// picture is preserved in [PlanetHealthScore.byState] and
/// [PlanetHealthScore.factors].
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
        final sa = scores[a.body]!;
        final sb = scores[b.body]!;
        // Precedence: strong (sign/conjunction) causes rank first; aspects
        // only order planets those leave level.
        final byStrong = sb.strongVirupas.compareTo(sa.strongVirupas);
        if (byStrong != 0) return byStrong;
        final byAspect = sb.aspectVirupas.compareTo(sa.aspectVirupas);
        if (byAspect != 0) return byAspect;
        // Dart's sort is not stable — fall back to karaka order for ties.
        return a.body.index.compareTo(b.body.index);
      });

    final ranked = <BeingHealth>[];
    for (var i = 0; i < ordered.length; i++) {
      final karaka = ordered[i];
      final score = scores[karaka.body]!;
      final previous = i > 0 ? scores[ordered[i - 1].body]! : null;
      final tiedWithPrevious =
          previous != null &&
          previous.strongVirupas == score.strongVirupas &&
          previous.aspectVirupas == score.aspectVirupas;
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
