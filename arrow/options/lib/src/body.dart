// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Celestial bodies supported by Arrow.
enum Body {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
  uranus,
  neptune,
  pluto,
  chiron,
  rahu,
  ketu;

  /// The 7 embodied planets (Sun through Saturn) — the karakas.
  static const karakas = [sun, moon, mars, mercury, jupiter, venus, saturn];

  /// The 9 Vedic grahas (7 karakas + nodes).
  static const grahas = [
    sun,
    moon,
    mars,
    mercury,
    jupiter,
    venus,
    saturn,
    rahu,
    ketu,
  ];
}
