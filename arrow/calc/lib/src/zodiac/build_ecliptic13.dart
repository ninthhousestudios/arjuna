import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'boundary_stars.dart';
import 'ecliptic13.dart';

/// Build an [Ecliptic13] from an [EphSnapshot].
///
/// Extracts boundary star longitudes from [snap.stars] and builds
/// the 13-constellation ecliptic. The snapshot must include [boundaryStars].
Ecliptic13 buildEcliptic13(EphSnapshot snap) {
  final starLongitudes = <Star, double>{};
  for (final entry in snap.stars.entries) {
    starLongitudes[entry.key] = entry.value.ecliptic.longitude;
  }
  return Ecliptic13.build(starLongitudes: starLongitudes);
}
