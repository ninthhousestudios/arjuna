// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_calc/src/vedic/rashi_aspect.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  // Tables from libaditya/constants.py:rashi_aspects.
  const quadrant = {
    1: [2, 5, 8],
    2: [7, 10, 1],
    3: [6, 9, 12],
    4: [5, 8, 11],
    5: [10, 1, 4],
    6: [9, 12, 3],
    7: [8, 11, 2],
    8: [1, 4, 7],
    9: [12, 3, 6],
    10: [11, 2, 5],
    11: [4, 7, 10],
    12: [3, 6, 9],
  };

  const element = {
    1: [2, 8, 11],
    2: [7, 4, 1],
    3: [6, 9, 12],
    4: [5, 2, 11],
    5: [7, 10, 4],
    6: [9, 12, 3],
    7: [8, 11, 5],
    8: [1, 10, 7],
    9: [12, 3, 6],
    10: [11, 2, 8],
    11: [4, 1, 10],
    12: [3, 6, 9],
  };

  const conventional = {
    1: [5, 8, 11],
    2: [4, 7, 10],
    3: [6, 9, 12],
    4: [8, 11, 2],
    5: [7, 10, 1],
    6: [9, 12, 3],
    7: [11, 2, 5],
    8: [10, 1, 4],
    9: [12, 3, 6],
    10: [2, 5, 8],
    11: [1, 4, 7],
    12: [3, 6, 9],
  };

  void verifyTable(RashiAspectMode mode, Map<int, List<int>> expected) {
    for (final entry in expected.entries) {
      final sign = entry.key;
      final targets = entry.value;
      for (final target in targets) {
        expect(
          RashiAspect.doesAspect(sign, target, mode),
          isTrue,
          reason: '$mode: sign $sign should aspect $target',
        );
      }
      for (var other = 1; other <= 12; other++) {
        if (other == sign || targets.contains(other)) continue;
        expect(
          RashiAspect.doesAspect(sign, other, mode),
          isFalse,
          reason: '$mode: sign $sign should NOT aspect $other',
        );
      }
    }
  }

  group('doesAspect — full table verification', () {
    test('quadrant table matches libaditya', () {
      verifyTable(RashiAspectMode.quadrant, quadrant);
    });

    test('element table matches libaditya', () {
      verifyTable(RashiAspectMode.element, element);
    });

    test('conventional table matches libaditya', () {
      verifyTable(RashiAspectMode.conventional, conventional);
    });
  });

  group('doesAspect — default mode is quadrant', () {
    test('sign 1 aspects 2, 5, 8 by default', () {
      expect(RashiAspect.doesAspect(1, 2), isTrue);
      expect(RashiAspect.doesAspect(1, 5), isTrue);
      expect(RashiAspect.doesAspect(1, 8), isTrue);
    });

    test('sign 1 does NOT aspect 11 by default (quadrant)', () {
      expect(RashiAspect.doesAspect(1, 11), isFalse);
    });

    test('sign 1 DOES aspect 11 in conventional', () {
      expect(
        RashiAspect.doesAspect(1, 11, RashiAspectMode.conventional),
        isTrue,
      );
    });
  });

  group('doesAspect — modes differ where expected', () {
    test(
      'sign 1: quadrant has 2 but not 11; conventional has 11 but not 2',
      () {
        expect(RashiAspect.doesAspect(1, 2, RashiAspectMode.quadrant), isTrue);
        expect(
          RashiAspect.doesAspect(1, 11, RashiAspectMode.quadrant),
          isFalse,
        );
        expect(
          RashiAspect.doesAspect(1, 2, RashiAspectMode.conventional),
          isFalse,
        );
        expect(
          RashiAspect.doesAspect(1, 11, RashiAspectMode.conventional),
          isTrue,
        );
      },
    );

    test('dual signs (3,6,9,12) are identical across all modes', () {
      for (final mode in RashiAspectMode.values) {
        expect(RashiAspect.doesAspect(3, 6, mode), isTrue);
        expect(RashiAspect.doesAspect(3, 9, mode), isTrue);
        expect(RashiAspect.doesAspect(3, 12, mode), isTrue);
        expect(RashiAspect.doesAspect(3, 1, mode), isFalse);
      }
    });
  });

  group('doesAspectWithOccupants', () {
    test('empty sign does not cast aspect', () {
      expect(RashiAspect.doesAspectWithOccupants(1, 2, false), isFalse);
    });

    test('occupied sign casts aspect to valid target', () {
      expect(RashiAspect.doesAspectWithOccupants(1, 2, true), isTrue);
    });

    test('occupied sign does not cast to invalid target', () {
      expect(RashiAspect.doesAspectWithOccupants(1, 4, true), isFalse);
    });

    test('mode is respected', () {
      expect(
        RashiAspect.doesAspectWithOccupants(
          1,
          11,
          true,
          RashiAspectMode.conventional,
        ),
        isTrue,
      );
      expect(
        RashiAspect.doesAspectWithOccupants(
          1,
          11,
          true,
          RashiAspectMode.quadrant,
        ),
        isFalse,
      );
    });
  });

  group('mutual', () {
    test('returns 0 when neither sign has grahas', () {
      expect(RashiAspect.mutual(1, 2, false, false), equals(0));
    });

    test('returns 1 when only sign1 is occupied and aspects sign2', () {
      expect(RashiAspect.mutual(1, 2, true, false), equals(1));
    });

    test('returns 2 when only sign2 is occupied and aspects sign1', () {
      expect(RashiAspect.mutual(1, 2, false, true), equals(2));
    });

    test('returns 3 for mutual aspect when both occupied', () {
      // Quadrant: 1→[2,5,8], 2→[7,10,1] — mutual
      expect(RashiAspect.mutual(1, 2, true, true), equals(3));
    });

    test('returns 0 when occupied but no structural aspect', () {
      expect(RashiAspect.mutual(1, 4, true, true), equals(0));
    });

    test('mode is respected', () {
      // Conventional: 1→[5,8,11], 5→[7,10,1] — mutual on 1↔5
      expect(
        RashiAspect.mutual(1, 5, true, true, RashiAspectMode.conventional),
        equals(3),
      );
      // Conventional: 1→[5,8,11], does not include 2
      expect(
        RashiAspect.mutual(1, 2, true, true, RashiAspectMode.conventional),
        equals(0),
      );
    });
  });
}
