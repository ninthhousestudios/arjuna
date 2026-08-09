// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:io';

import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:charts_dart/charts_dart.dart';

/// For each of the 84 beings, find one chart in which the being is *the
/// healthiest* being and one in which it is *the unhealthiest*, using the
/// fewest charts overall.
///
/// A being is only as healthy as the planet activating it. Each embodied
/// planet, at its own [Circle.aditya] sign, activates:
///
///   - its Aditya (always),
///   - its Naga (when it sits in a Moon hora),
///   - its Trimsamsa being (one of Gandharva/Rakshasa/Rishi/Yaksha/Apsara,
///     picked by degree).
///
/// So the beings activated by a chart's **rank-1** planet(s) are "the
/// healthiest" in that chart, and those activated by its **last-rank**
/// planet(s) are "the unhealthiest". A single chart can therefore witness
/// several beings at once. This tool ranks every chart, then greedily
/// set-covers the 168 slots (84 beings × {healthiest, unhealthiest}) with the
/// fewest charts.
///
/// Charts are drawn from the given corpora **in priority order**: a later
/// corpus is loaded only if the ones before it cannot witness every slot.
///
/// Usage: dart run tool/bin/find_being_extremes.dart [options]
///   --charts `dir`     A corpus directory (repeatable; priority = order
///                      given). Default: ~/charts/database, ~/charts/forumdb,
///                      ~/charts/mine.
///   --out `path`       Markdown output (default: docs/being-extremes.md).
///   --ephe-path `dir`  Swiss Ephemeris data directory. Defaults to
///                      $ARROW_EPHE_PATH, then libaditya/ephe, then unset
///                      (SWE falls back to Moshier).
///   --trimsamsa-only   Restrict the being universe to the 60 Trimsamsa
///                      beings (the 5 Trimsamsa types × 12 signs), ignoring
///                      the Aditya and Naga a planet also carries. The
///                      Trimsamsa being is the focus; the Aditya/Naga follow
///                      from its sign, so covering the 60 needs fewer charts.
void main(List<String> args) {
  final corpora = <String>[];
  var outPath = 'docs/being-extremes.md';
  String? ephePath;
  var trimsamsaOnly = false;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--charts' && i + 1 < args.length) {
      corpora.add(args[++i]);
    } else if (args[i] == '--out' && i + 1 < args.length) {
      outPath = args[++i];
    } else if (args[i] == '--ephe-path' && i + 1 < args.length) {
      ephePath = args[++i];
    } else if (args[i] == '--trimsamsa-only') {
      trimsamsaOnly = true;
    }
  }
  if (corpora.isEmpty) {
    final home = Platform.environment['HOME'] ?? '';
    corpora.addAll([
      '$home/charts/database',
      '$home/charts/forumdb',
      '$home/charts/mine',
    ]);
  }
  ephePath ??= _findEphePath();

  const options = ArrowPresets.aditya;
  final facade = SweFacade.create(ephePath: ephePath);

  // Every chart that witnessed at least one being at an extreme, keyed by a
  // stable id. A chart earns its place in the pool only if it covers a slot.
  final charts = <_ChartWitness>[];
  // Which corpora we actually had to consult.
  final corporaUsed = <String>[];

  var chartsRead = 0;
  var chartsFailed = 0;

  // The universe still needing a witness. Start with every slot (168, or 120
  // in --trimsamsa-only mode).
  final needHealthy = _allBeings(trimsamsaOnly).toSet();
  final needUnhealthy = _allBeings(trimsamsaOnly).toSet();

  for (final corpusDir in corpora) {
    if (needHealthy.isEmpty && needUnhealthy.isEmpty) break;

    final dir = Directory(corpusDir);
    if (!dir.existsSync()) {
      stderr.writeln('Corpus not found, skipping: $corpusDir');
      continue;
    }
    corporaUsed.add(corpusDir);
    final label = _corpusLabel(corpusDir);
    stderr.writeln('Scanning $corpusDir ...');

    final files =
        dir
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) => ChartIO.supportedExtensions.any(
                (ext) => f.path.toLowerCase().endsWith(ext),
              ),
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      chartsRead++;
      if (chartsRead % 200 == 0) {
        stderr.writeln('  ... $chartsRead charts read');
      }
      final witness = _rankChart(file, label, facade, options, trimsamsaOnly);
      if (witness == null) {
        chartsFailed++;
        continue;
      }
      charts.add(witness);
      needHealthy.removeAll(witness.healthiest);
      needUnhealthy.removeAll(witness.unhealthiest);
    }

    stderr.writeln(
      '  after $corpusDir: healthiest slots left=${needHealthy.length}, '
      'unhealthiest slots left=${needUnhealthy.length}',
    );
  }

  facade.dispose();

  final cover = _greedyCover(charts);
  final report = _writeReport(
    corporaUsed: corporaUsed,
    ephePath: ephePath,
    chartsRead: chartsRead,
    chartsFailed: chartsFailed,
    charts: charts,
    cover: cover,
    unwitnessedHealthy: needHealthy,
    unwitnessedUnhealthy: needUnhealthy,
    trimsamsaOnly: trimsamsaOnly,
  );

  File(outPath)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(report);
  final slots = _allBeings(trimsamsaOnly).length * 2;
  stderr.writeln(
    '\nWritten to $outPath — ${cover.selected.length} charts cover '
    '${slots - needHealthy.length - needUnhealthy.length} of $slots slots.',
  );
}

