import 'package:arrow_options/arrow_options.dart' as arrow;

import '../generated/arrow/chart.pb.dart' as pb;
import '../generated/arrow/types.pbenum.dart' as pbe;

class RequestMapper {
  static arrow.Location toLocation(pb.CalcRequest request) {
    final loc = request.location;
    return arrow.Location(
      latitude: loc.latitude,
      longitude: loc.longitude,
      altitude: loc.altitude,
    );
  }

  static arrow.ArrowOptions toArrowOptions(pb.CalcRequest request) {
    return _resolvePreset(request.preset);
  }

  static arrow.ArrowOptions _resolvePreset(pbe.CalculationPreset preset) =>
      switch (preset) {
        pbe.CalculationPreset.ADITYA_PRESET => arrow.ArrowPresets.ernst,
        pbe.CalculationPreset.LAHIRI_PRESET => arrow.ArrowPresets.lahiriVedic,
        pbe.CalculationPreset.WESTERN_PRESET =>
          arrow.ArrowPresets.westernTropical,
        _ => arrow.ArrowPresets.ernst,
      };
}
