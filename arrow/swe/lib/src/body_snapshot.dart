// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'body_position.dart';
import 'pheno_data.dart';

part 'body_snapshot.freezed.dart';

/// Positions-only ephemeris output: what [SweFacade.calcBodies] computes.
///
/// Every field here is present because it was asked for. There are no house
/// cusps, angles, sunrise/sunset, fixed stars, or nakshatra-frame longitudes —
/// not empty ones, *absent* ones. Callers that need those want
/// [SweFacade.calcAll] and [EphSnapshot].
///
/// The body maps are keyed by the [Body] values in [sweConfig]; Ketu appears
/// only when requested and Rahu was also computed.
@freezed
abstract class BodySnapshot with _$BodySnapshot {
  const factory BodySnapshot({
    required double jdUt,
    required Location location,
    required SweConfig sweConfig,
    required Map<Body, BodyPosition> bodiesEcliptic,
    required Map<Body, BodyPosition> bodiesEquatorial,

    /// Empty when `includePheno: false` was passed, and otherwise missing the
    /// nodes (which have no phenomena) plus any body whose pheno call failed.
    required Map<Body, PhenoData> phenoData,

    /// Null when [ReferencePoint.barycentric] was not in
    /// [SweConfig.extraFrames] — distinct from an empty map.
    Map<Body, BodyPosition>? bodiesEclipticBarycentric,

    /// Null when [ReferencePoint.heliocentric] was not in
    /// [SweConfig.extraFrames]. Never contains [Body.sun].
    Map<Body, BodyPosition>? bodiesEclipticHeliocentric,
  }) = _BodySnapshot;
}
