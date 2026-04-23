import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:quiver_server/src/server.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '50051')
    ..addOption('ephe-path', help: 'Swiss Ephemeris data directory')
    ..addOption('pool-size', help: 'Number of worker isolates (default: CPU count, clamped 2-16)')
    ..addOption('log-level', defaultsTo: 'info')
    ..addFlag('help', abbr: 'h', negatable: false);

  final results = parser.parse(args);

  if (results.flag('help')) {
    stderr.writeln('Usage: quiver_server [options]');
    stderr.writeln(parser.usage);
    exit(0);
  }

  final int port;
  try {
    port = int.parse(results.option('port')!);
  } on FormatException {
    stderr.writeln('Error: --port must be an integer');
    exit(1);
  }
  final ephePath = results.option('ephe-path');
  final poolSizeStr = results.option('pool-size');
  final int? poolSize;
  if (poolSizeStr != null) {
    try {
      poolSize = int.parse(poolSizeStr);
    } on FormatException {
      stderr.writeln('Error: --pool-size must be an integer');
      exit(1);
    }
  } else {
    poolSize = null;
  }

  Logger.root.level = Level.LEVELS.firstWhere(
    (l) => l.name == results.option('log-level')!.toUpperCase(),
    orElse: () => Level.INFO,
  );
  Logger.root.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.loggerName}: ${record.message}');
  });

  await serve(port: port, ephePath: ephePath, poolSize: poolSize);
}
