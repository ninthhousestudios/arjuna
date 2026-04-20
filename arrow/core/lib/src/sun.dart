import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'planet.dart';

/// The Sun.
///
/// Extends [Planet] with Sun-specific year-scale semantics — in particular
/// the four tropical cardinal points (equinoxes and solstices), which are
/// properties of a calendar year rather than a single snapshot.
class Sun extends Planet {
  Sun(EphSnapshot snapshot, CalcConfig config, VargaType vargaType)
      : super(Body.sun, snapshot, config, vargaType);

  /// The four tropical cardinal points of [year] as JDs (UT).
  ///
  /// Requires a [SweFacade] because the calculation iterates on the Sun's
  /// tropical longitude — it is not derivable from a single [EphSnapshot].
  static CardinalPoints cardinalPointsOf(
    int year,
    SweFacade swe, {
    EphemerisSource source = EphemerisSource.swissEph,
  }) =>
      swe.calcCardinalPoints(year, source: source);
}
