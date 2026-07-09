// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_core/arrow_core.dart';

import 'rashi_aspect.dart';

/// Result of [Jaimini.argala]: categorised influences on a target sign.
class ArgalaResult {
  final Map<int, List<Body>> unobstructed;
  final List<Body> thirdMaleficArgala;
  final Map<int, List<Body>> obstructed;

  const ArgalaResult({
    required this.unobstructed,
    required this.thirdMaleficArgala,
    required this.obstructed,
  });
}

/// Jaimini system calculations, ported from libaditya.
///
/// Sign numbers are 1-12 throughout (Aries=1 … Pisces=12).
class Jaimini {
  const Jaimini._();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Forward sign distance: [signsForward(s, 1)] == [s] (inclusive counting).
  static int signsForward(int sign, int n) => ((sign + n - 2) % 12) + 1;

  /// Forward count from [from] to [to], 1-12 inclusive.
  /// [signsApart(s, s)] == 1.
  static int signsApart(int from, int to) => ((to - from) % 12) + 1;

  // ---------------------------------------------------------------------------
  // Private extraction helpers
  // ---------------------------------------------------------------------------

  static Map<int, List<Body>> _grahasPerSign(Varga varga) {
    final map = <int, List<Body>>{};
    for (final g in varga.grahas) {
      (map[g.sign] ??= []).add(g.body);
    }
    return map;
  }

  static Map<int, List<Body>> _karakasPerSign(Varga varga) {
    final map = <int, List<Body>>{};
    for (final k in varga.karakas) {
      (map[k.sign] ??= []).add(k.body);
    }
    return map;
  }

  static Map<int, int> _signToLordSign(Varga varga) {
    return {
      for (var s = 1; s <= 12; s++) s: varga.karaka(SignData.lord(s)).sign,
    };
  }

  // ---------------------------------------------------------------------------
  // Pada
  // ---------------------------------------------------------------------------

  /// Jaimini pada (arudha) of a bhava.
  ///
  /// [refSign] — the bhava sign (e.g. lagna sign).
  /// [lordSign] — the sign occupied by the bhava lord.
  static int pada(int refSign, int lordSign) {
    final apart = signsApart(refSign, lordSign);
    if (apart == 1 || apart == 7) return signsForward(refSign, 10);
    if (apart == 4 || apart == 10) return signsForward(refSign, 4);
    return signsForward(lordSign, apart);
  }

  /// Arudha Lagna: pada of the 1st house.
  static int arudhaLagna(int lagnaSign, int lagnaLordSign) =>
      pada(lagnaSign, lagnaLordSign);

  /// Upapada: pada of the 12th house cusp sign.
  static int upapada(int cuspSign, int lordSign) => pada(cuspSign, lordSign);

  /// Compute padas for all 12 houses.
  static Map<int, int> allPadas(Varga varga) {
    final signToLordSign = _signToLordSign(varga);
    return {
      for (final e in signToLordSign.entries) e.key: pada(e.key, e.value),
    };
  }

  // ---------------------------------------------------------------------------
  // Argala
  // ---------------------------------------------------------------------------

  /// Argala (intervention) analysis on [targetSign].
  static ArgalaResult argala(Varga varga, {required int targetSign}) {
    final grahasPerSign = _grahasPerSign(varga);
    final ketuSign = varga.planet(Body.ketu).sign;
    final firstStrengthRanking = firstStrength(varga);
    // Step 1: Ketu in targetSign reverses house offsets.
    final ketuInTarget = ketuSign == targetSign;
    int offset(int n) {
      if (!ketuInTarget) return n;
      return ((-n) % 12 == 0) ? 12 : (-n) % 12;
    }

    List<Body> grahasAt(int sign) => grahasPerSign[sign] ?? const [];

    int count(int sign) => grahasAt(sign).length;

    // Argala/virodhina offset pairs (forward offsets from target).
    const pairs = [(2, 12), (11, 3), (4, 10), (9, 5)];

    final unobstructed = <int, List<Body>>{};
    final obstructed = <int, List<Body>>{};

    for (final (argalaOffset, virodhinaOffset) in pairs) {
      final argalaSign = signsForward(targetSign, offset(argalaOffset));
      final virodhinaSign = signsForward(targetSign, offset(virodhinaOffset));

      final argalaBodies = grahasAt(argalaSign);
      if (argalaBodies.isEmpty) continue;

      final argalaCount = argalaBodies.length;
      final virodhinaCount = count(virodhinaSign);

      if (argalaCount > virodhinaCount) {
        unobstructed[argalaOffset] = argalaBodies;
      } else if (argalaCount < virodhinaCount) {
        obstructed[argalaOffset] = argalaBodies;
      } else {
        // Equal counts: argala stands iff its sign ranks higher.
        final argalaRank = firstStrengthRanking.indexOf(argalaSign);
        final virodhinaRank = firstStrengthRanking.indexOf(virodhinaSign);
        // Lower index = stronger. Argala stands if stronger (smaller index).
        if (argalaRank != -1 &&
            (virodhinaRank == -1 || argalaRank < virodhinaRank)) {
          unobstructed[argalaOffset] = argalaBodies;
        } else {
          obstructed[argalaOffset] = argalaBodies;
        }
      }
    }

    // Step 4: 3rd-house malefic argala.
    final thirdSign = signsForward(targetSign, offset(3));
    final thirdBodies = grahasAt(thirdSign);
    final malefics = thirdBodies.where(_isMalefic).toList();
    final benefics = thirdBodies.where((b) => !_isMalefic(b)).toList();
    final thirdMaleficArgala = malefics.length > benefics.length
        ? malefics
        : <Body>[];

    return ArgalaResult(
      unobstructed: unobstructed,
      thirdMaleficArgala: thirdMaleficArgala,
      obstructed: obstructed,
    );
  }

