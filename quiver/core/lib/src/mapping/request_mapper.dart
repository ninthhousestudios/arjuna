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
    return arrow.ArrowOptions(
      sweConfig: _toSweConfig(request),
      calcConfig: _toCalcConfig(request),
    );
  }

  static arrow.SweConfig _toSweConfig(pb.CalcRequest request) {
    var config = const arrow.SweConfig();

    if (request.hasSignAyanamsa()) {
      config = config.copyWith(signAyanamsa: _mapAyanamsa(request.signAyanamsa));
    }
    if (request.hasHouseSystem()) {
      config = config.copyWith(houseSystem: _mapHouseSystem(request.houseSystem));
    }
    if (request.hasTrueNode()) {
      config = config.copyWith(trueNode: request.trueNode);
    }
    if (request.hasTopocentric()) {
      config = config.copyWith(topocentric: request.topocentric);
    }
    if (request.bodies.isNotEmpty) {
      config = config.copyWith(bodies: request.bodies.map(_mapBody).toSet());
    }

    return config;
  }

  static arrow.CalcConfig _toCalcConfig(pb.CalcRequest request) {
    var config = const arrow.CalcConfig();

    if (request.hasCircle()) {
      config = config.copyWith(circle: _mapCircle(request.circle));
    }
    if (request.hasNakAyanamsa()) {
      config = config.copyWith(nakAyanamsa: _mapAyanamsa(request.nakAyanamsa));
    }
    if (request.hasNakEquatorial()) {
      config = config.copyWith(nakEquatorial: request.nakEquatorial);
    }

    return config;
  }

  static arrow.Body _mapBody(pbe.Body body) => switch (body) {
        pbe.Body.SUN => arrow.Body.sun,
        pbe.Body.MOON => arrow.Body.moon,
        pbe.Body.MERCURY => arrow.Body.mercury,
        pbe.Body.VENUS => arrow.Body.venus,
        pbe.Body.MARS => arrow.Body.mars,
        pbe.Body.JUPITER => arrow.Body.jupiter,
        pbe.Body.SATURN => arrow.Body.saturn,
        pbe.Body.RAHU => arrow.Body.rahu,
        pbe.Body.KETU => arrow.Body.ketu,
        pbe.Body.URANUS => arrow.Body.uranus,
        pbe.Body.NEPTUNE => arrow.Body.neptune,
        pbe.Body.PLUTO => arrow.Body.pluto,
        _ => arrow.Body.sun,
      };

  static arrow.Ayanamsa _mapAyanamsa(pbe.Ayanamsa a) => switch (a) {
        pbe.Ayanamsa.TROPICAL => arrow.Ayanamsa.tropical,
        pbe.Ayanamsa.LAHIRI => arrow.Ayanamsa.lahiri,
        pbe.Ayanamsa.RAMAN => arrow.Ayanamsa.raman,
        pbe.Ayanamsa.KRISHNAMURTI => arrow.Ayanamsa.krishnamurti,
        pbe.Ayanamsa.FAGAN_BRADLEY => arrow.Ayanamsa.fagan,
        pbe.Ayanamsa.DHRUVA => arrow.Ayanamsa.dhruva,
        _ => arrow.Ayanamsa.tropical,
      };

  static arrow.HouseSystem _mapHouseSystem(pbe.HouseSystem h) => switch (h) {
        pbe.HouseSystem.CAMPANUS => arrow.HouseSystem.campanus,
        pbe.HouseSystem.PLACIDUS => arrow.HouseSystem.placidus,
        pbe.HouseSystem.KOCH => arrow.HouseSystem.koch,
        pbe.HouseSystem.EQUAL => arrow.HouseSystem.equalAsc,
        pbe.HouseSystem.WHOLE_SIGN => arrow.HouseSystem.wholeSigns,
        pbe.HouseSystem.PORPHYRY => arrow.HouseSystem.porphyrius,
        pbe.HouseSystem.REGIOMONTANUS => arrow.HouseSystem.regiomontanus,
        _ => arrow.HouseSystem.campanus,
      };

  static arrow.Circle _mapCircle(pbe.Circle c) => switch (c) {
        pbe.Circle.ADITYA => arrow.Circle.aditya,
        pbe.Circle.ZODIAC => arrow.Circle.zodiac,
        _ => arrow.Circle.aditya,
      };
}
