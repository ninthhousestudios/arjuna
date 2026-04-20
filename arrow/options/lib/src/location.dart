import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

/// Geographic location for chart calculation.
@freezed
abstract class Location with _$Location {
  const factory Location({
    required double latitude,
    required double longitude,
    @Default(0.0) double altitude,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}
