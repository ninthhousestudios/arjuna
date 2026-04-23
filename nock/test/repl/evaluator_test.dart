import 'package:nock/src/repl/ast.dart';
import 'package:nock/src/repl/error.dart';
import 'package:nock/src/repl/evaluator.dart';
import 'package:nock/src/repl/lexer.dart';
import 'package:nock/src/repl/parser.dart';
import 'package:nock/src/repl/types/chart.dart';
import 'package:nock/src/repl/types/config.dart';
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

  group('literals', () {
    test('number literal', () async {
      final result = await _runExpr(eval, '42');
      expect(result, isA<NockNumber>());
      expect((result as NockNumber).value, 42.0);
    });

    test('string literal', () async {
      final result = await _runExpr(eval, '"hello"');
      expect(result, isA<NockString>());
      expect((result as NockString).value, 'hello');
    });

    test('negative number', () async {
      final result = await _runExpr(eval, '-86.15');
      expect(result, isA<NockNumber>());
      expect((result as NockNumber).value, -86.15);
    });
  });

  group('variables', () {
    test('assign and retrieve', () async {
      await _run(eval, 'x = 42');
      final result = await _runExpr(eval, 'x');
      expect(result, isA<NockNumber>());
      expect((result as NockNumber).value, 42.0);
    });

    test('assign returns value', () async {
      final result = await _run(eval, 'x = 42');
      expect(result, isA<NockNumber>());
    });

    test('undefined variable throws', () async {
      expect(
        () => _runExpr(eval, 'undefined_var'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('undefined'))),
      );
    });

    test('cannot assign to reserved name', () async {
      expect(
        () => _run(eval, 'chart = 42'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('reserved'))),
      );
    });

    test('cannot assign to quit', () async {
      expect(
        () => _run(eval, 'quit = 42'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('reserved'))),
      );
    });
  });

  group('chart()', () {
    test('creates a chart with date, lat, lon', () async {
      final result =
          await _runExpr(eval, 'chart("1990-06-15 14:30", 39.76, -86.15)');
      expect(result, isA<NockChart>());
    });

    test('chart assigned to variable gets label', () async {
      await _run(eval, 'josh = chart("1990-06-15 14:30", 39.76, -86.15)');
      final josh = session.variables['josh'] as NockChart;
      expect(josh.label, 'josh');
    });

    test('chart with config argument', () async {
      await _run(eval, 'cfg = config(ayanamsa: "lahiri")');
      final result = await _runExpr(
          eval, 'chart("1990-06-15 14:30", 39.76, -86.15, cfg)');
      expect(result, isA<NockChart>());
    });

    test('wrong arg count throws', () async {
      expect(
        () => _runExpr(eval, 'chart("1990-06-15")'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('3 or 4 arguments'))),
      );
    });

    test('wrong arg type throws', () async {
      expect(
        () => _runExpr(eval, 'chart(42, 39.76, -86.15)'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('expected string'))),
      );
    });

    test('invalid date throws', () async {
      expect(
        () => _runExpr(eval, 'chart("not-a-date", 39.76, -86.15)'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('invalid date'))),
      );
    });
  });

  group('property access', () {
    test('chart.sun returns planet', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.sun');
      expect(result.typeName(), 'planet');
    });

    test('chart.sun.sign returns sign', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.sun.sign');
      expect(result.typeName(), 'sign');
    });

    test('chart.sun.nakshatra returns nakshatra', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.sun.nakshatra');
      expect(result.typeName(), 'nakshatra');
    });

    test('chart.sun.retrograde returns bool', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.sun.retrograde');
      expect(result, isA<NockBool>());
      expect((result as NockBool).value, false);
    });

    test('chart.sun.speed returns number', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.sun.speed');
      expect(result, isA<NockNumber>());
    });

    test('chart.sun.house returns number', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.sun.house');
      expect(result, isA<NockNumber>());
    });

    test('chart.asc returns sign', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.asc');
      expect(result.typeName(), 'sign');
    });

    test('chart.planets returns list', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.planets');
      expect(result, isA<NockList>());
      expect((result as NockList).items, isNotEmpty);
    });

    test('chart.karakas returns list', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.karakas');
      expect(result, isA<NockList>());
    });

    test('invalid property throws', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      expect(
        () => _runExpr(eval, 'j.nonexistent'),
        throwsA(isA<NockError>()),
      );
    });
  });

  group('method calls', () {
    test('chart.navamsa() returns varga', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.navamsa()');
      expect(result.typeName(), 'varga');
    });

    test('chart.varga(9) returns navamsa', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.varga(9)');
      expect(result.typeName(), 'varga');
    });

    test('varga planet access works', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.navamsa().sun');
      expect(result.typeName(), 'planet');
    });
  });

  group('config()', () {
    test('default config', () async {
      final result = await _runExpr(eval, 'config()');
      expect(result, isA<NockConfig>());
      final cfg = result as NockConfig;
      expect(cfg.ayanamsa, 'tropical');
      expect(cfg.houses, 'campanus');
    });

    test('config with ayanamsa override', () async {
      final result = await _runExpr(eval, 'config(ayanamsa: "lahiri")');
      expect(result, isA<NockConfig>());
      expect((result as NockConfig).ayanamsa, 'lahiri');
    });

    test('config updates session default', () async {
      await _run(eval, 'config(ayanamsa: "lahiri")');
      expect(session.config.ayanamsa, 'lahiri');
    });

    test('chart uses session config by default', () async {
      await _run(eval, 'config(ayanamsa: "lahiri")');
      final result =
          await _runExpr(eval, 'chart("1990-06-15 14:30", 39.76, -86.15)');
      expect(result, isA<NockChart>());
    });

    test('config property access', () async {
      await _run(eval, 'c = config(ayanamsa: "lahiri")');
      final result = await _runExpr(eval, 'c.ayanamsa');
      expect(result, isA<NockString>());
      expect((result as NockString).value, 'lahiri');
    });

    test('invalid ayanamsa throws', () async {
      expect(
        () => _runExpr(eval, 'config(ayanamsa: "garbage")'),
        throwsA(isA<NockError>()),
      );
    });
  });

  group('now()', () {
    test('creates chart for current time', () async {
      final result = await _runExpr(eval, 'now(lat: 39.76, lon: -86.15)');
      expect(result, isA<NockChart>());
    });

    test('now without args throws', () async {
      expect(
        () => _runExpr(eval, 'now()'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('lat'))),
      );
    });
  });

  group('builtins', () {
    test('help returns string', () async {
      final result = await _runExpr(eval, 'help');
      expect(result, isA<NockString>());
      expect((result as NockString).value, contains('chart'));
    });

    test('vars with no variables', () async {
      final result = await _runExpr(eval, 'vars');
      expect(result, isA<NockString>());
      expect((result as NockString).value, contains('no variables'));
    });

    test('vars after assignment', () async {
      await _run(eval, 'x = 42');
      final result = await _runExpr(eval, 'vars');
      expect(result, isA<NockString>());
      final display = (result as NockString).value;
      expect(display, contains('x'));
      expect(display, contains('number'));
    });
  });

  group('unknown function', () {
    test('throws on unknown function', () async {
      expect(
        () => _runExpr(eval, 'bogus()'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('unknown function'))),
      );
    });
  });

  group('end-to-end chains', () {
    test('chart then planet then property', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.moon.longitude');
      expect(result, isA<NockNumber>());
    });

    test('multiple variables', () async {
      await _run(eval, 'a = chart("1990-06-15 14:30", 39.76, -86.15)');
      await _run(eval, 'b = chart("2000-01-01 12:00", 40.71, -74.00)');
      final sunA = await _runExpr(eval, 'a.sun.longitude');
      final sunB = await _runExpr(eval, 'b.sun.longitude');
      expect((sunA as NockNumber).value,
          isNot(equals((sunB as NockNumber).value)));
    });

    test('reassign variable', () async {
      await _run(eval, 'x = 42');
      await _run(eval, 'x = 99');
      final result = await _runExpr(eval, 'x');
      expect((result as NockNumber).value, 99.0);
    });

    test('chart with explicit config overrides session', () async {
      await _run(eval, 'vedic = config(ayanamsa: "lahiri")');
      await _run(eval, 'config(ayanamsa: "tropical")');
      final result = await _runExpr(
          eval, 'chart("1990-06-15 14:30", 39.76, -86.15, vedic)');
      expect(result, isA<NockChart>());
    });

    test('dignity access on karaka', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final result = await _runExpr(eval, 'j.sun.dignity');
      expect(result.typeName(), 'dignity');
    });

    test('dignity access on node throws', () async {
      await _run(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      expect(
        () => _runExpr(eval, 'j.rahu.dignity'),
        throwsA(isA<NockError>().having(
            (e) => e.message, 'message', contains('not a karaka'))),
      );
    });
  });
}
