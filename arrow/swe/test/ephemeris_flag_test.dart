// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph/swisseph.dart';
import 'package:test/test.dart';

void main() {
  group('ephemerisFlag', () {
    test('swissEph maps to seFlgSwiEph', () {
      expect(ephemerisFlag(EphemerisSource.swissEph), seFlgSwiEph);
    });

    test('moshier maps to seFlgMosEph', () {
      expect(ephemerisFlag(EphemerisSource.moshier), seFlgMosEph);
    });

    test('swissEph and moshier flags differ', () {
      expect(
        ephemerisFlag(EphemerisSource.swissEph),
        isNot(ephemerisFlag(EphemerisSource.moshier)),
      );
    });

    test('jplEph maps to seFlgJplEph', () {
      expect(ephemerisFlag(EphemerisSource.jplEph), seFlgJplEph);
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
