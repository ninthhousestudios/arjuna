// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:freezed_annotation/freezed_annotation.dart';

import 'rashi_aspect_mode.dart';

import 'dasha_year_length.dart';

part 'vedic_config.freezed.dart';
part 'vedic_config.g.dart';

/// Vedic-tradition-specific configuration.
@freezed
abstract class VedicConfig with _$VedicConfig {
  const factory VedicConfig({
    /// Number of chara karakas: 7 (standard) or 8 (includes Rahu).
    @Default(7) int charaKarakaCount,
    @Default(DashaYearLength.saura) DashaYearLength dashaYearLength,
    @Default(RashiAspectMode.quadrant) RashiAspectMode rashiAspectMode,
  }) = _VedicConfig;

  factory VedicConfig.fromJson(Map<String, dynamic> json) =>
      _$VedicConfigFromJson(json);
}
