import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

/// End-to-end wiring check: build a [Chart] from a synthetic snapshot,
/// run every arrow_calc unit against it, and assert all produce
/// well-formed output. No golden comparisons — those live in the
/// per-unit tests. This exists to catch breakage at the seams.
EphSnapshot _stubSnapshot() {
  const location = Location(latitude: 40.0, longitude: -74.0);

  final bodies = <Body, BodyPosition>{
    Body.sun: const BodyPosition(
      longitude: 45.0, latitude: 0.5, distance: 1.0,
      speedLongitude: 0.98, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.moon: const BodyPosition(
      longitude: 120.0, latitude: -1.2, distance: 0.0025,
      speedLongitude: 13.2, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.mars: const BodyPosition(
      longitude: 200.0, latitude: 1.5, distance: 1.8,
      speedLongitude: -0.3, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.mercury: const BodyPosition(
      longitude: 55.0, latitude: -0.2, distance: 0.9,
      speedLongitude: 1.5, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.jupiter: const BodyPosition(
      longitude: 280.0, latitude: 0.3, distance: 5.2,
      speedLongitude: 0.08, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.venus: const BodyPosition(
      longitude: 30.0, latitude: -0.5, distance: 0.7,
      speedLongitude: 1.2, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.saturn: const BodyPosition(
      longitude: 310.0, latitude: 0.1, distance: 9.5,
      speedLongitude: 0.03, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.rahu: const BodyPosition(
      longitude: 100.0, latitude: 0.0, distance: 0.0,
      speedLongitude: -0.05, speedLatitude: 0.0, speedDistance: 0.0,
    ),
    Body.ketu: const BodyPosition(
      longitude: 280.0, latitude: 0.0, distance: 0.0,
      speedLongitude: -0.05, speedLatitude: 0.0, speedDistance: 0.0,
    ),
  };

  // Pheno — sparse (nodes omitted, per EphSnapshot contract).
  final pheno = <Body, PhenoData>{
    Body.sun: const PhenoData(
        phaseAngle: 0, phase: 1, elongation: 0,
        apparentDiameter: 0.53, apparentMagnitude: -26.7),
    Body.moon: const PhenoData(
        phaseAngle: 75, phase: 0.63, elongation: 75,
        apparentDiameter: 0.52, apparentMagnitude: -10),
    Body.mars: const PhenoData(
        phaseAngle: 30, phase: 0.93, elongation: 155,
        apparentDiameter: 0.003, apparentMagnitude: -1),
    Body.mercury: const PhenoData(
        phaseAngle: 110, phase: 0.32, elongation: 10,
        apparentDiameter: 0.002, apparentMagnitude: 0),
    Body.jupiter: const PhenoData(
        phaseAngle: 5, phase: 0.99, elongation: 125,
        apparentDiameter: 0.01, apparentMagnitude: -2),
    Body.venus: const PhenoData(
        phaseAngle: 90, phase: 0.5, elongation: 15,
        apparentDiameter: 0.01, apparentMagnitude: -4),
    Body.saturn: const PhenoData(
        phaseAngle: 3, phase: 0.99, elongation: 95,
        apparentDiameter: 0.005, apparentMagnitude: 0.5),
  };

  return EphSnapshot(
    jdUt: 2460000.5,
    location: location,
    sweConfig: const SweConfig(),
    bodiesEcliptic: bodies,
    bodiesEquatorial: bodies,
    phenoData: pheno,
    cusps: List.generate(12, (i) => (i * 30.0 + 10.0) % 360),
    ascmc: const AscMcPoints(
      ascendant: 10.0, mc: 280.0, armc: 280.0, vertex: 190.0,
      equatorialAscendant: 10.0, coAscendantKoch: 10.0,
      coAscendantMunkasey: 10.0, polarAscendant: 190.0,
    ),
    sunTimes: const SunTimes(sunrise: 2460000.75, sunset: 2460001.25),
    ayanamsaValue: 0.0,
  );
}

const _karakas = [
  Body.sun, Body.moon, Body.mars, Body.mercury,
  Body.jupiter, Body.venus, Body.saturn,
];

void main() {
  final snapshot = _stubSnapshot();
  const config = CalcConfig();
  final chart = Chart(snapshot, config);

  group('full pipeline', () {
    final longitudes = {
      for (final e in snapshot.bodiesEcliptic.entries)
        e.key: e.value.longitude,
    };
    final dignities = <Body, DignityType>{
      for (final body in snapshot.bodiesEcliptic.keys)
        body: Dignity.calculate(
          body,
          chart.rashi.planet(body).sign,
          chart.rashi.planet(body).longitude.inSignLongitude,
          chart.rashi
              .planet(SignData.lord(chart.rashi.planet(body).sign))
              .sign,
        ),
    };

    test('chart rashi has planets with dignity computable', () {
      for (final body in _karakas) {
        final p = chart.rashi.planet(body);
        expect(p.sign, inInclusiveRange(1, 12));
        expect(dignities[body], isNotNull, reason: '${body.name} dignity');
      }
    });

    test('Baladi runs for all karakas', () {
      for (final body in _karakas) {
        final p = chart.rashi.planet(body);
        final state = Baladi.of(p.sign, p.longitude.inSignLongitude);
        expect(state.libadityaName, isNotEmpty);
      }
    });

    test('Jagradadi runs for all karakas', () {
      for (final body in _karakas) {
        final state = Jagradadi.of(dignities[body]!);
        expect(state.libadityaName, isNotEmpty);
      }
    });

    test('Deeptadi runs for all karakas', () {
      final sunLon = snapshot.bodiesEcliptic[Body.sun]!.longitude;
      for (final body in _karakas) {
        final p = chart.rashi.planet(body);
        final state = Deeptadi.of(
          body: body,
          dignity: dignities[body]!,
          eclipticLongitude: p.rawLongitude,
          isRetrograde: p.isRetrograde,
          sunLongitude: sunLon,
          grahaLongitudes: longitudes,
        );
        expect(state.libadityaName, isNotEmpty);
      }
    });

    test('Lajjitaadi covers karaka set (none throw, each has ≥ 1 state)', () {
      final signs = {
        for (final body in _karakas) body: chart.rashi.planet(body).sign,
      };
      final karakaDignities = {
        for (final body in _karakas) body: dignities[body]!,
      };
      final ascLon = Longitude(
          snapshot.ascmc.ascendant, snapshot.ascmc.ascendant,
          VargaType.rashi, config);
      final fifthLon = Longitude(
          snapshot.cusps[4], snapshot.cusps[4], VargaType.rashi, config);
      final result = Lajjitaadi.compute(
        grahaLongitudes: longitudes,
        karakaDignities: karakaDignities,
        karakaSigns: signs,
        lagnaSign: ascLon.sign,
        fifthCuspSign: fifthLon.sign,
      );
      // Each returned karaka must have at least one non-empty state.
      for (final entry in result.entries) {
        expect(entry.value.avasthas, isNotEmpty,
            reason: '${entry.key.name} avasthas');
        for (final factors in entry.value.avasthas.values) {
          expect(factors, isNotEmpty);
        }
      }
    });

    test('Motion classifies all 9 grahas + retrograde seam', () {
      for (final body in snapshot.bodiesEcliptic.keys) {
        final p = chart.rashi.planet(body);
        // Access through Planet getters (motion state now on core).
        p.direction;
        p.speedClass;
      }
      // Mars stub has speedLongitude -0.3 → must classify retrograde.
      final mars = chart.rashi.planet(Body.mars);
      expect(mars.direction, Direction.retrograde);
    });

    test('Synodic sparse — planets yes, nodes no', () {
      final all = chart.synodicStates;
      expect(all.keys, containsAll(_karakas),
          reason: 'karakas should have synodic state');
      expect(all.containsKey(Body.rahu), isFalse);
      expect(all.containsKey(Body.ketu), isFalse);
      for (final s in all.values) {
        expect(s.category, isNotNull);
      }
      final rahu = chart.rashi.planet(Body.rahu);
      expect(rahu.synodicState, isNull);
    });

    test('Aspect strength wires to Parashara formula', () {
      final sunLon = snapshot.bodiesEcliptic[Body.sun]!.longitude;
      final marsLon = snapshot.bodiesEcliptic[Body.mars]!.longitude;
      final strength = Aspect.strength(Body.mars, marsLon, sunLon);
      expect(strength, greaterThanOrEqualTo(0));
      expect(strength, lessThanOrEqualTo(60));
    });
  });
}
