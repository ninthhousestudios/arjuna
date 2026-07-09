// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sun_times.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SunTimes _$SunTimesFromJson(Map<String, dynamic> json) => _SunTimes(
  sunrise: (json['sunrise'] as num?)?.toDouble(),
  sunset: (json['sunset'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SunTimesToJson(_SunTimes instance) => <String, dynamic>{
  'sunrise': instance.sunrise,
  'sunset': instance.sunset,
};
