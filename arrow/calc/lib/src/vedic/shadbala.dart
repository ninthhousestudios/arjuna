import 'dart:math' as math;

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';

import 'aspect.dart';
import 'shadbala_const.dart';

enum _Gender { male, female, neutral }

/// Planet genders for sama-visama and drekkana bala.
/// Sun=M, Moon=F, Mars=M, Mercury=N, Jupiter=M, Venus=F, Saturn=M.
const _planetGender = <Body, _Gender>{
  Body.sun: _Gender.male,
  Body.moon: _Gender.female,
  Body.mars: _Gender.male,
  Body.mercury: _Gender.neutral,
  Body.jupiter: _Gender.male,
  Body.venus: _Gender.female,
  Body.saturn: _Gender.neutral,
};

/// Six-fold planetary strength (Shadbala). All virupas (1/60th of a rupa).
///
/// Ported from libaditya. Fields map directly to the six balas:
///   1. Sthana Bala  — positional strength (5 sub-balas)
///   2. Dig Bala     — directional strength
///   3. Ayana Bala   — solstitial strength (part of Kala Bala)
///   4. Cheshta Bala — motional strength (part of Kala Bala)
///   5. Drig Bala    — aspectual strength
///
/// Note: Naisargika (natural) and Chesta bala sub-components of Kala Bala
/// beyond ayana/cheshta are not included here.
class Shadbala {
  final double uccaBala;
  final double saptavargajaBala;
  final double samaVisamaBala;
  final double kendradiBala;
  final double drekkanaBala;
  final double digBala;
  final double ayanaBala;
  final double cheshtaBala;
  final double drigBala;

  const Shadbala({
    required this.uccaBala,
    required this.saptavargajaBala,
    required this.samaVisamaBala,
    required this.kendradiBala,
    required this.drekkanaBala,
    required this.digBala,
    required this.ayanaBala,
    required this.cheshtaBala,
    required this.drigBala,
  });

  /// Sthana Bala = sum of five positional sub-balas.
  double get sthanaBala =>
      uccaBala + saptavargajaBala + samaVisamaBala + kendradiBala + drekkanaBala;

  /// Total in virupas.
  double get totalVirupas => sthanaBala + digBala + ayanaBala + cheshtaBala + drigBala;

  /// Total in rupas (virupas / 60).
  double get totalRupas => totalVirupas / 60.0;
}

/// Shadbala calculation functions. All static, no state.
class ShadbalaCalc {
  const ShadbalaCalc._();

  // ---------------------------------------------------------------------------
  // Core primitive
  // ---------------------------------------------------------------------------

  /// Virupas (0–60) measuring how close [selfLon] is to [pointLon].
  ///
  /// Returns 60 when [selfLon] == [pointLon], 0 at the opposite (180° away),
  /// and 30 at 90° from [pointLon]. Linear on the shortest arc.
  static double virupasBetween(double selfLon, double pointLon) {
    var dist = (selfLon - pointLon) % 360.0;
    if (dist < 0) dist += 360.0;
    if (dist > 180.0) dist = 360.0 - dist; // shortest arc, 0–180
    return (1.0 - dist / 180.0) * 60.0;
  }

  // ---------------------------------------------------------------------------
  // 1a. Uccha Bala
  // ---------------------------------------------------------------------------

  /// Strength from proximity to exaltation point, 0–60 virupas.
  ///
  /// Moon and Mercury use range-based logic (exaltation spans a few degrees).
  /// All other karakas: linear via [virupasBetween].
  static double uccaBala(Body body, double eclipticLon) {
    if (body == Body.moon) return _moonUccaBala(eclipticLon);
    if (body == Body.mercury) return _mercuryUccaBala(eclipticLon);
    final pt = ShadbalaCon.exaltationPoint[body];
    if (pt == null) return 0.0;
    return virupasBetween(eclipticLon, pt);
  }

  // Moon: range 30–33° = 60, range 210–213° = 0, otherwise proportional.
  static double _moonUccaBala(double lon) {
    if (lon >= ShadbalaCon.moonExaltStart && lon <= ShadbalaCon.moonExaltEnd) {
      return 60.0;
    }
    if (lon >= ShadbalaCon.moonDebilStart && lon <= ShadbalaCon.moonDebilEnd) {
      return 0.0;
    }
    // Proportional over the 177° half-arc between range edges.
    return virupasBetween(lon, ShadbalaCon.moonExaltEnd);
  }

  // Mercury: range 150–165° = 60, range 330–345° = 0, otherwise proportional.
  static double _mercuryUccaBala(double lon) {
    if (lon >= ShadbalaCon.mercuryExaltStart && lon <= ShadbalaCon.mercuryExaltEnd) {
      return 60.0;
    }
    if (lon >= ShadbalaCon.mercuryDebilStart && lon <= ShadbalaCon.mercuryDebilEnd) {
      return 0.0;
    }
    return virupasBetween(lon, ShadbalaCon.mercuryExaltEnd);
  }

