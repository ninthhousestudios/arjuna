import 'panchanga_names.dart' as names;

/// Span of one yoga in degrees: 13°20' = 13 + 20/60.
const double yogaSpan = 13.0 + (20.0 / 60.0);

/// Result of a yoga (nityayoga) calculation.
class Yoga {
  /// 1-based yoga number (1–27).
  final int number;

  /// IAST name of this yoga.
  final String name;

  /// Degrees elapsed within this yoga (0–13°20').
  final double degreesElapsed;

  /// Degrees remaining in this yoga (0–13°20').
  final double degreesRemaining;

  const Yoga({
    required this.number,
    required this.name,
    required this.degreesElapsed,
    required this.degreesRemaining,
  });

  /// Fraction elapsed (0.0–1.0).
  double get fractionElapsed => degreesElapsed / yogaSpan;

  /// Fraction remaining (0.0–1.0).
  double get fractionRemaining => degreesRemaining / yogaSpan;

  @override
  String toString() => '$number $name';
}

/// Calculate the nityayoga from sun and moon sidereal longitudes.
///
/// The yoga is based on the sum of the sun and moon longitudes measured from
/// the beginning of Ashvini (i.e. sidereal longitudes). Each yoga spans
/// 13°20'. The caller must provide sidereal longitudes — or more precisely,
/// longitudes measured from the start of the nakshatra cycle (Ashvini = 0°).
Yoga calcYoga(double sunSiderealLongitude, double moonSiderealLongitude) {
  final raw =
      ((moonSiderealLongitude + sunSiderealLongitude) % 360) / yogaSpan;
  final remainder = raw % 1;
  final elapsed = remainder * yogaSpan;
  final remaining = yogaSpan - elapsed;
  final index = raw.toInt();

  return Yoga(
    number: index + 1,
    name: names.yogas[index],
    degreesElapsed: elapsed,
    degreesRemaining: remaining,
  );
}
