// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vedic_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VedicConfig _$VedicConfigFromJson(Map<String, dynamic> json) => _VedicConfig(
  charaKarakaCount: (json['charaKarakaCount'] as num?)?.toInt() ?? 7,
  dashaYearLength:
      $enumDecodeNullable(_$DashaYearLengthEnumMap, json['dashaYearLength']) ??
      DashaYearLength.saura,
  rashiAspectMode:
      $enumDecodeNullable(_$RashiAspectModeEnumMap, json['rashiAspectMode']) ??
      RashiAspectMode.quadrant,
);

Map<String, dynamic> _$VedicConfigToJson(_VedicConfig instance) =>
    <String, dynamic>{
      'charaKarakaCount': instance.charaKarakaCount,
      'dashaYearLength': _$DashaYearLengthEnumMap[instance.dashaYearLength]!,
      'rashiAspectMode': _$RashiAspectModeEnumMap[instance.rashiAspectMode]!,
    };

const _$DashaYearLengthEnumMap = {
  DashaYearLength.saura: 'saura',
  DashaYearLength.nakshatra: 'nakshatra',
  DashaYearLength.savana: 'savana',
  DashaYearLength.sidereal: 'sidereal',
  DashaYearLength.chandra: 'chandra',
  DashaYearLength.lunar: 'lunar',
};

const _$RashiAspectModeEnumMap = {
  RashiAspectMode.quadrant: 'quadrant',
  RashiAspectMode.element: 'element',
  RashiAspectMode.conventional: 'conventional',
};
