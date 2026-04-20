import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';

import 'aspect.dart';

/// Deeptadi Avastha — mood/condition of a planet. Ported from
/// `libaditya/calc/avasthas.py:252-309`. Cascaded priority:
/// 1. Deepta — exalted
/// 2. Swastha — own sign
/// 3. Mudita — in a friend's sign (friend / great friend dignity)
/// 4. Shanta — longitude falls in a benefic navamsa sign
/// 5. Shakta — retrograde
/// 6. Peedita — conjunct or aspected by a natural malefic
/// 7. Deena — debilitated
/// 8. Vikala — combust
/// 9. Khala — in an enemy's sign (enemy / great enemy dignity)
/// Fallback: Shanta (matches libaditya's behavior for uncovered cases).
enum DeeptadiState {
  deepta,
  swastha,
  mudita,
  shanta,
  shakta,
  peedita,
  deena,
  vikala,
  khala;

  static const _names = [
    'Deepta', 'Swastha', 'Mudita', 'Shanta', 'Shakta',
    'Peedita', 'Deena', 'Vikala', 'Khala',
  ];

  String get libadityaName => _names[index];
}

/// Benefic navamsa signs per libaditya `BENEFIC_NAVAMSA_SIGNS`.
const Set<int> _beneficNavamsaSigns = {2, 3, 4, 6, 7, 9, 12};

class Deeptadi {
  const Deeptadi._();

  /// Compute the Deeptadi state for [body].
  ///
  /// [eclipticLongitude] is the raw (non-sidereal, pre-ayanamsa) ecliptic
  /// longitude that libaditya calls `ecliptic_longitude()`. This is used
  /// to compute the navamsa sign inline (matching libaditya's formula) and
  /// to check combustion against [sunLongitude].
  ///
  /// [grahaLongitudes] must contain all nine grahas (Sun, Moon, Mars,
  /// Mercury, Jupiter, Venus, Saturn, Rahu, Ketu) keyed by [Body]. The
  /// malefic-aspect check (step 6) iterates all grahas whose [Nature] is
  /// malefic (Sun/Mars/Saturn/Rahu/Ketu) and tests
  /// [Aspect.doesAspect] from the malefic to [body].
  static DeeptadiState of({
    required Body body,
    required DignityType dignity,
    required double eclipticLongitude,
    required bool isRetrograde,
    required double sunLongitude,
    required Map<Body, double> grahaLongitudes,
  }) {
    // 1. Deepta — exalted
    if (dignity == DignityType.exalted) return DeeptadiState.deepta;
    // 2. Swastha — own sign
    if (dignity == DignityType.ownSign) return DeeptadiState.swastha;
    // 3. Mudita — friend's sign (F or GF)
    if (dignity == DignityType.friend ||
        dignity == DignityType.greatFriend) {
      return DeeptadiState.mudita;
    }
    // 4. Shanta — navamsa sign is benefic.
    // libaditya: floor(lon / (30/9)) % 12 + 1
    final navamsaSign = (eclipticLongitude / (30.0 / 9.0)).floor() % 12 + 1;
    if (_beneficNavamsaSigns.contains(navamsaSign)) {
      return DeeptadiState.shanta;
    }
    // 5. Shakta — retrograde
    if (isRetrograde) return DeeptadiState.shakta;
    // 6. Peedita — conjunct a natural malefic.
    // libaditya (avasthas.py:289) only checks `aspect == "Y"` (conjunction),
    // not aspect strength. Use [Aspect.isConjunction] to match exactly.
    // Moon is contextual — needs the Sun longitude to classify.
    final moonLon = grahaLongitudes[Body.moon];
    for (final entry in grahaLongitudes.entries) {
      final other = entry.key;
      if (other == body) continue;
      final natureOfOther = other == Body.moon
          ? Nature.ofMoon(sunLongitude: sunLongitude, moonLongitude: moonLon!)
          : Nature.of(other);
      if (natureOfOther != Nature.malefic) continue;
      if (Aspect.isConjunction(entry.value, eclipticLongitude)) {
        return DeeptadiState.peedita;
      }
    }
    // 7. Deena — debilitated
    if (dignity == DignityType.debilitated) return DeeptadiState.deena;
    // 8. Vikala — combust (skip Sun, Rahu, Ketu — handled by Dignity.isCombust)
    if (Dignity.isCombust(body, eclipticLongitude, sunLongitude,
        isRetrograde: isRetrograde)) {
      return DeeptadiState.vikala;
    }
    // 9. Khala — enemy's sign (E or GE)
    if (dignity == DignityType.enemy ||
        dignity == DignityType.greatEnemy) {
      return DeeptadiState.khala;
    }
    // Fallback — libaditya returns Shanta.
    return DeeptadiState.shanta;
  }
}
