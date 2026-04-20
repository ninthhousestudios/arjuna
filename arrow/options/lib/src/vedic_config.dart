import 'package:freezed_annotation/freezed_annotation.dart';

part 'vedic_config.freezed.dart';
part 'vedic_config.g.dart';

/// Vedic-tradition-specific configuration.
@freezed
abstract class VedicConfig with _$VedicConfig {
  const factory VedicConfig({
    /// Number of chara karakas: 7 (standard) or 8 (includes Rahu).
    @Default(7) int charaKarakaCount,
  }) = _VedicConfig;

  factory VedicConfig.fromJson(Map<String, dynamic> json) =>
      _$VedicConfigFromJson(json);
}
