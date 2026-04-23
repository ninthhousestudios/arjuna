import 'package:test/test.dart';
import 'package:nock/src/repl/lexer.dart';
import 'package:nock/src/repl/parser.dart';
import 'package:nock/src/repl/ast.dart';
import 'package:nock/src/repl/error.dart';

Stmt parseInput(String input) {
  final tokens = Lexer(input).tokenize();
  return Parser(tokens).parse();
}

void main() {
  group('Parser', () {
    test('parses function call with positional args', () {
      final stmt = parseInput('chart("1990-06-15", 39.76, -86.15)');
      final expr = (stmt as ExprStmt).expr as Call;
      expect(expr.name, 'chart');
      expect(expr.positional.length, 3);
      expect((expr.positional[0] as StringLit).value, '1990-06-15');
      expect((expr.positional[1] as NumberLit).value, 39.76);
      expect((expr.positional[2] as NumberLit).value, -86.15);
      expect(expr.named, isEmpty);
    });

    test('parses assignment', () {
      final stmt = parseInput('josh = chart("1990-06-15", 39.76, -86.15)');
      final assign = stmt as Assignment;
      expect(assign.name, 'josh');
      final call = assign.value as Call;
      expect(call.name, 'chart');
      expect(call.positional.length, 3);
    });

    test('parses dot-chained property access', () {
      final stmt = parseInput('josh.sun.nakshatra');
      final access = (stmt as ExprStmt).expr as Access;
      expect(access.field, 'nakshatra');
      final inner = access.object as Access;
      expect(inner.field, 'sun');
      expect((inner.object as Ident).name, 'josh');
    });

    test('parses method call with no args', () {
      final stmt = parseInput('josh.navamsa()');
      final mc = (stmt as ExprStmt).expr as MethodCall;
      expect((mc.object as Ident).name, 'josh');
      expect(mc.method, 'navamsa');
      expect(mc.positional, isEmpty);
      expect(mc.named, isEmpty);
    });

    test('parses method call with positional arg', () {
      final stmt = parseInput('josh.dashas("yogini")');
      final mc = (stmt as ExprStmt).expr as MethodCall;
      expect(mc.method, 'dashas');
      expect(mc.positional.length, 1);
      expect((mc.positional[0] as StringLit).value, 'yogini');
    });

    test('parses function call with named args only', () {
      final stmt = parseInput('config(ayanamsa: "lahiri", houses: "whole_sign")');
      final call = (stmt as ExprStmt).expr as Call;
      expect(call.name, 'config');
      expect(call.positional, isEmpty);
      expect(call.named.length, 2);
      expect((call.named['ayanamsa'] as StringLit).value, 'lahiri');
      expect((call.named['houses'] as StringLit).value, 'whole_sign');
    });

    test('parses function call with ident positional args', () {
      final stmt = parseInput('synastry(josh, sarah)');
      final call = (stmt as ExprStmt).expr as Call;
      expect(call.name, 'synastry');
      expect(call.positional.length, 2);
      expect((call.positional[0] as Ident).name, 'josh');
      expect((call.positional[1] as Ident).name, 'sarah');
    });

    test('error on assignment without name', () {
      expect(() => parseInput('= foo'), throwsA(isA<NockError>()));
    });

    test('error on unclosed paren', () {
      expect(() => parseInput('chart("hello"'), throwsA(isA<NockError>()));
    });

    test('error on trailing tokens', () {
      expect(() => parseInput('help foo'), throwsA(isA<NockError>()));
    });

    test('bare ident is ExprStmt(Ident)', () {
      final stmt = parseInput('help');
      final ident = (stmt as ExprStmt).expr as Ident;
      expect(ident.name, 'help');
    });

    test('parenthesized expression', () {
      final stmt = parseInput('(josh)');
      final ident = (stmt as ExprStmt).expr as Ident;
      expect(ident.name, 'josh');
    });
  });
}
