// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:quiver_embedded/quiver_embedded.dart';

import '../repl/error.dart';
import '../repl/evaluator.dart';
import '../repl/lexer.dart';
import '../repl/parser.dart';

class ReplCommand extends Command<void> {
  @override
  final name = 'repl';

  @override
  final description = 'Interactive astrology session.';

  @override
  Future<void> run() async {
    await runRepl();
  }
}

Future<void> runRepl() async {
  final vayu = Vayu();
  final session = ReplSession(vayu: vayu);
  final evaluator = Evaluator(session);

  stdout.writeln('nock repl — type help for commands, quit to exit');
  stdout.writeln('');

  try {
    while (true) {
      stdout.write('nock> ');
      final line = stdin.readLineSync();
      if (line == null || line.trim() == 'quit') break;
      if (line.trim().isEmpty) continue;

      try {
        final tokens = Lexer(line).tokenize();
        final stmt = Parser(tokens).parse();
        final result = await evaluator.execute(stmt);
        if (result != null) {
          stdout.writeln(result.display());
          stdout.writeln('');
        }
      } on NockError catch (e) {
        stdout.writeln('  error: ${e.message}');
      }
    }
  } finally {
    vayu.dispose();
  }
}
