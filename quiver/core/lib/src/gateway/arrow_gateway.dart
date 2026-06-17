import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:logging/logging.dart';

import '../generated/arrow/chart.pb.dart';
import '../mapping/request_mapper.dart';
import '../mapping/response_mapper.dart';

final _log = Logger('Quiver.Core.ArrowGateway');

/// Callback that produces an [EphSnapshot] from raw inputs.
///
/// Used to abstract over synchronous [SweFacade] (embedded/local) vs
/// asynchronous [IsolatePool] (server) calculation backends.
typedef SnapshotCalculator =
    Future<EphSnapshot> Function(
      double jdUt,
      Location location,
      ArrowOptions options,
    );

class ArrowGateway {
  final SnapshotCalculator _calculate;

  ArrowGateway.fromCalculator(this._calculate);

  /// Convenience: wrap a synchronous [SweFacade].
  factory ArrowGateway(SweFacade swe) => ArrowGateway.fromCalculator(
    (jd, loc, opts) async => swe.calcAll(jd, loc, opts.sweConfig),
  );

  Future<CalcResponse> calculateChart(CalcRequest request) async {
    final location = RequestMapper.toLocation(request);
    final options = RequestMapper.toArrowOptions(request);

    _log.info(
      'calculateChart jd=${request.jdUt} '
      'lat=${location.latitude} lon=${location.longitude}',
    );

    final snapshot = await _calculate(request.jdUt, location, options);
    return ResponseMapper.fromSnapshot(snapshot, options.calcConfig);
  }
}
