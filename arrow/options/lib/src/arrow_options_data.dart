import 'package:freezed_annotation/freezed_annotation.dart';

import 'ayanamsa.dart';
import 'calc_config.dart';
import 'swe_config.dart';

part 'arrow_options_data.freezed.dart';
part 'arrow_options_data.g.dart';

/// Top-level options for Arrow calculations.
@freezed
abstract class ArrowOptions with _$ArrowOptions {
  const ArrowOptions._();
  const factory ArrowOptions({
    @Default(SweConfig()) SweConfig sweConfig,
    @Default(CalcConfig()) CalcConfig calcConfig,
  }) = _ArrowOptions;

  /// Throws [ArgumentError] if the config combination is invalid.
  void validate() {
    if (sweConfig.nakAyanamsa == Ayanamsa.dhruva &&
        !calcConfig.nakEquatorial) {
      throw ArgumentError('Dhruva ayanamsa requires nakEquatorial=true');
    }
  }

  factory ArrowOptions.fromJson(Map<String, dynamic> json) =>
      _$ArrowOptionsFromJson(json);
}
