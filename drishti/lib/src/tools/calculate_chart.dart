import 'package:logging/logging.dart';
import 'package:mcp_dart/mcp_dart.dart' hide Logger;
import 'package:meta/meta.dart';
import 'package:quiver_embedded/quiver_embedded.dart';

import '../formatting/chart_formatter.dart';

final _log = Logger('Drishti.CalculateChart');

/// Input schema for the calculate_chart tool.
final _inputSchema = JsonObject(
  properties: {
    'jd': JsonNumber(
      description: 'Julian Day (UT). Preferred for machine callers. '
          'Provide either jd or date.',
    ),
    'date': JsonString(
      description: 'ISO 8601 date-time in UTC (e.g. 2000-01-01T12:00:00Z). '
          'Provide either date or jd.',
    ),
    'lat': JsonNumber(
      description: 'Geographic latitude (-90 to 90). Alias for latitude.',
      minimum: -90,
      maximum: 90,
    ),
    'latitude': JsonNumber(
      description: 'Geographic latitude (-90 to 90)',
      minimum: -90,
      maximum: 90,
    ),
    'lon': JsonNumber(
      description: 'Geographic longitude (-180 to 180). Alias for longitude.',
      minimum: -180,
      maximum: 180,
    ),
    'longitude': JsonNumber(
      description: 'Geographic longitude (-180 to 180)',
      minimum: -180,
      maximum: 180,
    ),
    'altitude': JsonNumber(
      description: 'Altitude in meters (default: 0)',
      defaultValue: 0,
    ),
    'preset': JsonString(
      description: 'Calculation preset (default: ernst)',
      enumValues: ['ernst', 'lahiri', 'western'],
      defaultValue: 'ernst',
    ),
  },
  required: [],
);

/// Registers the calculate_chart tool on the given [server].
void registerCalculateChart(McpServer server, Vayu vayu) {
  server.registerTool(
    'calculate_chart',
    description: 'Calculate an astrological chart for a given date, time, and location. '
        'Returns planetary positions with sign, nakshatra, dignity, and house cusps.',
    inputSchema: _inputSchema,
    callback: (args, extra) => _handleCalculateChart(args, vayu),
  );
}

@visibleForTesting
CallToolResult handleCalculateChart(
  Map<String, dynamic> args,
  Vayu vayu,
) =>
    _handleCalculateChart(args, vayu);

CallToolResult _handleCalculateChart(
  Map<String, dynamic> args,
  Vayu vayu,
) {
  // Parse time — accept jd (preferred) or date.
  final jdRaw = _parseNum(args['jd']);
  final dateStr = args['date'] as String?;

  double? jd = jdRaw;
  if (jd == null) {
    if (dateStr == null || dateStr.isEmpty) {
      return _errorResult('Provide either jd or date');
    }
    final dateTime = DateTime.tryParse(dateStr);
    if (dateTime == null) {
      return _errorResult(
          'Invalid date format: $dateStr. Use ISO 8601 (e.g. 2000-01-01T12:00:00Z)');
    }
    if (!dateStr.endsWith('Z') &&
        !dateStr.contains('+') &&
        !RegExp(r'\d{2}-\d{2}$').hasMatch(dateStr)) {
      _log.info(
          'Date "$dateStr" has no timezone indicator; interpreted as local time');
    }
    jd = julianDay(dateTime.toUtc());
  }

  // Parse latitude (accept lat or latitude).
  final lat = _parseNum(args['lat']) ?? _parseNum(args['latitude']);
  if (lat == null) {
    return _errorResult('Missing required parameter: latitude (or lat)');
  }
  if (lat < -90 || lat > 90) {
    return _errorResult('Latitude must be between -90 and 90, got $lat');
  }

  // Parse longitude (accept lon or longitude).
  final lon = _parseNum(args['lon']) ?? _parseNum(args['longitude']);
  if (lon == null) {
    return _errorResult('Missing required parameter: longitude (or lon)');
  }
  if (lon < -180 || lon > 180) {
    return _errorResult('Longitude must be between -180 and 180, got $lon');
  }

  // Parse altitude.
  final alt = _parseNum(args['altitude']) ?? 0.0;

  // Parse preset.
  final presetStr = args['preset'] as String? ?? 'ernst';
  final options = switch (presetStr) {
    'ernst' => ArrowPresets.ernst,
    'lahiri' => ArrowPresets.lahiriVedic,
    'western' => ArrowPresets.westernTropical,
    _ => null,
  };
  if (options == null) {
    return _errorResult(
        "Unknown preset: '$presetStr'. Valid values: ernst, lahiri, western");
  }

  final location = Location(latitude: lat, longitude: lon, altitude: alt);

  _log.fine('Calculating chart: jd=$jd, location=$location, preset=$presetStr');

  try {
    final chart = vayu.calculateChartFromJd(jd, location, options);
    final formatted = formatChart(chart);
    return CallToolResult.fromStructuredContent(formatted);
  } catch (e, st) {
    _log.warning('Chart calculation failed', e, st);
    return _errorResult('Chart calculation failed: $e');
  }
}

double? _parseNum(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

CallToolResult _errorResult(String message) {
  return CallToolResult(
    content: [TextContent(text: message)],
    isError: true,
  );
}
