// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:quiver_server/src/isolate_pool.dart';
import 'package:test/test.dart';

void main() {
  // J2000.0 — 2000-01-01 12:00 UT
  const testJd = 2451545.0;
  const testLocation = Location(latitude: 28.6139, longitude: 77.2090);
  final testOptions = ArrowPresets.aditya;

  group('IsolatePool', () {
    late IsolatePool pool;

    setUp(() async {
      pool = IsolatePool(size: 2);
      await pool.start();
    });

    tearDown(() async {
      await pool.dispose();
    });

    test('single request returns valid snapshot', () async {
      final snapshot = await pool.calculate(testJd, testLocation, testOptions);

      expect(snapshot.jdUt, equals(testJd));
      expect(snapshot.bodiesEcliptic, isNotEmpty);
      expect(snapshot.bodiesEquatorial, isNotEmpty);
      expect(snapshot.cusps, hasLength(12));
      expect(snapshot.ascmc.ascendant, isNonZero);
    });

    test('concurrent requests complete without error', () async {
      final futures = List.generate(10, (i) {
        // Vary the JD slightly so each request is distinct.
        final jd = testJd + i * 0.01;
        return pool.calculate(jd, testLocation, testOptions);
      });

      final results = await Future.wait(futures);
      expect(results, hasLength(10));

      for (var i = 0; i < results.length; i++) {
        final snap = results[i];
        expect(snap.jdUt, closeTo(testJd + i * 0.01, 1e-9));
        expect(snap.bodiesEcliptic, isNotEmpty);
      }
    });

    test('results match direct SweFacade calculation', () async {
      // Pool result.
      final poolSnap = await pool.calculate(testJd, testLocation, testOptions);

      // Direct SweFacade result.
      final swe = SweFacade.create();
      final directSnap = swe.calcAll(
        testJd,
        testLocation,
        testOptions.sweConfig,
      );

      // Compare body ecliptic longitudes.
      for (final body in directSnap.bodiesEcliptic.keys) {
        final directPos = directSnap.bodiesEcliptic[body]!;
        final poolPos = poolSnap.bodiesEcliptic[body]!;
        expect(
          poolPos.longitude,
          closeTo(directPos.longitude, 1e-6),
          reason: '$body ecliptic longitude should match',
        );
        expect(
          poolPos.latitude,
          closeTo(directPos.latitude, 1e-6),
          reason: '$body ecliptic latitude should match',
        );
      }

      // Compare cusps.
      for (var i = 0; i < 12; i++) {
        expect(
          poolSnap.cusps[i],
          closeTo(directSnap.cusps[i], 1e-6),
          reason: 'cusp $i should match',
        );
      }

      // Compare ascendant and MC.
      expect(
        poolSnap.ascmc.ascendant,
        closeTo(directSnap.ascmc.ascendant, 1e-6),
      );
      expect(poolSnap.ascmc.mc, closeTo(directSnap.ascmc.mc, 1e-6));
    });

    test('dispose drains in-flight requests', () async {
      // Fire off several requests, then dispose immediately.
      final futures = List.generate(5, (i) {
        return pool.calculate(testJd + i * 0.1, testLocation, testOptions);
      });

      // Dispose should wait for in-flight requests.
      await pool.dispose();

      // Every future must resolve (success or error) — none should hang.
      int succeeded = 0;
      int errored = 0;
      for (final f in futures) {
        try {
          await f;
          succeeded++;
        } catch (_) {
          errored++;
        }
      }
      expect(succeeded + errored, equals(5));
      expect(succeeded, greaterThan(0));
    });

    test('calculate throws after dispose', () async {
      await pool.dispose();

      expect(
        () => pool.calculate(testJd, testLocation, testOptions),
        throwsStateError,
      );
    });

    test('start is idempotent', () async {
      // Pool already started in setUp. Calling start again should not throw.
      await pool.start();

      final snapshot = await pool.calculate(testJd, testLocation, testOptions);
      expect(snapshot.bodiesEcliptic, isNotEmpty);
    });
  });
}
