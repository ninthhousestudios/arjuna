// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'nakshatra.dart' show nakshatraSpan;

/// Vedanga Jyotisha Ecliptic ayanamsa (libaditya ayanamsa 99,
/// `Ayanamsa.eclipticVedangaJyotisha`).
///
/// Places the beginning of Dhanishta at the winter solstice (270° ecliptic),
/// which puts Ashvini at 360° - (270° + 5 × nakshatra_span) from the
/// vernal equinox. This is a fixed offset of 23°20' added to the tropical
/// ecliptic longitude — it does not vary with time.
///
/// Use this for ad-hoc tropical→sidereal conversion before passing into
/// [calcNakshatra] / [calcYoga]. For full snapshot integration via
/// `Ayanamsa.eclipticVedangaJyotisha`, see `swe_facade.dart` (not yet wired).
///
/// [tropicalLongitude] is the tropical ecliptic longitude of the body.
double vedangaJyotishaEcliptic(double tropicalLongitude) {
  // Ashvini is 5 nakshatras after Dhanishta (nakshatras 22→27, then Ashvini)
  // Dhanishta starts at 270° ecliptic (winter solstice)
  final ashviniOffset = 360 - (270 + 5 * nakshatraSpan);
  return (tropicalLongitude + ashviniOffset) % 360;
}
