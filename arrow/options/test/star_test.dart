// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('Star', () {
    test('labels are unique and non-empty', () {
      final labels = Star.values.map((s) => s.label).toList();
      expect(labels.toSet().length, labels.length);
      for (final l in labels) {
        expect(l, isNotEmpty);
      }
    });

    test('nakshatra values are in range 1-27', () {
      for (final s in Star.values) {
        if (s.nakshatra != null) {
          expect(
            s.nakshatra,
            inInclusiveRange(1, 27),
            reason: '${s.name} nakshatra',
          );
        }
      }
    });

    test('each nakshatra 1-27 has exactly one junction star', () {
      final nakshatraStars = <int, Star>{};
      for (final s in Star.values) {
        if (s.nakshatra != null) {
          expect(
            nakshatraStars.containsKey(s.nakshatra),
            isFalse,
            reason:
                'duplicate junction star for nakshatra ${s.nakshatra}: '
                '${nakshatraStars[s.nakshatra]?.name} and ${s.name}',
          );
          nakshatraStars[s.nakshatra!] = s;
        }
      }
      for (var i = 1; i <= 27; i++) {
        expect(
          nakshatraStars.containsKey(i),
          isTrue,
          reason: 'missing junction star for nakshatra $i',
        );
      }
    });

    test('junctionStars returns exactly 27 stars', () {
      expect(Star.junctionStars, hasLength(27));
    });

    test('galacticCenter has no nakshatra and no magnitude', () {
      expect(Star.galacticCenter.nakshatra, isNull);
      expect(Star.galacticCenter.traditionalMag, isNull);
    });
  });
}
