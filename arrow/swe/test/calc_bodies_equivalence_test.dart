// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

@Tags(['integration'])
library;

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

import 'helpers/find_ephe_path.dart';

/// [SweFacade.calcBodies] is the positions-only path event scans use in place
/// of [SweFacade.calcAll]. It is only safe to substitute if it is not merely
/// close but *bit-identical* — a scan that brackets a crossing by sign change
/// will walk off a boundary on a last-ulp difference, and a silently different
/// reference frame reads as a plausible-looking wrong answer rather than an
/// error. So these compare with `equals`, never `closeTo`.
/// [Body.grahas] as a set — [SweConfig.bodies] is a `Set<Body>`.
const _grahas = <Body>{
  Body.sun,
  Body.moon,
  Body.mars,
  Body.mercury,
  Body.jupiter,
  Body.venus,
  Body.saturn,
  Body.rahu,
  Body.ketu,
};

void main() {
  final ephePath = findEphePath();
  final skipReason = ephePath == null
      ? 'no ephe path found; set ARROW_EPHE_PATH'
      : null;

  group('calcBodies ≡ calcAll — integration', skip: skipReason, () {
    // Spread across the ephemeris: 1900, J2000, 2026, 2100.
    const epochs = <double>[2415020.5, 2451545.0, 2461145.0, 2488069.5];

    const location = Location(
      latitude: 40.7128,
      longitude: -74.0060,
      altitude: 10.0,
    );

    late SweFacade facade;

    setUp(() {
      facade = SweFacade.create(ephePath: ephePath);
    });

    tearDown(() {
      facade.dispose();
    });

    void expectPositionsIdentical(BodyPosition actual, BodyPosition expected) {
      expect(actual.longitude, equals(expected.longitude));
      expect(actual.latitude, equals(expected.latitude));
      expect(actual.distance, equals(expected.distance));
      expect(actual.speedLongitude, equals(expected.speedLongitude));
      expect(actual.speedLatitude, equals(expected.speedLatitude));
      expect(actual.speedDistance, equals(expected.speedDistance));
    }

    void expectMapsIdentical(
      Map<Body, BodyPosition>? actual,
      Map<Body, BodyPosition>? expected,
      String label,
    ) {
      if (expected == null) {
        expect(actual, isNull, reason: '$label should be absent');
        return;
      }
      expect(actual, isNotNull, reason: '$label should be present');
      expect(
        actual!.keys.toSet(),
        equals(expected.keys.toSet()),
        reason: label,
      );
      for (final body in expected.keys) {
        expectPositionsIdentical(actual[body]!, expected[body]!);
      }
    }

    void expectEquivalent(SweConfig sweConfig, String label) {
      for (final jdUt in epochs) {
        final full = facade.calcAll(jdUt, location, sweConfig);
        final bodies = facade.calcBodies(jdUt, location, sweConfig);

        expectMapsIdentical(
          bodies.bodiesEcliptic,
          full.bodiesEcliptic,
          '$label ecliptic @ $jdUt',
        );
        expectMapsIdentical(
          bodies.bodiesEquatorial,
          full.bodiesEquatorial,
          '$label equatorial @ $jdUt',
        );
        expectMapsIdentical(
          bodies.bodiesEclipticBarycentric,
          full.bodiesEclipticBarycentric,
          '$label barycentric @ $jdUt',
        );
        expectMapsIdentical(
          bodies.bodiesEclipticHeliocentric,
          full.bodiesEclipticHeliocentric,
          '$label heliocentric @ $jdUt',
        );

        expect(
          bodies.phenoData.keys.toSet(),
          equals(full.phenoData.keys.toSet()),
          reason: '$label pheno keys @ $jdUt',
        );
        for (final body in full.phenoData.keys) {
          final actual = bodies.phenoData[body]!;
          final expected = full.phenoData[body]!;
          expect(actual.phaseAngle, equals(expected.phaseAngle));
          expect(actual.phase, equals(expected.phase));
          expect(actual.elongation, equals(expected.elongation));
          expect(actual.apparentDiameter, equals(expected.apparentDiameter));
          expect(actual.apparentMagnitude, equals(expected.apparentMagnitude));
        }

        expect(bodies.jdUt, equals(jdUt));
        expect(bodies.location, equals(location));
        expect(bodies.sweConfig, equals(sweConfig));
      }
    }

    test('tropical frame, all grahas', () {
      expectEquivalent(
        const SweConfig(bodies: _grahas, signAyanamsa: Ayanamsa.tropical),
        'tropical',
      );
    });

    test('sidereal (Lahiri) frame, all grahas', () {
      // The nak frame differs from the sign frame here, so calcAll runs its
      // extra nakshatra pass — calcBodies must be unaffected by skipping it.
      expectEquivalent(
        const SweConfig(
          bodies: _grahas,
          signAyanamsa: Ayanamsa.lahiri,
          nakAyanamsa: Ayanamsa.dhruva,
        ),
        'lahiri',
      );
    });

    test('single-body scan config (the innerorbits shape)', () {
      expectEquivalent(
        const SweConfig(bodies: {Body.moon}, signAyanamsa: Ayanamsa.tropical),
        'moon-only',
      );
    });

    test('two-body sidereal scan config', () {
      expectEquivalent(
        const SweConfig(
          bodies: {Body.venus, Body.sun},
          signAyanamsa: Ayanamsa.lahiri,
        ),
        'venus-sun sidereal',
      );
    });

    test('topocentric config', () {
      expectEquivalent(
        const SweConfig(
          bodies: {Body.moon, Body.sun},
          signAyanamsa: Ayanamsa.tropical,
          topocentric: true,
        ),
        'topocentric',
      );
    });

    test('extra reference frames', () {
      expectEquivalent(
        const SweConfig(
          bodies: {Body.sun, Body.jupiter, Body.rahu, Body.ketu},
          signAyanamsa: Ayanamsa.lahiri,
          extraFrames: {
            ReferencePoint.barycentric,
            ReferencePoint.heliocentric,
          },
        ),
        'extra frames',
      );
    });

    test('mean-node variant reaches Rahu and Ketu identically', () {
      expectEquivalent(
        const SweConfig(
          bodies: {Body.rahu, Body.ketu},
          signAyanamsa: Ayanamsa.tropical,
          trueNode: false,
        ),
        'mean node',
      );
    });

    test('includePheno: false drops pheno and nothing else', () {
      const sweConfig = SweConfig(
        bodies: {Body.venus, Body.sun},
        signAyanamsa: Ayanamsa.tropical,
      );
      const jdUt = 2461145.0;

      final withPheno = facade.calcBodies(jdUt, location, sweConfig);
      final without = facade.calcBodies(
        jdUt,
        location,
        sweConfig,
        includePheno: false,
      );

      expect(withPheno.phenoData, isNotEmpty);
      expect(without.phenoData, isEmpty);
      expectMapsIdentical(
        without.bodiesEcliptic,
        withPheno.bodiesEcliptic,
        'no-pheno ecliptic',
      );
      expectMapsIdentical(
        without.bodiesEquatorial,
        withPheno.bodiesEquatorial,
        'no-pheno equatorial',
      );
    });

    test('barycentric under Moshier fails fast, as calcAll does', () {
      const sweConfig = SweConfig(
        bodies: {Body.sun},
        ephemerisSource: EphemerisSource.moshier,
        extraFrames: {ReferencePoint.barycentric},
      );
      expect(
        () => facade.calcBodies(2461145.0, location, sweConfig),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
