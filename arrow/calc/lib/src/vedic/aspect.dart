import 'package:arrow_options/arrow_options.dart';

/// Parashara drishti (aspect) strength in degrees, ported from
/// `libaditya/libaditya/objects/planets.py:391-422` (base) with per-planet
/// overrides for Mars (`:823`), Jupiter (`:1026`), Saturn (`:1228`).
///
/// Strength is a continuous value per BPHS (Graha Sutras, Ernst Wilhelm).
/// 60 = full aspect; 0 = no aspect. Conjunction (same sign) is handled
/// separately via [isConjunction]; [strength] returns 0 for same-sign pairs
/// to mirror libaditya's `"Y"` sentinel.
class Aspect {
  const Aspect._();

  /// True iff [fromLon] and [toLon] share a zodiac sign (0–360°, 30° each).
  /// Mirrors libaditya's `self.sign() == planet.sign()` check.
  static bool isConjunction(double fromLon, double toLon) {
    return _sign(fromLon) == _sign(toLon);
  }

  /// Continuous Parashara aspect strength from [from] at [fromLon] to the
  /// target at [toLon]. Returns 0.0 for no aspect, conjunction, or the
  /// "within 30° orb" exclusion. Mars/Jupiter/Saturn use their overrides;
  /// all other bodies use the base piecewise.
  static double strength(Body from, double fromLon, double toLon) {
    if (isConjunction(fromLon, toLon)) return 0.0;
    final diff = _degreesApart(fromLon, toLon);
    if (diff <= 30 || diff >= 300) return 0.0;
    switch (from) {
      case Body.mars:
        return _marsStrength(diff);
      case Body.jupiter:
        return _jupiterStrength(diff);
      case Body.saturn:
        return _saturnStrength(diff);
      case Body.sun:
      case Body.moon:
      case Body.mercury:
      case Body.venus:
      case Body.rahu:
      case Body.ketu:
      case Body.uranus:
      case Body.neptune:
      case Body.pluto:
      case Body.chiron:
        return _baseStrength(diff);
    }
  }

  /// Convenience: body aspects target (includes conjunction).
  static bool doesAspect(Body from, double fromLon, double toLon) {
    return isConjunction(fromLon, toLon) || strength(from, fromLon, toLon) > 0;
  }

  // libaditya planets.py:391 (Sun/Moon/Mercury/Venus, and fallback).
  static double _baseStrength(double diff) {
    if (diff > 180 && diff < 300) return (300 - diff) / 2;
    if (diff > 150 && diff <= 180) return (diff - 150) * 2;
    if (diff > 120 && diff <= 150) return 150 - diff;
    if (diff > 90 && diff <= 120) return ((120 - diff) / 2) + 30;
    if (diff > 60 && diff <= 90) return (diff - 60) + 15;
    if (diff > 30 && diff <= 60) return (diff - 30) / 2;
    return 0.0;
  }

  // libaditya planets.py:823 (Mars).
  static double _marsStrength(double diff) {
    if (diff > 240 && diff < 300) return (300 - diff) / 2;
    if (diff > 210 && diff <= 240) return 60 - (diff - 210);
    if (diff > 180 && diff < 210) return 60;
    if (diff > 150 && diff <= 180) return (diff - 150) * 2;
    if (diff > 120 && diff <= 150) return 150 - diff;
    if (diff > 90 && diff <= 120) return 60 - (120 - diff);
    if (diff > 60 && diff <= 90) return (diff - 60) + (diff - 60) / 2 + 15;
    if (diff > 30 && diff <= 60) return (diff - 30) / 2;
    return 0.0;
  }

  // libaditya planets.py:1026 (Jupiter).
  static double _jupiterStrength(double diff) {
    if (diff > 270 && diff < 300) return (300 - diff) / 2;
    if (diff > 240 && diff <= 270) return ((30 - (diff - 240)) * 1.5) + 15;
    if (diff > 210 && diff <= 240) return ((diff - 210) / 2) + 45;
    if (diff > 180 && diff <= 210) return (300 - diff) / 2;
    if (diff > 150 && diff <= 180) return (diff - 150) * 2;
    if (diff > 120 && diff <= 150) return 60 - ((diff - 120) * 2);
    if (diff > 90 && diff <= 120) return ((120 - diff) / 2) + 45;
    if (diff > 60 && diff <= 90) return (diff - 60) + 15;
    if (diff > 30 && diff <= 60) return (diff - 30) / 2;
    return 0.0;
  }

  // libaditya planets.py:1228 (Saturn).
  static double _saturnStrength(double diff) {
    if (diff > 270 && diff < 300) return (300 - diff) * 2;
    if (diff > 240 && diff <= 270) return (diff - 240) + 30;
    if (diff > 180 && diff <= 240) return (300 - diff) / 2;
    if (diff > 150 && diff <= 180) return (diff - 150) * 2;
    if (diff > 120 && diff <= 150) return 150 - diff;
    if (diff > 90 && diff <= 120) return ((120 - diff) / 2) + 30;
    if (diff > 60 && diff <= 90) return 60 - ((diff - 60) / 2);
    if (diff > 30 && diff <= 60) return (diff - 30) * 2;
    return 0.0;
  }

  // libaditya longitude.py:238 — forward angular distance, [0, 360).
  static double _degreesApart(double fromLon, double toLon) {
    final d = (toLon - fromLon) % 360.0;
    return d < 0 ? d + 360.0 : d;
  }

  static int _sign(double lon) {
    final n = lon % 360.0;
    return ((n < 0 ? n + 360.0 : n) ~/ 30).toInt();
  }
}
