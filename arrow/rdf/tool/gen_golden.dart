// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Regenerates the ARP-4 serializer golden + its computed-view fixture from a
/// real Swiss Ephemeris run. Run from the `rdf/` package dir:
///
///     dart run tool/gen_golden.dart [path/to/chart.toml]
///
/// Defaults to `~/charts/mine/josh.toml` (the ARP-2 seed). Writes the byte
/// golden (`test/golden/josh-lahiri-wholesign.nq`) and a hermetic fixture
/// (`test/fixtures/josh-lahiri-wholesign.json`) so the golden test needs no
/// ephemeris — the SWE path is exercised here, at generation time.
library;

import 'dart:convert';
import 'dart:io';

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_rdf/arrow_rdf.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:charts_dart/charts_dart.dart';

/// The tracer view — one cell of the standard slate (I11): sidereal · lahiri ·
/// whole-sign. Kept identical to the golden test's reconstruction.
const ViewSpec tracerView = ViewSpec(
  circle: Circle.zodiac,
  signAyanamsa: Ayanamsa.lahiri,
  houseSystem: HouseSystem.wholeSigns,
  provenance: Provenance(
    engine: 'arrow',
    engineVersion: '0.1.0',
    ephemeris: 'swiss-ephemeris',
  ),
);

void main(List<String> args) {
  final home = Platform.environment['HOME'] ?? '';
  final chartPath = args.isNotEmpty ? args[0] : '$home/charts/mine/josh.toml';
  final ephePath = _findEphePath();
  if (ephePath == null) {
    stderr.writeln('no ephe path found; set ARROW_EPHE_PATH');
    exit(1);
  }

  final chart = TomlChartFormat.read(chartPath);
  final facade = SweFacade.create(ephePath: ephePath);
  try {
    final computer = ChartComputer(facade);
    final identity = computer.identity(chart);
    final computed = computer.compute(chart, tracerView);
    final doc = const ChartRdfSerializer().serialize(
      chart: identity,
      view: tracerView,
      computed: computed,
    );

    File('test/golden/josh-lahiri-wholesign.nq').writeAsStringSync(doc.write());

    final fixture = <String, Object?>{
      'identity': _identityJson(identity),
      'view': _viewJson(tracerView),
      'computed': _computedJson(computed),
    };
    File('test/fixtures/josh-lahiri-wholesign.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(fixture)}\n',
    );

    stdout.writeln(
      'wrote golden (${doc.quads.length} quads) + fixture for ${identity.name}',
    );
  } finally {
    facade.dispose();
  }
}

Map<String, Object?> _identityJson(ChartIdentity id) => <String, Object?>{
  'jd': id.jd,
  'lat': id.lat,
  'lon': id.lon,
  'name': id.name,
  'gender': id.gender,
  'rodden': id.rodden,
  'tags': id.tags,
  'placename': id.placename,
  'country': id.country,
  'civilDate': id.civilDate,
  'civilTime': id.civilTime,
  'utcOffset': id.utcOffset,
};

Map<String, Object?> _viewJson(ViewSpec view) => <String, Object?>{
  'circle': view.circle.name,
  'signAyanamsa': view.signAyanamsa.name,
  'houseSystem': view.houseSystem.name,
  'provenance': <String, Object?>{
    'engine': view.provenance.engine,
    'engineVersion': view.provenance.engineVersion,
    'ephemeris': view.provenance.ephemeris,
  },
};

Map<String, Object?> _computedJson(ComputedView computed) => <String, Object?>{
  'lagnaSign': computed.lagnaSign,
  'placements': <Map<String, Object?>>[
    for (final p in computed.placements)
      <String, Object?>{
        'body': p.body.name,
        'longitude': p.longitude,
        'sign': p.sign,
        'house': p.house,
        'retrograde': p.retrograde,
      },
  ],
};

String? _findEphePath() {
  final env = Platform.environment['ARROW_EPHE_PATH'];
  if (env != null && Directory(env).existsSync()) {
    return env;
  }
  final home = Platform.environment['HOME'] ?? '';
  for (final p in <String>[
    '$home/nhs/soft/astrology/libaditya/libaditya/ephe',
    '$home/.arrow/ephe',
    '/usr/local/share/swisseph',
  ]) {
    if (Directory(p).existsSync()) {
      return p;
    }
  }
  return null;
}
