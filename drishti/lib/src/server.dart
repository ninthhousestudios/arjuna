// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

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
/// Returns when the server shuts down (via signal or transport close).
Future<void> startServer({String? ephePath}) async {
  final server = McpServer(Implementation(name: 'drishti', version: '0.1.0'));

  final vayu = Vayu(ephePath: ephePath);

  registerCalculateChart(server, vayu);

  final transport = StdioServerTransport();
  await server.connect(transport);

  _log.info('Drishti MCP server started on stdio');

  final done = Completer<void>();

  void shutdown(String signal) {
    if (done.isCompleted) return;
    _log.info('$signal received, shutting down');
    vayu.dispose();
    server.close();
    done.complete();
  }

  final sigint = ProcessSignal.sigint.watch().listen((_) => shutdown('SIGINT'));
  StreamSubscription<ProcessSignal>? sigterm;
  if (!Platform.isWindows) {
    sigterm = ProcessSignal.sigterm.watch().listen((_) => shutdown('SIGTERM'));
  }

  await done.future;

  sigint.cancel();
  sigterm?.cancel();
}
