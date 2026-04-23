import 'package:arrow_core/arrow_core.dart';

import '../../format/planet.dart';
import '../../format/cusp.dart' as fmt;
import '../../format/table.dart';
import '../error.dart';
import 'cusp.dart';
import 'planet.dart';
import 'value.dart';

class NockVarga extends NockValue {
  final Varga varga;
  final Chart chart;

  NockVarga(this.varga, this.chart);

  @override
  String display() {
    final type = varga.vargaType;
    final header = '${type.name} (D${type.amsha})';
    const width = 46;
    final buf = StringBuffer();
    buf.writeln(topBorder(width));
    buf.writeln(row(header, width));
    buf.writeln(midBorder(width));
    buf.writeln(row('Body       Longitude     Speed', width));
    buf.writeln(midBorder(width));
    for (final planet in varga.planets) {
      buf.writeln(row(formatPlanetOneLiner(planet), width));
    }
    buf.writeln(midBorder(width));
    buf.writeln(row('Cusps', width));
    buf.writeln(midBorder(width));
    for (final cusp in varga.cusps) {
      buf.writeln(row(fmt.formatCusp(cusp), width));
    }
    buf.write(bottomBorder(width));
    return buf.toString();
  }

  @override
  NockValue access(String field) => switch (field) {
        'sun' => NockPlanet(varga.sun, chart),
        'moon' => NockPlanet(varga.moon, chart),
        'mars' => NockPlanet(varga.mars, chart),
        'mercury' => NockPlanet(varga.mercury, chart),
        'jupiter' => NockPlanet(varga.jupiter, chart),
        'venus' => NockPlanet(varga.venus, chart),
        'saturn' => NockPlanet(varga.saturn, chart),
        'rahu' => NockPlanet(varga.rahu, chart),
        'ketu' => NockPlanet(varga.ketu, chart),
        'houses' => NockList(varga.cusps.map(NockCusp.new).toList()),
        'planets' =>
          NockList(varga.planets.map((p) => NockPlanet(p, chart)).toList()),
        'grahas' =>
          NockList(varga.grahas.map((g) => NockPlanet(g, chart)).toList()),
        'karakas' =>
          NockList(varga.karakas.map((k) => NockPlanet(k, chart)).toList()),
        _ => throw NockError('varga has no property "$field"'),
      };

  @override
  String typeName() => 'varga';
}