/// Rank one chart and record which beings it witnesses at each extreme.
/// Returns null if the file cannot be read or calculated.
_ChartWitness? _rankChart(
  File file,
  String corpus,
  SweFacade facade,
  ArrowOptions options,
  bool trimsamsaOnly,
) {
  try {
    final data = ChartIO.read(file.path);
    final utc = _utcDateTime(data);
    final snapshot = facade.calcAll(
      julianDay(utc),
      Location(
        latitude: data.birthLocation.latitude,
        longitude: data.birthLocation.longitude,
      ),
      options.sweConfig,
    );
    final chart = Chart(snapshot, options.calcConfig);
    final ranked = PlanetHealth.rank(chart.rashi);
    if (ranked.isEmpty) return null;

    final topRank = ranked.first.rank;
    final bottomRank = ranked.last.rank;

    final healthiest = <BeingKey, double>{};
    final unhealthiest = <BeingKey, double>{};
    for (final r in ranked) {
      if (r.rank == topRank) {
        for (final b in _activated(r, trimsamsaOnly)) {
          // Keep the strongest score seen for this being in this chart.
          healthiest[b] = _max(healthiest[b], r.virupas);
        }
      }
      if (r.rank == bottomRank) {
        for (final b in _activated(r, trimsamsaOnly)) {
          unhealthiest[b] = _min(unhealthiest[b], r.virupas);
        }
      }
    }

    return _ChartWitness(
      name: data.name,
      corpus: corpus,
      path: file.path,
      utc: utc,
      localTime: data.dateTime,
      offsetHours: data.utcOffsetHours + data.dstOffsetHours,
      location: data.birthLocation,
      topScore: ranked.first.virupas,
      bottomScore: ranked.last.virupas,
      healthiestScores: healthiest,
      unhealthiestScores: unhealthiest,
    );
  } catch (e) {
    stderr.writeln('  ! skipped ${file.path}: $e');
    return null;
  }
}

/// The distinct beings a ranked planet activates: its Trimsamsa being, its
/// Aditya, and — in a Moon hora — its Naga (carried by [BeingHealth.horaBeing]).
///
/// In [trimsamsaOnly] mode only the Trimsamsa being counts; the Aditya and Naga
/// share the planet's sign and merely follow from it.
Set<BeingKey> _activated(BeingHealth r, bool trimsamsaOnly) => {
  BeingKey(r.trimsamsaBeing.signNumber, r.trimsamsaBeing.type),
  if (!trimsamsaOnly) ...[
    BeingKey(r.aditya.signNumber, r.aditya.type),
    BeingKey(r.horaBeing.signNumber, r.horaBeing.type),
  ],
};

double _max(double? a, double b) => a == null ? b : (b > a ? b : a);
double _min(double? a, double b) => a == null ? b : (b < a ? b : a);

