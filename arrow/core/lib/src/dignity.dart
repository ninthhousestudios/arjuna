import 'package:arrow_options/arrow_options.dart';

import 'sign_data.dart';

/// Natural friendship: "F", "N", or "E".
enum _NatRel { f, n, e }

/// Dignity tables and calculations, ported from libaditya.
class Dignity {
  Dignity._();

  // ---------------------------------------------------------------------------
  // Exaltation: Body → (sign, exact degree)
  // ---------------------------------------------------------------------------

  static const exaltation = <Body, (int, double)>{
    Body.sun: (1, 10.0),
    Body.moon: (2, 3.0),
    Body.mars: (10, 28.0),
    Body.mercury: (6, 15.0),
    Body.jupiter: (4, 5.0),
    Body.venus: (12, 27.0),
    Body.saturn: (7, 20.0),
  };

  // ---------------------------------------------------------------------------
  // Debilitation: opposite sign, same degree
  // ---------------------------------------------------------------------------

  static const debilitation = <Body, (int, double)>{
    Body.sun: (7, 10.0),
    Body.moon: (8, 3.0),
    Body.mars: (4, 28.0),
    Body.mercury: (12, 15.0),
    Body.jupiter: (10, 5.0),
    Body.venus: (6, 27.0),
    Body.saturn: (1, 20.0),
  };

  // ---------------------------------------------------------------------------
  // Moolatrikona: Body → (sign, startDeg, endDeg)
  // ---------------------------------------------------------------------------

  static const moolatrikona = <Body, (int, double, double)>{
    Body.sun: (5, 0.0, 20.0),
    Body.moon: (2, 3.0, 30.0),
    Body.mars: (1, 0.0, 12.0),
    Body.mercury: (6, 15.0, 20.0),
    Body.jupiter: (9, 0.0, 10.0),
    Body.venus: (7, 0.0, 15.0),
    Body.saturn: (11, 0.0, 20.0),
  };

  // ---------------------------------------------------------------------------
  // Own signs: Body → set of sign numbers
  // The degree ranges are handled by the priority logic (MT takes precedence).
  // ---------------------------------------------------------------------------

  static const ownSigns = <Body, Set<int>>{
    Body.sun: {5},
    Body.moon: {4},
    Body.mars: {1, 8},
    Body.mercury: {3, 6},
    Body.jupiter: {9, 12},
    Body.venus: {2, 7},
    Body.saturn: {10, 11},
  };

  // ---------------------------------------------------------------------------
  // Natural friendship table
  // Row = planet, columns = Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn
  // ---------------------------------------------------------------------------

  static const _friendshipTable = <Body, Map<Body, _NatRel>>{
    Body.sun: {
      Body.moon: _NatRel.f, Body.mars: _NatRel.f, Body.mercury: _NatRel.n,
      Body.jupiter: _NatRel.f, Body.venus: _NatRel.e, Body.saturn: _NatRel.e,
    },
    Body.moon: {
      Body.sun: _NatRel.f, Body.mars: _NatRel.n, Body.mercury: _NatRel.f,
      Body.jupiter: _NatRel.n, Body.venus: _NatRel.n, Body.saturn: _NatRel.n,
    },
    Body.mars: {
      Body.sun: _NatRel.f, Body.moon: _NatRel.f, Body.mercury: _NatRel.e,
      Body.jupiter: _NatRel.f, Body.venus: _NatRel.n, Body.saturn: _NatRel.n,
    },
    Body.mercury: {
      Body.sun: _NatRel.f, Body.moon: _NatRel.e, Body.mars: _NatRel.n,
      Body.jupiter: _NatRel.n, Body.venus: _NatRel.f, Body.saturn: _NatRel.n,
    },
    Body.jupiter: {
      Body.sun: _NatRel.f, Body.moon: _NatRel.f, Body.mars: _NatRel.f,
      Body.mercury: _NatRel.e, Body.venus: _NatRel.e, Body.saturn: _NatRel.n,
    },
    Body.venus: {
      Body.sun: _NatRel.e, Body.moon: _NatRel.e, Body.mars: _NatRel.n,
      Body.mercury: _NatRel.f, Body.jupiter: _NatRel.n, Body.saturn: _NatRel.f,
    },
    Body.saturn: {
      Body.sun: _NatRel.e, Body.moon: _NatRel.e, Body.mars: _NatRel.e,
      Body.mercury: _NatRel.f, Body.jupiter: _NatRel.n, Body.venus: _NatRel.f,
    },
  };

  // ---------------------------------------------------------------------------
  // Combustion orbs (degrees from Sun)
  // ---------------------------------------------------------------------------

  static const combustionOrbs = <Body, double>{
    Body.moon: 12.0,
    Body.mars: 17.0,
    Body.mercury: 14.0,
    Body.jupiter: 11.0,
    Body.venus: 10.0,
    Body.saturn: 15.0,
  };

  /// Mercury retrograde combustion orb (tightened).
  static const double mercuryRetrogradeOrb = 12.0;

  // ---------------------------------------------------------------------------
  // Calculations
  // ---------------------------------------------------------------------------

  /// Whether [body] is exalted in [sign] at [inSignDeg].
  ///
  /// libaditya uses whole-sign exaltation for most planets, with degree
  /// ranges for Moon (0-3° Taurus) and Mercury (0-15° Virgo).
  static bool isExalted(Body body, int sign, double inSignDeg) {
    final ex = exaltation[body];
    if (ex == null) return false;
    if (sign != ex.$1) return false;
    // Moon: only exalted in first 3° of Taurus
    if (body == Body.moon) return inSignDeg < 3;
    // Mercury: only exalted in first 15° of Virgo
    if (body == Body.mercury) return inSignDeg < 15;
    return true;
  }

