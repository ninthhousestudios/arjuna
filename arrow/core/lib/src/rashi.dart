import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'nakshatra.dart';
import 'planet.dart';
import 'varga.dart';

/// The rashi (D1) chart — extends [Varga] with nakshatra grouping.
///
/// Only the rashi chart tracks nakshatras; divisional charts don't.
class Rashi extends Varga {
  late final Map<int, Nakshatra> nakshatras; // 1-27

  Rashi(EphSnapshot snapshot, CalcConfig config)
      : super(VargaType.rashi, snapshot, config) {
    _initNakshatras();
  }

  void _initNakshatras() {
    final allPlanets = snapshot.bodiesEcliptic.keys
        .map((b) => planet(b))
        .toList();

    nakshatras = {};
    for (var n = 1; n <= 27; n++) {
      final nakPlanets = allPlanets
          .where((p) => p.nakshatra == n)
          .toList();
      nakshatras[n] = Nakshatra(n, nakPlanets);
    }
  }

  /// Get the nakshatra a planet occupies.
  Nakshatra nakshatraOf(Planet p) => nakshatras[p.nakshatra]!;

  @override
  String toString() => 'Rashi';
}
