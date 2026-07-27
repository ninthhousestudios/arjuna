// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Pins the SPDX/copyright header on every Dart source file under `arrow/`.
///
/// Code generation strips it: `build_runner` rewrites every `*.freezed.dart`
/// and `*.g.dart` with its own fixed header, dropping the license from 27
/// committed files, and the resulting diff reads as ordinary codegen churn.
/// That is exactly the kind of change that gets committed without a second
/// look, so it is asserted here rather than left to discipline.
///
/// Fix a failure with `dart run arrow/tool/bin/license_header.dart`.
library;

import 'dart:io';

import 'package:test/test.dart';

/// Duplicated from `arrow/tool/bin/license_header.dart` — `arrow_calc` does
/// not depend on `arrow_tool` (nothing does; it is a leaf), and a test-only
/// dependency inverted just to share two string constants would be worse than
/// the duplication. The test and the script are pinned to each other by the
/// first case below, which fails if either drifts.
const _header =
    '// SPDX-License-Identifier: AGPL-3.0-or-later\n'
    '// Copyright (C) 2026 Ninth House Studios LLC\n';

const _skipDirs = {'.dart_tool', '.git', 'build', 'claude'};

Directory _arrowRoot() {
  for (var dir = Directory.current.absolute; ; dir = dir.parent) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('name: arrow_workspace')) {
      return dir;
    }
    if (dir.path == dir.parent.path) {
      throw StateError('not inside the arrow workspace');
    }
  }
}

void main() {
  final arrowRoot = _arrowRoot();

  test('license_header.dart agrees with this test on the header', () {
    final script = File('${arrowRoot.path}/tool/bin/license_header.dart');
    expect(script.existsSync(), isTrue, reason: 'the fixer script is missing');
    final source = script.readAsStringSync();
    for (final line in _header.trim().split('\n')) {
      expect(
        source,
        contains(line),
        reason: 'the fixer would write a different header than this test pins',
      );
    }
  });

  test('every Dart source under arrow/ carries the SPDX header', () {
    final offenders = <String>[];
    for (final entity in arrowRoot.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final relative = entity.path.substring(arrowRoot.path.length + 1);
      if (relative.split(Platform.pathSeparator).any(_skipDirs.contains)) {
        continue;
      }
      if (!entity.readAsStringSync().startsWith(_header)) {
        offenders.add(relative);
      }
    }
    offenders.sort();

    expect(
      offenders,
      isEmpty,
      reason:
          'Missing the license header — codegen strips it from generated '
          'files. Run: dart run arrow/tool/bin/license_header.dart\n'
          '${offenders.join('\n')}',
    );
  });

  test('generated files are covered, not merely skipped', () {
    // The check above passes vacuously if the walk stops finding generated
    // files (a moved package, a widened skip list). Pin that it sees them.
    final generated = arrowRoot
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where(
          (f) =>
              !f.path.contains('.dart_tool') &&
              (f.path.endsWith('.freezed.dart') || f.path.endsWith('.g.dart')),
        )
        .length;
    expect(
      generated,
      greaterThanOrEqualTo(27),
      reason: 'expected the generated files in options/ and swe/ to be walked',
    );
  });
}
