import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';

import 'aspect.dart';

/// Lajjitaadi Avastha — the relational psychological state of a karaka.
///
/// Ported from `libaditya/calc/avasthas.py:43-206`. Seven states (English
/// names preserved verbatim from libaditya, no Sanskrit translation layer):
/// delighted, starved, agitated, thirsty, shamed, healthy, proud.
///
/// Each karaka can accumulate multiple factors per state. A factor names the
/// trigger (conjunction/aspect/sign/dignity/condition) with optional
/// contributing body/lord plus a strength in 0..60 (libaditya uses the
/// Parashara aspect strength from [Aspect.strength] for aspect factors, and
/// the constant 60 for conjunction/sign/dignity factors).
enum LajjitaadiState {
  delighted,
  starved,
  agitated,
  thirsty,
  shamed,
  healthy,
  proud;

  static const _names = [
    'delighted', 'starved', 'agitated', 'thirsty', 'shamed', 'healthy', 'proud',
  ];

  /// libaditya's dict key (see `avasthas.py:88+`).
  String get libadityaName => _names[index];
}

/// A single contributing factor to a [LajjitaadiState] for one karaka.
///
/// Mirrors libaditya's factor dict (`avasthas.py:88+`). Fields are optional
/// because not all sources populate all of them:
/// - `conjunction`/`aspect`: [planet] + [strength]
/// - `sign` (friend/enemy of sign lord): [lord] + [strength]
/// - `sign` (own sign, healthy): [strength] only
/// - `dignity` (proud): [dignity] + [strength]
/// - `condition` (shamed trigger): [detail] only
class LajjitaadiFactor {
  /// 'conjunction', 'aspect', 'sign', 'dignity', or 'condition'.
  final String source;

  /// Triggering body for conjunction/aspect factors.
  final Body? planet;

  /// Sign lord for sign-based factors (when lord != karaka).
  final Body? lord;

  /// Strength 0..60. Conjunction/sign/dignity → 60. Aspect → Parashara
  /// degree-based strength from [Aspect.strength].
  final double? strength;

  /// 'EX' (exalted) or 'MT' (moolatrikona) — only set for proud factors.
  final String? dignity;

  /// Free-form condition description — only set for shamed `condition`
  /// factors ("conjunct Rahu/Ketu", "in 5th sign", "conjunct 5th cusp").
  final String? detail;

  /// When present, marks this factor as one the karaka is *giving* to [to]
  /// rather than receiving. libaditya populates this in `avasthas.py:183+`.
  final Body? to;

  const LajjitaadiFactor({
    required this.source,
    this.planet,
    this.lord,
    this.strength,
    this.dignity,
    this.detail,
    this.to,
  });

  LajjitaadiFactor toGiving(Body recipient) => LajjitaadiFactor(
        source: source,
        planet: planet,
        lord: lord,
        strength: strength,
        dignity: dignity,
        detail: detail,
        to: recipient,
      );

  @override
  String toString() {
    final parts = <String>[source];
    if (planet != null) parts.add('planet=${planet!.name}');
    if (lord != null) parts.add('lord=${lord!.name}');
    if (strength != null) parts.add('strength=$strength');
    if (dignity != null) parts.add('dignity=$dignity');
    if (detail != null) parts.add('detail=$detail');
    if (to != null) parts.add('to=${to!.name}');
    return 'LajjitaadiFactor(${parts.join(', ')})';
  }
}

/// Full Lajjitaadi result for one karaka: per-state factor lists plus
/// pre-split `giving`/`receiving` views for relational navigation
/// (SkyBreath taps one planet to see whom it affects and who affects it).
class LajjitaadiResult {
  /// Raw per-state factor lists. Empty-state entries are omitted entirely
  /// to match libaditya's `if avasthas:` gate in `avasthas.py:178`.
  final Map<LajjitaadiState, List<LajjitaadiFactor>> avasthas;

  /// Subset of [avasthas] where the trigger is another named planet —
  /// this is what the karaka is *receiving* from others.
  final Map<LajjitaadiState, List<LajjitaadiFactor>> receiving;

  /// Factors this karaka causes in *other* karakas, keyed by state.
  /// Only populated once the full 7-karaka pass is complete.
  final Map<LajjitaadiState, List<LajjitaadiFactor>> giving;

  const LajjitaadiResult({
    required this.avasthas,
    required this.receiving,
    required this.giving,
  });
}

/// The seven karakas libaditya iterates for Lajjitaadi. Order matches
/// `avasthas.py:24`.
const List<Body> karakas = [
  Body.sun,
  Body.moon,
  Body.mars,
  Body.mercury,
  Body.jupiter,
  Body.venus,
  Body.saturn,
];

/// Nine grahas used for the aspect/conjunction scan. Matches
/// `avasthas.py:25`.
const List<Body> grahas = [
  Body.sun,
  Body.moon,
  Body.mars,
  Body.mercury,
  Body.jupiter,
  Body.venus,
  Body.saturn,
  Body.rahu,
  Body.ketu,
];

