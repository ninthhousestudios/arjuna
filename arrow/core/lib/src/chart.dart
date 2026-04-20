import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'motion_state.dart';
import 'rashi.dart';
import 'varga.dart';

/// The main entry point for a chart — wraps an [EphSnapshot] + [CalcConfig].
///
/// Provides the rashi (D1) chart and lazily-cached access to any divisional
/// chart via [varga].
///
/// Usage:
/// ```dart
/// final chart = Chart(snapshot, config);
/// chart.rashi.sun.sign;         // sign in rashi
/// chart.varga(VargaType.navamsha).sun.sign;  // sign in navamsha
/// ```
class Chart {
  final EphSnapshot snapshot;
  final CalcConfig config;

  /// The rashi (D1) chart.
  late final Rashi rashi;

  final Map<VargaType, Varga> _vargaCache = {};

  Chart(this.snapshot, this.config) {
    rashi = Rashi(snapshot, config);
    _vargaCache[VargaType.rashi] = rashi;
  }

  /// Get a divisional chart. Cached after first access.
  Varga varga(VargaType type) =>
      _vargaCache.putIfAbsent(type, () => Varga(type, snapshot, config));

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
