import 'package:arrow_options/arrow_options.dart' as arrow;
import 'package:arrow_swe/arrow_swe.dart' show julianDay;
import 'package:grpc/grpc.dart';

import '../generated/arrow/chart.pb.dart' as pb;
import '../generated/arrow/types.pbenum.dart' as pbe;

class RequestMapper {
  static double resolveJdUt(pb.CalcRequest request) {
    final hasTs = request.hasDatetime();
    final hasIso = request.hasDatetimeIso();
    final hasJd = request.hasJdUt();
    final count = [hasTs, hasIso, hasJd].where((b) => b).length;

    if (count == 0) {
      throw GrpcError.invalidArgument(
        'One of jd_ut, datetime, or datetime_iso must be set',
      );
    }
    if (count > 1) {
      throw GrpcError.invalidArgument(
        'Only one of jd_ut, datetime, or datetime_iso may be set',
      );
    }

    if (hasTs) return julianDay(request.datetime.toDateTime());
    if (hasIso) return _parseIsoToJd(request.datetimeIso);
    return request.jdUt;
  }

  static final _tzPattern = RegExp(r'[Zz]$|[+-]\d{2}:\d{2}$');

  static double _parseIsoToJd(String iso) {
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
    return julianDay(dt);
  }

  static arrow.Location toLocation(pb.CalcRequest request) {
    final loc = request.location;
    return arrow.Location(
      latitude: loc.latitude,
      longitude: loc.longitude,
      altitude: loc.altitude,
    );
  }

  static arrow.ArrowOptions toArrowOptions(pb.CalcRequest request) {
    return resolvePreset(request.preset);
  }

  static arrow.ArrowOptions resolvePreset(pbe.CalculationPreset preset) =>
      switch (preset) {
        pbe.CalculationPreset.ADITYA_PRESET => arrow.ArrowPresets.aditya,
        pbe.CalculationPreset.LAHIRI_PRESET => arrow.ArrowPresets.lahiriVedic,
        pbe.CalculationPreset.WESTERN_PRESET =>
          arrow.ArrowPresets.westernTropical,
        _ => arrow.ArrowPresets.aditya,
      };
}