// ---------------------------------------------------------------------------
// Greedy set cover
// ---------------------------------------------------------------------------

class _Cover {
  final List<_ChartWitness> selected;

  /// Being → the selected chart chosen to witness it, healthiest side.
  final Map<BeingKey, _ChartWitness> healthyWitness;
  final Map<BeingKey, _ChartWitness> unhealthyWitness;

  const _Cover(this.selected, this.healthyWitness, this.unhealthyWitness);
}

/// A slot in the cover universe: a being at one extreme.
typedef _Slot = (BeingKey being, bool healthiest);

/// Greedily pick the fewest charts that witness every reachable slot. Each
/// round takes the chart covering the most still-uncovered slots; ties break
/// toward the earlier corpus, then the more extreme score.
_Cover _greedyCover(List<_ChartWitness> charts) {
  // Build the reachable universe from what the pool can actually witness.
  final uncovered = <_Slot>{};
  for (final c in charts) {
    for (final b in c.healthiestScores.keys) {
      uncovered.add((b, true));
    }
    for (final b in c.unhealthiestScores.keys) {
      uncovered.add((b, false));
    }
  }

  final remaining = List<_ChartWitness>.from(charts);
  final selected = <_ChartWitness>[];

  while (uncovered.isNotEmpty) {
    _ChartWitness? best;
    var bestNew = 0;
    for (final c in remaining) {
      var n = 0;
      for (final b in c.healthiestScores.keys) {
        if (uncovered.contains((b, true))) n++;
      }
      for (final b in c.unhealthiestScores.keys) {
        if (uncovered.contains((b, false))) n++;
      }
      if (n > bestNew) {
        bestNew = n;
        best = c;
      }
    }
    if (best == null || bestNew == 0) break; // nothing left is coverable
    selected.add(best);
    remaining.remove(best);
    uncovered.removeWhere(
      (s) => s.$2
          ? best!.healthiestScores.containsKey(s.$1)
          : best!.unhealthiestScores.containsKey(s.$1),
    );
  }

  // Assign each being the most extreme witness among the selected charts.
  final healthyWitness = <BeingKey, _ChartWitness>{};
  final unhealthyWitness = <BeingKey, _ChartWitness>{};
  for (final c in selected) {
    c.healthiestScores.forEach((b, score) {
      final cur = healthyWitness[b];
      if (cur == null || score > cur.healthiestScores[b]!) {
        healthyWitness[b] = c;
      }
    });
    c.unhealthiestScores.forEach((b, score) {
      final cur = unhealthyWitness[b];
      if (cur == null || score < cur.unhealthiestScores[b]!) {
        unhealthyWitness[b] = c;
      }
    });
  }

  return _Cover(selected, healthyWitness, unhealthyWitness);
}

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------

