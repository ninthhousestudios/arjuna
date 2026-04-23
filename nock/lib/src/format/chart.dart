import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';

import 'cusp.dart';
import 'longitude.dart';
import 'planet.dart';
import 'table.dart';

const _chartWidth = 46;

/// Format a full chart as a box-drawing table.
///
/// Returns a multi-line string (no trailing newline). Pure function.
String formatChart(Chart chart, {String? label}) {
  final buf = StringBuffer();

  // Header
  buf.writeln(topBorder(_chartWidth));
  final headerLabel = label != null ? '  $label' : '';
  buf.writeln(row('Chart @ JD ${chart.snapshot.jdUt.toStringAsFixed(4)}$headerLabel', _chartWidth));
  buf.writeln(midBorder(_chartWidth));

  // Ascendant / MC
  final ascLon = Longitude(chart.ascendant, chart.ascendant,
      VargaType.rashi, chart.config);
  final mcLon = Longitude(chart.mc, chart.mc,
      VargaType.rashi, chart.config);
  buf.writeln(row(
      'Asc ${formatLongitude(ascLon)}  MC ${formatLongitude(mcLon)}',
      _chartWidth));
  buf.writeln(midBorder(_chartWidth));

  // Planet table header
  buf.writeln(row('Body       Longitude     Speed', _chartWidth));
  buf.writeln(midBorder(_chartWidth));

  // Planet rows
  for (final planet in chart.planets) {
    buf.writeln(row(formatPlanetOneLiner(planet), _chartWidth));
  }

  // Cusps section
  buf.writeln(midBorder(_chartWidth));
  buf.writeln(row('Cusps', _chartWidth));
  buf.writeln(midBorder(_chartWidth));

  for (final cusp in chart.cusps) {
    buf.writeln(row(formatCusp(cusp), _chartWidth));
  }

  buf.write(bottomBorder(_chartWidth));
  return buf.toString();
}
