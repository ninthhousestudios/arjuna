import 'package:arrow_options/arrow_options.dart' as arrow;
import 'package:arrow_swe/arrow_swe.dart' as swe;

import '../generated/arrow/chart.pb.dart' as pb_chart;
import '../generated/arrow/types.pb.dart' as pb;
import '../generated/arrow/types.pbenum.dart' as pbe;

class ResponseMapper {
  static pb_chart.CalcResponse fromSnapshot(swe.EphSnapshot snapshot) {
    return pb_chart.CalcResponse(snapshot: _mapSnapshot(snapshot));
  }

  static pb.EphSnapshot _mapSnapshot(swe.EphSnapshot s) {
    return pb.EphSnapshot(
      jdUt: s.jdUt,
      location: pb.Location(
        latitude: s.location.latitude,
        longitude: s.location.longitude,
        altitude: s.location.altitude,
      ),
      bodiesEcliptic: _mapBodyPositions(s.bodiesEcliptic),
      bodiesEquatorial: _mapBodyPositions(s.bodiesEquatorial),
      phenoData: _mapPhenoData(s.phenoData),
      cusps: s.cusps,
      ascmc: _mapAscMc(s.ascmc),
      sunTimes: _mapSunTimes(s.sunTimes),
      ayanamsaValue: s.ayanamsaValue,
      bodiesEclipticBarycentric:
          s.bodiesEclipticBarycentric != null
              ? _mapBodyPositions(s.bodiesEclipticBarycentric!)
              : [],
      bodiesEclipticHeliocentric:
          s.bodiesEclipticHeliocentric != null
              ? _mapBodyPositions(s.bodiesEclipticHeliocentric!)
              : [],
    );
  }

  static List<pb.BodyPositionEntry> _mapBodyPositions(
    Map<arrow.Body, swe.BodyPosition> bodies,
  ) {
    return bodies.entries.map((e) {
      return pb.BodyPositionEntry(
        body: _mapBody(e.key),
        position: pb.BodyPosition(
          longitude: e.value.longitude,
          latitude: e.value.latitude,
          distance: e.value.distance,
          speedLongitude: e.value.speedLongitude,
          speedLatitude: e.value.speedLatitude,
          speedDistance: e.value.speedDistance,
        ),
      );
    }).toList();
  }

  static List<pb.PhenoDataEntry> _mapPhenoData(
    Map<arrow.Body, swe.PhenoData> pheno,
  ) {
    return pheno.entries.map((e) {
      return pb.PhenoDataEntry(
        body: _mapBody(e.key),
        pheno: pb.PhenoData(
          phaseAngle: e.value.phaseAngle,
          phase: e.value.phase,
          elongation: e.value.elongation,
          apparentDiameter: e.value.apparentDiameter,
          apparentMagnitude: e.value.apparentMagnitude,
        ),
      );
    }).toList();
  }

  static pb.AscMcPoints _mapAscMc(swe.AscMcPoints a) {
    return pb.AscMcPoints(
      ascendant: a.ascendant,
      mc: a.mc,
      armc: a.armc,
      vertex: a.vertex,
      equatorialAscendant: a.equatorialAscendant,
      coAscendantKoch: a.coAscendantKoch,
      coAscendantMunkasey: a.coAscendantMunkasey,
      polarAscendant: a.polarAscendant,
    );
  }

  static pb.SunTimes _mapSunTimes(swe.SunTimes t) {
    final result = pb.SunTimes();
    if (t.sunrise != null) result.sunrise = t.sunrise!;
    if (t.sunset != null) result.sunset = t.sunset!;
    return result;
  }

  static pbe.Body _mapBody(arrow.Body body) => switch (body) {
        arrow.Body.sun => pbe.Body.SUN,
        arrow.Body.moon => pbe.Body.MOON,
        arrow.Body.mercury => pbe.Body.MERCURY,
        arrow.Body.venus => pbe.Body.VENUS,
        arrow.Body.mars => pbe.Body.MARS,
        arrow.Body.jupiter => pbe.Body.JUPITER,
        arrow.Body.saturn => pbe.Body.SATURN,
        arrow.Body.rahu => pbe.Body.RAHU,
        arrow.Body.ketu => pbe.Body.KETU,
        arrow.Body.uranus => pbe.Body.URANUS,
        arrow.Body.neptune => pbe.Body.NEPTUNE,
        arrow.Body.pluto => pbe.Body.PLUTO,
        _ => pbe.Body.BODY_UNSPECIFIED,
      };
}
