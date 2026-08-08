// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_calc/arrow_calc.dart' as calc;

import '../generated/quiver/being_health.pb.dart' as bh;
import '../generated/quiver/being_health.pbenum.dart' as bhe;
import 'quiver_type_mapper.dart';

/// Maps arrow's `PlanetHealth` ranking (`List<BeingHealth>` for one chart) into
/// the quiver being-health proto. Carries the full score breakdown — subtotals,
/// per-state totals, and every scored factor — for the technical report page.
class BeingHealthMapper {
  const BeingHealthMapper._();

  static bh.BeingRanking ranking(double jdUt, List<calc.BeingHealth> ranked) =>
      bh.BeingRanking(jdUt: jdUt, beings: ranked.map(_being).toList());

  static bh.BeingHealth _being(calc.BeingHealth b) => bh.BeingHealth(
    rank: b.rank,
    body: QuiverTypeMapper.body(b.body),
    score: _score(b.score),
    sign: b.sign,
    hora: QuiverTypeMapper.hora(b.hora),
    trimsamsaBeing: QuiverTypeMapper.being(b.trimsamsaBeing),
    horaBeing: QuiverTypeMapper.being(b.horaBeing),
    aditya: QuiverTypeMapper.being(b.aditya),
  );

  static bh.PlanetHealthScore _score(calc.PlanetHealthScore s) =>
      bh.PlanetHealthScore(
        body: QuiverTypeMapper.body(s.body),
        virupas: s.virupas,
        strongVirupas: s.strongVirupas,
        aspectVirupas: s.aspectVirupas,
        byState: s.byState.entries
            .map((e) => bh.StateVirupas(state: _state(e.key), virupas: e.value))
            .toList(),
        factors: s.factors.map(_scoredFactor).toList(),
      );

  static bh.ScoredFactor _scoredFactor(calc.ScoredFactor f) => bh.ScoredFactor(
    state: _state(f.state),
    strength: f.strength,
    virupas: f.virupas,
    factor: _factor(f.factor),
  );

  static bh.LajjitaadiFactor _factor(calc.LajjitaadiFactor f) {
    final proto = bh.LajjitaadiFactor(source: _source(f.source));
    if (f.planet != null) proto.planet = QuiverTypeMapper.body(f.planet!);
    if (f.lord != null) proto.lord = QuiverTypeMapper.body(f.lord!);
    if (f.strength != null) proto.strength = f.strength!;
    if (f.dignity != null) proto.dignity = f.dignity!;
    if (f.condition != null) proto.condition = _condition(f.condition!);
    if (f.detail != null) proto.detail = f.detail!;
    if (f.to != null) proto.to = QuiverTypeMapper.body(f.to!);
    return proto;
  }

  static bhe.LajjitaadiState _state(calc.LajjitaadiState s) => switch (s) {
    calc.LajjitaadiState.delighted => bhe.LajjitaadiState.DELIGHTED,
    calc.LajjitaadiState.starved => bhe.LajjitaadiState.STARVED,
    calc.LajjitaadiState.agitated => bhe.LajjitaadiState.AGITATED,
    calc.LajjitaadiState.thirsty => bhe.LajjitaadiState.THIRSTY,
    calc.LajjitaadiState.shamed => bhe.LajjitaadiState.SHAMED,
    calc.LajjitaadiState.healthy => bhe.LajjitaadiState.HEALTHY,
    calc.LajjitaadiState.proud => bhe.LajjitaadiState.PROUD,
  };

  static bhe.FactorSource _source(String source) => switch (source) {
    'conjunction' => bhe.FactorSource.CONJUNCTION,
    'aspect' => bhe.FactorSource.ASPECT,
    'sign' => bhe.FactorSource.SIGN,
    'dignity' => bhe.FactorSource.DIGNITY,
    'condition' => bhe.FactorSource.CONDITION,
    _ => bhe.FactorSource.FACTOR_SOURCE_UNSPECIFIED,
  };

  static bhe.ShameCondition _condition(calc.ShameCondition c) => switch (c) {
    calc.ShameCondition.conjunctNodes => bhe.ShameCondition.CONJUNCT_NODES,
    calc.ShameCondition.inFifthSign => bhe.ShameCondition.IN_FIFTH_SIGN,
    calc.ShameCondition.conjunctFifthCusp =>
      bhe.ShameCondition.CONJUNCT_FIFTH_CUSP,
  };
}
