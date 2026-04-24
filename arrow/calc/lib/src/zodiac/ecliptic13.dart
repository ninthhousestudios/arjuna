import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'boundary_stars.dart';
import 'constellation.dart';
import 'constellation_star_map.dart';

/// Build an [Ecliptic13] from an [EphSnapshot].
///
/// Extracts boundary star longitudes from [snap.starsEcliptic] and builds
/// the 13-constellation ecliptic. The snapshot must include [boundaryStars].
Ecliptic13 buildEcliptic13(EphSnapshot snap) {
  final starLongitudes = <Star, double>{};
  for (final entry in snap.starsEcliptic.entries) {
    starLongitudes[entry.key] = entry.value.longitude;
  }
  return Ecliptic13.build(starLongitudes: starLongitudes);
}

/// 13-constellation true-sidereal ecliptic.
///
/// Computes constellation boundaries from boundary star positions, then
/// bins planets and stars into their constellations by ecliptic longitude.
///
/// Ported from libaditya `the_stars.py:Ecliptic`.
class Ecliptic13 {
  final Map<ConstellationId, Constellation> _constellations;

  Ecliptic13._(this._constellations);

  /// Build the 13-constellation ecliptic from a chart's stars and planets.
  ///
  /// [starLongitudes] maps each [Star] enum entry to its true-sidereal
  /// ecliptic longitude (degrees). Must contain all boundary stars from
  /// [constellationStarMap].
  ///
  /// [planets] and [fixedStars] are placed into constellations after
  /// boundaries are computed. Stars with |ecliptic latitude| > 10° are
  /// excluded from placement (too far from the ecliptic plane).
  factory Ecliptic13.build({
    required Map<Star, double> starLongitudes,
    List<CelestialBody> planets = const [],
    List<FixedStar> fixedStars = const [],
  }) {
    final ordered = ConstellationId.values;
    final boundaries = _computeBoundaries(starLongitudes, ordered);
    final constellations = <ConstellationId, Constellation>{};

    for (int i = 0; i < ordered.length; i++) {
      final id = ordered[i];
      final stars = constellationStarMap[id]!;
      constellations[id] = Constellation(
        id: id,
        firstStar: stars.first,
        lastStar: stars.last,
        beginning: boundaries[i],
        end: boundaries[(i + 1) % ordered.length],
      );
    }

    final ecliptic = Ecliptic13._(constellations);

    for (final planet in planets) {
      ecliptic._placePlanet(planet);
    }
    for (final star in fixedStars) {
      if (star.position.latitude.abs() <= 10.0) {
        ecliptic._placeStar(star);
      }
    }

    return ecliptic;
  }

  /// All 13 constellations in ecliptic order.
  List<Constellation> get constellations =>
      ConstellationId.values.map((id) => _constellations[id]!).toList();

  /// Look up a constellation by id.
  Constellation operator [](ConstellationId id) => _constellations[id]!;

  /// Find which constellation contains the given ecliptic [longitude].
  Constellation constellationAt(double longitude) {
    final lon = longitude % 360;
    for (final c in _constellations.values) {
      if (c.contains(lon)) return c;
    }
    return _constellations.values.first;
  }

  /// Placement result for a longitude: constellation, degrees into it,
  /// and percentage through.
  ({Constellation constellation, double degreesInto, double percent})
      longitudeToConstellation(double longitude) {
    final c = constellationAt(longitude);
    final degreesInto = ((longitude % 360) - c.beginning + 360) % 360;
    final percent = (degreesInto / c.length) * 100;
    return (constellation: c, degreesInto: degreesInto, percent: percent);
  }

  void _placePlanet(CelestialBody planet) {
    final c = constellationAt(planet.rawLongitude);
    c.addPlanet(planet);
  }

  void _placeStar(FixedStar star) {
    final c = constellationAt(star.rawLongitude);
    c.addStar(star);
  }

  /// Compute boundary longitudes between adjacent constellations.
  ///
  /// Each boundary is the midpoint between the last star of constellation N
  /// and the first star of constellation N+1.
  static List<double> _computeBoundaries(
    Map<Star, double> starLongitudes,
    List<ConstellationId> ordered,
  ) {
    final boundaries = <double>[];

    for (int i = 0; i < ordered.length; i++) {
      final current = ordered[i];
      final next = ordered[(i + 1) % ordered.length];

      final lastStar = constellationStarMap[current]!.last;
      final firstStar = constellationStarMap[next]!.first;

      final lastLon = starLongitudes[lastStar];
      final firstLon = starLongitudes[firstStar];

      if (lastLon == null || firstLon == null) {
        throw StateError(
          'Missing boundary star longitude: '
          '${lastStar.label} or ${firstStar.label}. '
          'Ensure all boundary stars are included in SweConfig.stars.',
        );
      }

      final gap = (firstLon - lastLon + 360) % 360;
      final midpoint = (lastLon + gap / 2) % 360;
      boundaries.add(midpoint);
    }

    // Rotate so the first boundary is for Aries (boundary between Pisces and Aries).
    // boundaries[i] is the boundary between constellation i-1 and i,
    // but we computed boundary between i and i+1. The boundary at index
    // ordered.length-1 is between Pisces(last) and Aries(first) = Aries start.
    final ariesBoundary = boundaries.removeLast();
    boundaries.insert(0, ariesBoundary);

    return boundaries;
  }

  @override
  String toString() {
    final lines =
        constellations.map((c) => '  ${c.id.label}: ${c.length.toStringAsFixed(2)}°');
    return 'Ecliptic13(\n${lines.join('\n')}\n)';
  }
}
