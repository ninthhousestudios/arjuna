import 'package:arrow_options/arrow_options.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'asc_mc_points.dart';
import 'body_position.dart';
import 'json_converters.dart';
import 'pheno_data.dart';
import 'star_position.dart';
import 'sun_times.dart';

part 'eph_snapshot.freezed.dart';
part 'eph_snapshot.g.dart';

@freezed
abstract class EphSnapshot with _$EphSnapshot {
  const factory EphSnapshot({
    required double jdUt,
    required Location location,
    required SweConfig sweConfig,
    @BodyMapConverter() required Map<Body, BodyPosition> bodiesEcliptic,
    @BodyMapConverter() required Map<Body, BodyPosition> bodiesEquatorial,
    @BodyPhenoMapConverter() required Map<Body, PhenoData> phenoData,
    required List<double> cusps,
    required AscMcPoints ascmc,
    required SunTimes sunTimes,
    required double ayanamsaValue,
    @BodyDoubleMapConverter() @Default(<Body, double>{}) Map<Body, double> bodiesNakEclLon,
    @BodyDoubleMapConverter() @Default(<Body, double>{}) Map<Body, double> bodiesNakEquLon,
    @StarDoubleMapConverter() @Default(<Star, double>{}) Map<Star, double> starsNakEclLon,
    @StarDoubleMapConverter() @Default(<Star, double>{}) Map<Star, double> starsNakEquLon,
    @StringDoubleMapConverter() @Default(<String, double>{}) Map<String, double> customStarsNakEclLon,
    @StringDoubleMapConverter() @Default(<String, double>{}) Map<String, double> customStarsNakEquLon,
    @Default(<double>[]) List<double> cuspsNakLon,
    @BodyMapConverter() Map<Body, BodyPosition>? bodiesEclipticBarycentric,
    @BodyMapConverter() Map<Body, BodyPosition>? bodiesEclipticHeliocentric,
    @StarPositionMapConverter() @Default(<Star, StarPosition>{}) Map<Star, StarPosition> stars,
    @StringStarPositionMapConverter() @Default(<String, StarPosition>{}) Map<String, StarPosition> customStars,
  }) = _EphSnapshot;

  factory EphSnapshot.fromJson(Map<String, dynamic> json) =>
      _$EphSnapshotFromJson(json);
}
