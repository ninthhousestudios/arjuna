import 'package:arrow_options/arrow_options.dart';

import 'longitude.dart';

/// A house cusp with its number and longitude.
class Cusp {
  /// House number (1-12).
  final int house;

  /// The cusp longitude.
  final Longitude longitude;

  // Cusps are ecliptic-only; equatorial longitude set equal to ecliptic
  // because house cusps have no meaningful equatorial position.
  Cusp(this.house, double eclipticLongitude, CalcConfig config)
      : longitude = Longitude(
            eclipticLongitude, eclipticLongitude, VargaType.rashi, config);

  int get sign => longitude.sign;
  int get nakshatra => longitude.nakshatra;
  int get pada => longitude.pada;

  @override
  String toString() => 'Cusp($house, ${longitude.eclipticLongitude.toStringAsFixed(2)}°)';
}
