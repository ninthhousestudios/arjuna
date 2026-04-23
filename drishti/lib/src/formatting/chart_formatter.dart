import 'package:quiver_embedded/quiver_embedded.dart';

/// Sign names indexed by sign number (1-12).
const _signNames = [
  '', // 0 placeholder
  'Aries',
  'Taurus',
  'Gemini',
  'Cancer',
  'Leo',
  'Virgo',
  'Libra',
  'Scorpio',
  'Sagittarius',
  'Capricorn',
  'Aquarius',
  'Pisces',
];

/// Nakshatra names indexed by nakshatra number (1-27).
const _nakshatraNames = [
  '', // 0 placeholder
  'Ashvini',
  'Bharani',
  'Krittika',
  'Rohini',
  'Mrigashira',
  'Ardra',
  'Punarvasu',
  'Pushya',
  'Ashlesha',
  'Magha',
  'Purva Phalguni',
  'Uttara Phalguni',
  'Hasta',
  'Chitra',
  'Svati',
  'Vishakha',
  'Anuradha',
  'Jyeshtha',
  'Mula',
  'Purva Ashadha',
  'Uttara Ashadha',
  'Shravana',
  'Dhanishta',
  'Shatabhisha',
  'Purva Bhadrapada',
  'Uttara Bhadrapada',
  'Revati',
];

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
  if (sign < 1 || sign > 12) return 'Unknown';
  return _signNames[sign];
}

String _nakshatraName(int nak) {
  if (nak < 1 || nak > 27) return 'Unknown';
  return _nakshatraNames[nak];
}
