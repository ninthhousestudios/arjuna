import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

import 'cusp.dart';
import 'graha.dart';
import 'karaka.dart';
import 'planet.dart';
import 'sign.dart';

/// A divisional chart view over an [EphSnapshot].
///
/// Constructs [Planet]/[Graha]/[Karaka] objects for each body in the snapshot,
/// computes their positions in this varga's coordinate frame, and groups them
/// into [Sign] objects for sign-based lookup.
class Varga {
  final VargaType vargaType;
  final EphSnapshot snapshot;
  final CalcConfig config;

  late final Map<Body, Planet> _planetMap;
  late final Map<Body, Karaka> _karakaMap;
  late final Map<int, Sign> signs; // 1-12

  /// Division number for this varga.
  int get amsha => vargaType.amsha;

  Varga(this.vargaType, this.snapshot, this.config) {
    _init();
  }

  void _init() {
    // 1. Create Planet for each body in the snapshot
    _planetMap = {};
    for (final body in snapshot.bodiesEcliptic.keys) {
      _planetMap[body] = Planet(body, snapshot, config, vargaType);
    }

    // 2. Create Karaka for each karaka-eligible body
    _karakaMap = {};
    for (final body in Body.karakas) {
      if (_planetMap.containsKey(body)) {
        _karakaMap[body] = Karaka(_planetMap[body]!);
      }
    }

    // 3. Create cusps
    final cuspList = List.generate(12, (i) {
      return Cusp(i + 1, snapshot.cusps[i], config);
    });

    // 4. Build Sign objects: for each sign 1-12, collect planets/cusps
    signs = {};
    for (var s = 1; s <= 12; s++) {
      final signPlanets = _planetMap.values
          .where((p) => p.sign == s)
          .toList();
      final signCusps = cuspList
          .where((c) => c.sign == s)
          .toList();
      signs[s] = Sign(s, signPlanets, signCusps);
    }
  }

  /// Get a planet by body.
  Planet planet(Body body) => _planetMap[body]!;

  /// Get a karaka by body (only for karaka-eligible bodies).
  Karaka karaka(Body body) => _karakaMap[body]!;

  /// All karakas in this varga.
  List<Karaka> get karakas => _karakaMap.values.toList();

  /// Get the sign a planet occupies.
  Sign signOf(Planet p) => signs[p.sign]!;

  // Named planet accessors
  Planet get sun => _planetMap[Body.sun]!;
  Planet get moon => _planetMap[Body.moon]!;
  Planet get mars => _planetMap[Body.mars]!;
  Planet get mercury => _planetMap[Body.mercury]!;
  Planet get jupiter => _planetMap[Body.jupiter]!;
  Planet get venus => _planetMap[Body.venus]!;
  Planet get saturn => _planetMap[Body.saturn]!;
  Planet get rahu => _planetMap[Body.rahu]!;
  Planet get ketu => _planetMap[Body.ketu]!;

  @override
  String toString() => 'Varga(${vargaType.name})';
}
