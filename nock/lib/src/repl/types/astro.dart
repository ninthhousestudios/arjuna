// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';

import '../../format/longitude.dart';
import 'value.dart';

class NockSign extends NockValue {
  final int number;
  final Longitude lon;

  NockSign(this.number, this.lon);

  @override
  String display() {
    final name = SignData.name(number);
    final glyph = signGlyph(number);
    return '$name $glyph';
  }

  @override
  String typeName() => 'sign';
}

class NockNakshatra extends NockValue {
  final int number;
  final int pada;

  NockNakshatra(this.number, this.pada);

  @override
  String display() {
    final name = NakshatraData.name(number);
    final lord = NakshatraData.lord(number).name;
    return '$name $pada ($lord)';
  }

  @override
  String typeName() => 'nakshatra';
}

class NockDignity extends NockValue {
  final DignityType type;

  NockDignity(this.type);

  @override
  String display() => switch (type) {
    DignityType.exalted => 'Exalted',
    DignityType.moolatrikona => 'Moolatrikona',
    DignityType.ownSign => 'Own Sign',
    DignityType.greatFriend => 'Great Friend',
    DignityType.friend => 'Friend',
    DignityType.neutral => 'Neutral',
    DignityType.enemy => 'Enemy',
    DignityType.greatEnemy => 'Great Enemy',
    DignityType.debilitated => 'Debilitated',
  };

  @override
  String typeName() => 'dignity';
}
