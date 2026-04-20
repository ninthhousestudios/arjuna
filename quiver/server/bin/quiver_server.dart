import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:quiver_server/src/server.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '50051')
    ..addOption('ephe-path', help: 'Swiss Ephemeris data directory')
    ..addOption('log-level', defaultsTo: 'info');

  final results = parser.parse(args);
  final port = int.parse(results.option('port')!);
  final ephePath = results.option('ephe-path');

  Logger.root.level = Level.LEVELS.firstWhere(
    (l) => l.name == results.option('log-level')!.toUpperCase(),
    orElse: () => Level.INFO,
  );
  Logger.root.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.loggerName}: ${record.message}');
  });

  await serve(port: port, ephePath: ephePath);
}
