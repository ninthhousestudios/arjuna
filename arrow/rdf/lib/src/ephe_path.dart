// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:io';

/// Locate a Swiss Ephemeris data directory for the SWE-touching tools (golden
/// generation, the corpus pipeline). Honours `ARROW_EPHE_PATH`, then falls back
/// to well-known local checkouts. Returns null when none exists, so callers can
/// fail with a clear message rather than an opaque SWE error.
String? findEphePath() {
  final env = Platform.environment['ARROW_EPHE_PATH'];
  if (env != null && Directory(env).existsSync()) {
    return env;
  }
  final home = Platform.environment['HOME'] ?? '';
  for (final p in <String>[
    '$home/nhs/soft/astrology/libaditya/libaditya/ephe',
    '$home/.arrow/ephe',
    '/usr/local/share/swisseph',
  ]) {
    if (Directory(p).existsSync()) {
      return p;
    }
  }
  return null;
}
