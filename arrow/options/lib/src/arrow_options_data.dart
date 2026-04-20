import 'package:freezed_annotation/freezed_annotation.dart';

import 'calc_config.dart';
import 'swe_config.dart';

part 'arrow_options_data.freezed.dart';
part 'arrow_options_data.g.dart';

/// Top-level options for Arrow calculations.
@freezed
abstract class ArrowOptions with _$ArrowOptions {
  const factory ArrowOptions({
    @Default(SweConfig()) SweConfig sweConfig,
    @Default(CalcConfig()) CalcConfig calcConfig,
  }) = _ArrowOptions;

  factory ArrowOptions.fromJson(Map<String, dynamic> json) =>
      _$ArrowOptionsFromJson(json);
}
