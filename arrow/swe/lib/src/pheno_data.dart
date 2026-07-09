// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pheno_data.freezed.dart';
part 'pheno_data.g.dart';

/// Solar-phase data from `swe_pheno_ut()`. Mirrors swisseph's `PhenoResult`.
///
/// Sparse on [EphSnapshot.phenoData] — lunar nodes (Rahu/Ketu) are
/// mathematical points and have no pheno output; they are omitted from
/// the map rather than zero-filled.
@freezed
abstract class PhenoData with _$PhenoData {
  const factory PhenoData({
    required double phaseAngle,
    required double phase,
    required double elongation,
    required double apparentDiameter,
    required double apparentMagnitude,
  }) = _PhenoData;

  factory PhenoData.fromJson(Map<String, dynamic> json) =>
      _$PhenoDataFromJson(json);
}
