// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Box-drawing utilities for terminal output.
library;

String topBorder(int width) => '┌${'─' * (width - 2)}┐';

String bottomBorder(int width) => '└${'─' * (width - 2)}┘';

String midBorder(int width) => '├${'─' * (width - 2)}┤';

String row(String content, int width) {
  // Width includes the two border characters.
  final inner = width - 4; // "│ " + content + " │"
  final padded = content.length > inner
      ? content.substring(0, inner)
      : content.padRight(inner);
  return '│ $padded │';
}