  // ---------------------------------------------------------------------------
  // 1b. Saptavargaja Bala
  // ---------------------------------------------------------------------------

  /// Strength from dignity across 7 vargas (D1,D2,D3,D7,D9,D12,D30).
  ///
  /// [sevenVargas] must be exactly 7 records with the sign and dignity for each
  /// varga. If dignity is exalted or debilitated, the compound friendship level
  /// for that placement is used to determine the point value instead.
  ///
  /// Maximum possible: 7 × 45 = 315 virupas.
  static double saptavargajaBala(
    Body body,
    List<({int sign, DignityType dignity})> sevenVargas,
  ) {
    assert(sevenVargas.length == 7, 'saptavargajaBala requires exactly 7 vargas');
    var total = 0.0;
    for (final varga in sevenVargas) {
      total += _saptavargajaPoints(body, varga.sign, varga.dignity);
    }
    return total;
  }

  static double _saptavargajaPoints(Body body, int sign, DignityType dignity) {
    if (dignity == DignityType.exalted || dignity == DignityType.debilitated) {
      // Exalted/debilitated are not in the saptavargaja points table.
      // We need compound friendship for the sign, but lordSign (the sign where
      // the sign lord currently sits) is not available at this layer — callers
      // who have it should pre-resolve DignityType via Dignity.calculate().
      // Fall back to natural friendship only (temporal component unknown).
      final lord = SignData.lord(sign);
      final isNatFriend = Dignity.isNaturalFriend(body, lord);
      final isNatEnemy = Dignity.isNaturalEnemy(body, lord);
      final level = isNatFriend
          ? FriendshipLevel.friend
          : isNatEnemy
              ? FriendshipLevel.enemy
              : FriendshipLevel.neutral;
      return ShadbalaCon.compoundFriendshipPoints[level] ?? 10.0;
    }
    return ShadbalaCon.saptavargajaPoints[dignity] ?? 10.0;
  }

  // ---------------------------------------------------------------------------
  // 1c. Sama-Visama Bala
  // ---------------------------------------------------------------------------

  /// Strength from planet gender matching sign gender, across rashi and navamsha.
  ///
  /// Each matching varga contributes 15 virupas. Neuter planets match male signs.
  /// Maximum: 30 virupas.
  static double samaVisamaBala(Body body, int rashiSign, int navamshaSign) {
    final gender = _planetGender[body];
    if (gender == null) return 0.0;
    var total = 0.0;
    if (_matchesSign(gender, rashiSign)) total += 15.0;
    if (_matchesSign(gender, navamshaSign)) total += 15.0;
    return total;
  }

  // Odd signs = male, even signs = female. Neuter matches male (odd).
  static bool _matchesSign(_Gender gender, int sign) {
    final isMaleSign = sign % 2 != 0;
    return switch (gender) {
      _Gender.male => isMaleSign,
      _Gender.female => !isMaleSign,
      _Gender.neutral => isMaleSign,
    };
  }

  // ---------------------------------------------------------------------------
  // 1d. Kendra-di Bala
  // ---------------------------------------------------------------------------

  /// Strength from house position: kendra=60, panaphara=30, apoklima=15.
  static double kendradiBala(int houseFromLagna) {
    final h = ((houseFromLagna - 1) % 12) + 1; // normalise to 1–12
    return switch (h) {
      1 || 4 || 7 || 10 => 60.0, // kendra
      2 || 5 || 8 || 11 => 30.0, // panaphara
      _ => 15.0,                  // apoklima (3, 6, 9, 12)
    };
  }

  // ---------------------------------------------------------------------------
  // 1e. Drekkana Bala
  // ---------------------------------------------------------------------------

  /// Strength from decanate match with planet gender: 15 if match, 0 otherwise.
  ///
  /// 0–10° = 1st decan (M), 10–20° = 2nd (N), 20–30° = 3rd (F).
  /// Neuter planets match neutral decan.
  static double drekkanaBala(Body body, double inSignLon) {
    final gender = _planetGender[body];
    if (gender == null) return 0.0;
    final decan = (inSignLon / 10.0).floor().clamp(0, 2);
    final decanGender = const [_Gender.male, _Gender.neutral, _Gender.female][decan];
    return gender == decanGender ? 15.0 : 0.0;
  }

  // ---------------------------------------------------------------------------
  // 2. Dig Bala
  // ---------------------------------------------------------------------------

  /// Directional strength: 0–60 virupas based on proximity to the digbala cusp.
  ///
  /// [digbalaCuspLon] is the ecliptic longitude of the house where the body is
  /// strongest (e.g. ASC for Mercury/Jupiter, MC for Sun/Mars, etc.).
  static double digBala(Body body, double planetLon, double digbalaCuspLon) {
    return virupasBetween(planetLon, digbalaCuspLon);
  }

  // ---------------------------------------------------------------------------
  // 3. Ayana Bala
  // ---------------------------------------------------------------------------

