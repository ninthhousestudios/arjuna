// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StarPosition _$StarPositionFromJson(Map<String, dynamic> json) =>
    _StarPosition(
      ecliptic: BodyPosition.fromJson(json['ecliptic'] as Map<String, dynamic>),
      equatorial: BodyPosition.fromJson(
        json['equatorial'] as Map<String, dynamic>,
      ),
      starData: json['starData'] == null
          ? null
          : StarData.fromJson(json['starData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StarPositionToJson(_StarPosition instance) =>
    <String, dynamic>{
      'ecliptic': instance.ecliptic,
      'equatorial': instance.equatorial,
      'starData': instance.starData,
    };
