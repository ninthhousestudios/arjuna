// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// A reference frame for body position calculation.
///
/// Geocentric (Earth-centered) is always computed and is the default frame
/// for arrow. Barycentric and heliocentric are opt-in via
/// `SweConfig.extraFrames` and produce additional position maps on the
/// resulting [EphSnapshot].
enum ReferencePoint {
  /// Earth-centered frame. Always implicitly computed.
  geocentric(label: 'Geocentric'),

  /// Solar System Barycenter–centered frame. Requires `EphemerisSource.swissEph`
  /// or `.jplEph`; Moshier cannot compute barycentric positions.
  barycentric(label: 'Barycentric'),

  /// Sun-centered frame. The Sun itself is omitted (always at origin).
  heliocentric(label: 'Heliocentric');

  final String label;
  const ReferencePoint({required this.label});
}
