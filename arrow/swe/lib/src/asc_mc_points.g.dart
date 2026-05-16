// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asc_mc_points.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AscMcPoints _$AscMcPointsFromJson(Map<String, dynamic> json) => _AscMcPoints(
  ascendant: (json['ascendant'] as num).toDouble(),
  mc: (json['mc'] as num).toDouble(),
  armc: (json['armc'] as num).toDouble(),
  vertex: (json['vertex'] as num).toDouble(),
  equatorialAscendant: (json['equatorialAscendant'] as num).toDouble(),
  coAscendantKoch: (json['coAscendantKoch'] as num).toDouble(),
  coAscendantMunkasey: (json['coAscendantMunkasey'] as num).toDouble(),
  polarAscendant: (json['polarAscendant'] as num).toDouble(),
);

Map<String, dynamic> _$AscMcPointsToJson(_AscMcPoints instance) =>
    <String, dynamic>{
      'ascendant': instance.ascendant,
      'mc': instance.mc,
      'armc': instance.armc,
      'vertex': instance.vertex,
      'equatorialAscendant': instance.equatorialAscendant,
      'coAscendantKoch': instance.coAscendantKoch,
      'coAscendantMunkasey': instance.coAscendantMunkasey,
      'polarAscendant': instance.polarAscendant,
    };
