import 'package:arrow_options/arrow_options.dart';

import 'varga_deities.dart';

/// Result of a varga calculation: the new longitude and optional deity.
typedef VargaResult = (double longitude, VargaDeity? deity);

/// A longitude in the ecliptic, aware of its varga (divisional chart) context.
///
/// Given an ecliptic longitude, a [VargaType], and a [CalcConfig], computes:
/// - The amsha (varga) longitude
/// - The sign (1-12) respecting the configured [Circle]
/// - Nakshatra (1-27) and pada (1-4)
/// - The presiding deity for the varga division
class Longitude {
  /// Raw ecliptic longitude (0-360), as received from ephemeris.
  final double eclipticLongitude;

  /// Equatorial longitude, used for nakshatra when [CalcConfig.nakEquatorial].
  final double equatorialLongitude;

  /// Which varga this longitude is computed for.
  final VargaType vargaType;

  /// Calculation configuration (circle, nakshatra ayanamsa, etc.).
  final CalcConfig config;

  /// The longitude in the varga's coordinate frame.
  late final double amshaLongitude;

  /// The presiding deity for the varga division (null for rashi).
  late final VargaDeity? deity;

  Longitude(
    this.eclipticLongitude,
    this.equatorialLongitude,
    this.vargaType,
    this.config,
  ) {
    if (vargaType == VargaType.rashi) {
      amshaLongitude = eclipticLongitude;
      deity = null;
    } else {
      final result = _computeVarga(eclipticLongitude, vargaType);
      amshaLongitude = result.$1 % 360;
      deity = result.$2;
    }
  }

  /// The amsha (division number) of this varga.
  int get amsha => vargaType.amsha;

  /// The longitude in the varga's coordinate frame.
  double get longitude => amshaLongitude;

  /// Sign index (0-based). Circle-aware.
  ///
  /// For [Circle.aditya], sign 1 starts at 330deg ecliptic, so the raw
  /// index is shifted by +1 mod 12.
  int get signIndex {
    final raw = (longitude % 360) ~/ 30;
    return config.circle == Circle.aditya
        ? (raw.toInt() + 1) % 12
        : raw.toInt();
  }

  /// Sign number (1-12).
  int get sign => signIndex + 1;

  /// Nakshatra (1-27).
  ///
  /// Uses nakshatra-specific ayanamsa and optionally equatorial longitude.
  int get nakshatra {
    final rawLon =
        config.nakEquatorial ? equatorialLongitude : eclipticLongitude;
    // nakAyanamsa offset would be applied here when available from EphSnapshot
    return ((rawLon % 360) / (360 / 27)).floor() + 1;
  }

  /// Pada (1-4) within nakshatra.
  int get pada {
    final rawLon =
        config.nakEquatorial ? equatorialLongitude : eclipticLongitude;
    final nakSpan = 360.0 / 27;
    final posInNak = rawLon % nakSpan;
    return (posInNak / (nakSpan / 4)).floor() + 1;
  }

  /// Degrees within current sign (0-30).
  double get inSignLongitude => longitude % 30;

  /// Angular distance from this longitude to [other], going forward.
  double degreesApart(double other) => ((other - eclipticLongitude) % 360);

  /// Signs apart from this sign to [otherSign] (1-12).
  int signsApart(int otherSign) => ((otherSign - sign) % 12);

  /// Whether ecliptic longitude is between [long1] and [long2] (going forward).
  bool isBetween(double long1, double long2) {
    final lon = eclipticLongitude % 360;
    final l1 = long1 % 360;
    final l2 = long2 % 360;
    if (l1 <= l2) return lon >= l1 && lon <= l2;
    return lon >= l1 || lon <= l2;
  }

  // ---------------------------------------------------------------------------
  // Varga dispatch
  // ---------------------------------------------------------------------------

