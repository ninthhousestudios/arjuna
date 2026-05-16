// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pheno_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhenoData _$PhenoDataFromJson(Map<String, dynamic> json) => _PhenoData(
  phaseAngle: (json['phaseAngle'] as num).toDouble(),
  phase: (json['phase'] as num).toDouble(),
  elongation: (json['elongation'] as num).toDouble(),
  apparentDiameter: (json['apparentDiameter'] as num).toDouble(),
  apparentMagnitude: (json['apparentMagnitude'] as num).toDouble(),
);

Map<String, dynamic> _$PhenoDataToJson(_PhenoData instance) =>
    <String, dynamic>{
      'phaseAngle': instance.phaseAngle,
      'phase': instance.phase,
      'elongation': instance.elongation,
      'apparentDiameter': instance.apparentDiameter,
      'apparentMagnitude': instance.apparentMagnitude,
    };
