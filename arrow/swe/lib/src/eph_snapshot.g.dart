// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eph_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EphSnapshot _$EphSnapshotFromJson(Map<String, dynamic> json) => _EphSnapshot(
  jdUt: (json['jdUt'] as num).toDouble(),
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
  sweConfig: SweConfig.fromJson(json['sweConfig'] as Map<String, dynamic>),
  bodiesEcliptic: const BodyMapConverter().fromJson(
    json['bodiesEcliptic'] as Map<String, dynamic>,
  ),
  bodiesEquatorial: const BodyMapConverter().fromJson(
    json['bodiesEquatorial'] as Map<String, dynamic>,
  ),
  phenoData: const BodyPhenoMapConverter().fromJson(
    json['phenoData'] as Map<String, dynamic>,
  ),
  cusps: (json['cusps'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
  ascmc: AscMcPoints.fromJson(json['ascmc'] as Map<String, dynamic>),
  sunTimes: SunTimes.fromJson(json['sunTimes'] as Map<String, dynamic>),
  ayanamsaValue: (json['ayanamsaValue'] as num).toDouble(),
  bodiesNakEclLon: json['bodiesNakEclLon'] == null
      ? const <Body, double>{}
      : const BodyDoubleMapConverter().fromJson(
          json['bodiesNakEclLon'] as Map<String, dynamic>,
        ),
  bodiesNakEquLon: json['bodiesNakEquLon'] == null
      ? const <Body, double>{}
      : const BodyDoubleMapConverter().fromJson(
          json['bodiesNakEquLon'] as Map<String, dynamic>,
        ),
  starsNakEclLon: json['starsNakEclLon'] == null
      ? const <Star, double>{}
      : const StarDoubleMapConverter().fromJson(
          json['starsNakEclLon'] as Map<String, dynamic>,
        ),
  starsNakEquLon: json['starsNakEquLon'] == null
      ? const <Star, double>{}
      : const StarDoubleMapConverter().fromJson(
          json['starsNakEquLon'] as Map<String, dynamic>,
        ),
  customStarsNakEclLon: json['customStarsNakEclLon'] == null
      ? const <String, double>{}
      : const StringDoubleMapConverter().fromJson(
          json['customStarsNakEclLon'] as Map<String, dynamic>,
        ),
  customStarsNakEquLon: json['customStarsNakEquLon'] == null
      ? const <String, double>{}
      : const StringDoubleMapConverter().fromJson(
          json['customStarsNakEquLon'] as Map<String, dynamic>,
        ),
  cuspsNakLon:
      (json['cuspsNakLon'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const <double>[],
  bodiesEclipticBarycentric:
      _$JsonConverterFromJson<Map<String, dynamic>, Map<Body, BodyPosition>>(
        json['bodiesEclipticBarycentric'],
        const BodyMapConverter().fromJson,
      ),
  bodiesEclipticHeliocentric:
      _$JsonConverterFromJson<Map<String, dynamic>, Map<Body, BodyPosition>>(
        json['bodiesEclipticHeliocentric'],
        const BodyMapConverter().fromJson,
      ),
  stars: json['stars'] == null
      ? const <Star, StarPosition>{}
      : const StarPositionMapConverter().fromJson(
          json['stars'] as Map<String, dynamic>,
        ),
  customStars: json['customStars'] == null
      ? const <String, StarPosition>{}
      : const StringStarPositionMapConverter().fromJson(
          json['customStars'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$EphSnapshotToJson(
  _EphSnapshot instance,
) => <String, dynamic>{
  'jdUt': instance.jdUt,
  'location': instance.location,
  'sweConfig': instance.sweConfig,
  'bodiesEcliptic': const BodyMapConverter().toJson(instance.bodiesEcliptic),
  'bodiesEquatorial': const BodyMapConverter().toJson(
    instance.bodiesEquatorial,
  ),
  'phenoData': const BodyPhenoMapConverter().toJson(instance.phenoData),
  'cusps': instance.cusps,
  'ascmc': instance.ascmc,
  'sunTimes': instance.sunTimes,
  'ayanamsaValue': instance.ayanamsaValue,
  'bodiesNakEclLon': const BodyDoubleMapConverter().toJson(
    instance.bodiesNakEclLon,
  ),
  'bodiesNakEquLon': const BodyDoubleMapConverter().toJson(
    instance.bodiesNakEquLon,
  ),
  'starsNakEclLon': const StarDoubleMapConverter().toJson(
    instance.starsNakEclLon,
  ),
  'starsNakEquLon': const StarDoubleMapConverter().toJson(
    instance.starsNakEquLon,
  ),
  'customStarsNakEclLon': const StringDoubleMapConverter().toJson(
    instance.customStarsNakEclLon,
  ),
  'customStarsNakEquLon': const StringDoubleMapConverter().toJson(
    instance.customStarsNakEquLon,
  ),
  'cuspsNakLon': instance.cuspsNakLon,
  'bodiesEclipticBarycentric':
      _$JsonConverterToJson<Map<String, dynamic>, Map<Body, BodyPosition>>(
        instance.bodiesEclipticBarycentric,
        const BodyMapConverter().toJson,
      ),
  'bodiesEclipticHeliocentric':
      _$JsonConverterToJson<Map<String, dynamic>, Map<Body, BodyPosition>>(
        instance.bodiesEclipticHeliocentric,
        const BodyMapConverter().toJson,
      ),
  'stars': const StarPositionMapConverter().toJson(instance.stars),
  'customStars': const StringStarPositionMapConverter().toJson(
    instance.customStars,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
