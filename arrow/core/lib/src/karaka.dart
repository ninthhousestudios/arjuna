import 'package:arrow_options/arrow_options.dart';

import 'dignity.dart';
import 'graha.dart';
import 'longitude.dart';
import 'sign_data.dart';

/// A karaka — a graha eligible for Jaimini chara karaka assignment.
///
/// Extends [Graha] with dignity and combustion.
class Karaka extends Graha {
  final double? _sunLongitude;

  Karaka(super.body, super.snapshot, super.config, super.vargaType,
      {double? sunLongitude})
      : _sunLongitude = sunLongitude;

  double get inSignLongitude => longitude.inSignLongitude;

  DignityType get dignity {
    final signLord = SignData.lord(sign);
    final lordPos = snapshot.bodiesEcliptic[signLord];
    if (lordPos == null) {
      return Dignity.calculate(body, sign, longitude.inSignLongitude, sign);
    }
    final lordLon =
        Longitude(lordPos.longitude, lordPos.longitude, VargaType.rashi, config);
    return Dignity.calculate(
        body, sign, longitude.inSignLongitude, lordLon.sign);
  }

  bool get isCombust {
    if (_sunLongitude == null) return false;
    return Dignity.isCombust(
        body, rawLongitude, _sunLongitude, isRetrograde: isRetrograde);
  }

  @override
  String toString() => 'Karaka(${body.name})';
}
