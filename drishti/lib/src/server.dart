import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:mcp_dart/mcp_dart.dart' hide Logger;
import 'package:quiver_embedded/quiver_embedded.dart';

import 'tools/calculate_chart.dart';

final _log = Logger('Drishti');

/// Starts the Drishti MCP server on stdio transport.
///
/// [ephePath] is the optional path to Swiss Ephemeris data files.
Future<void> startServer({String? ephePath}) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    stderr.writeln('[${record.level.name}] ${record.loggerName}: ${record.message}');
  });

  final server = McpServer(
    Implementation(name: 'drishti', version: '0.1.0'),
  );

  final vayu = Vayu(ephePath: ephePath);

  registerCalculateChart(server, vayu);

  final transport = StdioServerTransport();
  await server.connect(transport);

  _log.info('Drishti MCP server started on stdio');

  // Listen for SIGINT to clean up.
  final sigint = ProcessSignal.sigint.watch().listen((_) async {
    _log.info('SIGINT received, shutting down');
    vayu.dispose();
    await server.close();
    exit(0);
  });

  // Keep alive until the transport closes.
  // The MCP server handles the event loop via the transport.
  // We wait for the server to be closed (transport disconnect).
  await Future<void>.delayed(const Duration(days: 365));

  sigint.cancel();
  vayu.dispose();
}