  /// Solstitial strength: proximity to Cancer (90°) or Capricorn (270°).
  ///
  /// Sun/Mars/Jupiter/Venus: strongest at Cancer (northern solstice, 90°).
  /// Moon/Saturn: strongest at Capricorn (southern solstice, 270°).
  /// Mercury: whichever solstice is closer (higher value wins).
  static double ayanaBala(Body body, double tropicalLon) {
    switch (body) {
      case Body.sun:
      case Body.mars:
      case Body.jupiter:
      case Body.venus:
        return virupasBetween(tropicalLon, 90.0);
      case Body.moon:
      case Body.saturn:
        return virupasBetween(tropicalLon, 270.0);
      case Body.mercury:
        final north = virupasBetween(tropicalLon, 90.0);
        final south = virupasBetween(tropicalLon, 270.0);
        return math.max(north, south);
      default:
        return 0.0;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Cheshta Bala
  // ---------------------------------------------------------------------------

  /// Motional strength, 0–60 virupas.
  ///
  /// Sun: same as ayana bala (proximity to Cancer).
  /// Moon: proximity to opposition with Sun (full moon = peak motion).
  /// Inner planets (Mercury, Venus): computed from apogee = planet mean lon.
  /// Outer planets (Mars, Jupiter, Saturn): apogee = sun mean lon.
  static double cheshtaBala(
    Body body,
    double eclipticLon,
    double julianDay, {
    double? sunEclipticLon,
  }) {
    switch (body) {
      case Body.sun:
        return virupasBetween(eclipticLon, 90.0);
      case Body.moon:
        final sunLon = sunEclipticLon ?? 0.0;
        return virupasBetween(eclipticLon, (sunLon + 180.0) % 360.0);
      case Body.mercury:
      case Body.venus:
        return _innerPlanetCheshta(body, eclipticLon, julianDay);
      case Body.mars:
      case Body.jupiter:
      case Body.saturn:
        return _outerPlanetCheshta(body, eclipticLon, julianDay);
      default:
        return 0.0;
    }
  }

  // Inner planets: apogee = planet mean longitude.
  static double _innerPlanetCheshta(Body body, double trueLon, double jd) {
    final t = (jd - 2451545.0) / 36525.0;
    final sunMean = _meanLon(Body.sun, t);
    final planetMean = _meanLon(body, t);
    final average = (trueLon + sunMean) / 2.0;
    var reduce = (planetMean - average).abs() % 360.0;
    if (reduce > 180.0) reduce = 360.0 - reduce;
    return reduce / 3.0;
  }

  // Outer planets: apogee = sun mean longitude.
  static double _outerPlanetCheshta(Body body, double trueLon, double jd) {
    final t = (jd - 2451545.0) / 36525.0;
    final sunMean = _meanLon(Body.sun, t);
    final planetMean = _meanLon(body, t);
    final average = (trueLon + planetMean) / 2.0;
    var reduce = (sunMean - average).abs() % 360.0;
    if (reduce > 180.0) reduce = 360.0 - reduce;
    return reduce / 3.0;
  }

  /// Evaluate the mean longitude polynomial for [body] at Julian centuries [t].
  static double _meanLon(Body body, double t) {
    final c = ShadbalaCon.meanLonCoeffs[body];
    if (c == null) return 0.0;
    final raw = c[0] + c[1] * t + c[2] * t * t + c[3] * t * t * t;
    return raw % 360.0;
  }

  // ---------------------------------------------------------------------------
  // 5. Drig Bala
  // ---------------------------------------------------------------------------

  /// Aspectual strength: sum of aspect contributions from the other 6 karakas.
  ///
  /// Full benefics (Jupiter, Mercury): +strength.
  /// Partial benefics (Venus, waxing Moon): +strength / 4.
  /// Malefics (Sun, Mars, Saturn, waning Moon): −strength / 4.
  static double drigBala(Body body, Varga varga) {
    final bodyLon = varga.planet(body).rawLongitude;
    final sunLon = varga.sun.rawLongitude;
    final moonLon = varga.moon.rawLongitude;

    var total = 0.0;
    for (final aspector in Body.karakas) {
      if (aspector == body) continue;
      final aspectorLon = varga.karaka(aspector).rawLongitude;
      final strength = Aspect.strength(aspector, aspectorLon, bodyLon);
      if (strength == 0.0) continue;

      final nature = Nature.of(aspector, sunLongitude: sunLon, moonLongitude: moonLon);

      switch (aspector) {
        case Body.jupiter:
        case Body.mercury:
          total += strength; // full benefic
        case Body.venus:
          total += strength / 4.0; // partial benefic
        case Body.moon:
          if (nature == Nature.benefic) {
            total += strength / 4.0; // waxing moon: partial benefic
          } else {
            total -= strength / 4.0; // waning moon: malefic
          }
        case Body.sun:
        case Body.mars:
        case Body.saturn:
          total -= strength / 4.0; // malefic
        default:
          break;
      }
    }
    return total;
  }
}
