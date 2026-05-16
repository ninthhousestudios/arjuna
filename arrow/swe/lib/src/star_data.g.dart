// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StarData _$StarDataFromJson(Map<String, dynamic> json) => _StarData(
  apparentMagnitude: (json['apparentMagnitude'] as num?)?.toDouble(),
  riseJd: (json['riseJd'] as num?)?.toDouble(),
  setJd: (json['setJd'] as num?)?.toDouble(),
  circumpolar: json['circumpolar'] as bool? ?? false,
);

Map<String, dynamic> _$StarDataToJson(_StarData instance) => <String, dynamic>{
  'apparentMagnitude': instance.apparentMagnitude,
  'riseJd': instance.riseJd,
  'setJd': instance.setJd,
  'circumpolar': instance.circumpolar,
};
