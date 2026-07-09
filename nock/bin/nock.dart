// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:args/command_runner.dart';
import 'package:nock/src/commands/chart.dart';
import 'package:nock/src/commands/health.dart';
import 'package:nock/src/commands/repl.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    await runRepl();
    return;
  }

  final runner =
      CommandRunner<void>(
          'nock',
          'CLI astrology app — living API docs for Quiver.',
        )
        ..addCommand(HealthCommand())
        ..addCommand(ChartCommand())
        ..addCommand(ReplCommand());

  await runner.run(args);
}
