// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:logging/logging.dart';
import 'package:quiver_core/arrow_internal.dart'
    show CalculationPreset, RequestMapper;

final _log = Logger('Quiver.Embedded');

/// Vayu — the embedded (in-process) facade over the full Arrow pipeline.
///
/// Hides SwissEph lifecycle, Julian Day conversion, and the
/// SWE → Core → Calc pipeline behind three methods:
///
/// - [calculateChart] — full pipeline from DateTime to Chart.
/// - [calculateSnapshot] — stops after SWE, returns raw [EphSnapshot].
/// - [recalculate] — re-derives a [Chart] from an existing snapshot with
///   a different [CalcConfig] (no SWE re-computation).
///
/// Call [dispose] when finished to release the ephemeris handle.
class Vayu {
  final SweFacade _swe;
  bool _disposed = false;

  Vayu._({required SweFacade swe}) : _swe = swe;

  factory Vayu({String? ephePath, String? jplFile}) {
    final facade = SweFacade.create(ephePath: ephePath, jplFile: jplFile);
    _log.info('Vayu created (ephePath=$ephePath, jplFile=$jplFile)');
    return Vayu._(swe: facade);
  }

  /// Full pipeline: DateTime (UTC) → [Chart].
  Chart calculateChart(
    DateTime dateTimeUtc,
    Location location,
    CalculationPreset preset,
  ) {
    assert(dateTimeUtc.isUtc, 'dateTimeUtc must be in UTC');
    _checkNotDisposed();
    final options = RequestMapper.resolvePreset(preset);
    final jd = julianDay(dateTimeUtc);
    final snapshot = _swe.calcAll(jd, location, options.sweConfig);
    return Chart(snapshot, options.calcConfig);
  }

  /// Full pipeline from Julian Day (UT) → [Chart].
  Chart calculateChartFromJd(
    double jd,
    Location location,
    CalculationPreset preset,
  ) {
    _checkNotDisposed();
    final options = RequestMapper.resolvePreset(preset);
    final snapshot = _swe.calcAll(jd, location, options.sweConfig);
    return Chart(snapshot, options.calcConfig);
  }

  /// Partial pipeline: DateTime (UTC) → [EphSnapshot] (no Chart layer).
  EphSnapshot calculateSnapshot(
    DateTime dateTimeUtc,
    Location location,
    CalculationPreset preset,
  ) {
    assert(dateTimeUtc.isUtc, 'dateTimeUtc must be in UTC');
    _checkNotDisposed();
    final options = RequestMapper.resolvePreset(preset);
    final jd = julianDay(dateTimeUtc);
    return _swe.calcAll(jd, location, options.sweConfig);
  }

  /// Re-derive a [Chart] from an existing [snapshot] with a different config.
  ///
  /// No SWE re-computation — purely the Core/Calc layer.
  Chart recalculate(EphSnapshot snapshot, CalcConfig config) {
    _checkNotDisposed();
    return Chart(snapshot, config);
  }

  /// Release the ephemeris handle. Subsequent calls throw [StateError].
  void dispose() {
    if (!_disposed) {
      _swe.dispose();
      _disposed = true;
      _log.info('Vayu disposed');
    }
  }

  void _checkNotDisposed() {
    if (_disposed) throw StateError('Vayu has been disposed');
  }
}
