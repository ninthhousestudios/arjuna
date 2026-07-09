// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Which zodiac framework to use for sign assignment.
enum ZodiacSystem {
  /// Standard 12-sign tropical zodiac (equinox-anchored).
  tropical12,

  /// Standard 12-sign sidereal zodiac (ayanamsa-shifted).
  sidereal12,

  /// 13-constellation true-sidereal zodiac using actual boundary stars.
  trueSidereal13,
}
