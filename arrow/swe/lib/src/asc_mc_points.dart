import 'package:freezed_annotation/freezed_annotation.dart';

part 'asc_mc_points.freezed.dart';
part 'asc_mc_points.g.dart';

@freezed
abstract class AscMcPoints with _$AscMcPoints {
  const factory AscMcPoints({
    required double ascendant,
    required double mc,
    required double armc,
    required double vertex,
    required double equatorialAscendant,
    required double coAscendantKoch,
    required double coAscendantMunkasey,
    required double polarAscendant,
  }) = _AscMcPoints;

  factory AscMcPoints.fromJson(Map<String, dynamic> json) =>
      _$AscMcPointsFromJson(json);
}