  /// Whether [body] is debilitated in [sign] at [inSignDeg].
  static bool isDebilitated(Body body, int sign, double inSignDeg) {
    final db = debilitation[body];
    if (db == null) return false;
    if (sign != db.$1) return false;
    if (body == Body.moon) return inSignDeg < 3;
    if (body == Body.mercury) return inSignDeg < 15;
    return true;
  }

  /// Whether [body] is in moolatrikona in [sign] at [inSignDeg].
  static bool isMoolatrikona(Body body, int sign, double inSignDeg) {
    final mt = moolatrikona[body];
    if (mt == null) return false;
    if (sign != mt.$1) return false;
    return inSignDeg >= mt.$2 && inSignDeg < mt.$3;
  }

  /// Whether [body] is in its own sign at [inSignDeg].
  ///
  /// Own sign is the remainder of the sign after moolatrikona/exaltation
  /// degrees are excluded.
  static bool isOwnSign(Body body, int sign, double inSignDeg) {
    final own = ownSigns[body];
    if (own == null || !own.contains(sign)) return false;
    // Check it's not in the MT or EX portion of the same sign
    if (isMoolatrikona(body, sign, inSignDeg)) return false;
    if (isExalted(body, sign, inSignDeg)) return false;
    return true;
  }

  static _NatRel? _naturalRelationship(Body body, Body lord) {
    if (body == lord) return null; // same planet
    return _friendshipTable[body]?[lord];
  }

  /// Whether two bodies are natural friends.
  static bool isNaturalFriend(Body body, Body lord) =>
      _naturalRelationship(body, lord) == _NatRel.f;

  /// Whether two bodies are natural enemies.
  static bool isNaturalEnemy(Body body, Body lord) =>
      _naturalRelationship(body, lord) == _NatRel.e;

  /// Temporary friendship based on sign positions.
  ///
  /// If the other planet is 2, 3, 4, 10, 11, or 12 signs away, it's a
  /// temporary friend. Otherwise temporary enemy.
  static bool isTemporaryFriend(int sign1, int sign2) {
    final apart = ((sign2 - sign1) % 12);
    // Signs 2,3,4,10,11,0(=12) away are friends
    // That means indices 1,2,3,9,10,11 in 0-based
    return apart >= 1 && apart <= 3 || apart >= 9 && apart <= 11;
  }

  /// Combined (compound) friendship from natural + temporary.
  static FriendshipLevel compoundFriendship(
      Body body, Body lord, int bodySign, int lordSign) {
    final nat = _naturalRelationship(body, lord);
    if (nat == null) return FriendshipLevel.neutral;
    final tempFriend = isTemporaryFriend(bodySign, lordSign);

    return switch ((nat, tempFriend)) {
      (_NatRel.f, true) => FriendshipLevel.greatFriend,
      (_NatRel.f, false) => FriendshipLevel.neutral,
      (_NatRel.n, true) => FriendshipLevel.friend,
      (_NatRel.n, false) => FriendshipLevel.enemy,
      (_NatRel.e, true) => FriendshipLevel.neutral,
      (_NatRel.e, false) => FriendshipLevel.greatEnemy,
    };
  }

  /// Calculate the dignity of a body at a given sign and in-sign degree,
  /// with the sign lord's position for friendship calculation.
  ///
  /// Priority (libaditya): check special dignities last (they override).
  /// 1. Compute compound friendship → base dignity
  /// 2. Override: exalted, moolatrikona, own sign, debilitated
  static DignityType calculate(
      Body body, int sign, double inSignDeg, int lordSign) {
    // Rahu/Ketu: use sign lord's dignity
    if (body == Body.rahu || body == Body.ketu) {
      final lord = SignData.lord(sign);
      return calculate(lord, sign, inSignDeg, lordSign);
    }

    // Start with compound friendship as base
    final signLord = SignData.lord(sign);
    final compound = compoundFriendship(body, signLord, sign, lordSign);
    var dignity = switch (compound) {
      FriendshipLevel.greatFriend => DignityType.greatFriend,
      FriendshipLevel.friend => DignityType.friend,
      FriendshipLevel.neutral => DignityType.neutral,
      FriendshipLevel.enemy => DignityType.enemy,
      FriendshipLevel.greatEnemy => DignityType.greatEnemy,
    };

    // Override with special dignities (checked in priority order, last wins)
    if (isDebilitated(body, sign, inSignDeg)) dignity = DignityType.debilitated;
    if (isOwnSign(body, sign, inSignDeg)) dignity = DignityType.ownSign;
    if (isMoolatrikona(body, sign, inSignDeg)) {
      dignity = DignityType.moolatrikona;
    }
    if (isExalted(body, sign, inSignDeg)) dignity = DignityType.exalted;

    return dignity;
  }

  /// Whether a planet is combust (too close to the Sun).
  static bool isCombust(
      Body body, double bodyLongitude, double sunLongitude,
      {bool isRetrograde = false}) {
    if (body == Body.sun || body == Body.rahu || body == Body.ketu) {
      return false;
    }
    var orb = combustionOrbs[body];
    if (orb == null) return false;
    if (body == Body.mercury && isRetrograde) orb = mercuryRetrogradeOrb;

    final distance = ((bodyLongitude - sunLongitude) % 360).abs();
    final angularSep = distance > 180 ? 360 - distance : distance;
    return angularSep < orb;
  }
}

