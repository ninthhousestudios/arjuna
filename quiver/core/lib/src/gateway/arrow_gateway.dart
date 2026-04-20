import 'package:arrow_swe/arrow_swe.dart';
import 'package:logging/logging.dart';

import '../generated/arrow/chart.pb.dart';
import '../mapping/request_mapper.dart';
import '../mapping/response_mapper.dart';

final _log = Logger('Quiver.Core.ArrowGateway');

class ArrowGateway {
  final SweFacade _swe;

  ArrowGateway(this._swe);

  CalcResponse calculateChart(CalcRequest request) {
    final location = RequestMapper.toLocation(request);
    final options = RequestMapper.toArrowOptions(request);

    _log.info('calculateChart jd=${request.jdUt} '
        'lat=${location.latitude} lon=${location.longitude}');

    final snapshot = _swe.calcAll(request.jdUt, location, options);
    return ResponseMapper.fromSnapshot(snapshot);
  }
}
