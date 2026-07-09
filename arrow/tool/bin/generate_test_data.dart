// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:convert';
import 'dart:io';

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:arrow_tool/arrow_tool.dart';
import 'package:swisseph/swisseph.dart';

/// Generate test fixture JSON from a .chtk chart file.
///
/// Usage: dart run tool/bin/generate_test_data.dart [options]
///   --chtk `path`      Path to .chtk file (default: ~/charts/mine/josh.chtk)
///   --swe-lib `path`   Path to libswe.so/.dylib (default: searches common paths)
///   --ephe-path `dir`  Swiss Ephemeris data directory (.se1 + sefstars.txt).
///                      Defaults to $ARROW_EPHE_PATH, then libaditya/ephe, then
///                      left unset (SWE falls back to Moshier).
void main(List<String> args) {
  String? chtkPath;
  String? sweLib;
  String? ephePath;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--chtk' && i + 1 < args.length) {
      chtkPath = args[++i];
    } else if (args[i] == '--swe-lib' && i + 1 < args.length) {
      sweLib = args[++i];
    } else if (args[i] == '--ephe-path' && i + 1 < args.length) {
      ephePath = args[++i];
    } else if (!args[i].startsWith('-')) {
      chtkPath ??= args[i];
    }
  }

  chtkPath ??= '${Platform.environment['HOME']}/charts/mine/josh.chtk';
  sweLib ??= _findSweLibrary();
  ephePath ??= _findEphePath();

  if (!File(chtkPath).existsSync()) {
    stderr.writeln('Chart file not found: $chtkPath');
    exit(1);
  }
  if (sweLib == null || !File(sweLib).existsSync()) {
    stderr.writeln('Swiss Ephemeris library not found. Pass --swe-lib <path>');
    exit(1);
  }

  // 1. Read chart data
  final chart = ChtkFormat.read(chtkPath);
  print('Name:     ${chart.name}');
  print('Date:     ${chart.dateTime}');
  print('Location: ${chart.birthLocation}');
  print('UTC:      ${chart.utcOffsetHours}h');
  print('');

  // 2. Compute Julian Day (UTC)
  final utc = chart.utcDateTime;
  final jdUt = _julianDay(
    utc.year,
    utc.month,
    utc.day,
    utc.hour + utc.minute / 60.0 + utc.second / 3600.0,
  );
  print('JD (UT): $jdUt');

  // 3. Build Location and Options
  final location = Location(
    latitude: chart.birthLocation.latitude,
    longitude: chart.birthLocation.longitude,
  );
  const options = ArrowPresets.aditya;

  // 4. Compute EphSnapshot
  final swe = SwissEph(sweLib);
  final facade = SweFacade(swe, ephePath: ephePath);
  final snapshot = facade.calcAll(jdUt, location, options.sweConfig);
  swe.close();

  // 5. Output reference data
  final output = <String, dynamic>{
    'name': chart.name,
    'date': chart.dateTime.toIso8601String(),
    'utc': utc.toIso8601String(),
    'jd_ut': jdUt,
    'location': {
      'latitude': chart.birthLocation.latitude,
      'longitude': chart.birthLocation.longitude,
      'city': chart.birthLocation.city,
      'country': chart.birthLocation.country,
    },
    'preset': 'ernst',
    'ayanamsa_value': snapshot.ayanamsaValue,
    'bodies_ecliptic': {
      for (final entry in snapshot.bodiesEcliptic.entries)
        entry.key.name: {
          'longitude': entry.value.longitude,
          'latitude': entry.value.latitude,
          'speed': entry.value.speedLongitude,
        },
    },
    'bodies_equatorial': {
      for (final entry in snapshot.bodiesEquatorial.entries)
        entry.key.name: {
          'longitude': entry.value.longitude,
          'latitude': entry.value.latitude,
        },
    },
    'cusps': snapshot.cusps,
    'ascendant': snapshot.ascmc.ascendant,
    'mc': snapshot.ascmc.mc,
  };

  final jsonString = const JsonEncoder.withIndent('  ').convert(output);
  print('');
  print(jsonString);

  // Write to file
  final outPath = 'test/fixtures/reference.json';
  final outDir = Directory('test/fixtures');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  File(outPath).writeAsStringSync(jsonString);
  print('\nWritten to $outPath');
}

/// Search common locations for the Swiss Ephemeris data directory.
String? _findEphePath() {
  final env = Platform.environment['ARROW_EPHE_PATH'];
  if (env != null && Directory(env).existsSync()) return env;

  final home = Platform.environment['HOME'] ?? '';
  final candidates = [
    '$home/nhs/soft/astrology/libaditya/libaditya/ephe',
    '$home/.arrow/ephe',
    '/usr/local/share/swisseph',
  ];
  for (final path in candidates) {
    if (Directory(path).existsSync()) return path;
  }
  return null;
}

/// Search common locations for the Swiss Ephemeris shared library.
String? _findSweLibrary() {
  final home = Platform.environment['HOME'] ?? '';
  final candidates = [
    '/usr/local/lib/libswe.so',
    '/usr/lib/libswe.so',
    '$home/.local/lib/libswe.so',
    '/usr/local/lib/libswe.dylib',
  ];
  for (final path in candidates) {
    if (File(path).existsSync()) return path;
  }
  return null;
}

/// Meeus formula for Julian Day Number.
double _julianDay(int year, int month, int day, double hour) {
  var y = year;
  var m = month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final a = y ~/ 100;
  final b = 2 - a + a ~/ 4;
  final jd =
      (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      day +
      hour / 24.0 +
      b -
      1524.5;
  return jd;
}
