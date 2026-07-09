// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:args/command_runner.dart';

void main(List<String> args) {
  final runner = CommandRunner<void>('bowyer', 'Admin panel CLI for Quiver.');

  runner.run(args);
}
