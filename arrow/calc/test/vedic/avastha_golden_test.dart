// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:convert';
import 'dart:io';

import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

/// Libaditya dignity code → Arrow [DignityType].
const Map<String, DignityType> _dignityMap = {
  'EX': DignityType.exalted,
  'OH': DignityType.ownSign,
  'MT': DignityType.moolatrikona,
  'F': DignityType.friend,
  'GF': DignityType.greatFriend,
  'N': DignityType.neutral,
  'E': DignityType.enemy,
  'GE': DignityType.greatEnemy,
  'DB': DignityType.debilitated,
};

const List<String> _karakaNames = [
  'Sun',
  'Moon',
  'Mars',
  'Mercury',
  'Jupiter',
  'Venus',
  'Saturn',
];

Body _bodyFor(String libadityaName) =>
    Body.values.firstWhere((b) => b.name == libadityaName.toLowerCase());

Varga _vargaFromFixture(Map<String, dynamic> data) {
  final bodies = data['bodies_ecliptic'] as Map<String, dynamic>;
  final retrograde = data['retrograde'] as Map<String, dynamic>;
  final lagnaSign = data['lagna_sign'] as int;

  final bodyPositions = <Body, BodyPosition>{};
  for (final entry in bodies.entries) {
    final body = _bodyFor(entry.key);
    final pos = entry.value as Map<String, dynamic>;
    final lon = pos['longitude'] as double;
    final isRetro = retrograde[entry.key] == true;
    bodyPositions[body] = BodyPosition(
      longitude: lon,
      latitude: 0.0,
      distance: 1.0,
      speedLongitude: isRetro ? -1.0 : 1.0,
      speedLatitude: 0.0,
      speedDistance: 0.0,
    );
  }

  final cusps = List.generate(12, (i) {
    final sign = ((lagnaSign - 1 + i) % 12) + 1;
    return ((sign + 10) % 12) * 30.0 + 15.0;
  });

  final nakLons = bodyPositions.map((k, v) => MapEntry(k, v.longitude));

  final snapshot = EphSnapshot(
    jdUt: 2460000.5,
    location: const Location(latitude: 0.0, longitude: 0.0),
    sweConfig: const SweConfig(),
    bodiesEcliptic: bodyPositions,
    bodiesEquatorial: bodyPositions,
    phenoData: const {},
    cusps: cusps,
    ascmc: AscMcPoints(
      ascendant: cusps[0],
      mc: cusps[9],
      armc: cusps[9],
      vertex: 190.0,
      equatorialAscendant: cusps[0],
      coAscendantKoch: cusps[0],
      coAscendantMunkasey: cusps[0],
      polarAscendant: 190.0,
    ),
    sunTimes: const SunTimes(sunrise: 2460000.75, sunset: 2460001.25),
    ayanamsaValue: 0.0,
    bodiesNakEclLon: nakLons,
    bodiesNakEquLon: nakLons,
  );

  return Varga(VargaType.rashi, snapshot, const CalcConfig());
}

String _pascal(String name) => name[0].toUpperCase() + name.substring(1);

/// Serialize a [LajjitaadiFactor] to the same JSON shape libaditya emits.
Map<String, dynamic> _factorJson(LajjitaadiFactor f) {
  final m = <String, dynamic>{'source': f.source};
  if (f.planet != null) m['planet'] = _pascal(f.planet!.name);
  if (f.lord != null) m['lord'] = _pascal(f.lord!.name);
  if (f.strength != null) m['strength'] = f.strength;
  if (f.dignity != null) m['dignity'] = f.dignity;
  if (f.detail != null) m['detail'] = f.detail;
  return m;
}

/// Canonical sort key so lists can be compared order-insensitive.
String _factorKey(Map<String, dynamic> f) =>
    '${f['source']}|${f['planet'] ?? ''}|${f['lord'] ?? ''}|'
    '${f['dignity'] ?? ''}|${f['detail'] ?? ''}';

