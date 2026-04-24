import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'longitude.dart';
import 'sky_object.dart';

/// A graha (planetary body) in a chart.
///
/// Extends [SkyObject] with [Body]-specific position lookup and
/// extra reference frames (barycentric, heliocentric).
class CelestialBody extends SkyObject {
  final Body body;
  final EphSnapshot snapshot;
  @override
  final CalcConfig config;
  @override
  final VargaType vargaType;

  CelestialBody(this.body, this.snapshot, this.config, this.vargaType);

  @override
  BodyPosition get position => snapshot.bodiesEcliptic[body]!;
  @override
  BodyPosition get equatorialPosition => snapshot.bodiesEquatorial[body]!;

  /// Barycentric (Solar System Barycenter-centered) ecliptic position.
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
