import 'package:quiver_embedded/quiver_embedded.dart';

/// Format a [Chart] into a structured map suitable for MCP structured content.
Map<String, dynamic> formatChart(Chart chart) {
  final cusps = chart.cusps;
  return {
    'summary': {
      'jd': chart.snapshot.jdUt,
      'ayanamsa': chart.snapshot.ayanamsaValue,
      'ascendant': chart.ascendant,
      'mc': chart.mc,
    },
    'planets': [
      for (final planet in chart.planets) _formatPlanet(planet, cusps),
    ],
    'houses': [
      for (var i = 0; i < cusps.length; i++)
        _formatHouse(i + 1, cusps[i]),
    ],
    'ascmc': {
      'armc': chart.snapshot.ascmc.armc,
      'vertex': chart.snapshot.ascmc.vertex,
      'equatorial_ascendant': chart.snapshot.ascmc.equatorialAscendant,
      'co_ascendant_koch': chart.snapshot.ascmc.coAscendantKoch,
      'co_ascendant_munkasey': chart.snapshot.ascmc.coAscendantMunkasey,
      'polar_ascendant': chart.snapshot.ascmc.polarAscendant,
    },
  };
}

Map<String, dynamic> _formatPlanet(Planet planet, List<Cusp> cusps) {
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
    'house_number': _houseNumber(planet.rawLongitude, cusps),
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

/// Find which house a planet falls in by checking cusp boundaries.
///
/// Iterates cusps and finds the pair where [longitude] falls between
/// cusp[i] and cusp[i+1], handling the 360-to-0 degree wrap.
/// Returns a house number in the range 1-12.
int _houseNumber(double longitude, List<Cusp> cusps) {
  for (var i = 0; i < cusps.length; i++) {
    final cuspLon = cusps[i].longitude.eclipticLongitude;
    final nextCuspLon =
        cusps[(i + 1) % cusps.length].longitude.eclipticLongitude;

    if (nextCuspLon > cuspLon) {
      // Normal case: no wrap-around.
      if (longitude >= cuspLon && longitude < nextCuspLon) {
        return i + 1;
      }
    } else {
      // Wrap-around: cusp spans 360°/0° boundary.
      if (longitude >= cuspLon || longitude < nextCuspLon) {
        return i + 1;
      }
    }
  }
  // Fallback — should not happen with valid cusp data.
  return 1;
}
