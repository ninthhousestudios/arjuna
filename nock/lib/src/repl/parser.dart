// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'ast.dart';
import 'error.dart';
import 'lexer.dart';

class Parser {
  final List<Token> tokens;
  int _pos = 0;

  Parser(this.tokens);

  Stmt parse() {
    final stmt = _statement();
    _expect(TokenType.eof, 'Expected end of input');
    return stmt;
  }

  Stmt _statement() {
    if (_check(TokenType.ident) && _checkAt(1, TokenType.equals)) {
      return _assignment();
    }
    return ExprStmt(_expr());
  }

  Assignment _assignment() {
    final name = _advance();
    _advance(); // consume '='
    final value = _expr();
    return Assignment(name.lexeme, value);
  }

  Expr _expr() => _access();

  Expr _access() {
    var left = _call();
    while (_match(TokenType.dot)) {
      final field = _expect(TokenType.ident, 'Expected identifier after "."');
      if (_match(TokenType.lparen)) {
        final (positional, named) = _args();
        _expect(TokenType.rparen, 'Expected ")" after arguments');
        left = MethodCall(left, field.lexeme, positional, named);
      } else {
        left = Access(left, field.lexeme);
      }
    }
    return left;
  }

  Expr _call() {
    if (_check(TokenType.ident) && _checkAt(1, TokenType.lparen)) {
      final name = _advance();
      _advance(); // consume '('
      final (positional, named) = _args();
      _expect(TokenType.rparen, 'Expected ")" after arguments');
      return Call(name.lexeme, positional, named);
    }
    return _atom();
  }

  (List<Expr>, Map<String, Expr>) _args() {
    final positional = <Expr>[];
    final named = <String, Expr>{};

    if (_check(TokenType.rparen)) return (positional, named);

    _parseArg(positional, named);
    while (_match(TokenType.comma)) {
      _parseArg(positional, named);
    }
    return (positional, named);
  }

  void _parseArg(List<Expr> positional, Map<String, Expr> named) {
    if (_check(TokenType.ident) && _checkAt(1, TokenType.colon)) {
      final key = _advance();
      _advance(); // consume ':'
      named[key.lexeme] = _expr();
    } else {
      positional.add(_expr());
    }
  }

  Expr _atom() {
    if (_match(TokenType.string)) {
      final lexeme = _previous().lexeme;
      return StringLit(lexeme.substring(1, lexeme.length - 1));
    }
    if (_match(TokenType.number)) {
      return NumberLit(double.parse(_previous().lexeme));
    }
    if (_match(TokenType.ident)) {
      return Ident(_previous().lexeme);
    }
    if (_match(TokenType.lparen)) {
      final expr = _expr();
      _expect(TokenType.rparen, 'Expected ")" after expression');
      return expr;
    }
    throw NockError(
      'Unexpected token "${_peek().lexeme}" at offset ${_peek().offset}',
    );
  }

  // --- Helpers ---

  Token _peek() => tokens[_pos];

  Token _previous() => tokens[_pos - 1];

  Token _advance() {
    final t = tokens[_pos];
    if (t.type != TokenType.eof) _pos++;
    return t;
  }

  bool _check(TokenType type) => _peek().type == type;

  bool _checkAt(int ahead, TokenType type) {
    final i = _pos + ahead;
    if (i >= tokens.length) return false;
    return tokens[i].type == type;
  }

  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  Token _expect(TokenType type, String message) {
    if (_check(type)) return _advance();
    throw NockError('$message at offset ${_peek().offset}');
  }
}
