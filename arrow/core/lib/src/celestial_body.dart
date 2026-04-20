import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'longitude.dart';

/// Base class for all celestial bodies in a chart.
///
/// Wraps a [Body] enum value with its positions from an [EphSnapshot],
/// providing [Longitude]-based access to sign, nakshatra, and varga data.
class CelestialBody {
  final Body body;
  final EphSnapshot snapshot;
  final CalcConfig config;
  final VargaType vargaType;

  CelestialBody(this.body, this.snapshot, this.config, this.vargaType);

  BodyPosition get position => snapshot.bodiesEcliptic[body]!;
  BodyPosition get equatorialPosition => snapshot.bodiesEquatorial[body]!;
  double get rawLongitude => position.longitude;
  double get rawEquatorialLongitude => equatorialPosition.longitude;

  Longitude get longitude =>
      Longitude(rawLongitude, rawEquatorialLongitude, vargaType, config);

  /// Compute longitude in a different varga.
  Longitude varga(VargaType type) =>
      Longitude(rawLongitude, rawEquatorialLongitude, type, config);

  int get sign => longitude.sign;
  int get nakshatra => longitude.nakshatra;
  int get pada => longitude.pada;

  /// Barycentric (Solar System Barycenter–centered) ecliptic position.
  ///
  /// Null when `ReferencePoint.barycentric` is not in `SweConfig.extraFrames`.
  /// Null for [Body.ketu] only if Rahu was not requested.
  BodyPosition? get barycentricPosition =>
      snapshot.bodiesEclipticBarycentric?[body];

  /// Heliocentric (Sun-centered) ecliptic position.
  ///
  /// Null when `ReferencePoint.heliocentric` is not in `SweConfig.extraFrames`,
  /// and always null for [Body.sun] (at origin).
  BodyPosition? get heliocentricPosition =>
      snapshot.bodiesEclipticHeliocentric?[body];

  /// Rashi-only longitude in the barycentric frame.
  ///
  /// Equatorial longitude is passed as 0.0, so varga calculations beyond rashi
  /// that key off equatorial longitude will give wrong answers. For anything
  /// beyond sign/degree-in-sign, read [barycentricPosition] directly.
  Longitude? get barycentricRashiLongitude {
    final pos = barycentricPosition;
    if (pos == null) return null;
    return Longitude(pos.longitude, 0.0, VargaType.rashi, config);
  }

  /// Rashi-only longitude in the heliocentric frame. Same equatorial caveat
  /// as [barycentricRashiLongitude].
  Longitude? get heliocentricRashiLongitude {
    final pos = heliocentricPosition;
    if (pos == null) return null;
    return Longitude(pos.longitude, 0.0, VargaType.rashi, config);
  }

  @override
  String toString() => '${body.name}(${rawLongitude.toStringAsFixed(2)}°)';
}
