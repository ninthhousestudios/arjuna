// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cardinal_points.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CardinalPoints _$CardinalPointsFromJson(Map<String, dynamic> json) =>
    _CardinalPoints(
      ascendingEquinox: (json['ascendingEquinox'] as num).toDouble(),
      northernSolstice: (json['northernSolstice'] as num).toDouble(),
      descendingEquinox: (json['descendingEquinox'] as num).toDouble(),
      southernSolstice: (json['southernSolstice'] as num).toDouble(),
    );

Map<String, dynamic> _$CardinalPointsToJson(_CardinalPoints instance) =>
    <String, dynamic>{
      'ascendingEquinox': instance.ascendingEquinox,
      'northernSolstice': instance.northernSolstice,
      'descendingEquinox': instance.descendingEquinox,
      'southernSolstice': instance.southernSolstice,
    };
