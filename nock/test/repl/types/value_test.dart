import 'package:nock/src/repl/error.dart';
import 'package:nock/src/repl/types/value.dart';
import 'package:test/test.dart';

void main() {
  group('NockString', () {
    test('display returns the value', () {
      expect(NockString('hello').display(), 'hello');
    });

    test('access throws', () {
      expect(
        () => NockString('hello').access('foo'),
        throwsA(isA<NockError>()),
      );
    });

    test('typeName is string', () {
      expect(NockString('x').typeName(), 'string');
    });
  });

  group('NockNumber', () {
    test('display integer value without decimal', () {
      expect(NockNumber(42.0).display(), '42');
    });

    test('display fractional value with decimal', () {
      expect(NockNumber(3.14).display(), '3.14');
    });

    test('access throws', () {
      expect(
        () => NockNumber(1.0).access('foo'),
        throwsA(isA<NockError>()),
      );
    });
  });

  group('NockBool', () {
    test('display true', () {
      expect(NockBool(true).display(), 'true');
    });

    test('display false', () {
      expect(NockBool(false).display(), 'false');
    });
  });

  group('NockList', () {
    test('display joins items with newlines', () {
      final list = NockList([NockString('a'), NockString('b'), NockString('c')]);
      expect(list.display(), 'a\nb\nc');
    });

    test('display empty list', () {
      expect(NockList([]).display(), '');
    });
  });
}
