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
    final iso = request.datetimeIso;
    final baseJd = _parseIsoToJd(iso);

    if (!request.hasTimeUncertainty() ||
        request.timeUncertainty.whichKind() == qt.TimeUncertainty_Kind.notSet ||
        request.timeUncertainty.whichKind() == qt.TimeUncertainty_Kind.exact) {
      return [baseJd];
    }

    final uncertainty = _mapUncertainty(request.timeUncertainty);
    final offset = _parseUtcOffset(iso);
    // sampleTimes needs local wall-clock date; pass a pseudo-UTC DateTime
    // with the local y/m/d so hour boundaries are in local time.
    final localDt = _parseLocalDateTime(iso);
    final samples = sampleTimes(localDt, uncertainty);
    // Each sample is local wall-clock as pseudo-UTC; subtract offset to get
    // true UTC, then convert to Julian Day.
    return samples
        .map((local) => local.subtract(offset))
        .map(julianDay)
        .toList();
  }

  TimeUncertainty _mapUncertainty(qt.TimeUncertainty proto) {
    return switch (proto.whichKind()) {
      qt.TimeUncertainty_Kind.period => PeriodTime(
        startHour: _validateHour(proto.period.startHour, 'start_hour'),
        endHour: _validateHour(proto.period.endHour, 'end_hour'),
      ),
      qt.TimeUncertainty_Kind.unknown => UnknownTime(
        intervalHours: _validateInterval(proto.unknown.intervalHours),
      ),
      _ => const ExactTime(),
    };
  }

  int _validateHour(int hour, String field) {
    if (hour < 0 || hour > 23) {
      throw GrpcError.invalidArgument('$field must be 0..23, got $hour');
    }
    return hour;
  }

  int _validateInterval(int interval) {
    if (interval < 1 || interval > 24) {
      throw GrpcError.invalidArgument(
        'interval_hours must be 1..24, got $interval',
      );
    }
    return interval;
  }

  static final _tzPattern = RegExp(r'[Zz]$|[+-]\d{2}:\d{2}$');
  static final _offsetPattern = RegExp(r'([+-])(\d{2}):(\d{2})$');

  double _parseIsoToJd(String iso) {
    final dt = _parseUtcDateTime(iso);
    return julianDay(dt);
  }

  /// Parse as UTC (Dart's default: offset applied, result is UTC).
  DateTime _parseUtcDateTime(String iso) {
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

  /// Extract local wall-clock y/m/d as a pseudo-UTC DateTime (no offset
  /// applied) so sampleTimes interprets hour boundaries in local time.
  DateTime _parseLocalDateTime(String iso) {
    final stripped = iso
        .replaceAll(_offsetPattern, '')
        .replaceAll(RegExp(r'[Zz]$'), '');
    final dt = DateTime.tryParse('${stripped}Z');
    if (dt == null) {
      throw GrpcError.invalidArgument(
        'datetime_iso is not a valid ISO 8601 string: $iso',
      );
    }
    return dt;
  }

  /// Parse the UTC offset from the ISO string as a Duration.
  Duration _parseUtcOffset(String iso) {
    if (iso.endsWith('Z') || iso.endsWith('z')) return Duration.zero;
    final match = _offsetPattern.firstMatch(iso);
    if (match == null) return Duration.zero;
    final sign = match.group(1) == '+' ? 1 : -1;
    final hours = int.parse(match.group(2)!);
    final minutes = int.parse(match.group(3)!);
    return Duration(hours: sign * hours, minutes: sign * minutes);
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
