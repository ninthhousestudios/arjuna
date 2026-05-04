import 'package:arrow_options/arrow_options.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'asc_mc_points.dart';
import 'body_position.dart';
import 'json_converters.dart';
import 'pheno_data.dart';
import 'star_data.dart';
import 'sun_times.dart';

part 'eph_snapshot.freezed.dart';
part 'eph_snapshot.g.dart';

@freezed
abstract class EphSnapshot with _$EphSnapshot {
  const factory EphSnapshot({
    required double jdUt,
    required Location location,
    required ArrowOptions options,
    @BodyMapConverter() required Map<Body, BodyPosition> bodiesEcliptic,
    @BodyMapConverter() required Map<Body, BodyPosition> bodiesEquatorial,
    @BodyPhenoMapConverter() required Map<Body, PhenoData> phenoData,
    required List<double> cusps,
    required AscMcPoints ascmc,
    required SunTimes sunTimes,
    required double ayanamsaValue,
    @Default(0.0) double nakAyanamsaValue,
    @BodyMapConverter() Map<Body, BodyPosition>? bodiesEclipticBarycentric,
    @BodyMapConverter() Map<Body, BodyPosition>? bodiesEclipticHeliocentric,
    @StarMapConverter() @Default(<Star, BodyPosition>{}) Map<Star, BodyPosition> starsEcliptic,
    @StarMapConverter() @Default(<Star, BodyPosition>{}) Map<Star, BodyPosition> starsEquatorial,
    @StringBodyPositionMapConverter() @Default(<String, BodyPosition>{}) Map<String, BodyPosition> customStarsEcliptic,
    @StringBodyPositionMapConverter() @Default(<String, BodyPosition>{}) Map<String, BodyPosition> customStarsEquatorial,
    @StarDataMapConverter() @Default(<Star, StarData>{}) Map<Star, StarData> starData,
    @StringStarDataMapConverter() @Default(<String, StarData>{}) Map<String, StarData> customStarData,
  }) = _EphSnapshot;

  factory EphSnapshot.fromJson(Map<String, dynamic> json) =>
      _$EphSnapshotFromJson(json);
}
