// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

class NockError implements Exception {
  final String message;
  NockError(this.message);

  @override
  String toString() => 'NockError: $message';
}
