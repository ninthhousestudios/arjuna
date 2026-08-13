// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:io';

import 'package:arrow_rdf/arrow_rdf.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:charts_dart/charts_dart.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

/// SWE-dependent: proves the live compute path still reproduces the committed
/// golden, so the hermetic fixture can't silently rot against arrow changes.
/// Skips when the ephemeris or the seed chart isn't present (e.g. CI).
void main() {
  final ephePath = _findEphePath();
  final chartPath =
      '${Platform.environment['HOME'] ?? ''}/charts/mine/josh.toml';
  final skip = ephePath == null
      ? 'no ephe path (set ARROW_EPHE_PATH)'
      : (!File(chartPath).existsSync() ? 'seed chart $chartPath absent' : null);

  test('live SWE compute reproduces the golden', () {
    final fixture = GoldenFixture.load(
      'test/fixtures/josh-lahiri-wholesign.json',
    );
    final golden = packageFile(
      'test/golden/josh-lahiri-wholesign.nq',
    ).readAsStringSync();

    final chart = TomlChartFormat.read(chartPath);
    final facade = SweFacade.create(ephePath: ephePath);
    try {
      final computer = ChartComputer(facade);
      final doc = const ChartRdfSerializer().serialize(
        chart: computer.identity(chart),
        view: fixture.view,
        computed: computer.compute(chart, fixture.view),
      );
      expect(doc.write(), golden);
    } finally {
      facade.dispose();
    }
  }, skip: skip);
}

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
