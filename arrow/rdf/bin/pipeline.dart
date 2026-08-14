// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// ARP-6 corpus pipeline — thin orchestration tying the four ARP slices into a
/// single end-to-end ingest (PRD "corpus pipeline CLI"):
///
///   .chtk collection
///     → OACF TOML         (ARP-3, charts_dart `batch`; folder taxonomy → tags)
///     → N-Quads, 2 views  (ARP-4, this package's serializer + ChartComputer)
///     → vidya load-corpus (ARP-5, bulk-load into instance graphs)
///
/// The standard slate for this slice is two view cells (I11): aditya × whole-sign
/// and tropical × whole-sign, both from one Swiss Ephemeris run per chart.
///
/// Per-chart failures are collected and summarised, never fatal — a corpus of
/// 1,786 charts must not be held hostage by one unparseable file. The whole run
/// is idempotent (I3): OACF TOML canonicalisation, deterministic IRIs, and
/// vidya's content-addressed load all re-run to the same state.
///
/// ```
/// dart run arrow_rdf:pipeline <chtk-dir> [options]
///
/// Options:
///   --corpus=<name>       vidya corpus name         (default: chtk-dir basename)
///   --toml-dir=<path>     OACF TOML output          (default: ~/charts/arp-corpus)
///   --nquads=<path>       aggregated .nq output     (default: <toml-dir>.nq)
///   --ephe=<path>         ephemeris dir             (default: ARROW_EPHE_PATH / known)
///   --vidya=<path>        vidya binary              (default: VIDYA_BIN / 'vidya')
///   --charts-dart=<path>  charts_dart package dir   (default: sibling checkout)
///   --skip-chtk           reuse an existing TOML dir (skip step 1)
///   --no-load             stop after writing the .nq (skip vidya load-corpus)
/// ```
library;

import 'dart:io';

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_rdf/arrow_rdf.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:charts_dart/charts_dart.dart';

/// Version stamped onto every view's provenance and passed to vidya as the
/// pipeline version (I9). Tracks arrow_rdf's package version.
const String _pipelineVersion = '0.1.0';

const Provenance _provenance = Provenance(
  engine: 'arrow',
  engineVersion: _pipelineVersion,
  ephemeris: 'swiss-ephemeris',
);

/// The standard view slate for ARP-6 (two cells of I11), both whole-sign:
/// aditya circle (Ernst Wilhelm's tropical-aditya) and tropical (zodiac circle).
/// Both share one SweConfig, so they cost one ephemeris call per chart.
const List<ViewSpec> _views = <ViewSpec>[
  ViewSpec(
    circle: Circle.aditya,
    signAyanamsa: Ayanamsa.tropical,
    houseSystem: HouseSystem.wholeSigns,
    provenance: _provenance,
  ),
  ViewSpec(
    circle: Circle.zodiac,
    signAyanamsa: Ayanamsa.tropical,
    houseSystem: HouseSystem.wholeSigns,
    provenance: _provenance,
  ),
];

void main(List<String> args) {
  final opts = _Options.parse(args);
  if (opts == null) {
    exit(64); // EX_USAGE
  }

  // ── Step 1: .chtk → OACF TOML (ARP-3, canonical parser in charts_dart) ──
  if (opts.skipChtk) {
    stdout.writeln(
      'Step 1/3: skipping chtk→OACF (--skip-chtk); '
      'reusing ${opts.tomlDir}',
    );
  } else {
    _batchToOacf(opts);
  }

  // ── Step 2: OACF TOML → N-Quads for both views (ARP-4) ──
  final result = _serializeCorpus(opts);
  if (result.charts == 0) {
    stderr.writeln('No charts serialized from ${opts.tomlDir}; aborting.');
    exit(1);
  }

  // ── Step 3: vidya load-corpus (ARP-5) ──
  if (opts.noLoad) {
    stdout.writeln(
      '\nStep 3/3: skipping load (--no-load). '
      'Load it yourself with:\n  ${opts.vidya} load-corpus ${opts.corpus} '
      '${opts.nquads} --source ${opts.source} '
      '--pipeline-version $_pipelineVersion',
    );
  } else {
    _loadCorpus(opts);
  }

  stdout.writeln('\nDone.');
}

