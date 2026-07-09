// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

import 'dignity.dart';
import 'longitude.dart';
import 'planet.dart';
import 'sign_data.dart';

/// A karaka — one of the 7 embodied planets with dignity and combustion.
class Karaka extends Planet {
  final double? _sunLongitude;

  Karaka(
    super.body,
    super.snapshot,
    super.config,
    super.vargaType, {
    double? sunLongitude,
  }) : _sunLongitude = sunLongitude;

  double get inSignLongitude => longitude.inSignLongitude;

  DignityType get dignity {
    final signLord = SignData.lord(sign);
    final lordPos = snapshot.bodiesEcliptic[signLord];
    if (lordPos == null) {
      return Dignity.calculate(body, sign, longitude.inSignLongitude, sign);
    }
    final lordLon = Longitude(lordPos.longitude, VargaType.rashi, config);
    return Dignity.calculate(
      body,
      sign,
      longitude.inSignLongitude,
      lordLon.sign,
    );
  }

  bool get isCombust {
    if (_sunLongitude == null) return false;
    return Dignity.isCombust(
      body,
      rawLongitude,
      _sunLongitude,
      isRetrograde: isRetrograde,
    );
  }

  @override
  String toString() => 'Karaka(${body.name})';
}
