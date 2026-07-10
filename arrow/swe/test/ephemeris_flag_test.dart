// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph_rs/swisseph_rs.dart' as swe;
import 'package:test/test.dart';

void main() {
  group('ephemerisFlag', () {
    test('swissEph maps to CalcFlags.swiEph', () {
      expect(ephemerisFlag(EphemerisSource.swissEph), swe.CalcFlags.swiEph);
    });

    test('moshier maps to CalcFlags.mosEph', () {
      expect(ephemerisFlag(EphemerisSource.moshier), swe.CalcFlags.mosEph);
    });

    test('swissEph and moshier flags differ', () {
      expect(
        ephemerisFlag(EphemerisSource.swissEph),
        isNot(ephemerisFlag(EphemerisSource.moshier)),
      );
    });

    test('jplEph maps to CalcFlags.jplEph', () {
      expect(ephemerisFlag(EphemerisSource.jplEph), swe.CalcFlags.jplEph);
    });

    test('all three sources yield distinct flags', () {
      final flags = EphemerisSource.values.map(ephemerisFlag).toSet();
      expect(flags.length, 3);
    });

    test('SweConfig default is swissEph (preserves prior behavior)', () {
      expect(SweConfig().ephemerisSource, EphemerisSource.swissEph);
    });
  });
}