/// Shell out to charts_dart's `batch` command — the single home of .chtk parsing
/// (ARP-3) and of the folder-segment→OACF-tag taxonomy, which lives only in that
/// bin. Running it here (rather than re-reading .chtk directly) keeps that logic
/// unduplicated and writes the OACF TOML corpus that is the I4 source of truth.
void _batchToOacf(_Options opts) {
  stdout.writeln('Step 1/3: chtk→OACF  ${opts.chtkDir} → ${opts.tomlDir}');
  final proc = Process.runSync('dart', <String>[
    'run',
    'charts_dart',
    'batch',
    opts.chtkDir,
    opts.tomlDir,
  ], workingDirectory: opts.chartsDartDir);
  stdout.write(proc.stdout);
  if (proc.exitCode != 0) {
    stderr
      ..writeln(proc.stderr)
      ..writeln(
        'charts_dart batch failed (exit ${proc.exitCode}). '
        'Is --charts-dart=${opts.chartsDartDir} a charts_dart checkout?',
      );
    exit(proc.exitCode);
  }
}

/// Read every OACF TOML under the corpus, compute + serialize both views, and
/// aggregate into one canonical .nq. Per-chart failures are collected, never
/// fatal. Aggregating all quads into a single [NQuadsDocument] before [write]
/// gives one globally-sorted, diffable, deterministic file (I3).
_SerializeResult _serializeCorpus(_Options opts) {
  final ephe = opts.ephePath;
  if (ephe == null) {
    stderr.writeln('No ephemeris path found; set ARROW_EPHE_PATH or --ephe=.');
    exit(1);
  }

  final tomls = _tomlFiles(opts.tomlDir);
  stdout.writeln(
    '\nStep 2/3: serialize  ${tomls.length} charts × '
    '${_views.length} views → ${opts.nquads}',
  );
  if (tomls.isEmpty) {
    return const _SerializeResult(0, 0, <String>[]);
  }

  final facade = SweFacade.create(ephePath: ephe);
  const serializer = ChartRdfSerializer();
  const minter = IriMinter();
  final allQuads = <Quad>[];
  final failures = <String>[];
  var charts = 0;

  try {
    final computer = ChartComputer(facade);
    for (final file in tomls) {
      final rel = _relative(file.path, opts.tomlDir);
      try {
        final chart = TomlChartFormat.read(file.path);
        final identity = computer.identity(chart);
        // The identity graph is per-chart, not per-view; each serialize() bundles
        // it with the view. Emit it once (from the first view) and keep only the
        // view graph from the rest, so the corpus .nq carries no duplicate
        // identity quads. (vidya's set semantics would collapse them anyway, but
        // a clean, diffable file is the point of a canonical serializer.)
        final identityGraph = minter.chartGraphIri(
          chart: minter.chartIri(
            jd: identity.jd,
            lat: identity.lat,
            lon: identity.lon,
            name: identity.name,
          ),
        );
        var first = true;
        for (final view in _views) {
          final computed = computer.compute(chart, view);
          final quads = serializer
              .serialize(chart: identity, view: view, computed: computed)
              .quads;
          for (final q in quads) {
            if (first || q.graph != identityGraph) {
              allQuads.add(q);
            }
          }
          first = false;
        }
        charts++;
      } catch (e) {
        failures.add('  $rel: $e');
      }
    }
  } finally {
    facade.dispose();
  }

  File(opts.nquads).writeAsStringSync(NQuadsDocument(allQuads).write());

  stdout.writeln(
    '  $charts charts ok, ${failures.length} failed; '
    '${allQuads.length} quads written.',
  );
  if (failures.isNotEmpty) {
    stdout.writeln('  Failures:');
    for (final f in failures) {
      stdout.writeln(f);
    }
  }
  return _SerializeResult(charts, allQuads.length, failures);
}

/// Invoke `vidya load-corpus`. Requires read-write store access, so the vidya
/// service must be stopped first (it holds the write lock) — we surface vidya's
/// own error rather than trying to stop it.
void _loadCorpus(_Options opts) {
  stdout.writeln(
    '\nStep 3/3: load  vidya load-corpus ${opts.corpus} '
    '${opts.nquads}',
  );
  final proc = Process.runSync(opts.vidya, <String>[
    'load-corpus',
    opts.corpus,
    opts.nquads,
    '--source',
    opts.source,
    '--pipeline-version',
    _pipelineVersion,
  ]);
  stdout.write(proc.stdout);
  if (proc.exitCode != 0) {
    stderr
      ..writeln(proc.stderr)
      ..writeln(
        'vidya load-corpus failed (exit ${proc.exitCode}). '
        'Is the vidya service stopped (it holds the write lock), and is '
        "'${opts.vidya}' on PATH / --vidya correct?",
      );
    exit(proc.exitCode);
  }
}

