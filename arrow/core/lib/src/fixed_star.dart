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
  final double _nakAyanamsaValue;

  /// Nakshatra number (1-27) if this star is a junction star (yogatara).
  final int? junctionOf;

  /// Magnitude and rise/set data. Null when `includeStarData` is not requested.
  final StarData? starData;

  /// Apparent magnitude — from [StarData] if available, else [Star.traditionalMag].
  double? get magnitude => starData?.apparentMagnitude ?? star?.traditionalMag;

  @override
  final CalcConfig config;

  @override
  VargaType get vargaType => VargaType.rashi;

  @override
  BodyPosition get position => _eclipticPos;

  @override
  BodyPosition get equatorialPosition => _equatorialPos;

  @override
  double get nakAyanamsaValue => _nakAyanamsaValue;

  FixedStar._({
    required this.star,
    required this.name,
    required BodyPosition eclipticPos,
    required BodyPosition equatorialPos,
    required this.junctionOf,
    required this.starData,
    required this.config,
    required double nakAyanamsaValue,
  })  : _eclipticPos = eclipticPos,
        _equatorialPos = equatorialPos,
        _nakAyanamsaValue = nakAyanamsaValue;

  /// Construct from a [Star] enum entry and snapshot data.
  factory FixedStar.fromEnum(
    Star star,
    EphSnapshot snapshot,
    CalcConfig config,
  ) {
    final sp = snapshot.stars[star]!;
    return FixedStar._(
      star: star,
      name: star.label,
      eclipticPos: sp.ecliptic,
      equatorialPos: sp.equatorial,
      junctionOf: star.nakshatra,
      starData: sp.starData,
      config: config,
      nakAyanamsaValue: snapshot.nakAyanamsaValue,
    );
  }

  /// Construct from a custom star name and snapshot data.
  factory FixedStar.custom(
    String name,
    EphSnapshot snapshot,
    CalcConfig config,
  ) {
    final sp = snapshot.customStars[name]!;
    return FixedStar._(
      star: null,
      name: name,
      eclipticPos: sp.ecliptic,
      equatorialPos: sp.equatorial,
      junctionOf: null,
      starData: sp.starData,
      config: config,
      nakAyanamsaValue: snapshot.nakAyanamsaValue,
    );
  }

  @override
  String toString() =>
      'FixedStar($name, ${rawLongitude.toStringAsFixed(2)}°)';
}
