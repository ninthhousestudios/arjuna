// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

import 'varga_deities.dart';
import 'varga_math.dart';

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

  /// Which varga this longitude is computed for.
  final VargaType vargaType;

  /// Calculation configuration (circle, nakshatra ayanamsa, etc.).
  final CalcConfig config;

  /// Pre-computed longitude in the nakshatra frame (0-360).
  /// Computed by SWE in the appropriate sidereal/equatorial mode.
  /// When null, falls back to [eclipticLongitude].
  final double? nakLongitude;

  /// The longitude in the varga's coordinate frame.
  late final double amshaLongitude;

  /// The presiding deity for the varga division (null for rashi).
  late final VargaDeity? deity;

  Longitude(
    this.eclipticLongitude,
    this.vargaType,
    this.config, {
    this.nakLongitude,
  }) {
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
  int get nakshatra => ((_nakshatraLon() % 360) / (360 / 27)).floor() + 1;

  /// Pada (1-4) within nakshatra.
  int get pada {
    const nakSpan = 360.0 / 27;
    final posInNak = _nakshatraLon() % nakSpan;
    return (posInNak / (nakSpan / 4)).floor() + 1;
  }

  double _nakshatraLon() => (nakLongitude ?? eclipticLongitude) % 360;

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

  int get _adityaOffset => config.circle == Circle.aditya ? 30 : 0;

  VargaResult _computeVarga(double lon, VargaType type) {
    final offset = _adityaOffset;
    if (type.isParivritti) return parivritti(lon, type.amsha, offset);
    return switch (type) {
      VargaType.hora => hora(lon, offset),
      VargaType.drekkana => drekkana(lon, offset),
      VargaType.chaturthamsha => chaturthamsha(lon, offset),
      VargaType.saptamsha => saptamsha(lon, offset),
      VargaType.dashamsha => dashamsha(lon, offset),
      VargaType.dashamshaReversed => dashamsha(lon, offset, evenReversed: true),
      VargaType.dvadashamsha => dvadashamsha(lon, offset),
      VargaType.shodashamsha => shodashamsha(lon, offset),
      VargaType.vimshamsha => vimshamsha(lon, offset),
      VargaType.parasharaChaturvimshamsha => siddhamsha(
        lon,
        offset,
        parashara: true,
      ),
      VargaType.siddhamsha => siddhamsha(lon, offset),
      VargaType.trimsamsha => trimsamsha(lon, offset),
      VargaType.bhamsha => bhamsha(lon, offset),
      VargaType.khavedamsha => khavedamsha(lon, offset),
      VargaType.akshavedamsha => akshavedamsha(lon, offset),
      VargaType.shashtyamsha => shashtyamsha(lon, offset),
      _ => parivritti(lon, type.amsha, offset),
    };
  }

  @override
  String toString() =>
      'Longitude($eclipticLongitude, amsha=$amshaLongitude, '
      'varga=${vargaType.name})';
}
