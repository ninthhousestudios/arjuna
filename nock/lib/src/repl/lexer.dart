// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'error.dart';

enum TokenType {
  ident,
  string,
  number,
  lparen,
  rparen,
  dot,
  comma,
  colon,
  equals,
  eof,
}

class Token {
  final TokenType type;
  final String lexeme;
  final int offset;

  Token(this.type, this.lexeme, this.offset);

  @override
  String toString() => 'Token($type, ${repr(lexeme)}, $offset)';

  static String repr(String s) => '"${s.replaceAll('"', r'\"')}"';
}

class Lexer {
  final String source;
  int _pos = 0;

  Lexer(this.source);

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (_pos < source.length) {
      _skipWhitespace();
      if (_pos >= source.length) break;

      final start = _pos;
      final c = source[_pos];

      if (c == '"') {
        tokens.add(_string());
      } else if (_isDigit(c) ||
          (c == '-' &&
              _pos + 1 < source.length &&
              _isDigit(source[_pos + 1]))) {
        tokens.add(_number());
      } else if (_isIdentStart(c)) {
        tokens.add(_ident());
      } else if (c == '(') {
        tokens.add(Token(TokenType.lparen, '(', start));
        _pos++;
      } else if (c == ')') {
        tokens.add(Token(TokenType.rparen, ')', start));
        _pos++;
      } else if (c == '.') {
        tokens.add(Token(TokenType.dot, '.', start));
        _pos++;
      } else if (c == ',') {
        tokens.add(Token(TokenType.comma, ',', start));
        _pos++;
      } else if (c == ':') {
        tokens.add(Token(TokenType.colon, ':', start));
        _pos++;
      } else if (c == '=') {
        tokens.add(Token(TokenType.equals, '=', start));
        _pos++;
      } else {
        throw NockError('Unexpected character "$c" at offset $start');
      }
    }
    tokens.add(Token(TokenType.eof, '', _pos));
    return tokens;
  }

  void _skipWhitespace() {
    while (_pos < source.length &&
        (source[_pos] == ' ' || source[_pos] == '\t')) {
      _pos++;
    }
  }

  Token _string() {
    final start = _pos;
    _pos++; // skip opening quote
    while (_pos < source.length && source[_pos] != '"') {
      _pos++;
    }
    if (_pos >= source.length) {
      throw NockError('Unterminated string starting at offset $start');
    }
    _pos++; // skip closing quote
    final lexeme = source.substring(start, _pos);
    return Token(TokenType.string, lexeme, start);
  }

  Token _number() {
    final start = _pos;
    if (source[_pos] == '-') _pos++;
    while (_pos < source.length && _isDigit(source[_pos])) {
      _pos++;
    }
    if (_pos < source.length && source[_pos] == '.') {
      _pos++;
      while (_pos < source.length && _isDigit(source[_pos])) {
        _pos++;
      }
    }
    return Token(TokenType.number, source.substring(start, _pos), start);
  }

  Token _ident() {
    final start = _pos;
    while (_pos < source.length && _isIdentContinue(source[_pos])) {
      _pos++;
    }
    return Token(TokenType.ident, source.substring(start, _pos), start);
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isIdentStart(String c) =>
      (c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 90) ||
      (c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 122) ||
      c == '_';
  bool _isIdentContinue(String c) => _isIdentStart(c) || _isDigit(c);
}
