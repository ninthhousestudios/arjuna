// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:freezed_annotation/freezed_annotation.dart';

import 'body_position.dart';
import 'star_data.dart';

part 'star_position.freezed.dart';
part 'star_position.g.dart';

@freezed
abstract class StarPosition with _$StarPosition {
  const factory StarPosition({
    required BodyPosition ecliptic,
    required BodyPosition equatorial,
    StarData? starData,
  }) = _StarPosition;

  factory StarPosition.fromJson(Map<String, dynamic> json) =>
      _$StarPositionFromJson(json);
}
