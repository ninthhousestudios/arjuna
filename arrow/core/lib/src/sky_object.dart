import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'longitude.dart';

/// Base class for all objects with a position in the sky.
///
/// Both grahas ([CelestialBody]) and fixed stars ([FixedStar]) extend this,
/// mirroring libaditya's `CelestialObject`. Provides [Longitude]-based
/// access to sign, nakshatra, pada, and varga data from ecliptic/equatorial
/// positions.
abstract class SkyObject {
  BodyPosition get position;
  BodyPosition get equatorialPosition;
  CalcConfig get config;
  VargaType get vargaType;

  double get rawLongitude => position.longitude;
  double get rawEquatorialLongitude => equatorialPosition.longitude;

  /// Nakshatra-frame ayanamsa offset to apply when computing nakshatra and
  /// pada. Default 0 (tropical) — subclasses with snapshot access override.
  double get nakAyanamsaValue => 0.0;

  Longitude get longitude => Longitude(
        rawLongitude,
        rawEquatorialLongitude,
        vargaType,
        config,
        nakAyanamsaValue: nakAyanamsaValue,
      );

  Longitude varga(VargaType type) => Longitude(
        rawLongitude,
        rawEquatorialLongitude,
        type,
        config,
        nakAyanamsaValue: nakAyanamsaValue,
      );

  int get sign => longitude.sign;
  int get nakshatra => longitude.nakshatra;
  int get pada => longitude.pada;
}
