import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

import '../generated/quiver/chart.pb.dart' as qpb;
import '../generated/quiver/types.pb.dart' as qt;
import '../generated/quiver/types.pbenum.dart' as qe;
import '../mapping/quiver_response_mapper.dart';

final _log = Logger('Quiver.Gateway');

typedef SnapshotCalculator =
    Future<EphSnapshot> Function(
      double jdUt,
      Location location,
      ArrowOptions options,
    );

class QuiverGateway {
  final SnapshotCalculator _calculate;

  QuiverGateway.fromCalculator(this._calculate);

  Future<qpb.CalcResponse> calculate(qpb.CalcRequest request) async {
    _validateRequest(request);

    final location = _toLocation(request.location);
    final options = _resolvePreset(request.preset);
    final jds = _resolveTimes(request);

    _log.info(
      'calculate samples=${jds.length} '
      'lat=${location.latitude} lon=${location.longitude}',
    );

    final charts = <Chart>[];
    for (final jd in jds) {
      final snapshot = await _calculate(jd, location, options);
      charts.add(Chart(snapshot, options.calcConfig));
    }

    return QuiverResponseMapper.fromCharts(charts);
  }

  void _validateRequest(qpb.CalcRequest request) {
    if (!request.hasDatetimeIso() || request.datetimeIso.isEmpty) {
      throw GrpcError.invalidArgument('datetime_iso is required');
    }
    if (!request.hasLocation()) {
      throw GrpcError.invalidArgument('location is required');
    }
  }

  List<double> _resolveTimes(qpb.CalcRequest request) {
    final baseJd = _parseIsoToJd(request.datetimeIso);

    if (!request.hasTimeUncertainty() ||
        request.timeUncertainty.whichKind() == qt.TimeUncertainty_Kind.notSet ||
        request.timeUncertainty.whichKind() == qt.TimeUncertainty_Kind.exact) {
      return [baseJd];
    }

    final baseDt = _parseIso(request.datetimeIso);
    final uncertainty = _mapUncertainty(request.timeUncertainty);
    return sampleTimes(baseDt, uncertainty).map(julianDay).toList();
  }

  TimeUncertainty _mapUncertainty(qt.TimeUncertainty proto) {
    return switch (proto.whichKind()) {
      qt.TimeUncertainty_Kind.period => PeriodTime(
        startHour: proto.period.startHour,
        endHour: proto.period.endHour,
      ),
      qt.TimeUncertainty_Kind.unknown => UnknownTime(
        intervalHours: proto.unknown.intervalHours > 0
            ? proto.unknown.intervalHours
            : 4,
      ),
      _ => const ExactTime(),
    };
  }

  static final _tzPattern = RegExp(r'[Zz]$|[+-]\d{2}:\d{2}$');

  double _parseIsoToJd(String iso) {
    final dt = _parseIso(iso);
    return julianDay(dt);
  }

  DateTime _parseIso(String iso) {
    if (!_tzPattern.hasMatch(iso)) {
      throw GrpcError.invalidArgument(
        'datetime_iso must include a timezone designator (Z or +/-HH:MM): $iso',
      );
    }
    final dt = DateTime.tryParse(iso);
    if (dt == null) {
      throw GrpcError.invalidArgument(
        'datetime_iso is not a valid ISO 8601 string: $iso',
      );
    }
    return dt;
  }

  Location _toLocation(qt.Location loc) {
    return Location(
      latitude: loc.latitude,
      longitude: loc.longitude,
      altitude: loc.altitude,
    );
  }

  ArrowOptions _resolvePreset(qe.CalculationPreset preset) {
    return switch (preset) {
      qe.CalculationPreset.ADITYA_PRESET => ArrowPresets.aditya,
      qe.CalculationPreset.LAHIRI_PRESET => ArrowPresets.lahiriVedic,
      qe.CalculationPreset.WESTERN_PRESET => ArrowPresets.westernTropical,
      _ => ArrowPresets.aditya,
    };
  }
}
