import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'longitude.dart';
import 'planet.dart';

/// A Vedic graha — wraps [Planet] via composition.
///
/// Grahas are the 9 Vedic planets (Sun through Ketu). This class delegates
/// positional access to the underlying [Planet] and will gain Vedic-specific
/// behavior (dignity, friendship, etc.) in later issues.
class Graha {
  final Planet planet;

  Graha(this.planet);

  Body get body => planet.body;
  EphSnapshot get snapshot => planet.snapshot;
  CalcConfig get config => planet.config;
  VargaType get vargaType => planet.vargaType;

  Longitude get longitude => planet.longitude;
  Longitude varga(VargaType type) => planet.varga(type);

  int get sign => planet.sign;
  int get nakshatra => planet.nakshatra;
  int get pada => planet.pada;
  bool get isRetrograde => planet.isRetrograde;
  double get rawLongitude => planet.rawLongitude;

  @override
  String toString() => 'Graha(${body.name})';
}
