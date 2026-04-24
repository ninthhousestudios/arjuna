import 'package:freezed_annotation/freezed_annotation.dart';

import 'ayanamsa.dart';
import 'circle.dart';
import 'tradition.dart';
import 'vedic_config.dart';
import 'zodiac_system.dart';

part 'calc_config.freezed.dart';
part 'calc_config.g.dart';

/// Configuration for derived calculations.
///
/// Changes here do not trigger SWE recalculation — same EphSnapshot,
/// new Chart.
@freezed
abstract class CalcConfig with _$CalcConfig {
  const factory CalcConfig({
    @Default(Circle.aditya) Circle circle,
    @Default(Ayanamsa.dhruva) Ayanamsa nakAyanamsa,
    @Default(true) bool nakEquatorial,
    @Default({Tradition.vedic}) Set<Tradition> traditions,
    @Default(ZodiacSystem.sidereal12) ZodiacSystem zodiacSystem,
    @Default(VedicConfig()) VedicConfig vedic,
  }) = _CalcConfig;

  factory CalcConfig.fromJson(Map<String, dynamic> json) =>
      _$CalcConfigFromJson(json);
}