String _writeReport({
  required List<String> corporaUsed,
  required String? ephePath,
  required int chartsRead,
  required int chartsFailed,
  required List<_ChartWitness> charts,
  required _Cover cover,
  required Set<BeingKey> unwitnessedHealthy,
  required Set<BeingKey> unwitnessedUnhealthy,
  required bool trimsamsaOnly,
}) {
  final all = _allBeings(trimsamsaOnly);
  final out = StringBuffer()
    ..writeln('# Being health extremes — witness charts')
    ..writeln()
    ..writeln(
      'Generated by `tool/bin/find_being_extremes.dart`'
      '${trimsamsaOnly ? ' --trimsamsa-only' : ''}. For each of the '
      '${all.length} ${trimsamsaOnly ? 'Trimsamsa ' : ''}beings, one chart in '
      'which it is *the healthiest* being and one in which it is *the '
      'unhealthiest*, chosen to use the fewest charts overall (greedy set '
      'cover). A being is as healthy as the planet activating it; the '
      '${trimsamsaOnly ? 'Trimsamsa being' : 'beings'} of a chart\'s rank-1 '
      'planet ${trimsamsaOnly ? 'is' : 'are'} its healthiest, '
      '${trimsamsaOnly ? 'that' : 'those'} of its last-rank planet its '
      'unhealthiest.'
      '${trimsamsaOnly ? ' The Aditya and Naga each planet also carries follow '
                'from its sign and are omitted here.' : ''}',
    )
    ..writeln()
    ..writeln(
      'Chart settings: ${_presetLabel()}. Ephemeris: '
      '${ephePath ?? 'Moshier (built-in)'}.',
    )
    ..writeln()
    ..writeln('Corpora consulted, in priority order:')
    ..writeln();
  for (final c in corporaUsed) {
    out.writeln('- `$c`');
  }
  out
    ..writeln()
    ..writeln(
      '$chartsRead charts read, $chartsFailed unreadable/skipped. '
      '**${cover.selected.length} charts** witness all reachable slots.',
    )
    ..writeln();

  final coveredH = all.where((b) => cover.healthyWitness.containsKey(b)).length;
  final coveredU = all
      .where((b) => cover.unhealthyWitness.containsKey(b))
      .length;
  out
    ..writeln('## Coverage')
    ..writeln()
    ..writeln('| Extreme | Beings witnessed | of ${all.length} |')
    ..writeln('|---------|-----------------:|----:|')
    ..writeln('| Healthiest | $coveredH | ${all.length} |')
    ..writeln('| Unhealthiest | $coveredU | ${all.length} |')
    ..writeln();

  if (unwitnessedHealthy.isNotEmpty || unwitnessedUnhealthy.isNotEmpty) {
    out
      ..writeln('### Never witnessed (no chart in any corpus reached these)')
      ..writeln();
    if (unwitnessedHealthy.isNotEmpty) {
      out
        ..writeln(
          '- **As healthiest:** '
          '${unwitnessedHealthy.map(_beingLabel).join(', ')}',
        )
        ..writeln();
    }
    if (unwitnessedUnhealthy.isNotEmpty) {
      out
        ..writeln(
          '- **As unhealthiest:** '
          '${unwitnessedUnhealthy.map(_beingLabel).join(', ')}',
        )
        ..writeln();
    }
  }

  // The selected charts.
  out
    ..writeln('## The chart set')
    ..writeln()
    ..writeln(
      'The ${cover.selected.length} charts below, together, witness every '
      'reachable being at both extremes.',
    )
    ..writeln()
    ..writeln('| # | Chart | Corpus | Date (UT) | Place |')
    ..writeln('|---|-------|--------|-----------|-------|');
  for (var i = 0; i < cover.selected.length; i++) {
    final c = cover.selected[i];
    out.writeln(
      '| ${i + 1} | ${c.name} | ${c.corpus} | ${_fmt(c.utc)} '
      '| ${_place(c.location)} |',
    );
  }

  // Per-being table.
  out
    ..writeln()
    ..writeln('## Per-being witnesses')
    ..writeln()
    ..writeln(
      'Score is the virupa health of the activating planet in the witness '
      'chart (higher = healthier).',
    )
    ..writeln()
    ..writeln(
      '| Being | Sign | Type | Healthiest in | Score | '
      'Unhealthiest in | Score |',
    )
    ..writeln(
      '|-------|-----:|------|---------------|------:|-----------------|------:|',
    );
  for (final b in all) {
    final h = cover.healthyWitness[b];
    final u = cover.unhealthyWitness[b];
    out.writeln(
      '| ${_beingName(b)} | ${b.sign} | ${_title(b.type.name)} '
      '| ${h?.name ?? '—'} '
      '| ${h == null ? '—' : _v(h.healthiestScores[b]!)} '
      '| ${u?.name ?? '—'} '
      '| ${u == null ? '—' : _v(u.unhealthiestScores[b]!)} |',
    );
  }
  out.writeln();

  return out.toString();
}

// ---------------------------------------------------------------------------
// Being universe
// ---------------------------------------------------------------------------

/// A being identified by its sign (1..12) and type — the natural key for the
/// 84-being table, since two beings can share a name across signs.
class BeingKey {
  final int sign;
  final BeingType type;
  const BeingKey(this.sign, this.type);

  @override
  bool operator ==(Object other) =>
      other is BeingKey && sign == other.sign && type == other.type;