  VargaResult _computeVarga(double lon, VargaType type) {
    if (type.isParivritti) return _parivritti(lon, type.amsha);
    return switch (type) {
      VargaType.hora => _hora(lon),
      VargaType.drekkana => _drekkana(lon),
      VargaType.chaturthamsha => _chaturthamsha(lon),
      VargaType.saptamsha => _saptamsha(lon),
      VargaType.dashamsha => _dashamsha(lon),
      VargaType.dashamshaReversed => _dashamsha(lon, evenReversed: true),
      VargaType.dvadashamsha => _dvadashamsha(lon),
      VargaType.shodashamsha => _shodashamsha(lon),
      VargaType.vimshamsha => _vimshamsha(lon),
      VargaType.parasharaChaturvimshamsha =>
        _siddhamsha(lon, parashara: true),
      VargaType.siddhamsha => _siddhamsha(lon),
      VargaType.trimsamsha => _trimsamsha(lon),
      VargaType.bhamsha => _bhamsha(lon),
      VargaType.khavedamsha => _khavedamsha(lon),
      VargaType.akshavedamsha => _akshavedamsha(lon),
      VargaType.shashtyamsha => _shashtyamsha(lon),
      _ => _parivritti(lon, type.amsha), // fallback
    };
  }

  // ---------------------------------------------------------------------------
  // Helper: aditya offset
  // ---------------------------------------------------------------------------

  /// Offset applied to longitude before varga calculation when using Aditya
  /// circle. In Aditya, sign 1 starts at 330deg, so we add 30deg to shift
  /// the longitude into the Aditya frame for sign-based varga logic.
  int get _adityaOffset => config.circle == Circle.aditya ? 30 : 0;

  /// Ecliptic sign number (1-12) in the raw ecliptic frame (before circle
  /// adjustment). This is what libaditya calls `real_sign`.
  int get _eclipticSignNum {
    final idx = ((eclipticLongitude + _adityaOffset) % 360) ~/ 30;
    return idx.toInt() + 1;
  }

  /// Degrees within the current ecliptic sign (0-30).
  double get _eclipticInSign => eclipticLongitude % 30;

  /// Base longitude for a given sign number, accounting for aditya offset.
  double _baseLon(int signNum) =>
      ((30 * (signNum - 1)) - _adityaOffset) % 360;

  /// Whether a sign number (1-12) is odd.
  static bool _isOdd(int signNum) => signNum.isOdd;

  // ---------------------------------------------------------------------------
  // Parivritti varga (cyclic n-fold)
  // ---------------------------------------------------------------------------

  /// Generic parivritti varga: divide each sign into [amsha] parts, then
  /// lay out 12 sign names cyclically across all (12 * amsha) divisions.
  VargaResult _parivritti(double lon, int thisAmsha) {
    final realSign = _eclipticSignNum;
    final realLon = lon + _adityaOffset;

    final amshaSize = 30.0 / thisAmsha;
    final position = realLon / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    final baseLon = 0.0 - _adityaOffset;

    // Look up deity for parivritti vargas that have them
    final deity = _parivrittiDeity(thisAmsha, amshaElapsed, realSign);

    final newLon = baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
    return (newLon, deity);
  }

  /// Amsha → canonical VargaType for deity lookup. lookupDeity handles
  /// its own modulo, so no per-case wrapping needed here.
  static const _deityVargaByAmsha = <int, VargaType>{
    3: VargaType.drekkana,
    4: VargaType.chaturthamsha,
    7: VargaType.saptamsha,
    9: VargaType.navamsha,
    10: VargaType.dashamsha,
    12: VargaType.dvadashamsha,
    16: VargaType.shodashamsha,
    20: VargaType.vimshamsha,
    24: VargaType.parasharaChaturvimshamsha,
    27: VargaType.bhamsha,
    40: VargaType.khavedamsha,
    60: VargaType.shashtyamsha,
  };

  /// Deity lookup for parivritti vargas, ported from
  /// `set_parivritti_deities` in libaditya.
  VargaDeity? _parivrittiDeity(int amsha, int whichAmsha, int realSign) {
    // D2 hora deity is sign-parity dependent, handled inline.
    if (amsha == 2) {
      final isOddPortion = (whichAmsha + 1).isOdd;
      if (_isOdd(realSign)) {
        return isOddPortion ? VargaDeity.sun : VargaDeity.moon;
      } else {
        return isOddPortion ? VargaDeity.moon : VargaDeity.sun;
      }
    }
    final type = _deityVargaByAmsha[amsha];
    if (type == null) return null;
    return lookupDeity(type, whichAmsha, signNum: realSign);
  }

  // ---------------------------------------------------------------------------
  // Special vargas
  // ---------------------------------------------------------------------------

