import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';

import 'longitude.dart';

const planetGlyphs = <Body, String>{
  Body.sun: '☉',
  Body.moon: '☽',
  Body.mars: '♂',
  Body.mercury: '☿',
  Body.jupiter: '♃',
  Body.venus: '♀',
  Body.saturn: '♄',
  Body.rahu: '☊',
  Body.ketu: '☋',
  Body.uranus: '⛢',
  Body.neptune: '♆',
  Body.pluto: '♇',
  Body.chiron: '⚷',
};

/// Compact summary: "☉ Sun       24°12' ♊"
String formatPlanetSummary(Planet planet) {
  final glyph = planetGlyphs[planet.body] ?? '?';
  final name = _bodyDisplayName(planet.body).padRight(8);
  final lon = formatLongitude(planet.longitude);
  return '$glyph $name $lon';
}

/// One-liner with speed and retrograde marker:
/// "☉ Sun       24°12' ♊   +0.9612"
/// "♄ Saturn     5°18' ♏   -0.0423 R"
String formatPlanetOneLiner(Planet planet) {
  final glyph = planetGlyphs[planet.body] ?? '?';
  final name = _bodyDisplayName(planet.body).padRight(8);
  final lon = formatLongitude(planet.longitude);
  final speed = planet.position.speedLongitude;
  final speedStr = speed.toStringAsFixed(4).padLeft(8);
  final retro = planet.isRetrograde ? ' R' : '  ';
  return '$glyph $name $lon  $speedStr$retro';
}

String _bodyDisplayName(Body body) {
  final raw = body.name;
  return raw[0].toUpperCase() + raw.substring(1);
}
