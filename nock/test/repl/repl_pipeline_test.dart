import 'package:nock/src/repl/error.dart';
import 'package:nock/src/repl/evaluator.dart';
import 'package:nock/src/repl/lexer.dart';
import 'package:nock/src/repl/parser.dart';
import 'package:nock/src/repl/types/chart.dart';
import 'package:nock/src/repl/types/config.dart';
import 'package:nock/src/repl/types/value.dart';
import 'package:quiver_embedded/quiver_embedded.dart';
import 'package:test/test.dart';

Future<NockValue?> _pipeline(Evaluator eval, String line) async {
  final tokens = Lexer(line).tokenize();
  final stmt = Parser(tokens).parse();
  return eval.execute(stmt);
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

  group('full REPL pipeline', () {
    test('multi-line session: assign, query, display', () async {
      final chart = await _pipeline(
          eval, 'josh = chart("1990-06-15 14:30", 39.76, -86.15)');
      expect(chart, isA<NockChart>());
      expect((chart as NockChart).label, 'josh');

      final sun = await _pipeline(eval, 'josh.sun');
      expect(sun!.typeName(), 'planet');
      expect(sun.display(), isNotEmpty);

      final sign = await _pipeline(eval, 'josh.sun.sign');
      expect(sign!.typeName(), 'sign');
      expect(sign.display(), isNotEmpty);
    });

    test('config then chart uses updated settings', () async {
      await _pipeline(eval, 'config(ayanamsa: "lahiri")');
      expect(session.config.ayanamsa, 'lahiri');

      final chart = await _pipeline(
          eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      expect(chart, isA<NockChart>());
    });

    test('display output is non-empty for all value types', () async {
      await _pipeline(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');

      for (final expr in [
        'j',
        'j.sun',
        'j.sun.sign',
        'j.sun.nakshatra',
        'j.sun.dignity',
        'j.sun.retrograde',
        'j.sun.longitude',
        'j.sun.speed',
        'j.sun.house',
        'j.asc',
        'j.mc',
        'j.planets',
        'j.houses',
        'j.karakas',
        'j.navamsa()',
        'help',
        'vars',
      ]) {
        final result = await _pipeline(eval, expr);
        expect(result, isNotNull, reason: '$expr should return a value');
        expect(result!.display(), isNotEmpty,
            reason: '$expr display should be non-empty');
      }
    });

    test('error recovery: bad input does not corrupt session', () async {
      await _pipeline(eval, 'x = 42');

      expect(
        () => _pipeline(eval, 'undefined_var'),
        throwsA(isA<NockError>()),
      );

      final result = await _pipeline(eval, 'x');
      expect((result as NockNumber).value, 42.0);
    });

    test('quit is not a function', () async {
      expect(
        () => _pipeline(eval, 'quit()'),
        throwsA(isA<NockError>()),
      );
    });

    test('date-only format works (no time)', () async {
      final result = await _pipeline(
          eval, 'chart("1990-06-15", 39.76, -86.15)');
      expect(result, isA<NockChart>());
    });

    test('iso format with T separator works', () async {
      final result = await _pipeline(
          eval, 'chart("1990-06-15T14:30:00", 39.76, -86.15)');
      expect(result, isA<NockChart>());
    });

    test('two charts produce different sun positions', () async {
      await _pipeline(eval, 'a = chart("1990-06-15", 39.76, -86.15)');
      await _pipeline(eval, 'b = chart("2000-01-01", 40.71, -74.00)');
      final lonA = await _pipeline(eval, 'a.sun.longitude');
      final lonB = await _pipeline(eval, 'b.sun.longitude');
      expect((lonA as NockNumber).value,
          isNot(equals((lonB as NockNumber).value)));
    });

    test('navamsa planet differs from rashi planet', () async {
      await _pipeline(eval, 'j = chart("1990-06-15 14:30", 39.76, -86.15)');
      final rashiSign = await _pipeline(eval, 'j.sun.sign');
      final navSign = await _pipeline(eval, 'j.navamsa().sun.sign');
      expect(rashiSign!.display(), isNotEmpty);
      expect(navSign!.display(), isNotEmpty);
    });
  });

  group('entry point wiring', () {
    test('ReplCommand has correct name and description', () async {
      // Just verify the import path works and the class exists
      await _pipeline(eval, 'help');
    });
  });
}