void _expectFactorsMatch(
  List<Map<String, dynamic>> got,
  List<Map<String, dynamic>> expected,
  String reason,
) {
  expect(got.length, expected.length, reason: '$reason length');
  got.sort((a, b) => _factorKey(a).compareTo(_factorKey(b)));
  expected.sort((a, b) => _factorKey(a).compareTo(_factorKey(b)));
  for (var i = 0; i < got.length; i++) {
    final g = got[i];
    final e = expected[i];
    expect(g['source'], e['source'], reason: '$reason[$i].source');
    expect(g['planet'], e['planet'], reason: '$reason[$i].planet');
    expect(g['lord'], e['lord'], reason: '$reason[$i].lord');
    expect(g['dignity'], e['dignity'], reason: '$reason[$i].dignity');
    expect(g['detail'], e['detail'], reason: '$reason[$i].detail');
    // libaditya emits strength as int 60 when constant; as float otherwise.
    if (e['strength'] != null || g['strength'] != null) {
      final gs = (g['strength'] as num?)?.toDouble();
      final es = (e['strength'] as num?)?.toDouble();
      expect(gs, isNotNull, reason: '$reason[$i].strength missing on got');
      expect(es, isNotNull, reason: '$reason[$i].strength missing on exp');
      expect(
        (gs! - es!).abs() < 1e-6,
        isTrue,
        reason: '$reason[$i].strength $gs vs $es',
      );
    }
  }
}

void main() {
  // Allow running from either arrow/ or arrow/calc/.
  final fixturesDir = Directory('test/fixtures/libaditya-golden').existsSync()
      ? Directory('test/fixtures/libaditya-golden')
      : Directory('calc/test/fixtures/libaditya-golden');

  final fixtures =
      fixturesDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (fixtures.isEmpty) {
    throw StateError(
      'No libaditya-golden fixtures found at ${fixturesDir.path}',
    );
  }

  for (final file in fixtures) {
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final slug = data['_chart'] as String;

    group('libaditya golden: $slug', () {
      final bodies = data['bodies_ecliptic'] as Map<String, dynamic>;
      final dignities = data['dignities'] as Map<String, dynamic>;
      final varga = _vargaFromFixture(data);

      for (final name in _karakaNames) {
        final body = _bodyFor(name);
        final pos = bodies[name] as Map<String, dynamic>;
        final lon = pos['longitude'] as double;
        final sign = pos['sign'] as int;
        final inSignDeg = lon % 30;
        final dignity = _dignityMap[dignities[name]]!;

        test('$name baladi', () {
          final expected = (data['baladi'] as Map)[name];
          expect(Baladi.of(sign, inSignDeg).libadityaName, expected);
        });

        test('$name jagradadi', () {
          final expected = (data['jagradadi'] as Map)[name];
          expect(Jagradadi.of(dignity).libadityaName, expected);
        });

        test('$name deeptadi', () {
          final expected = (data['deeptadi'] as Map)[name];
          final got = Deeptadi.of(body, varga);
          expect(got.libadityaName, expected);
        });
      }

      test('lajjitaadi full', () {
        final got = Lajjitaadi.compute(varga);
        final expected = data['lajjitaadi'] as Map<String, dynamic>;

        // Compare set of emitted karakas (both sides skip empty avasthas).
        final gotNames = got.keys.map((b) => _pascal(b.name)).toSet();
        expect(
          gotNames,
          equals(expected.keys.toSet()),
          reason: '$slug lajjitaadi karaka set',
        );

        for (final name in expected.keys) {
          final body = _bodyFor(name);
          final expStates = expected[name] as Map<String, dynamic>;
          final result = got[body]!;
          final gotStateKeys = {
            for (final e in result.avasthas.entries) e.key.libadityaName,
          };
          expect(
            gotStateKeys,
            equals(expStates.keys.toSet()),
            reason: '$slug $name state set',
          );

          for (final stateName in expStates.keys) {
            final state = LajjitaadiState.values.firstWhere(
              (s) => s.libadityaName == stateName,
            );
            final gotFactors = result.avasthas[state]!
                .map(_factorJson)
                .toList();
            final expFactors = (expStates[stateName] as List)
                .cast<Map>()
                .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
                .toList();
            _expectFactorsMatch(
              gotFactors,
              expFactors,
              '$slug $name $stateName',
            );
          }
        }
      });
    });
  }
}