  @override
  int get hashCode => Object.hash(sign, type);
}

/// The five Trimsamsa being types, in [BeingType] order — the focus of the
/// ranking. The remaining two (Aditya, Naga) are a planet's sign followers.
const _trimsamsaTypes = [
  BeingType.gandharva,
  BeingType.rakshasa,
  BeingType.rishi,
  BeingType.yaksha,
  BeingType.apsara,
];

/// The being universe: all 84 (12 signs × 7 types), or the 60 Trimsamsa beings
/// (12 signs × 5 types) when [trimsamsaOnly].
List<BeingKey> _allBeings(bool trimsamsaOnly) => [
  for (var sign = 1; sign <= 12; sign++)
    for (final type in trimsamsaOnly ? _trimsamsaTypes : BeingType.values)
      BeingKey(sign, type),
];

String _beingName(BeingKey b) => BeingData.forSign(b.sign, b.type).name;
String _beingLabel(BeingKey b) =>
    '${_beingName(b)} (${_title(b.type.name)} sign ${b.sign})';

// ---------------------------------------------------------------------------
// Chart witness record
// ---------------------------------------------------------------------------

class _ChartWitness {
  final String name;
  final String corpus;
  final String path;
  final DateTime utc;
  final DateTime localTime;
  final double offsetHours;
  final GeoLocation location;
  final double topScore;
  final double bottomScore;

  /// Beings this chart witnesses as *healthiest*, with the activating planet's
  /// virupa score.
  final Map<BeingKey, double> healthiestScores;

  /// Beings this chart witnesses as *unhealthiest*, with the score.
  final Map<BeingKey, double> unhealthiestScores;

  const _ChartWitness({
    required this.name,
    required this.corpus,
    required this.path,
    required this.utc,
    required this.localTime,
    required this.offsetHours,
    required this.location,
    required this.topScore,
    required this.bottomScore,
    required this.healthiestScores,
    required this.unhealthiestScores,
  });

  Set<BeingKey> get healthiest => healthiestScores.keys.toSet();
  Set<BeingKey> get unhealthiest => unhealthiestScores.keys.toSet();
}

// ---------------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------------

/// [ChartData.utcDateTime] returns a local-kind [DateTime]; [julianDay] would
/// shift it again by the machine timezone. Rebuild the same instant as UTC.
DateTime _utcDateTime(ChartData data) {
  final local = data.dateTime;
  return DateTime.utc(
    local.year,
    local.month,
    local.day,
    local.hour,
    local.minute,
    local.second,
  ).subtract(
    Duration(
      minutes: ((data.utcOffsetHours + data.dstOffsetHours) * 60).round(),
    ),
  );
}

String _corpusLabel(String dir) {
  final parts = dir.split('/');
  return parts.isEmpty ? dir : parts.last;
}

String _place(GeoLocation loc) {
  final city = loc.city.isEmpty ? '' : loc.city;
  final country = loc.country.isEmpty ? '' : ', ${loc.country}';
  final coords =
      '(${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)})';
  return '$city$country $coords'.trim();
}

String _presetLabel() {
  const c = ArrowPresets.aditya;
  return 'circle=${c.calcConfig.circle.name}, '
      'sign ayanamsa=${c.sweConfig.signAyanamsa.name}, '
      'houses=${c.sweConfig.houseSystem.name}';
}

String _v(double value) => value.toStringAsFixed(1);
String _title(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _fmt(DateTime dt) =>
    '${dt.year}-${_p2(dt.month)}-${_p2(dt.day)} '
    '${_p2(dt.hour)}:${_p2(dt.minute)}';

String _p2(int n) => n.toString().padLeft(2, '0');

String? _findEphePath() {
  final env = Platform.environment['ARROW_EPHE_PATH'];
  if (env != null && Directory(env).existsSync()) return env;
  final home = Platform.environment['HOME'] ?? '';
  for (final path in [
    '$home/nhs/soft/astrology/libaditya/libaditya/ephe',
    '$home/.arrow/ephe',
    '/usr/local/share/swisseph',
  ]) {
    if (Directory(path).existsSync()) return path;
  }
  return null;
}