  /// D2 Hora.
  ///
  /// First half of odd sign: Sun, stays in same sign.
  /// Second half of odd sign: Moon, goes to opposite sign.
  /// Even signs: reversed.
  VargaResult _hora(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final baseLon = _baseLon(realSign);
    final oppositeLon = (baseLon + 180) % 360;

    VargaDeity deity;
    double newLon;

    if (_isOdd(realSign) && realInSign < 15) {
      deity = VargaDeity.sun;
      newLon = baseLon + (realInSign / 15) * 30;
    } else if (_isOdd(realSign) && realInSign >= 15) {
      deity = VargaDeity.moon;
      newLon = oppositeLon + ((realInSign - 15) / 15) * 30;
    } else if (!_isOdd(realSign) && realInSign < 15) {
      deity = VargaDeity.moon;
      newLon = baseLon + (realInSign / 15) * 30;
    } else {
      deity = VargaDeity.sun;
      newLon = oppositeLon + ((realInSign - 15) / 15) * 30;
    }

    return (newLon, deity);
  }

  /// D3 Drekkana.
  ///
  /// First third stays in same sign (Narada).
  /// Second third goes to 5th sign from here / next trine (Agastya).
  /// Third third goes to 9th sign from here / next-next trine (Durvasas).
  VargaResult _drekkana(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final baseLon = _baseLon(realSign);
    final trineLon = (baseLon + 120) % 360;
    final trineTrineLon = (baseLon + 240) % 360;

    VargaDeity deity;
    double newLon;

    if (realInSign < 10) {
      deity = VargaDeity.narada;
      newLon = baseLon + (realInSign / 10) * 30;
    } else if (realInSign < 20) {
      deity = VargaDeity.agastya;
      newLon = trineLon + ((realInSign - 10) / 10) * 30;
    } else {
      deity = VargaDeity.durvasas;
      newLon = trineTrineLon + ((realInSign - 20) / 10) * 30;
    }

    return (newLon, deity);
  }

  /// D4 Chaturthamsha.
  ///
  /// Divide into 4: each quarter goes to the next sign of same modality
  /// (0deg, +90deg, +180deg, +270deg from base).
  VargaResult _chaturthamsha(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final baseLon = _baseLon(realSign);
    final sq1 = (baseLon + 90) % 360;
    final sq2 = (baseLon + 180) % 360;
    final sq3 = (baseLon + 270) % 360;

    const fourth = 30.0 / 4;

    VargaDeity deity;
    double newLon;

    if (realInSign < fourth) {
      deity = VargaDeity.sanaka;
      newLon = baseLon + (realInSign / fourth) * 30;
    } else if (realInSign < 2 * fourth) {
      deity = VargaDeity.sananda;
      newLon = sq1 + ((realInSign - fourth) / fourth) * 30;
    } else if (realInSign < 3 * fourth) {
      deity = VargaDeity.sanatkumara;
      newLon = sq2 + ((realInSign - 2 * fourth) / fourth) * 30;
    } else {
      deity = VargaDeity.sanatana;
      newLon = sq3 + ((realInSign - 3 * fourth) / fourth) * 30;
    }

    return (newLon, deity);
  }

  /// D10 Dashamsha.
  ///
  /// Odd signs start with themselves.
  /// Even signs start with the 9th sign from themselves.
  /// [evenReversed]: if true, even signs count backward.
  VargaResult _dashamsha(double lon, {bool evenReversed = false}) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final baseLonOdd = _baseLon(realSign);
    // Even starts at sign + 8 (the 9th sign counting from itself)
    final evenStart = ((realSign - 1) + 8) % 12;
    final baseLonEven = _baseLon(evenStart + 1);

    const amshaSize = 30.0 / 10;
    final position = realInSign / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    final deity = lookupDeity(VargaType.dashamsha, amshaElapsed % 10,
        signNum: realSign);

    double baseLon;
    int direction = 1;
    if (_isOdd(realSign)) {
      baseLon = baseLonOdd;
    } else {
      baseLon = baseLonEven;
      if (evenReversed) direction = -1;
    }

