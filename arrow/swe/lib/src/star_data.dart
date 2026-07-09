// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:freezed_annotation/freezed_annotation.dart';

part 'star_data.freezed.dart';
part 'star_data.g.dart';

/// Magnitude and rise/set data for a fixed star.
///
/// Rise/set fields require `includeStarData: true` on [SweFacade.calcAll] —
/// they are null when that flag is off (or when the star is circumpolar).
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
