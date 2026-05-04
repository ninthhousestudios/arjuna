import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'cusp.dart';
import 'fixed_star.dart';
import 'karaka.dart';
import 'motion_state.dart';
import 'planet.dart';
import 'rashi.dart';
import 'varga.dart';

/// The main entry point for a chart — wraps an [EphSnapshot] + [CalcConfig].
///
/// Provides the rashi (D1) chart and lazily-cached access to any divisional
/// chart via [varga]. Typed planet accessors delegate to [rashi].
///
/// Usage:
/// ```dart
/// final chart = Chart(snapshot, config);
/// chart.sun.dignity;                     // dignity in rashi
/// chart.rashi.sun.sign;                  // sign in rashi
/// chart.varga(VargaType.navamsha).sun.sign;  // sign in navamsha
/// ```
class Chart {
  final EphSnapshot snapshot;
  final CalcConfig config;

  /// The rashi (D1) chart.
  late final Rashi rashi;

  final Map<VargaType, Varga> _vargaCache = {};

  late final Map<Star, FixedStar> fixedStars;
  late final Map<String, FixedStar> customFixedStars;

  Chart(this.snapshot, this.config)
      : assert(
          config.nakEquatorial ||
              snapshot.sweConfig.nakAyanamsa != Ayanamsa.dhruva,
          'Dhruva ayanamsa requires nakEquatorial=true',
        ) {
    rashi = Rashi(snapshot, config);
    _vargaCache[VargaType.rashi] = rashi;

    fixedStars = {
      for (final star in snapshot.stars.keys)
        star: FixedStar.fromEnum(star, snapshot, config),
    };
    customFixedStars = {
      for (final name in snapshot.customStars.keys)
        name: FixedStar.custom(name, snapshot, config),
    };
  }

  /// Get a divisional chart. Cached after first access.
  Varga varga(VargaType type) =>
      _vargaCache.putIfAbsent(type, () => Varga(type, snapshot, config));

  // Typed planet accessors (delegate to rashi).
  Karaka get sun => rashi.sun;
  Karaka get moon => rashi.moon;
  Karaka get mars => rashi.mars;
  Karaka get mercury => rashi.mercury;
  Karaka get jupiter => rashi.jupiter;
  Karaka get venus => rashi.venus;
  Karaka get saturn => rashi.saturn;
  Planet get rahu => rashi.rahu;
  Planet get ketu => rashi.ketu;

  List<Karaka> get karakas => rashi.karakas;
  List<Planet> get grahas => rashi.grahas;
  List<Planet> get planets => rashi.planets;

  List<Cusp> get cusps => rashi.cusps;
  Cusp cusp(int house) => cusps[house - 1];

  double get ascendant => snapshot.ascmc.ascendant;
  double get mc => snapshot.ascmc.mc;

  /// Synodic state for each body that has pheno data. Sparse — nodes
  /// (Rahu/Ketu) are omitted since their pheno is null.
  Map<Body, SynodicState> get synodicStates {
    final out = <Body, SynodicState>{};
    for (final body in snapshot.bodiesEcliptic.keys) {
      final state = rashi.planet(body).synodicState;
      if (state == null) continue;
      out[body] = state;
    }
    return out;
  }

  @override
  String toString() => 'Chart(jd=${snapshot.jdUt})';
}
