// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Which ephemeris backend SWE uses to compute body positions.
enum EphemerisSource {
  /// Swiss Ephemeris compressed files (.se1). Highest precision, requires ephe path.
  swissEph,

  /// Moshier analytical approximation. No data files, lower precision, wider range limits.
  moshier,

  /// JPL DE binary ephemeris. Requires a JPL file path set via swe_set_jpl_file.
  // TODO: wire up jplFilePath on SweConfig before enabling this in SweFacade.
  jplEph,
}