/// Water signs per libaditya `WATER_SIGNS` (`avasthas.py:26`): Cancer,
/// Scorpio, Pisces.
const Set<int> _waterSigns = {4, 8, 12};

class Lajjitaadi {
  const Lajjitaadi._();

  /// Compute Lajjitaadi for all seven karakas.
  ///
  /// [grahaLongitudes] must contain all nine grahas keyed by [Body]
  /// (longitudes are ecliptic, same reference frame used by [Aspect]).
  /// [karakaDignities] and [karakaSigns] cover the seven karakas.
  /// [lagnaSign] is the ascendant sign (1..12). [fifthCuspSign] is the
  /// sign occupied by the 5th house cusp.
  ///
  /// Returns a map keyed by karaka body. Karakas with no factors in any
  /// state are omitted entirely (matches libaditya's `if avasthas:` gate).
  static Map<Body, LajjitaadiResult> compute({
    required Map<Body, double> grahaLongitudes,
    required Map<Body, DignityType> karakaDignities,
    required Map<Body, int> karakaSigns,
    required int lagnaSign,
    required int fifthCuspSign,
  }) {
    // avasthas.py:59 — 5th sign forward from lagna (1..12, wrap-safe).
    final fifthSignFromLagna = ((lagnaSign - 1 + 4) % 12) + 1;

    // Moon nature is contextual (libaditya planets.py:1652): benefic in
    // Shukla Paksha, malefic in Krishna. Pre-compute once.
    final sunLon = grahaLongitudes[Body.sun]!;
    final moonLon = grahaLongitudes[Body.moon]!;
    final moonNature =
        Nature.ofMoon(sunLongitude: sunLon, moonLongitude: moonLon);

    final raw = <Body, Map<LajjitaadiState, List<LajjitaadiFactor>>>{};

    for (final name in karakas) {
      final avasthas = <LajjitaadiState, List<LajjitaadiFactor>>{};
      final planetLon = grahaLongitudes[name]!;
      final signNum = karakaSigns[name]!;
      final dignity = karakaDignities[name]!;
      final signLord = SignData.lord(signNum);

      // avasthas.py:70–119 — per-other scan for delighted/starved/
      // agitated/thirsty.
      for (final otherName in grahas) {
        if (otherName == name) continue;
        final otherLon = grahaLongitudes[otherName]!;
        final isConjunction = Aspect.isConjunction(otherLon, planetLon);
        final aspectStrength = Aspect.strength(otherName, otherLon, planetLon);

        final isFriend = karakas.contains(otherName) &&
            Dignity.isNaturalFriend(name, otherName);
        final isEnemy = karakas.contains(otherName) &&
            Dignity.isNaturalEnemy(name, otherName);

        // --- Delighted ---
        if (isConjunction && otherName == Body.jupiter) {
          _add(avasthas, LajjitaadiState.delighted, LajjitaadiFactor(
            source: 'conjunction', planet: otherName, strength: 60,
          ));
        }
        if (isConjunction && isFriend && otherName != Body.saturn) {
          _add(avasthas, LajjitaadiState.delighted, LajjitaadiFactor(
            source: 'conjunction', planet: otherName, strength: 60,
          ));
        }
        if (aspectStrength > 0 && isFriend) {
          _add(avasthas, LajjitaadiState.delighted, LajjitaadiFactor(
            source: 'aspect', planet: otherName, strength: aspectStrength,
          ));
        }

        // --- Starved ---
        if (isConjunction && isEnemy) {
          _add(avasthas, LajjitaadiState.starved, LajjitaadiFactor(
            source: 'conjunction', planet: otherName, strength: 60,
          ));
        }
        // avasthas.py:101 — Saturn conjunction always starves (no friend
        // check; outer loop already excludes self-conjunction).
        if (isConjunction && otherName == Body.saturn) {
          _add(avasthas, LajjitaadiState.starved, LajjitaadiFactor(
            source: 'conjunction', planet: Body.saturn, strength: 60,
          ));
        }
        if (aspectStrength > 0 && isEnemy) {
          _add(avasthas, LajjitaadiState.starved, LajjitaadiFactor(
            source: 'aspect', planet: otherName, strength: aspectStrength,
          ));
        }

        // --- Agitated ---
        if (isConjunction && otherName == Body.sun) {
          _add(avasthas, LajjitaadiState.agitated, LajjitaadiFactor(
            source: 'conjunction', planet: Body.sun, strength: 60,
          ));
        }
        // avasthas.py:112 — aspected by natural enemy who is a malefic.
        // "other in KARAKAS" gate already enforced by isEnemy logic above.
        // Moon's nature is contextual — use the pre-computed moonNature.
        final otherNature = otherName == Body.moon
            ? moonNature
            : Nature.of(otherName);
        if (aspectStrength > 0 &&
            isEnemy &&
            otherNature == Nature.malefic) {
          _add(avasthas, LajjitaadiState.agitated, LajjitaadiFactor(
            source: 'aspect', planet: otherName, strength: aspectStrength,
          ));
        }

        // --- Thirsty ---
        if (_waterSigns.contains(signNum) &&
            aspectStrength > 0 &&
            isEnemy) {
          _add(avasthas, LajjitaadiState.thirsty, LajjitaadiFactor(
            source: 'aspect', planet: otherName, strength: aspectStrength,
          ));
        }
      }

      // avasthas.py:122–133 — delighted/starved by sign lord.
      if (signLord != name && karakas.contains(signLord)) {
        if (Dignity.isNaturalFriend(name, signLord)) {
          _add(avasthas, LajjitaadiState.delighted, LajjitaadiFactor(
            source: 'sign', lord: signLord, strength: 60,
          ));
        }
        if (Dignity.isNaturalEnemy(name, signLord)) {
          _add(avasthas, LajjitaadiState.starved, LajjitaadiFactor(
            source: 'sign', lord: signLord, strength: 60,
          ));
        }
      }

      // avasthas.py:136 — healthy in own sign.
      if (dignity == DignityType.ownSign) {
        _add(avasthas, LajjitaadiState.healthy, LajjitaadiFactor(
          source: 'sign', strength: 60,
        ));
      }

      // avasthas.py:140–143 — proud in EX or MT.
      if (dignity == DignityType.exalted) {
        _add(avasthas, LajjitaadiState.proud, LajjitaadiFactor(
          source: 'dignity', dignity: 'EX', strength: 60,
        ));
      } else if (dignity == DignityType.moolatrikona) {
        _add(avasthas, LajjitaadiState.proud, LajjitaadiFactor(
          source: 'dignity', dignity: 'MT', strength: 60,
        ));
      }

      // avasthas.py:149–175 — shamed (compound trigger).
      final conjSunMarsSaturn = <Body>[];
      var conjRahuKetu = false;
      for (final otherName in grahas) {
        if (otherName == name) continue;
        if (!Aspect.isConjunction(grahaLongitudes[otherName]!, planetLon)) {
          continue;
        }
        if (otherName == Body.sun ||
            otherName == Body.mars ||
            otherName == Body.saturn) {
          conjSunMarsSaturn.add(otherName);
        }
        if (otherName == Body.rahu || otherName == Body.ketu) {
          conjRahuKetu = true;
        }
      }
      if (conjSunMarsSaturn.isNotEmpty) {
        final inFifthSign = signNum == fifthSignFromLagna;
        final conjFifthCusp = signNum == fifthCuspSign;
        if (conjRahuKetu || inFifthSign || conjFifthCusp) {
          for (final trigger in conjSunMarsSaturn) {
            _add(avasthas, LajjitaadiState.shamed, LajjitaadiFactor(
              source: 'conjunction', planet: trigger, strength: 60,
            ));
          }
          if (conjRahuKetu) {
            _add(avasthas, LajjitaadiState.shamed, const LajjitaadiFactor(
              source: 'condition', detail: 'conjunct Rahu/Ketu',
            ));
          }
          if (inFifthSign) {
            _add(avasthas, LajjitaadiState.shamed, const LajjitaadiFactor(
              source: 'condition', detail: 'in 5th sign',
            ));
          }
          if (conjFifthCusp && !inFifthSign) {
            _add(avasthas, LajjitaadiState.shamed, const LajjitaadiFactor(
              source: 'condition', detail: 'conjunct 5th cusp',
            ));
          }
        }
      }

      raw[name] = avasthas;
    }

    // avasthas.py:183–205 — build receiving + giving from the raw pass.
    final results = <Body, LajjitaadiResult>{};
    for (final name in karakas) {
      final avasthas = raw[name]!;
      if (avasthas.isEmpty) continue;

      final receiving = <LajjitaadiState, List<LajjitaadiFactor>>{};
      for (final entry in avasthas.entries) {
        final planetFactors =
            entry.value.where((f) => f.planet != null).toList();
        if (planetFactors.isNotEmpty) receiving[entry.key] = planetFactors;
      }

      final giving = <LajjitaadiState, List<LajjitaadiFactor>>{};
      for (final otherName in karakas) {
        if (otherName == name) continue;
        final otherAvasthas = raw[otherName];
        if (otherAvasthas == null) continue;
        for (final entry in otherAvasthas.entries) {
          for (final f in entry.value) {
            if (f.planet == name) {
              _add(giving, entry.key, f.toGiving(otherName));
            }
          }
        }
      }

      results[name] = LajjitaadiResult(
        avasthas: avasthas,
        receiving: receiving,
        giving: giving,
      );
    }
    return results;
  }
}

void _add<K>(Map<K, List<LajjitaadiFactor>> map, K key, LajjitaadiFactor f) {
  (map[key] ??= <LajjitaadiFactor>[]).add(f);
}