    final newLon =
        baseLon + (direction * amshaElapsed * 30) + (currentInAmsha * 30);
    return (newLon, deity);
  }

  /// D12 Dvadashamsha.
  ///
  /// Each sign divided into 12, first part = same sign, then forward.
  VargaResult _dvadashamsha(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final baseLon = _baseLon(realSign);

    const amshaSize = 30.0 / 12;
    final position = realInSign / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    final deity = lookupDeity(VargaType.dvadashamsha, amshaElapsed % 4,
        signNum: realSign);

    final newLon =
        baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
    return (newLon, deity);
  }

  /// D16 Shodashamsha.
  ///
  /// Moveable signs start from Aries (1).
  /// Fixed signs start from Leo (5).
  /// Dual signs start from Sagittarius (9).
  VargaResult _shodashamsha(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final baseLonMoveable = _baseLon(1);
    final baseLonFixed = _baseLon(5);
    final baseLonDual = _baseLon(9);

    const amshaSize = 30.0 / 16;
    final position = realInSign / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    double baseLon;
    final mod = (realSign - 1) % 3;
    if (mod == 0) {
      baseLon = baseLonMoveable; // moveable: 1,4,7,10
    } else if (mod == 1) {
      baseLon = baseLonFixed; // fixed: 2,5,8,11
    } else {
      baseLon = baseLonDual; // dual: 3,6,9,12
    }

    final deity = lookupDeity(VargaType.shodashamsha, amshaElapsed % 4,
        signNum: realSign);

    final newLon =
        baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
    return (newLon, deity);
  }

  /// D20 Vimshamsha.
  ///
  /// Moveable signs start from Aries (1).
  /// Fixed signs start from Sagittarius (9).
  /// Dual signs start from Leo (5).
  VargaResult _vimshamsha(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final baseLonMoveable = _baseLon(1);
    final baseLonFixed = _baseLon(9);
    final baseLonDual = _baseLon(5);

    const amshaSize = 30.0 / 20;
    final position = realInSign / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    double baseLon;
    final mod = (realSign - 1) % 3;
    if (mod == 0) {
      baseLon = baseLonMoveable;
    } else if (mod == 1) {
      baseLon = baseLonFixed;
    } else {
      baseLon = baseLonDual;
    }

    final deity = lookupDeity(VargaType.vimshamsha, amshaElapsed,
        signNum: realSign);

    final newLon =
        baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
    return (newLon, deity);
  }

  /// D24 Siddhamsha / Parashara Chaturvimshamsha.
  ///
  /// Odd signs: start at Leo (5), go forward.
  /// Even signs: start at Cancer (4), go backward (siddhamsha) or
  ///   forward (parashara).
  VargaResult _siddhamsha(double lon, {bool parashara = false}) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final baseLonOdd = _baseLon(5);
    final baseLonEven = _baseLon(4);

    const amshaSize = 30.0 / 24;
    final position = realInSign / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    final deity = lookupDeity(
        VargaType.parasharaChaturvimshamsha, amshaElapsed % 12,
        signNum: realSign);

    double newLon;
    if (_isOdd(realSign)) {
      newLon = baseLonOdd + (amshaElapsed * 30) + (currentInAmsha * 30);
    } else {
      final direction = parashara ? 1 : -1;
      newLon = baseLonEven +
          (direction * amshaElapsed * 30) +
          (currentInAmsha * 30);
    }

    return (newLon, deity);
  }

  /// D27 Bhamsha.
  ///
  /// Fire signs start at Aries (1).
  /// Earth signs start at Cancer (4).
  /// Air signs start at Libra (7).
  /// Water signs start at Capricorn (10).
  VargaResult _bhamsha(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    // Element based on sign: fire=1,5,9  earth=2,6,10  air=3,7,11  water=4,8,12
    final element = ((realSign - 1) % 4);
    final startSign = switch (element) {
      0 => 1, // fire -> Aries
      1 => 4, // earth -> Cancer
      2 => 7, // air -> Libra
      _ => 10, // water -> Capricorn
    };

    final baseLon = _baseLon(startSign);

    const amshaSize = 30.0 / 27;
    final position = realInSign / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    final deity =
        lookupDeity(VargaType.bhamsha, amshaElapsed, signNum: realSign);

    final newLon =
        baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
    return (newLon, deity);
  }

  /// D40 Khavedamsha.
  ///
  /// Odd signs start at Aries (1).
  /// Even signs start at Libra (7).
  VargaResult _khavedamsha(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final baseLon = _isOdd(realSign) ? _baseLon(1) : _baseLon(7);

    const amshaSize = 30.0 / 40;
    final position = realInSign / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    final deity = lookupDeity(VargaType.khavedamsha, amshaElapsed % 12,
        signNum: realSign);

    final newLon =
        baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
    return (newLon, deity);
  }

  /// D45 Akshavedamsha.
  ///
  /// Moveable signs start at Aries (1).
  /// Fixed signs start at Leo (5).
  /// Dual signs start at Sagittarius (9).
  VargaResult _akshavedamsha(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final mod = (realSign - 1) % 3;
    final startSign = switch (mod) {
      0 => 1, // moveable
      1 => 5, // fixed
      _ => 9, // dual
    };

    final baseLon = _baseLon(startSign);

    const amshaSize = 30.0 / 45;
    final position = realInSign / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    final deity = lookupDeity(VargaType.akshavedamsha, amshaElapsed % 3,
        signNum: realSign);

    final newLon =
        baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
    return (newLon, deity);
  }

  /// D7 Saptamsha.
  ///
  /// Divide each sign into 7 equal parts (4°17'8.57" each).
  /// Odd signs count from the sign itself; even signs from the 7th sign.
  VargaResult _saptamsha(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    const amshaSize = 30.0 / 7;
    final position = realInSign / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    final startSign = _isOdd(realSign)
        ? realSign
        : ((realSign - 1 + 6) % 12) + 1;

    final baseLon = _baseLon(startSign);

    final deity = lookupDeity(VargaType.saptamsha, amshaElapsed,
        signNum: realSign);

    final newLon = baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
    return (newLon, deity);
  }

  /// D30 Trimsamsha (Parashara).
  ///
  /// Unequal divisions within each sign. Odd signs:
  /// Mars(5°)→Aries, Saturn(5°)→Aquarius, Jupiter(8°)→Sagittarius,
  /// Mercury(7°)→Gemini, Venus(5°)→Taurus. Even signs: reversed order.
  VargaResult _trimsamsha(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    // (endDeg, targetSign) — target is the lord's primary sign.
    const oddTable = [
      (5.0, 1), // Mars → Aries
      (10.0, 11), // Saturn → Aquarius
      (18.0, 9), // Jupiter → Sagittarius
      (25.0, 3), // Mercury → Gemini
      (30.0, 2), // Venus → Taurus
    ];

    const evenTable = [
      (5.0, 2), // Venus → Taurus
      (12.0, 3), // Mercury → Gemini
      (20.0, 9), // Jupiter → Sagittarius
      (25.0, 11), // Saturn → Aquarius
      (30.0, 1), // Mars → Aries
    ];

    final table = _isOdd(realSign) ? oddTable : evenTable;

    double prevEnd = 0.0;
    int targetSign = 1;
    double portionSize = 5.0;

    for (final (endDeg, lordSign) in table) {
      if (realInSign < endDeg) {
        targetSign = lordSign;
        portionSize = endDeg - prevEnd;
        break;
      }
      prevEnd = endDeg;
    }

    final posInPortion = (realInSign - prevEnd) / portionSize;
    final baseLon = _baseLon(targetSign);
    final newLon = baseLon + posInPortion * 30;

    return (newLon, null);
  }

  /// D60 Shashtyamsha.
  ///
  /// Algorithm from Santhanam's BPHS translation.
  /// Multiply in-sign degrees by 2, take remainder mod 12, add 1 to get
  /// how many signs forward from the rashi sign.
  VargaResult _shashtyamsha(double lon) {
    final realSign = _eclipticSignNum;
    final realInSign = _eclipticInSign;

    final calc = (realInSign * 2).floor();
    final remainder = calc % 12;
    // How many signs forward (1-based, astrological counting)
    final fromAmsha = remainder + 1;
    // Astrological forward: sign + (n-1), wrapping at 12
    final targetSign = ((realSign - 1) + (fromAmsha - 1)) % 12 + 1;

    final baseLon = _baseLon(targetSign);

    const amshaSize = 30.0 / 60;
    final position = realInSign / amshaSize;
    final amshaElapsed = position.floor();
    final currentInAmsha = position % 1;

    final deity = lookupDeity(VargaType.shashtyamsha, amshaElapsed,
        signNum: realSign);

    // Only the fractional position within the D60 division maps to the sign
    final newLon = baseLon + (currentInAmsha * 30);
    return (newLon, deity);
  }

  @override
  String toString() =>
      'Longitude($eclipticLongitude, amsha=$amshaLongitude, '
      'varga=${vargaType.name})';
}
