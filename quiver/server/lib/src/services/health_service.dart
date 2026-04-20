import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

import 'package:quiver_core/quiver_core.dart';

final _log = Logger('Quiver.Server.Health');

class HealthService extends HealthServiceBase {
  final DateTime _startTime = DateTime.now();

  static const _version = '0.1.0';

  @override
  Future<HealthResponse> check(
    ServiceCall call,
    HealthRequest request,
  ) async {
    final uptime = DateTime.now().difference(_startTime).inSeconds;
    _log.fine('Health check: uptime=${uptime}s');

    return HealthResponse(
      healthy: true,
      version: _version,
      uptimeSeconds: Int64(uptime),
    );
  }
}
