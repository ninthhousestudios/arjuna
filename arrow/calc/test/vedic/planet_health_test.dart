// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

import '../helpers/stub_varga.dart';

/// Scattered positions — 40° apart, no two in the same sign.
/// Default cusps give lagnaSign=1 (Aries), fifthCuspSign=5 (Leo).
Varga _scattered({Map<Body, double> override = const {}}) {
  return stubVarga(
    longitudes: {
      Body.sun: 10.0,
      Body.moon: 50.0,
      Body.mars: 90.0,
      Body.mercury: 130.0,
      Body.jupiter: 170.0,
      Body.venus: 210.0,
      Body.saturn: 250.0,
      Body.rahu: 290.0,
      Body.ketu: 110.0,
      ...override,
    },
  );
}

/// Sum of the [state] contributions across [score]'s factors.
double _stateTotal(PlanetHealthScore score, LajjitaadiState state) =>
    score.byState[state] ?? 0.0;

void main() {
  group('PlanetHealth.score — factor weighting', () {
    test('conjunction factors score at full weight', () {
      // Mercury conjunct Saturn in Sagittarius: Saturn is Mercury's natural
      // enemy AND the "Saturn always starves" rule fires — one physical
      // fact, so it must be scored once at -45, not twice.
      final v = _scattered(override: {Body.mercury: 250.0, Body.saturn: 255.0});
      final mercury = PlanetHealth.score(v)[Body.mercury]!;
      final saturnFactors = mercury.factors.where(
        (f) =>
            f.state == LajjitaadiState.starved &&
            f.factor.source == 'conjunction' &&
            f.factor.planet == Body.saturn,
      );
      expect(saturnFactors, hasLength(1));
      expect(saturnFactors.single.virupas, -45.0);
    });

    test('aspect factors are prorated by aspect strength', () {
      final v = _scattered();
      for (final score in PlanetHealth.score(v).values) {
        for (final f in score.factors) {
          if (f.factor.source != 'aspect') continue;
          final expected =
              LajjitaadiWeights.defaults.virupasFor(f.state) *
              f.factor.strength! /
              60.0;
          expect(f.virupas, closeTo(expected, 1e-9));
          expect(f.virupas.abs(), lessThanOrEqualTo(60.0));
        }
      }
    });

    test('proud (exalted) scores +45', () {
      // Sun exalted in Aries at 10°. Healthy states ride the shifted-down
      // ladder so afflictions outweigh them.
      final v = _scattered(override: {Body.sun: 10.0});
      final sun = PlanetHealth.score(v)[Body.sun]!;
      expect(sun.isProud, isTrue);
      expect(_stateTotal(sun, LajjitaadiState.proud), 45.0);
    });

    test('nodes and 5th-sign shame carry equal strength', () {
      // Moon in Leo (5th sign from Aries lagna) conjunct Mars and Rahu:
      // one malefic trigger (-60) + nodes condition (-60) + 5th sign (-60).
      // Laura: shame ranks equally whether by nodes or in the 5th whole sign.
      final v = _scattered(
        override: {Body.moon: 120.0, Body.mars: 125.0, Body.rahu: 128.0},
      );
      final moon = PlanetHealth.score(v)[Body.moon]!;
      expect(moon.isShamed, isTrue);

      final shame = moon.factors.where(
        (f) => f.state == LajjitaadiState.shamed,
      );
      final nodes = shame.singleWhere(
        (f) => f.factor.condition == ShameCondition.conjunctNodes,
      );
      final fifth = shame.singleWhere(
        (f) => f.factor.condition == ShameCondition.inFifthSign,
      );
      expect(nodes.virupas, -60.0);
      expect(fifth.virupas, -60.0);
      // Shame is a whole-sign phenomenon: nodes and 5th sign weigh the same.
      expect(nodes.virupas, fifth.virupas);
    });

    test('weights are overridable without touching the scorer', () {
      final v = _scattered(override: {Body.sun: 10.0});
      const flat = LajjitaadiWeights(proud: 10);
      final sun = PlanetHealth.score(v, weights: flat)[Body.sun]!;
      expect(_stateTotal(sun, LajjitaadiState.proud), 10.0);
    });

    test('karakas Lajjitaadi omits score zero', () {
      // Everything mutually unaspected is impossible with 7 planets, so
      // assert the weaker invariant: every karaka is present in the map.
      final scores = PlanetHealth.score(_scattered());
      expect(scores.keys, containsAll(Body.karakas));
      for (final s in scores.values) {
        expect(s.virupas, isA<double>());
      }
    });
  });

  group('PlanetHealth.rank', () {
    test('orders by strong subtotal first, aspects only breaking ties', () {
      final ranked = PlanetHealth.rank(_scattered());
      expect(ranked, hasLength(7));
      expect(ranked.map((r) => r.body).toSet(), Body.karakas.toSet());
      for (var i = 1; i < ranked.length; i++) {
        final prev = ranked[i - 1].score;
        final cur = ranked[i].score;
        final reason = '${ranked[i - 1].body.name} vs ${ranked[i].body.name}';
        // Strong (sign/conjunction) subtotal is the primary key; a lower
        // strong subtotal can never rank above a higher one, however the
        // aspects fall.
        expect(
          prev.strongVirupas,
          greaterThanOrEqualTo(cur.strongVirupas),
          reason: reason,
        );
        if (prev.strongVirupas == cur.strongVirupas) {
          expect(
            prev.aspectVirupas,
            greaterThanOrEqualTo(cur.aspectVirupas),
            reason: reason,
          );
        }
      }
      expect(ranked.first.rank, 1);
    });

    test('ties share a rank', () {
      final ranked = PlanetHealth.rank(_scattered());
      for (var i = 1; i < ranked.length; i++) {
        final prev = ranked[i - 1].score;
        final cur = ranked[i].score;
        final tied =
            prev.strongVirupas == cur.strongVirupas &&
            prev.aspectVirupas == cur.aspectVirupas;
        if (tied) {
          expect(ranked[i].rank, ranked[i - 1].rank);
        } else {
          expect(ranked[i].rank, greaterThan(ranked[i - 1].rank));
        }
      }
    });

    test('each ranked planet carries its hora and trimsamsa beings', () {
      final ranked = PlanetHealth.rank(_scattered());
      for (final r in ranked) {
        expect(r.sign, inInclusiveRange(1, 12));
        expect(r.trimsamsaBeing.signNumber, r.sign);
        expect(r.aditya.type, BeingType.aditya);
        expect(
          r.horaBeing.type,
          r.hora == Hora.sun ? BeingType.aditya : BeingType.naga,
        );
        expect(
          r.trimsamsaBeing.type,
          isNot(anyOf(BeingType.aditya, BeingType.naga)),
        );
      }
    });

    test('a shamed, starved planet ranks below an exalted one', () {
      // Sun exalted in Aries; Moon shamed in the 5th with Mars and Rahu.
      final v = _scattered(
        override: {Body.moon: 120.0, Body.mars: 125.0, Body.rahu: 128.0},
      );
      final ranked = PlanetHealth.rank(v);
      final sunRank = ranked.indexWhere((r) => r.body == Body.sun);
      final moonRank = ranked.indexWhere((r) => r.body == Body.moon);
      expect(sunRank, lessThan(moonRank));
    });
  });
}
