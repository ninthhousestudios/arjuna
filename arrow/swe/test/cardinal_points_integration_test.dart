@Tags(['integration'])
library;

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph/swisseph.dart';
import 'package:test/test.dart';

import 'helpers/find_ephe_path.dart';

/// Expected cardinal-point calendar dates for the test years.
///
/// Dates are UT, drawn from USNO astronomical almanac data. Times are
/// intentionally not asserted — a ±1-day window on the date is plenty
/// to catch wrong-year / wrong-longitude / wrong-order bugs without
/// coupling to an exact JD value.
const _expected = <int, List<(int, int)>>{
  // (month, day) in order: asc equinox, N solstice, desc equinox, S solstice.
  2000: [(3, 20), (6, 21), (9, 22), (12, 21)],
  2024: [(3, 20), (6, 20), (9, 22), (12, 21)],
  2026: [(3, 20), (6, 21), (9, 23), (12, 21)],
};

void main() {
  final ephePath = findEphePath();
  final skipReason = ephePath == null
      ? 'no ephe path found; set ARROW_EPHE_PATH'
      : null;

  group('calcCardinalPoints — integration', skip: skipReason, () {
    late SwissEph swe;
    late SweFacade facade;

    setUp(() {
      swe = SwissEph.find();
      facade = SweFacade(swe, ephePath: ephePath);
    });

    tearDown(() {
      swe.close();
    });

    for (final entry in _expected.entries) {
      final year = entry.key;
      final expected = entry.value;

      test('$year — four points in calendar year, in order', () {
        final cp = facade.calcCardinalPoints(year);
        final jds = [
          cp.ascendingEquinox,
          cp.northernSolstice,
          cp.descendingEquinox,
          cp.southernSolstice,
        ];

        // All four fall in the requested calendar year, in chronological order.
        for (var i = 0; i < 4; i++) {
          final date = swe.revjul(jds[i]);
          expect(date.year, equals(year),
              reason: 'point $i of $year landed in ${date.year}');
          expect(date.month, equals(expected[i].$1),
              reason: 'point $i of $year: expected month ${expected[i].$1}, '
                  'got ${date.month}');
          expect(date.day, closeTo(expected[i].$2, 1),
              reason: 'point $i of $year: expected day ~${expected[i].$2}, '
                  'got ${date.day}');
        }

        expect(cp.ascendingEquinox, lessThan(cp.northernSolstice));
        expect(cp.northernSolstice, lessThan(cp.descendingEquinox));
        expect(cp.descendingEquinox, lessThan(cp.southernSolstice));
      });
    }

    test('Moshier source also works (tropical is ephemeris-agnostic)', () {
      final cp = facade.calcCardinalPoints(
        2026,
        source: EphemerisSource.moshier,
      );
      // Sanity: March equinox lands in March 2026.
      final date = swe.revjul(cp.ascendingEquinox);
      expect(date.year, 2026);
      expect(date.month, 3);
      expect(date.day, closeTo(20, 1));
    });
  });
}
