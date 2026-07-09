// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

import 'package:quiver_core/grpc_health.dart' as std;
import 'package:quiver_core/quiver_core.dart';

final _log = Logger('Quiver.Server.Health');

/// Custom Quiver health service with version and uptime info.
class HealthService extends HealthServiceBase {
  final DateTime _startTime = DateTime.now();

  static const _version = '0.1.0';

  @override
  Future<HealthResponse> check(ServiceCall call, HealthRequest request) async {
    final uptime = DateTime.now().difference(_startTime).inSeconds;
    _log.fine('Health check: uptime=${uptime}s');

    return HealthResponse(
      healthy: true,
      version: _version,
      uptimeSeconds: Int64(uptime),
    );
  }
}

/// Standard grpc.health.v1.Health service for grpc_health_probe compatibility.
class GrpcHealthService extends std.HealthServiceBase {
  @override
  Future<std.HealthCheckResponse> check(
    ServiceCall call,
    std.HealthCheckRequest request,
  ) async {
    return std.HealthCheckResponse()
      ..status = std.HealthCheckResponse_ServingStatus.SERVING;
  }
}
