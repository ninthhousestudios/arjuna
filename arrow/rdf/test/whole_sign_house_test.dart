// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_rdf/arrow_rdf.dart';
import 'package:test/test.dart';

/// Hermetic coverage for the whole-sign house formula (ARP-4 follow-up,
/// arjuna/arrow/24). The golden fixture and serializer unit test both bake house
/// values in, and the live-compute path (ChartComputer) is SWE-gated and skips
/// off Josh's machine — so the negative-modulo wrap is exercised nowhere else.
void main() {
  test('body in the lagna sign is house 1', () {
    expect(wholeSignHouse(6, 6), 1);
    expect(wholeSignHouse(1, 1), 1);
    expect(wholeSignHouse(12, 12), 1);
  });

  test('body ahead of the lagna counts up without wrapping', () {
    expect(wholeSignHouse(8, 6), 3);
    expect(wholeSignHouse(12, 1), 12);
  });

  test('body behind the lagna wraps forward (negative modulo)', () {
    // vrishabha(2) with kanya(6) lagna -> 9th, as in the ARP-2 golden.
    expect(wholeSignHouse(2, 6), 9);
    expect(wholeSignHouse(1, 12), 2);
  });

  test('the sign just behind the lagna is the 12th', () {
    expect(wholeSignHouse(5, 6), 12);
    expect(wholeSignHouse(12, 1), 12);
    expect(wholeSignHouse(11, 12), 12);
  });

  test('every (body, lagna) in 1..12 maps into 1..12', () {
    for (var lagna = 1; lagna <= 12; lagna++) {
      for (var body = 1; body <= 12; body++) {
        expect(wholeSignHouse(body, lagna), inInclusiveRange(1, 12));
      }
    }
  });
}
