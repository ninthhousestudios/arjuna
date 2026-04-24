import 'package:freezed_annotation/freezed_annotation.dart';

part 'star_data.freezed.dart';
part 'star_data.g.dart';

/// Magnitude and rise/set data for a fixed star.
///
/// Rise/set fields require [SweConfig.includeStarRiseSet] — they are null
/// when that flag is off (or when the star is circumpolar / never rises).
@freezed
abstract class StarData with _$StarData {
  const factory StarData({
    double? apparentMagnitude,
    double? riseJd,
    double? setJd,
    @Default(false) bool circumpolar,
  }) = _StarData;

  factory StarData.fromJson(Map<String, dynamic> json) =>
      _$StarDataFromJson(json);
}
