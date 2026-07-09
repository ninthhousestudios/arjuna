// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BodyPosition _$BodyPositionFromJson(Map<String, dynamic> json) =>
    _BodyPosition(
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      speedLongitude: (json['speedLongitude'] as num).toDouble(),
      speedLatitude: (json['speedLatitude'] as num).toDouble(),
      speedDistance: (json['speedDistance'] as num).toDouble(),
    );

Map<String, dynamic> _$BodyPositionToJson(_BodyPosition instance) =>
    <String, dynamic>{
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'distance': instance.distance,
      'speedLongitude': instance.speedLongitude,
      'speedLatitude': instance.speedLatitude,
      'speedDistance': instance.speedDistance,
    };
