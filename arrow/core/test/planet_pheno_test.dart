import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

void main() {
  const pos = BodyPosition(
    longitude: 45.0, latitude: 0.0, distance: 1.0,
    speedLongitude: 1.0, speedLatitude: 0.0, speedDistance: 0.0,
  );
  const venusPheno = PhenoData(
    phaseAngle: 90.0,
    phase: 0.5,
    elongation: 46.0,
    apparentDiameter: 0.003,
    apparentMagnitude: -4.2,
  );

  EphSnapshot snap({required Map<Body, PhenoData> pheno}) => EphSnapshot(
        jdUt: 2460000.5,
        location: const Location(latitude: 0, longitude: 0, altitude: 0),
        options: const ArrowOptions(),
        bodiesEcliptic: {
          Body.sun: pos, Body.moon: pos, Body.mercury: pos, Body.venus: pos,
          Body.mars: pos, Body.jupiter: pos, Body.saturn: pos,
          Body.rahu: pos, Body.ketu: pos,
        },
        bodiesEquatorial: {
          Body.sun: pos, Body.moon: pos, Body.mercury: pos, Body.venus: pos,
          Body.mars: pos, Body.jupiter: pos, Body.saturn: pos,
          Body.rahu: pos, Body.ketu: pos,
        },
        phenoData: pheno,
        cusps: List.generate(12, (i) => i * 30.0),
        ascmc: const AscMcPoints(
          ascendant: 0, mc: 270, armc: 270, vertex: 180,
          equatorialAscendant: 0, coAscendantKoch: 0,
          coAscendantMunkasey: 0, polarAscendant: 0,
        ),
        sunTimes: const SunTimes(),
        ayanamsaValue: 0,
      );

  test('Planet.pheno returns snapshot entry for body', () {
    final s = snap(pheno: {Body.venus: venusPheno});
    final venus = Planet(Body.venus, s, const CalcConfig(), VargaType.rashi);
    expect(venus.pheno, equals(venusPheno));
  });

  test('Planet.pheno returns null for nodes (sparse map)', () {
    final s = snap(pheno: {Body.venus: venusPheno});
    final rahu = Planet(Body.rahu, s, const CalcConfig(), VargaType.rashi);
    final ketu = Planet(Body.ketu, s, const CalcConfig(), VargaType.rashi);
    expect(rahu.pheno, isNull);
    expect(ketu.pheno, isNull);
  });

  test('Planet.pheno identity: same reference as snapshot map entry', () {
    final s = snap(pheno: {Body.mars: venusPheno});
    final mars = Planet(Body.mars, s, const CalcConfig(), VargaType.rashi);
    expect(identical(mars.pheno, s.phenoData[Body.mars]), isTrue);
  });
}