  // ---------------------------------------------------------------------------
  // Bandhana Yogas
  // ---------------------------------------------------------------------------

  /// Bandhana yogas from lagna: symmetric pairs with equal non-zero counts.
  ///
  /// Returns a list of pairs `(List<Body>, List<Body>)` for each pair where
  /// both sides have the same non-zero number of grahas.
  static List<(List<Body>, List<Body>)> bandhanaYogas(Varga varga) {
    final lagnaSign = varga.cusps[0].sign;
    final grahasPerSign = _grahasPerSign(varga);

    List<Body> at(int offset) =>
        grahasPerSign[signsForward(lagnaSign, offset)] ?? const [];

    const offsets = [(2, 12), (3, 11), (4, 10), (5, 9), (6, 8)];
    final results = <(List<Body>, List<Body>)>[];

    for (final (a, b) in offsets) {
      final sideA = at(a);
      final sideB = at(b);
      if (sideA.isNotEmpty && sideA.length == sideB.length) {
        results.add((sideA, sideB));
      }
    }
    return results;
  }

  // ---------------------------------------------------------------------------
  // Third Strength
  // ---------------------------------------------------------------------------

  /// Third strength for all 12 signs.
  ///
  /// Each sign's distance to its lord determines its kendra/panapara/apoklima
  /// strength:
  /// - distance % 3 == 1 → Kendra (strength 2)
  /// - distance % 3 == 2 → Panapara (strength 1)
  /// - distance % 3 == 0 → Apoklima (strength 0)
  static Map<int, ({int strength, String label})> thirdStrength(Varga varga) {
    final signToLordSign = _signToLordSign(varga);
    return {
      for (final e in signToLordSign.entries)
        e.key: _thirdStrengthOf(signsApart(e.key, e.value)),
    };
  }

  static ({int strength, String label}) _thirdStrengthOf(int distance) {
    final r = distance % 3;
    if (r == 1) return (strength: 2, label: 'kendra');
    if (r == 2) return (strength: 1, label: 'panapara');
    return (strength: 0, label: 'apoklima');
  }

  // ---------------------------------------------------------------------------
  // Second Strength
  // ---------------------------------------------------------------------------

