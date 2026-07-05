import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';
import 'package:quiver_core/quiver_core.dart';

final _log = Logger('Quiver.Server.Chart');

class ChartService extends ChartServiceBase {
  final QuiverGateway _gateway;

  ChartService(this._gateway);

  @override
  Future<CalcResponse> calculate(ServiceCall call, CalcRequest request) async {
    _log.fine('Calculate request: ${request.datetimeIso}');

    try {
      return await _gateway.calculate(request);
    } on GrpcError {
      rethrow;
    } catch (e, stack) {
      _log.severe('Chart calculation failed', e, stack);
      throw GrpcError.internal('Chart calculation failed: $e');
    }
  }
}
