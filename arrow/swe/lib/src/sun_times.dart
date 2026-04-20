import 'package:freezed_annotation/freezed_annotation.dart';

part 'sun_times.freezed.dart';
part 'sun_times.g.dart';

/// Sunrise and sunset as Julian Day numbers (UT). Null if not computable
/// (e.g. circumpolar locations).
@freezed
abstract class SunTimes with _$SunTimes {
  const factory SunTimes({
    double? sunrise,
    double? sunset,
  }) = _SunTimes;

  factory SunTimes.fromJson(Map<String, dynamic> json) =>
      _$SunTimesFromJson(json);
}