  /// Second strength for all 12 signs.
  ///
  /// For each sign, returns the list of bodies among Jupiter, Mercury, and the
  /// sign's own lord that either conjoin or rashi-aspect that sign.
  static Map<int, List<Body>> secondStrength(
    Varga varga, {
    RashiAspectMode rashiAspectMode = RashiAspectMode.quadrant,
  }) {
    final signToLordSign = _signToLordSign(varga);
    final grahasPerSign = _grahasPerSign(varga);
    final jupiterSign = varga.karaka(Body.jupiter).sign;
    final mercurySign = varga.karaka(Body.mercury).sign;

    final result = <int, List<Body>>{};
    for (var sign = 1; sign <= 12; sign++) {
      final lordSign = signToLordSign[sign]!;
      final lord = SignData.lord(sign);

      final influencers = <Body>[];
      for (final (body, bodySign) in [
        (Body.jupiter, jupiterSign),
        (Body.mercury, mercurySign),
        (lord, lordSign),
      ]) {
        final conjoins = bodySign == sign;
        final aspects = RashiAspect.doesAspectWithOccupants(
          bodySign,
          sign,
          (grahasPerSign[bodySign] ?? const []).isNotEmpty,
          rashiAspectMode,
        );
        if (conjoins || aspects) influencers.add(body);
      }
      if (influencers.isNotEmpty) result[sign] = influencers;
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // First Strength
  // ---------------------------------------------------------------------------

  /// First strength: rank all 12 signs strongest-to-weakest by 8-level
  /// comparator.
  ///
  /// [knRao] — if true, tiebreaker uses lord's in-sign longitude (higher wins);
  ///   otherwise sign number (higher wins).
  static List<int> firstStrength(Varga varga, {bool knRao = false}) {
    final karakasPerSign = _karakasPerSign(varga);
    final signToLordSign = _signToLordSign(varga);
    final dignities = {for (final k in varga.karakas) k.body: k.dignity};
    final inSignLongitudes = {
      for (final k in varga.karakas) k.body: k.rawLongitude % 30.0,
    };
    final signs = List.generate(12, (i) => i + 1);

    List<Body> karakasOf(int sign) => karakasPerSign[sign] ?? const [];

    List<int> dignityScores(int sign) {
      return karakasOf(sign)
          .map((b) => _dignityScore(dignities[b] ?? DignityType.neutral))
          .toList()
        ..sort((a, b) => b.compareTo(a)); // descending
    }

    int quality(int sign) {
      switch (SignData.quality(sign)) {
        case Quality.mutable:
          return 2;
        case Quality.fixed:
          return 1;
        case Quality.cardinal:
          return 0;
      }
    }

    int compareSignPair(int a, int b) {
      // Level 0: karaka count
      final karakaA = karakasOf(a).length;
      final karakaB = karakasOf(b).length;
      if (karakaA != karakaB)
        return karakaB.compareTo(karakaA); // more = better

      // Level 1: dignity scores (descending sorted, lexicographic)
      final dA = dignityScores(a);
      final dB = dignityScores(b);
      final lexCmp = _lexCompare(dB, dA);
      if (lexCmp != 0) return lexCmp;

      // Level 2: sign modality (dual > fixed > cardinal)
      final qA = quality(a);
      final qB = quality(b);
      if (qA != qB) return qB.compareTo(qA); // higher enum wins

      // Level 3: karaka count in lord's sign
      final lA = signToLordSign[a]!;
      final lB = signToLordSign[b]!;
      final lKarakaA = karakasOf(lA).length;
      final lKarakaB = karakasOf(lB).length;
      if (lKarakaA != lKarakaB) return lKarakaB.compareTo(lKarakaA);

      // Level 4: dignity scores in lord's sign
      final ldA = dignityScores(lA);
      final ldB = dignityScores(lB);
      final lLexCmp = _lexCompare(ldB, ldA);
      if (lLexCmp != 0) return lLexCmp;

      // Level 5: lord's sign modality
      final lqA = quality(lA);
      final lqB = quality(lB);
      if (lqA != lqB) return lqB.compareTo(lqA);

      // Level 6: distance from sign to its lord (greater = stronger)
      final distA = signsApart(a, lA);
      final distB = signsApart(b, lB);
      if (distA != distB) return distB.compareTo(distA);

      // Level 7: tiebreaker
      if (knRao) {
        final lord = SignData.lord(a);
        final lordB = SignData.lord(b);
        final lonA = inSignLongitudes[lord] ?? 0.0;
        final lonB = inSignLongitudes[lordB] ?? 0.0;
        if (lonA != lonB) return lonB.compareTo(lonA);
      }
      return b.compareTo(a);
    }

    signs.sort(compareSignPair);
    return signs;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static int _dignityScore(DignityType d) {
    switch (d) {
      case DignityType.exalted:
        return 8;
      case DignityType.moolatrikona:
        return 7;
      case DignityType.ownSign:
        return 6;
      case DignityType.greatFriend:
        return 5;
      case DignityType.friend:
        return 4;
      case DignityType.neutral:
        return 3;
      case DignityType.enemy:
        return 2;
      case DignityType.greatEnemy:
        return 1;
      case DignityType.debilitated:
        return 0;
    }
  }

  /// Lexicographic comparison of two int lists (larger value at same position
  /// wins; longer list wins when all shared positions are equal).
  static int _lexCompare(List<int> a, List<int> b) {
    final len = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      if (a[i] != b[i]) return a[i].compareTo(b[i]);
    }
    return a.length.compareTo(b.length);
  }

  // Natural malefics for argala (includes Rahu/Ketu, Moon always excluded).
  // Distinct from NabhasaYogaCalc's conditional benefic/malefic lists which
  // classify Moon based on phase and exclude nodes entirely.
  static bool _isMalefic(Body body) {
    return body == Body.sun ||
        body == Body.mars ||
        body == Body.saturn ||
        body == Body.rahu ||
        body == Body.ketu;
  }
}
