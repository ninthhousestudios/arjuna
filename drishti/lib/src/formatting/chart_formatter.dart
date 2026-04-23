import 'package:quiver_embedded/quiver_embedded.dart';

/// Format a [Chart] into a structured map suitable for MCP structured content.
Map<String, dynamic> formatChart(Chart chart) {
  return {
    'summary': {
      'jd': chart.snapshot.jdUt,
      'ayanamsa': chart.snapshot.ayanamsaValue,
      'ascendant': chart.ascendant,
      'mc': chart.mc,
    },
    'planets': [
      for (final planet in chart.planets) _formatPlanet(planet),
    ],
    'houses': [
      for (var i = 0; i < chart.cusps.length; i++)
        _formatHouse(i + 1, chart.cusps[i]),
    ],
  };
}

Map<String, dynamic> _formatPlanet(Planet planet) {
  final sign = planet.longitude.sign;
  final nak = planet.longitude.nakshatra;

  final result = <String, dynamic>{
    'name': planet.body.name,
    // Ecliptic longitude after ayanamsa correction (sidereal for Vedic presets).
    'longitude': planet.rawLongitude,
    'sign': sign,
    'sign_name': _signName(sign),
    'degrees_in_sign': planet.longitude.inSignLongitude,
    'nakshatra': nak,
    'nakshatra_name': _nakshatraName(nak),
    'pada': planet.longitude.pada,
    'is_retrograde': planet.isRetrograde,
    'speed_class': planet.speedClass.name,
  };

  // Only Karaka has dignity; check type at runtime.
  if (planet is Karaka) {
    result['dignity'] = planet.dignity.name;
    result['is_combust'] = planet.isCombust;
  }

  return result;
}

Map<String, dynamic> _formatHouse(int number, Cusp cusp) {
  final sign = cusp.sign;
  return {
    'number': number,
    'sign': sign,
    'sign_name': _signName(sign),
    'longitude': cusp.longitude.eclipticLongitude,
  };
}

String _signName(int sign) {
  return SignData.names[sign] ?? 'Unknown';
}

String _nakshatraName(int nak) {
  return NakshatraData.names[nak] ?? 'Unknown';
}
