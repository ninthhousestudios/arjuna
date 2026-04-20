import 'dart:async';
import 'dart:io';

import 'package:arrow_swe/arrow_swe.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';
import 'package:quiver_core/quiver_core.dart';

import 'services/chart_service.dart';
import 'services/health_service.dart';

final _log = Logger('Quiver.Server');

class QuiverServer {
  final int _requestedPort;
  final String? ephePath;
  late final Server _server;

  int get port => _server.port ?? _requestedPort;

  QuiverServer({int port = 50051, this.ephePath}) : _requestedPort = port;

  Future<void> start() async {
    final swe = SweFacade(SwissEph.find(), ephePath: ephePath);
    final gateway = ArrowGateway(swe);

    _server = Server.create(
      services: [
        HealthService(),
        ChartService(gateway),
      ],
    );

    await _server.serve(port: _requestedPort);
    _log.info('Quiver listening on port $port');
  }

  Future<void> stop() async {
    _log.info('Shutting down...');
    await _server.shutdown();
    _log.info('Stopped.');
  }
}

Future<QuiverServer> serve({int port = 50051, String? ephePath}) async {
  final server = QuiverServer(port: port, ephePath: ephePath);

  ProcessSignal.sigint.watch().listen((_) async {
    await server.stop();
    exit(0);
  });

  await server.start();
  return server;
}
