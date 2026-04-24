import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'sky_object.dart';

/// A fixed star in a chart.
///
/// Extends [SkyObject] with star-specific identity (enum or custom name).
/// Unlike grahas, fixed stars have no retrograde, dignity, or avastha —
/// they are empirical sky objects, not mathematical points.
class FixedStar extends SkyObject {
  /// Non-null when this star comes from the [Star] enum.
  final Star? star;

  /// Display name — [Star.label] for enum stars, the raw SWE name for custom.
  final String name;

  final BodyPosition _eclipticPos;
  final BodyPosition _equatorialPos;

  /// Nakshatra number (1-27) if this star is a junction star (yogatara).
  final int? junctionOf;

  @override
  final CalcConfig config;

  @override
  VargaType get vargaType => VargaType.rashi;

  @override
  BodyPosition get position => _eclipticPos;

  @override
  BodyPosition get equatorialPosition => _equatorialPos;

  FixedStar._({
    required this.star,
    required this.name,
    required BodyPosition eclipticPos,
    required BodyPosition equatorialPos,
    required this.junctionOf,
    required this.config,
  })  : _eclipticPos = eclipticPos,
        _equatorialPos = equatorialPos;

  /// Construct from a [Star] enum entry and snapshot data.
  factory FixedStar.fromEnum(
    Star star,
    EphSnapshot snapshot,
    CalcConfig config,
  ) {
    return FixedStar._(
      star: star,
      name: star.label,
      eclipticPos: snapshot.starsEcliptic[star]!,
      equatorialPos: snapshot.starsEquatorial[star]!,
      junctionOf: star.nakshatra,
      config: config,
    );
  }

  /// Construct from a custom star name and snapshot data.
  factory FixedStar.custom(
    String name,
    EphSnapshot snapshot,
    CalcConfig config,
  ) {
    return FixedStar._(
      star: null,
      name: name,
      eclipticPos: snapshot.customStarsEcliptic[name]!,
      equatorialPos: snapshot.customStarsEquatorial[name]!,
      junctionOf: null,
      config: config,
    );
  }

  @override
  String toString() =>
      'FixedStar($name, ${rawLongitude.toStringAsFixed(2)}°)';
}
