// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:test/test.dart';
import 'package:nock/src/repl/lexer.dart';
import 'package:nock/src/repl/error.dart';

void main() {
  group('Lexer', () {
    List<Token> lex(String input) => Lexer(input).tokenize();

    test('tokenizes chart call with string, decimals, and negative number', () {
      final tokens = lex('chart("1990-06-15 14:30", 39.76, -86.15)');
      final types = tokens.map((t) => t.type).toList();
      expect(types, [
        TokenType.ident,
        TokenType.lparen,
        TokenType.string,
        TokenType.comma,
        TokenType.number,
        TokenType.comma,
        TokenType.number,
        TokenType.rparen,
        TokenType.eof,
      ]);
      expect(tokens[0].lexeme, 'chart');
      expect(tokens[2].lexeme, '"1990-06-15 14:30"');
      expect(tokens[4].lexeme, '39.76');
      expect(tokens[6].lexeme, '-86.15');
    });

    test('tokenizes dot-chained idents', () {
      final tokens = lex('josh.sun.nakshatra');
      final types = tokens.map((t) => t.type).toList();
      expect(types, [
        TokenType.ident,
        TokenType.dot,
        TokenType.ident,
        TokenType.dot,
        TokenType.ident,
        TokenType.eof,
      ]);
    });

    test('tokenizes named arg syntax', () {
      final tokens = lex('config(ayanamsa: "lahiri")');
      final types = tokens.map((t) => t.type).toList();
      expect(types, [
        TokenType.ident,
        TokenType.lparen,
        TokenType.ident,
        TokenType.colon,
        TokenType.string,
        TokenType.rparen,
        TokenType.eof,
      ]);
    });

    test('throws on unexpected character', () {
      expect(() => lex('@foo'), throwsA(isA<NockError>()));
    });

    test('empty string produces only EOF', () {
      final tokens = lex('');
      expect(tokens.length, 1);
      expect(tokens[0].type, TokenType.eof);
    });

    test('integer numbers without decimal', () {
      final tokens = lex('9');
      expect(tokens[0].type, TokenType.number);
      expect(tokens[0].lexeme, '9');
    });

    test('negative number at start of input', () {
      final tokens = lex('-42');
      expect(tokens[0].type, TokenType.number);
      expect(tokens[0].lexeme, '-42');
    });

    test('empty string literal', () {
      final tokens = lex('""');
      expect(tokens[0].type, TokenType.string);
      expect(tokens[0].lexeme, '""');
    });

    test('records correct offsets', () {
      final tokens = lex('a  b');
      expect(tokens[0].offset, 0);
      expect(tokens[1].offset, 3);
    });

    test('throws on unterminated string', () {
      expect(() => lex('"hello'), throwsA(isA<NockError>()));
    });
  });
}
