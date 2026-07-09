// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:freezed_annotation/freezed_annotation.dart';

part 'cardinal_points.freezed.dart';
part 'cardinal_points.g.dart';

/// The four tropical cardinal points of a calendar year as Julian Day
/// numbers (UT).
///
/// Each field is the JD at which the Sun's tropical ecliptic longitude
/// reaches the corresponding target:
/// - [ascendingEquinox] — 0° (March equinox)
/// - [northernSolstice] — 90° (June solstice)
/// - [descendingEquinox] — 180° (September equinox)
/// - [southernSolstice] — 270° (December solstice)
@freezed
abstract class CardinalPoints with _$CardinalPoints {
  const factory CardinalPoints({
    required double ascendingEquinox,
    required double northernSolstice,
    required double descendingEquinox,
    required double southernSolstice,
  }) = _CardinalPoints;

  factory CardinalPoints.fromJson(Map<String, dynamic> json) =>
      _$CardinalPointsFromJson(json);
}
