// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';
import 'package:quiver_core/quiver_core.dart';

final _log = Logger('Quiver.Server.BeingHealth');

class BeingHealthService extends BeingHealthServiceBase {
  final QuiverGateway _gateway;

  BeingHealthService(this._gateway);

  @override
  Future<BeingHealthResponse> rankBeings(
    ServiceCall call,
    BeingHealthRequest request,
  ) async {
    try {
      return await _gateway.rankBeings(request);
    } on GrpcError {
      rethrow;
    } catch (e, stack) {
      _log.severe('Being health ranking failed', e, stack);
      throw GrpcError.internal('Being health ranking failed: $e');
    }
  }
}
