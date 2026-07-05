import 'package:arrow_calc/arrow_calc.dart' show computeBeingUncertainty;
import 'package:arrow_core/arrow_core.dart' as core;
import 'package:arrow_options/arrow_options.dart' as arrow;

import '../generated/quiver/chart.pb.dart' as qpb;
import '../generated/quiver/types.pb.dart' as qt;
import '../generated/quiver/types.pbenum.dart' as qe;

class QuiverResponseMapper {
  static qpb.CalcResponse fromCharts(List<core.Chart> charts) {
    if (charts.length == 1) return _certain(charts.first);
    return _uncertain(charts);
  }

  static qpb.CalcResponse _certain(core.Chart chart) {
    return qpb.CalcResponse(
      timeCertain: true,
      placements: _mapPlacements(chart),
      atmakaraka: _computeAtmakaraka(chart),
    );
  }

  static qpb.CalcResponse _uncertain(List<core.Chart> charts) {
    final uncertainty = computeBeingUncertainty(charts);
    return qpb.CalcResponse(
      timeCertain: false,
      uncertainPlacements: _mapUncertainPlacements(charts, uncertainty),
      uncertainAtmakaraka: _computeUncertainAtmakaraka(charts),
    );
  }

  static List<qpb.Placement> _mapPlacements(core.Chart chart) {
    return chart.grahas.map((planet) {
      return qpb.Placement(
        body: _mapBody(planet.body),
        trimsamsaBeing: _mapBeing(planet.trimsamsaBeing),
        horaBeing: _mapBeing(planet.horaBeing),
        beingType: _mapBeingType(planet.beingType),
        hora: _mapHora(planet.hora),
      );
    }).toList();
  }

  static List<qpb.UncertainPlacement> _mapUncertainPlacements(
    List<core.Chart> charts,
    core.BeingUncertainty uncertainty,
  ) {
    final bodies = charts.first.grahas.map((p) => p.body).toList();
    return bodies.map((body) {
      final trimsamsaOptions = <qt.Being>{};
      final horaOptions = <qt.Being>{};
      final beingTypeOptions = <qe.BeingType>{};
      final horaEnumOptions = <qe.Hora>{};

      for (final chart in charts) {
        final planet = chart.grahas.firstWhere((p) => p.body == body);
        trimsamsaOptions.add(_mapBeing(planet.trimsamsaBeing));
        horaOptions.add(_mapBeing(planet.horaBeing));
        beingTypeOptions.add(_mapBeingType(planet.beingType));
        horaEnumOptions.add(_mapHora(planet.hora));
      }

      return qpb.UncertainPlacement(
        body: _mapBody(body),
        trimsamsaOptions: trimsamsaOptions.toList(),
        horaOptions: horaOptions.toList(),
        beingTypeOptions: beingTypeOptions.toList(),
        horaOptionsHora: horaEnumOptions.toList(),
      );
    }).toList();
  }

  static qpb.AtmakarakaResult _computeAtmakaraka(core.Chart chart) {
    final roles = core.CharaKaraka.assign(chart.karakas);
    final ak = roles[core.CharaKarakaRole.atmakaraka]!;
    final planet = chart.grahas.firstWhere((p) => p.body == ak.body);
    return qpb.AtmakarakaResult(
      body: _mapBody(ak.body),
      trimsamsaBeing: _mapBeing(planet.trimsamsaBeing),
      signNumber: ak.sign,
    );
  }

  static qpb.UncertainAtmakaraka _computeUncertainAtmakaraka(
    List<core.Chart> charts,
  ) {
    final seen = <String>{};
    final options = <qpb.AtmakarakaResult>[];

    for (final chart in charts) {
      final result = _computeAtmakaraka(chart);
      final key = '${result.body.value}:${result.signNumber}';
      if (seen.add(key)) {
        options.add(result);
      }
    }

    return qpb.UncertainAtmakaraka(options: options);
  }

  static qt.Being _mapBeing(arrow.Being being) {
    return qt.Being(
      name: being.name,
      type: _mapBeingType(being.type),
      signNumber: being.signNumber,
    );
  }

  static qe.BeingType _mapBeingType(arrow.BeingType type) => switch (type) {
    arrow.BeingType.gandharva => qe.BeingType.GANDHARVA,
    arrow.BeingType.rakshasa => qe.BeingType.RAKSHASA,
    arrow.BeingType.rishi => qe.BeingType.RISHI,
    arrow.BeingType.yaksha => qe.BeingType.YAKSHA,
    arrow.BeingType.apsara => qe.BeingType.APSARA,
    arrow.BeingType.aditya => qe.BeingType.ADITYA_BEING,
    arrow.BeingType.naga => qe.BeingType.NAGA,
  };

  static qe.Hora _mapHora(arrow.Hora hora) => switch (hora) {
    arrow.Hora.sun => qe.Hora.SUN_HORA,
    arrow.Hora.moon => qe.Hora.MOON_HORA,
  };

  static qe.Body _mapBody(arrow.Body body) => switch (body) {
    arrow.Body.sun => qe.Body.SUN,
    arrow.Body.moon => qe.Body.MOON,
    arrow.Body.mercury => qe.Body.MERCURY,
    arrow.Body.venus => qe.Body.VENUS,
    arrow.Body.mars => qe.Body.MARS,
    arrow.Body.jupiter => qe.Body.JUPITER,
    arrow.Body.saturn => qe.Body.SATURN,
    arrow.Body.rahu => qe.Body.RAHU,
    arrow.Body.ketu => qe.Body.KETU,
    _ => qe.Body.BODY_UNSPECIFIED,
  };
}
