// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// The OACF Chart identity the serializer emits — the neutral form of a
/// charts_dart `ChartData`, so the pure serializer needn't depend on
/// charts_dart (the adapter lives in ChartComputer). Optional OACF fields are
/// nullable and are simply not emitted when absent (round-trip fidelity §7).
///
/// [jd], [lat], [lon] are the natural key (I1); [name] joins the key for
/// minting because same-moment different-subject charts are legal.
final class ChartIdentity {
  final double jd;
  final double lat;
  final double lon;
  final String name;

  final String? gender;
  final String? rodden;
  final List<String> tags;
  final String? placename;
  final String? country;
  final String? civilDate;
  final String? civilTime;
  final double? utcOffset;

  const ChartIdentity({
    required this.jd,
    required this.lat,
    required this.lon,
    required this.name,
    this.gender,
    this.rodden,
    this.tags = const <String>[],
    this.placename,
    this.country,
    this.civilDate,
    this.civilTime,
    this.utcOffset,
  });
}
