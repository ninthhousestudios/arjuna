// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arrow_options_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ArrowOptions _$ArrowOptionsFromJson(Map<String, dynamic> json) =>
    _ArrowOptions(
      sweConfig: json['sweConfig'] == null
          ? const SweConfig()
          : SweConfig.fromJson(json['sweConfig'] as Map<String, dynamic>),
      calcConfig: json['calcConfig'] == null
          ? const CalcConfig()
          : CalcConfig.fromJson(json['calcConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ArrowOptionsToJson(_ArrowOptions instance) =>
    <String, dynamic>{
      'sweConfig': instance.sweConfig,
      'calcConfig': instance.calcConfig,
    };
