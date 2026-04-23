import 'dart:io';

import 'package:drishti/drishti.dart';
import 'package:logging/logging.dart';

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
        '[${record.level.name}] ${record.loggerName}: ${record.message}');
  });

  String? ephePath;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--ephe-path' && i + 1 < args.length) {
      ephePath = args[++i];
    }
  }
  ephePath ??= Platform.environment['DRISHTI_EPHE_PATH'];

  if (ephePath != null && !Directory(ephePath).existsSync()) {
    stderr.writeln('Error: ephemeris path does not exist: $ephePath');
    exit(1);
  }

  await startServer(ephePath: ephePath);
}