List<File> _tomlFiles(String dir) {
  final root = Directory(dir);
  if (!root.existsSync()) {
    return const <File>[];
  }
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.toml'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

String _relative(String path, String from) =>
    path.startsWith('$from/') ? path.substring(from.length + 1) : path;

final class _SerializeResult {
  final int charts;
  final int quads;
  final List<String> failures;
  const _SerializeResult(this.charts, this.quads, this.failures);
}

final class _Options {
  final String chtkDir;
  final String corpus;
  final String tomlDir;
  final String nquads;
  final String source;
  final String vidya;
  final String chartsDartDir;
  final String? ephePath;
  final bool skipChtk;
  final bool noLoad;

  const _Options({
    required this.chtkDir,
    required this.corpus,
    required this.tomlDir,
    required this.nquads,
    required this.source,
    required this.vidya,
    required this.chartsDartDir,
    required this.ephePath,
    required this.skipChtk,
    required this.noLoad,
  });

  /// Parse argv, or return null (after printing usage) on a malformed request.
  static _Options? parse(List<String> args) {
    final home = Platform.environment['HOME'] ?? '';
    final positional = <String>[];
    final flags = <String, String>{};
    var skipChtk = false;
    var noLoad = false;

    for (final arg in args) {
      if (arg == '--help' || arg == '-h') {
        _usage(stdout);
        return null;
      } else if (arg == '--skip-chtk') {
        skipChtk = true;
      } else if (arg == '--no-load') {
        noLoad = true;
      } else if (arg.startsWith('--')) {
        final eq = arg.indexOf('=');
        if (eq < 0) {
          stderr.writeln('Unknown or malformed flag: $arg');
          _usage(stderr);
          return null;
        }
        flags[arg.substring(2, eq)] = arg.substring(eq + 1);
      } else {
        positional.add(arg);
      }
    }

    if (positional.length != 1) {
      stderr.writeln(
        'Expected exactly one <chtk-dir>, got ${positional.length}.',
      );
      _usage(stderr);
      return null;
    }

    final chtkDir = positional.single;
    final corpus = flags['corpus'] ?? _basename(chtkDir);
    final tomlDir = flags['toml-dir'] ?? '$home/charts/arp-corpus';
    return _Options(
      chtkDir: chtkDir,
      corpus: corpus,
      tomlDir: tomlDir,
      nquads: flags['nquads'] ?? '$tomlDir.nq',
      source: flags['source'] ?? chtkDir,
      vidya: flags['vidya'] ?? Platform.environment['VIDYA_BIN'] ?? 'vidya',
      chartsDartDir:
          flags['charts-dart'] ?? '$home/nhs/soft/astrology/charts_dart',
      ephePath: flags['ephe'] ?? findEphePath(),
      skipChtk: skipChtk,
      noLoad: noLoad,
    );
  }

  static void _usage(IOSink out) {
    out.writeln(
      'Usage: dart run arrow_rdf:pipeline <chtk-dir> [options]\n'
      '  --corpus=<name>       vidya corpus name    (default: chtk-dir basename)\n'
      '  --toml-dir=<path>     OACF TOML output      (default: ~/charts/arp-corpus)\n'
      '  --nquads=<path>       aggregated .nq output (default: <toml-dir>.nq)\n'
      '  --source=<str>        vidya provenance source (default: chtk-dir)\n'
      '  --ephe=<path>         ephemeris dir         (default: ARROW_EPHE_PATH)\n'
      '  --vidya=<path>        vidya binary          (default: VIDYA_BIN / vidya)\n'
      '  --charts-dart=<path>  charts_dart checkout  (default: sibling repo)\n'
      '  --skip-chtk           reuse existing TOML (skip step 1)\n'
      '  --no-load             stop after writing the .nq',
    );
  }

  static String _basename(String path) {
    final trimmed = path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
    final slash = trimmed.lastIndexOf('/');
    return slash < 0 ? trimmed : trimmed.substring(slash + 1);
  }
}
