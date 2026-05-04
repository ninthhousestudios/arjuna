import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

void main() {
  const geoPos = BodyPosition(
    longitude: 45.0, latitude: 0.0, distance: 1.0,
    speedLongitude: 1.0, speedLatitude: 0.0, speedDistance: 0.0,
  );
  const baryPos = BodyPosition(
    longitude: 225.0, latitude: 0.001, distance: 0.006,
    speedLongitude: 1.0, speedLatitude: 0.0, speedDistance: 0.0,
  );
  const helioPos = BodyPosition(
    longitude: 120.0, latitude: 1.2, distance: 5.2,
    speedLongitude: 0.1, speedLatitude: 0.0, speedDistance: 0.0,
  );

  final geoMap = {
    for (final b in Body.values) b: geoPos,
  };

  final nakLons = geoMap.map((k, v) => MapEntry(k, v.longitude));

  EphSnapshot snap({
    Map<Body, BodyPosition>? bary,
    Map<Body, BodyPosition>? helio,
  }) =>
      EphSnapshot(
        jdUt: 2460000.5,
        location: const Location(latitude: 0, longitude: 0, altitude: 0),
        sweConfig: const SweConfig(),
        bodiesEcliptic: geoMap,
        bodiesEquatorial: geoMap,
        phenoData: const {},
        cusps: List.generate(12, (i) => i * 30.0),
        ascmc: const AscMcPoints(
          ascendant: 0, mc: 270, armc: 270, vertex: 180,
          equatorialAscendant: 0, coAscendantKoch: 0,
          coAscendantMunkasey: 0, polarAscendant: 0,
        ),
        sunTimes: const SunTimes(),
        ayanamsaValue: 0,
        bodiesNakEclLon: nakLons,
        bodiesNakEquLon: nakLons,
        bodiesEclipticBarycentric: bary,
        bodiesEclipticHeliocentric: helio,
      );

  test('returns null when neither extra frame is present', () {
    final s = snap();
    final sun = Planet(Body.sun, s, const CalcConfig(), VargaType.rashi);
    expect(sun.barycentricPosition, isNull);
    expect(sun.heliocentricPosition, isNull);
    expect(sun.barycentricRashiLongitude, isNull);
    expect(sun.heliocentricRashiLongitude, isNull);
  });

  test('barycentric populated, heliocentric null', () {
    final s = snap(bary: {Body.sun: baryPos});
    final sun = Planet(Body.sun, s, const CalcConfig(), VargaType.rashi);
    expect(sun.barycentricPosition, equals(baryPos));
    expect(sun.heliocentricPosition, isNull);
    expect(sun.barycentricRashiLongitude, isNotNull);
  });

  test('heliocentric omits Sun', () {
    final s = snap(helio: {Body.mars: helioPos});
    final mars = Planet(Body.mars, s, const CalcConfig(), VargaType.rashi);
    final sun = Planet(Body.sun, s, const CalcConfig(), VargaType.rashi);
    expect(mars.heliocentricPosition, equals(helioPos));
    expect(sun.heliocentricPosition, isNull);
  });
}
