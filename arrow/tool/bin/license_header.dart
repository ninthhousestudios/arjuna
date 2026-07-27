// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Restore the SPDX/copyright header on every Dart source file under `arrow/`.
///
/// Needed because code generation strips it. `build_runner` rewrites every
/// `*.freezed.dart` and `*.g.dart` from scratch with its own fixed header, so
/// a plain codegen run silently drops the license from 27 committed files. The
/// `.g.dart` half could be fixed at the source (`source_gen:combining_builder`
/// takes a `header:` option in build.yaml), but freezed hardcodes its header
/// in `PartBuilder(...)` and reads no option — so the `.freezed.dart` half
/// needs repairing after the fact either way, and one mechanism beats two.
///
/// Run after any codegen:
///
///     dart run arrow/tool/bin/license_header.dart
///
/// `--check` reports offenders and exits 1 without writing, which is what
/// `arrow/calc/test/license_header_test.dart` asserts on every test run.
library;

import 'dart:io';

const _header =
    '// SPDX-License-Identifier: AGPL-3.0-or-later\n'
    '// Copyright (C) 2026 Ninth House Studios LLC\n';

/// Directory names skipped wherever they appear in the tree.
///
/// `claude/` holds planning artifacts and archived snapshots of deleted code,
/// not shipped source; `.dart_tool/` and `build/` are build products.
const _skipDirs = {'.dart_tool', '.git', 'build', 'claude'};

/// Files under `arrow/` that are missing the header, in tree order.
List<File> findOffenders(Directory arrowRoot) {
  final offenders = <File>[];
  for (final entity in arrowRoot.listSync(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final relative = entity.path.substring(arrowRoot.path.length + 1);
    if (relative.split(Platform.pathSeparator).any(_skipDirs.contains)) {
      continue;
    }
    if (!entity.readAsStringSync().startsWith(_header)) offenders.add(entity);
  }
  offenders.sort((a, b) => a.path.compareTo(b.path));
  return offenders;
}

/// The `arrow/` workspace root, found by walking up from [start].
///
/// Resolved by content rather than by a fixed relative path so the script and
/// the test behave the same whichever package directory they are invoked from.
Directory? findArrowRoot(Directory start) {
  for (var dir = start.absolute; ; dir = dir.parent) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('name: arrow_workspace')) {
      return dir;
    }
    if (dir.path == dir.parent.path) return null;
  }
}

void main(List<String> args) {
  final checkOnly = args.contains('--check');

  final arrowRoot = findArrowRoot(Directory.current);
  if (arrowRoot == null) {
    stderr.writeln(
      'not inside the arrow workspace (no arrow_workspace '
      'pubspec.yaml in any parent of ${Directory.current.path})',
    );
    exit(2);
  }

  final offenders = findOffenders(arrowRoot);
  if (offenders.isEmpty) {
    stdout.writeln('all Dart sources under ${arrowRoot.path} carry the header');
    return;
  }

  for (final file in offenders) {
    final relative = file.path.substring(arrowRoot.path.length + 1);
    if (checkOnly) {
      stdout.writeln('missing header: $relative');
      continue;
    }
    file.writeAsStringSync('$_header\n${file.readAsStringSync()}');
    stdout.writeln('added header: $relative');
  }

  if (checkOnly) {
    stderr.writeln(
      '\n${offenders.length} file(s) missing the license header. '
      'Run: dart run arrow/tool/bin/license_header.dart',
    );
    exit(1);
  }
}
