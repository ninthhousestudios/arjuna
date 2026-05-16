// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calc_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalcConfig _$CalcConfigFromJson(Map<String, dynamic> json) => _CalcConfig(
  circle: $enumDecodeNullable(_$CircleEnumMap, json['circle']) ?? Circle.aditya,
  nakEquatorial: json['nakEquatorial'] as bool? ?? true,
  traditions:
      (json['traditions'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$TraditionEnumMap, e))
          .toSet() ??
      const {Tradition.vedic},
  zodiacSystem:
      $enumDecodeNullable(_$ZodiacSystemEnumMap, json['zodiacSystem']) ??
      ZodiacSystem.sidereal12,
  vedic: json['vedic'] == null
      ? const VedicConfig()
      : VedicConfig.fromJson(json['vedic'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CalcConfigToJson(
  _CalcConfig instance,
) => <String, dynamic>{
  'circle': _$CircleEnumMap[instance.circle]!,
  'nakEquatorial': instance.nakEquatorial,
  'traditions': instance.traditions.map((e) => _$TraditionEnumMap[e]!).toList(),
  'zodiacSystem': _$ZodiacSystemEnumMap[instance.zodiacSystem]!,
  'vedic': instance.vedic,
};

const _$CircleEnumMap = {Circle.aditya: 'aditya', Circle.zodiac: 'zodiac'};

const _$TraditionEnumMap = {Tradition.vedic: 'vedic'};

const _$ZodiacSystemEnumMap = {
  ZodiacSystem.tropical12: 'tropical12',
  ZodiacSystem.sidereal12: 'sidereal12',
  ZodiacSystem.trueSidereal13: 'trueSidereal13',
};
