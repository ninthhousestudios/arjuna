import 'package:freezed_annotation/freezed_annotation.dart';

import 'ayanamsa.dart';
import 'body.dart';
import 'ephemeris_source.dart';
import 'house_system.dart';
import 'reference_point.dart';
import 'star.dart';

part 'swe_config.freezed.dart';
part 'swe_config.g.dart';

/// Configuration that affects raw SWE positions.
///
/// Changing any field requires a full SWE recalculation.
@freezed
abstract class SweConfig with _$SweConfig {
  const factory SweConfig({
    @Default({
      Body.sun,
      Body.moon,
      Body.mercury,
      Body.venus,
      Body.mars,
      Body.jupiter,
      Body.saturn,
      Body.rahu,
      Body.ketu,
    })
    Set<Body> bodies,
    @Default(Ayanamsa.tropical) Ayanamsa signAyanamsa,
    @Default(HouseSystem.campanus) HouseSystem houseSystem,
    @Default(true) bool trueNode,
    @Default(false) bool topocentric,
    @Default(EphemerisSource.swissEph) EphemerisSource ephemerisSource,
    @Default(<ReferencePoint>{}) Set<ReferencePoint> extraFrames,
    @Default(<Star>{}) Set<Star> stars,
    @Default(<String>{}) Set<String> customStarNames,
    @Default(false) bool includeStarData,
    @Default(Ayanamsa.dhruva) Ayanamsa nakAyanamsa,
  }) = _SweConfig;

  factory SweConfig.fromJson(Map<String, dynamic> json) =>
      _$SweConfigFromJson(json);
}
