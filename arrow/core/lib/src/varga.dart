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
  late final Map<Body, Graha> _grahaMap;
  late final Map<Body, Karaka> _karakaMap;
  late final List<Cusp> cusps;
  late final Map<int, Sign> signs; // 1-12

  /// Division number for this varga.
  int get amsha => vargaType.amsha;

  Varga(this.vargaType, this.snapshot, this.config) {
    _initMaps();
  }

  void _initMaps() {
    final sunLon = snapshot.bodiesEcliptic[Body.sun]?.longitude;

    _planetMap = {};
    _grahaMap = {};
    _karakaMap = {};

    for (final body in snapshot.bodiesEcliptic.keys) {
      if (Body.karakas.contains(body)) {
        final k = Karaka(body, snapshot, config, vargaType,
            sunLongitude: sunLon);
        _karakaMap[body] = k;
        _grahaMap[body] = k;
        _planetMap[body] = k;
      } else if (body == Body.rahu || body == Body.ketu) {
        final g = Graha(body, snapshot, config, vargaType);
        _grahaMap[body] = g;
        _planetMap[body] = g;
      } else {
        _planetMap[body] = Planet(body, snapshot, config, vargaType);
      }
    }

    cusps = List.generate(12, (i) {
      return Cusp(i + 1, snapshot.cusps[i], config);
    });

    signs = {};
    for (var s = 1; s <= 12; s++) {
      final signPlanets =
          _planetMap.values.where((p) => p.sign == s).toList();
      final signCusps = cusps.where((c) => c.sign == s).toList();
      signs[s] = Sign(s, signPlanets, signCusps);
    }
  }

  /// Get a planet by body.
  Planet planet(Body body) => _planetMap[body]!;

  /// Get a karaka by body (only for karaka-eligible bodies).
  Karaka karaka(Body body) => _karakaMap[body]!;

  /// All karakas in this varga.
  List<Karaka> get karakas => _karakaMap.values.toList();

  /// All grahas (karakas + Rahu/Ketu) in this varga.
  List<Graha> get grahas => _grahaMap.values.toList();

  /// All planets in this varga.
  List<Planet> get planets => _planetMap.values.toList();

  /// Get the sign a planet occupies.
  Sign signOf(Planet p) => signs[p.sign]!;

  // Named planet accessors with narrowed return types.
  Karaka get sun => _karakaMap[Body.sun]!;
  Karaka get moon => _karakaMap[Body.moon]!;
  Karaka get mars => _karakaMap[Body.mars]!;
  Karaka get mercury => _karakaMap[Body.mercury]!;
  Karaka get jupiter => _karakaMap[Body.jupiter]!;
  Karaka get venus => _karakaMap[Body.venus]!;
  Karaka get saturn => _karakaMap[Body.saturn]!;
  Graha get rahu => _grahaMap[Body.rahu]!;
  Graha get ketu => _grahaMap[Body.ketu]!;

  @override
  String toString() => 'Varga(${vargaType.name})';
}
