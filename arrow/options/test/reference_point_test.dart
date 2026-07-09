// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:convert';

import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('ReferencePoint', () {
    test('has exactly 3 values', () {
      expect(ReferencePoint.values, hasLength(3));
    });

    test('labels are distinct and non-empty', () {
      final labels = ReferencePoint.values.map((e) => e.label).toSet();
      expect(labels, hasLength(3));
      for (final l in labels) {
        expect(l, isNotEmpty);
      }
    });
  });

  group('SweConfig.extraFrames', () {
    test('defaults to empty set', () {
      expect(const SweConfig().extraFrames, isEmpty);
    });

    test('round-trips barycentric through JSON', () {
      const cfg = SweConfig(extraFrames: {ReferencePoint.barycentric});
      final restored = SweConfig.fromJson(jsonDecode(jsonEncode(cfg.toJson())));
      expect(restored.extraFrames, equals({ReferencePoint.barycentric}));
    });

    test('round-trips both frames through JSON', () {
      const cfg = SweConfig(
        extraFrames: {ReferencePoint.barycentric, ReferencePoint.heliocentric},
      );
      final restored = SweConfig.fromJson(jsonDecode(jsonEncode(cfg.toJson())));
      expect(
        restored.extraFrames,
        equals({ReferencePoint.barycentric, ReferencePoint.heliocentric}),
      );
    });
  });
}
