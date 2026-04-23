import 'dart:io';

import 'package:nock/src/repl/error.dart';
import 'package:nock/src/repl/evaluator.dart';
import 'package:nock/src/repl/lexer.dart';
import 'package:nock/src/repl/parser.dart';
import 'package:nock/src/repl/types/chart.dart';
import 'package:nock/src/repl/types/value.dart';
import 'package:quiver_embedded/quiver_embedded.dart';
import 'package:test/test.dart';

Future<NockValue?> _run(Evaluator eval, String input) async {
  final tokens = Lexer(input).tokenize();
  final stmt = Parser(tokens).parse();
  return eval.execute(stmt);
}

Future<NockValue> _runExpr(Evaluator eval, String input) async {
  final result = await _run(eval, input);
  return result!;
}

String _fixture(String name) {
  final dir = Directory.current.path;
  return '$dir/test/fixtures/$name';
}

void main() {
  late Vayu vayu;
  late ReplSession session;
  late Evaluator eval;

  setUpAll(() {
    vayu = Vayu();
  });

  tearDownAll(() {
    vayu.dispose();
  });

  setUp(() {
    session = ReplSession(vayu: vayu);
    eval = Evaluator(session);
  });

  group('read() .chtk', () {
    test('reads a chtk file and returns a chart', () async {
      final path = _fixture('carl-jung.chtk');
      final result = await _runExpr(eval, 'read("$path")');
      expect(result, isA<NockChart>());
    });

    test('chart from chtk has label from file', () async {
      final path = _fixture('carl-jung.chtk');
      final result = await _runExpr(eval, 'read("$path")');
      final chart = result as NockChart;
      expect(chart.label, contains('Carl Jung'));
    });

    test('chart from chtk has accessible planets', () async {
      final path = _fixture('carl-jung.chtk');
      await _run(eval, 'jung = read("$path")');
      final sun = await _runExpr(eval, 'jung.sun');
      expect(sun.typeName(), 'planet');
    });

    test('chart from chtk supports property chains', () async {
      final path = _fixture('carl-jung.chtk');
      await _run(eval, 'jung = read("$path")');
      final sign = await _runExpr(eval, 'jung.sun.sign');
      expect(sign.typeName(), 'sign');
      expect(sign.display(), isNotEmpty);
    });

    test('chart from chtk supports navamsa', () async {
      final path = _fixture('carl-jung.chtk');
      await _run(eval, 'jung = read("$path")');
      final nav = await _runExpr(eval, 'jung.navamsa()');
      expect(nav.typeName(), 'varga');
    });

    test('assigned chart gets variable name as label', () async {
      final path = _fixture('carl-jung.chtk');
      await _run(eval, 'jung = read("$path")');
      final jung = session.variables['jung'] as NockChart;
      expect(jung.label, 'jung');
    });
  });

  group('read() .toml', () {
    test('reads a toml file and returns a chart', () async {
      final path = _fixture('josh.toml');
      final result = await _runExpr(eval, 'read("$path")');
      expect(result, isA<NockChart>());
    });

    test('chart from toml has label from file', () async {
      final path = _fixture('josh.toml');
      final result = await _runExpr(eval, 'read("$path")');
      final chart = result as NockChart;
      expect(chart.label, 'Josh');
    });

    test('chart from toml has accessible planets', () async {
      final path = _fixture('josh.toml');
      await _run(eval, 'j = read("$path")');
      final sun = await _runExpr(eval, 'j.sun');
      expect(sun.typeName(), 'planet');
    });
  });

  group('read() errors', () {
    test('missing file throws', () async {
      expect(
        () => _runExpr(eval, 'read("nonexistent.chtk")'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('file not found'))),
      );
    });

    test('unsupported extension throws', () async {
      final path = _fixture('carl-jung.chtk');
      // Create a temp file with wrong extension
      final tmpPath = '${path}.xyz';
      File(path).copySync(tmpPath);
      addTearDown(() => File(tmpPath).deleteSync());
      expect(
        () => _runExpr(eval, 'read("$tmpPath")'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('unsupported format'))),
      );
    });

    test('wrong arg count throws', () async {
      expect(
        () => _runExpr(eval, 'read()'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('1 argument'))),
      );
    });

    test('wrong arg type throws', () async {
      expect(
        () => _runExpr(eval, 'read(42)'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('expected string'))),
      );
    });
  });

  group('read() with config', () {
    test('read uses session config', () async {
      final path = _fixture('carl-jung.chtk');
      await _run(eval, 'config(ayanamsa: "lahiri")');
      final result = await _runExpr(eval, 'read("$path")');
      expect(result, isA<NockChart>());
    });
  });
}
