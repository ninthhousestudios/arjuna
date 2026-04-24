import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:meta/meta.dart';

/// A constellation in the 13-sign true-sidereal zodiac.
///
/// Boundaries are computed from the midpoints between adjacent boundary
/// stars. Planets and stars are placed into constellations by ecliptic
/// longitude.
class Constellation {
  final ConstellationId id;
  final Star firstStar;
  final Star lastStar;

  /// Ecliptic longitude where this constellation begins (degrees, 0-360).
  final double beginning;

  /// Ecliptic longitude where this constellation ends (degrees, 0-360).
  final double end;

  final List<CelestialBody> _planets = [];
  final List<FixedStar> _stars = [];

  Constellation({
    required this.id,
    required this.firstStar,
    required this.lastStar,
    required this.beginning,
    required this.end,
  });

  double get length => (end - beginning + 360) % 360;

  List<CelestialBody> get planets => List.unmodifiable(_planets);
  List<FixedStar> get stars => List.unmodifiable(_stars);

  int get planetCount => _planets.length;
  int get starCount => _stars.length;

  @internal
  void addPlanet(CelestialBody planet) => _planets.add(planet);
  @internal
  void addStar(FixedStar star) => _stars.add(star);

  /// Whether [longitude] falls within this constellation's boundaries.
  bool contains(double longitude) {
    if (beginning < end) {
      return longitude >= beginning && longitude < end;
    }
    // Wraps around 0°.
    return longitude >= beginning || longitude < end;
  }

  @override
  String toString() =>
      'Constellation(${id.label}, ${beginning.toStringAsFixed(2)}°–'
      '${end.toStringAsFixed(2)}°, ${length.toStringAsFixed(2)}°)';
}
