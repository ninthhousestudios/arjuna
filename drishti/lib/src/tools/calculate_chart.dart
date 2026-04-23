import 'package:logging/logging.dart';
import 'package:mcp_dart/mcp_dart.dart' hide Logger;
import 'package:quiver_embedded/quiver_embedded.dart';

import '../formatting/chart_formatter.dart';

final _log = Logger('Drishti.CalculateChart');

/// Input schema for the calculate_chart tool.
final _inputSchema = JsonObject(
  properties: {
    'date': JsonString(
      description: 'ISO 8601 date-time in UTC (e.g. 2000-01-01T12:00:00Z)',
    ),
    'latitude': JsonNumber(
      description: 'Geographic latitude (-90 to 90)',
      minimum: -90,
      maximum: 90,
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
  required: ['date', 'latitude', 'longitude'],
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

CallToolResult _handleCalculateChart(
  Map<String, dynamic> args,
  Vayu vayu,
) {
  // Parse date.
  final dateStr = args['date'] as String?;
  if (dateStr == null || dateStr.isEmpty) {
    return _errorResult('Missing required parameter: date');
  }
  final dateTime = DateTime.tryParse(dateStr);
  if (dateTime == null) {
    return _errorResult('Invalid date format: $dateStr. Use ISO 8601 (e.g. 2000-01-01T12:00:00Z)');
  }
  final utcDateTime = dateTime.toUtc();

  // Parse latitude.
  final lat = _parseNum(args['latitude']);
  if (lat == null) {
    return _errorResult('Missing or invalid required parameter: latitude');
  }
  if (lat < -90 || lat > 90) {
    return _errorResult('Latitude must be between -90 and 90, got $lat');
  }

  // Parse longitude.
  final lon = _parseNum(args['longitude']);
  if (lon == null) {
    return _errorResult('Missing or invalid required parameter: longitude');
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
    _ => ArrowPresets.ernst,
  };

  final location = Location(latitude: lat, longitude: lon, altitude: alt);

  _log.fine('Calculating chart: date=$utcDateTime, location=$location, preset=$presetStr');

  try {
    final chart = vayu.calculateChart(utcDateTime, location, options);
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
