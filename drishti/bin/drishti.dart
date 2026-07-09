// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:io';

import 'package:drishti/drishti.dart';
import 'package:logging/logging.dart';

/// Look for bundled ephe/ directory.
///
/// Search order: next to compiled binary, then `drishti/ephe/` relative to
/// cwd (covers `dart run drishti:drishti` from the workspace root), then
/// `ephe/` relative to cwd.
String? _findBundledEphe() {
  final candidates = [
    Directory('${File(Platform.resolvedExecutable).parent.path}/ephe'),
    Directory('drishti/ephe'),
    Directory('ephe'),
  ];
  for (final dir in candidates) {
    if (dir.existsSync()) return dir.path;
  }
  return null;
}

void main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    stderr.writeln('Usage: drishti [--ephe-path <dir>]');
    stderr.writeln('  --ephe-path  Path to Swiss Ephemeris data files');
    stderr.writeln('               (or set DRISHTI_EPHE_PATH env var)');
    exit(0);
  }

  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    stderr.writeln(
      '[${record.level.name}] ${record.loggerName}: ${record.message}',
    );
  });

  String? ephePath;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--ephe-path' && i + 1 < args.length) {
      ephePath = args[++i];
    }
  }
  ephePath ??= Platform.environment['DRISHTI_EPHE_PATH'];
  ephePath ??= _findBundledEphe();

  if (ephePath != null && !Directory(ephePath).existsSync()) {
    stderr.writeln('Error: ephemeris path does not exist: $ephePath');
    exit(1);
  }

  await startServer(ephePath: ephePath);
}
