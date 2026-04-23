sealed class Expr {}

class NumberLit extends Expr {
  final double value;
  NumberLit(this.value);
}

class StringLit extends Expr {
  final String value;
  StringLit(this.value);
}

class Ident extends Expr {
  final String name;
  Ident(this.name);
}

class Call extends Expr {
  final String name;
  final List<Expr> positional;
  final Map<String, Expr> named;
  Call(this.name, this.positional, this.named);
}

class Access extends Expr {
  final Expr object;
  final String field;
  Access(this.object, this.field);
}

class MethodCall extends Expr {
  final Expr object;
  final String method;
  final List<Expr> positional;
  final Map<String, Expr> named;
  MethodCall(this.object, this.method, this.positional, this.named);
}

sealed class Stmt {}

class ExprStmt extends Stmt {
  final Expr expr;
  ExprStmt(this.expr);
}

class Assignment extends Stmt {
  final String name;
  final Expr value;
  Assignment(this.name, this.value);
}
