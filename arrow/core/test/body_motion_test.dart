// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('meanDailyMotion', () {
    test('table covers every Body enum value', () {
      expect(meanDailyMotion.keys.toSet(), equals(Body.values.toSet()));
    });

    test('all values positive', () {
      for (final entry in meanDailyMotion.entries) {
        expect(entry.value, greaterThan(0.0), reason: entry.key.name);
      }
    });

    test(
      'ordering Moon > Mercury > Venus > Sun > Mars > Jupiter > Saturn > outers',
      () {
        final v = meanDailyMotion;
        expect(v[Body.moon]!, greaterThan(v[Body.mercury]!));
        expect(v[Body.mercury]!, greaterThan(v[Body.venus]!));
        expect(v[Body.venus]!, greaterThan(v[Body.sun]!));
        expect(v[Body.sun]!, greaterThan(v[Body.mars]!));
        expect(v[Body.mars]!, greaterThan(v[Body.jupiter]!));
        expect(v[Body.jupiter]!, greaterThan(v[Body.saturn]!));
        expect(v[Body.saturn]!, greaterThan(v[Body.uranus]!));
        expect(v[Body.uranus]!, greaterThan(v[Body.neptune]!));
        expect(v[Body.neptune]!, greaterThan(v[Body.pluto]!));
        // Chiron (~50y orbit) faster than Pluto (~248y).
        expect(v[Body.chiron]!, greaterThan(v[Body.pluto]!));
        // But slower than Saturn (~29y).
        expect(v[Body.saturn]!, greaterThan(v[Body.chiron]!));
      },
    );
  });

  group('stationThreshold', () {
    test('covers every Body enum value', () {
      expect(stationThreshold.keys.toSet(), equals(Body.values.toSet()));
    });

    test('is 10% of mean daily motion', () {
      for (final body in Body.values) {
        expect(
          stationThreshold[body]!,
          closeTo(meanDailyMotion[body]! * 0.1, 1e-12),
          reason: body.name,
        );
      }
    });
  });
}
