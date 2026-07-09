// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_position.freezed.dart';
part 'body_position.g.dart';

@freezed
abstract class BodyPosition with _$BodyPosition {
  const factory BodyPosition({
    required double longitude,
    required double latitude,
    required double distance,
    required double speedLongitude,
    required double speedLatitude,
    required double speedDistance,
  }) = _BodyPosition;

  factory BodyPosition.fromJson(Map<String, dynamic> json) =>
      _$BodyPositionFromJson(json);
}
