// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:async';
import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';
import 'package:quiver_core/quiver_core.dart';

import 'isolate_pool.dart';
import 'logging_interceptor.dart';
import 'services/chart_service.dart';
import 'services/health_service.dart';

final _log = Logger('Quiver.Server');

class QuiverServer {
  final int _requestedPort;
  final String? ephePath;
  final int? poolSize;
  late final Server _server;
  IsolatePool? _pool;

  int get port => _server.port ?? _requestedPort;

  QuiverServer({int port = 50051, this.ephePath, this.poolSize})
    : _requestedPort = port;

  Future<void> start() async {
    final pool = IsolatePool(size: poolSize, ephePath: ephePath);
    await pool.start();
    _pool = pool;

    final gateway = QuiverGateway.fromCalculator(pool.calculate);

    _server = Server.create(
      services: [GrpcHealthService(), HealthService(), ChartService(gateway)],
      serverInterceptors: [LoggingInterceptor()],
    );

    await _server.serve(port: _requestedPort);
    _log.info('Quiver listening on port $port (pool: ${pool.size} isolates)');
  }

  Future<void> stop() async {
    _log.info('Shutting down...');
    await _server.shutdown();
    await _pool?.dispose();
    _log.info('Stopped.');
  }
}

Future<QuiverServer> serve({
  int port = 50051,
  String? ephePath,
  int? poolSize,
}) async {
  final server = QuiverServer(
    port: port,
    ephePath: ephePath,
    poolSize: poolSize,
  );

  Future<void> shutdown() async {
    await server.stop();
    exit(0);
  }

  ProcessSignal.sigint.watch().listen((_) => shutdown());
  ProcessSignal.sigterm.watch().listen((_) => shutdown());

  await server.start();
  return server;
}
