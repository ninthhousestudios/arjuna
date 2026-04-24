import 'package:arrow_options/arrow_options.dart';

import 'constellation_star_map.dart';

/// All [Star] entries required as boundary stars for the 13-constellation
/// system. Use this to populate [SweConfig.stars] when building an
/// [Ecliptic13].
final Set<Star> boundaryStars = constellationStarMap.values
    .expand((e) => [e.first, e.last])
    .toSet();
