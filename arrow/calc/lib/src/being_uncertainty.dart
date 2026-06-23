import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';

BeingUncertainty computeBeingUncertainty(List<Chart> charts) {
  if (charts.length < 2) return BeingUncertainty.none;

  final trimsamsaResult = <Body, List<Being>>{};
  final horaResult = <Body, List<Being>>{};

  for (final body in Body.grahas) {
    final trimsamsaSet = <Being>{};
    final horaSet = <Being>{};

    for (final chart in charts) {
      final planet = chart.grahas.firstWhere((p) => p.body == body);
      trimsamsaSet.add(planet.trimsamsaBeing);
      horaSet.add(planet.horaBeing);
    }

    if (trimsamsaSet.length > 1) {
      trimsamsaResult[body] = trimsamsaSet.toList();
    }
    if (horaSet.length > 1) {
      horaResult[body] = horaSet.toList();
    }
  }

  return BeingUncertainty(
    trimsamsaOptions: trimsamsaResult,
    horaOptions: horaResult,
  );
}
