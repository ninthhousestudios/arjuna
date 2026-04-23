# Nock REPL — Implementation Plan

Implements the DSL described in `nock/doc/repl.md`. Turns Nock into an interactive astrological scripting environment alongside its existing CLI mode.

## Prerequisites

Two things must exist before the REPL can work:

1. **Arrow core domain model completion** — at minimum the REPL critical path (Steps 0, 7, 1, 2 from `arrow/core/doc/completion-plan.md`). The REPL types wrap `Chart`, `Planet`/`Graha`/`Karaka`, `Cusp`. These need typed accessors on Chart and dignity wired to Karaka.

2. **Vayu in-process** — the REPL calls `Vayu.local()` to get a connection that calculates charts without a running server. Currently `quiver_embedded` is an empty stub.

This plan covers Vayu implementation as Phase 1 since it's tightly coupled to the REPL.

## Phase 1: Vayu In-Process

**Goal:** `Vayu.local()` returns a Vayu instance that can calculate charts. No server, no gRPC, no serialization.

### What Vayu Does

```dart
final vayu = await Vayu.local(ephePath: '/path/to/ephe');
final chart = await vayu.chart(jdUt, lat, lon);           // default config
final chart = await vayu.chart(jdUt, lat, lon, config);   // explicit config
await vayu.shutdown();
```

Internally: initializes Swiss Ephemeris via `arrow_swe`, calls `Swe.calculate()` to get `EphSnapshot`, wraps it in `Chart(snapshot, calcConfig)`, returns the `Chart`.

### Why async

SWE initialization involves loading ephemeris files. The chart calculation itself is synchronous Dart + FFI, but wrapping it in `Future` keeps the API uniform with `Vayu.remote()` (which will be async for real — gRPC calls). Also leaves room for isolate-based parallelism later without API change.

### Dependencies

`quiver_embedded` currently depends on `quiver_core` and `logging`. It needs:

```yaml
dependencies:
  arrow_options:
    path: ../../arrow/options
  arrow_swe:
    path: ../../arrow/swe
  arrow_core:
    path: ../../arrow/core
  logging: ^1.3.0
```

Drop `quiver_core` — Vayu in-process doesn't use gRPC stubs. (It stays in `nock/pubspec.yaml` because the CLI commands still use it for `--remote` mode, but the REPL's local path goes through Vayu, not gRPC.)

### Files

```
quiver/embedded/
├── lib/
│   ├── quiver_embedded.dart    ← barrel: export Vayu
│   └── src/
│       └── vayu.dart           ← Vayu class
├── pubspec.yaml                ← add arrow_* dependencies
└── test/
    └── vayu_test.dart
```

### Vayu Class

```dart
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

class Vayu {
  final Swe _swe;

  Vayu._(this._swe);

  static Future<Vayu> local({String? ephePath}) async {
    final swe = Swe(ephePath: ephePath);
    return Vayu._(swe);
  }

  /// Calculate a chart. Returns Arrow's rich domain Chart.
  Future<Chart> chart(
    double jdUt,
    double latitude,
    double longitude, [
    CalcConfig? calcConfig,
  ]) async {
    final sweConfig = SweConfig();  // default, or derive from calcConfig
    final snapshot = _swe.calculate(jdUt, latitude, longitude, sweConfig);
    final config = calcConfig ?? CalcConfig();
    return Chart(snapshot, config);
  }

  Future<void> shutdown() async {
    _swe.close();
  }
}
```

The exact `Swe` API (`Swe()`, `.calculate()`, `.close()`) needs to be checked against what `arrow_swe` actually exports. The shape above is the intent — adapt to the real API.

### SweConfig vs CalcConfig Mapping

The REPL's `NockConfig` holds user-facing settings (ayanamsa name, house system name, etc.). These need to map down to:

- `SweConfig` — passed to `_swe.calculate()`. Controls what SWE computes: ayanamsa enum, house system enum, node type, bodies list.
- `CalcConfig` — passed to `Chart()`. Controls derived calculations: tradition, circle, varga variants, dasha options.

Vayu handles the split: it takes one config from the caller and produces the two configs Arrow needs. For Phase 1, default configs only. The config mapping becomes real when the REPL's `config()` function is implemented (Phase 4).

### Tests

- Construct `Vayu.local()`, calculate a known chart (e.g. J2000.0 epoch), verify planet positions match expected values.
- Verify `Chart` has expected structure: `chart.rashi.sun` works, cusps exist.
- Test shutdown is clean.

### Prerequisite Check

Before writing Vayu, verify the `arrow_swe` API:
- What is the `Swe` constructor signature?
- What does `calculate()` take and return?
- Where do ephemeris files live? Does Nock need to know the path?
- Is `SweConfig` a required arg or optional?

Read `arrow/swe/lib/` to confirm. Do not guess.

---

## Phase 2: Formatters

**Goal:** Extract formatting from `chart.dart` into shared utilities used by both CLI and REPL.

### What Exists

`nock/lib/src/commands/chart.dart` has:
- `_signNames` — `['Ari', 'Tau', ...]`
- `_fmtLon(double lon)` — formats decimal longitude to `DD°MM Sgn`
- `_printChart(EphSnapshot, lat, lon)` — full box-drawing chart table

These work on raw `EphSnapshot` + doubles. The REPL needs formatters that work on Arrow domain objects (`Chart`, `Planet`, `Cusp`). Both CLI and REPL should share the same formatting code.

### Files

```
nock/lib/src/format/
├── longitude.dart      ← format a Longitude to string
├── chart.dart          ← format a Chart to multi-line string
├── planet.dart         ← format a Planet to one-line string
├── cusp.dart           ← format a Cusp to one-line string
└── table.dart          ← box-drawing utilities (borders, padding, alignment)
```

### Formatter Design

Formatters are pure functions: domain object in, string out. No side effects, no stdout.

```dart
// longitude.dart
String formatLongitude(Longitude lon);
  // → "24°12' ♊"

// planet.dart
String formatPlanetSummary(Planet planet);
  // → "☉ Sun      24°12' ♊   House 10"

String formatPlanetOneLiner(Planet planet);
  // → "☉ Sun  24°12' ♊  speed +0.96  House 10"

// chart.dart
String formatChart(Chart chart, {String? label});
  // → full box-drawing table

// cusp.dart
String formatCusp(Cusp cusp);
  // → "House  1: 2°15' ♍"
```

### Planet Glyphs

```dart
const planetGlyphs = <Body, String>{
  Body.sun: '☉',
  Body.moon: '☽',
  Body.mars: '♂',
  Body.mercury: '☿',
  Body.jupiter: '♃',
  Body.venus: '♀',
  Body.saturn: '♄',
  // Rahu/Ketu: ☊/☋ or custom
};
```

### Sign Glyphs

```dart
const signGlyphs = ['♈','♉','♊','♋','♌','♍','♎','♏','♐','♑','♒','♓'];
```

### Migration

After formatters are extracted, update `chart.dart` CLI command to use them. The command still receives `EphSnapshot` from gRPC — it wraps it in a `Chart` first, then calls the formatter. This means the CLI command now depends on `arrow_core` (to construct a `Chart`), which is a new dependency for the command but a dependency Nock already has via `quiver_embedded`.

### Tests

Formatter tests with known inputs, verify exact string output. These are snapshot-style tests — golden strings.

---

## Phase 3: REPL Language

**Goal:** The lexer, parser, and AST. Pure language machinery, no evaluation, no Arrow dependency.

### 3A: Token Types and Lexer

**File:** `nock/lib/src/repl/lexer.dart`

```dart
enum TokenType {
  ident,      // josh, chart, sun, config
  string,     // "1990-06-15 14:30"
  number,     // 39.76, -86.15, 9
  lparen,     // (
  rparen,     // )
  dot,        // .
  comma,      // ,
  colon,      // :
  equals,     // =
  eof,
}

class Token {
  final TokenType type;
  final String lexeme;
  final int offset;
}

class Lexer {
  final String source;
  List<Token> tokenize();
}
```

Lexer rules:
- Skip whitespace.
- `"..."` → string (no escape sequences needed for v1; dates and config values don't need them).
- Digit or `-` followed by digit → number. Handles negative numbers (`-86.15`) and plain integers.
- Letter or `_` followed by alphanumeric/`_` → ident.
- Single-character punctuation: `(`, `)`, `.`, `,`, `:`, `=`.
- Anything else → `NockError` with offset.

Negative number ambiguity: `-86.15` as a number literal vs. subtraction. Since there's no subtraction operator in the language, always parse `-` followed by digits as a negative number.

**Tests:** `test/repl/lexer_test.dart`
- Tokenize `chart("1990-06-15 14:30", 39.76, -86.15)` → expected token sequence.
- Tokenize `josh.sun.nakshatra` → ident, dot, ident, dot, ident.
- Tokenize `config(ayanamsa: "lahiri")` → ident, lparen, ident, colon, string, rparen.
- Error on unexpected character.
- Empty string → just EOF.

### 3B: AST Types

**File:** `nock/lib/src/repl/ast.dart`

```dart
sealed class Expr {}

class NumberLit extends Expr {
  final double value;
}

class StringLit extends Expr {
  final String value;
}

class Ident extends Expr {
  final String name;
}

class Call extends Expr {
  final String name;
  final List<Expr> positional;
  final Map<String, Expr> named;
}

class Access extends Expr {
  final Expr object;
  final String field;
}

class MethodCall extends Expr {
  final Expr object;
  final String method;
  final List<Expr> positional;
  final Map<String, Expr> named;
}

sealed class Stmt {}

class ExprStmt extends Stmt {
  final Expr expr;
}

class Assignment extends Stmt {
  final String name;
  final Expr value;
}
```

No tests needed for AST — it's just data classes.

### 3C: Parser

**File:** `nock/lib/src/repl/parser.dart`

```dart
class Parser {
  final List<Token> tokens;

  Parser(this.tokens);

  /// Parse one statement (one line of REPL input).
  Stmt parse();
}
```

Grammar (from `repl.md`):

```
statement   = assignment | exprStmt
assignment  = IDENT '=' expr
exprStmt    = expr
expr        = access
access      = call ( '.' IDENT ( '(' args? ')' )? )*
call        = IDENT '(' args? ')' | atom
args        = arg ( ',' arg )*
arg         = IDENT ':' expr | expr
atom        = STRING | NUMBER | IDENT | '(' expr ')'
```

Parsing `assignment` vs `exprStmt`: peek at first two tokens. If `IDENT EQUALS`, it's an assignment. Otherwise, parse as expression.

Named arg detection in `arg`: peek at `IDENT COLON`. If so, consume both and parse the value expression. Otherwise, parse as positional.

Method call vs. property access in `access`: after consuming `.IDENT`, if next token is `LPAREN`, it's a method call — parse args. Otherwise, it's a property access.

**Tests:** `test/repl/parser_test.dart`
- `chart("1990-06-15", 39.76, -86.15)` → `ExprStmt(Call("chart", [...]))`
- `josh = chart(...)` → `Assignment("josh", Call(...))`
- `josh.sun.nakshatra` → `ExprStmt(Access(Access(Ident, "sun"), "nakshatra"))`
- `josh.navamsa()` → `ExprStmt(MethodCall(Ident, "navamsa", []))`
- `josh.dashas("yogini")` → `ExprStmt(MethodCall(Ident, "dashas", ["yogini"]))`
- `config(ayanamsa: "lahiri", houses: "whole_sign")` → `ExprStmt(Call("config", [], {ayanamsa: ..., houses: ...}))`
- `synastry(josh, sarah)` → `ExprStmt(Call("synastry", [Ident, Ident]))`
- Error on `= foo` (assignment without name).
- Error on unclosed paren.

---

## Phase 4: NockValue Types

**Goal:** The REPL's value types. Each wraps an Arrow domain object and knows how to display itself and resolve property/method access.

### Value Protocol

**File:** `nock/lib/src/repl/types/value.dart`

```dart
abstract class NockValue {
  /// Multi-line display for REPL output.
  String display();

  /// Resolve property access: `this.field`
  NockValue access(String field);

  /// Resolve method call: `this.method(args)`
  Future<NockValue> call(String method, List<NockValue> positional, Map<String, NockValue> named);
}

class NockString extends NockValue {
  final String value;
  String display() => value;
  NockValue access(String field) => throw NockError('string has no property "$field"');
  // ...
}

class NockNumber extends NockValue {
  final double value;
  String display() => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();
  // ...
}

class NockBool extends NockValue {
  final bool value;
  String display() => value.toString();
  // ...
}
```

Primitive types throw on property access and method calls. Only `NockChart` and `NockPlanet` have rich resolution.

### NockChart

**File:** `nock/lib/src/repl/types/chart.dart`

Wraps `Chart` (from arrow_core). Holds a reference to `Vayu` for methods that trigger recalculation (e.g., `.navamsa()`).

```dart
class NockChart extends NockValue {
  final Chart chart;
  final Vayu vayu;
  final String? label;  // variable name, set by evaluator on assignment

  String display() => formatChart(chart, label: label);

  NockValue access(String field) => switch (field) {
    'sun'      => NockPlanet(chart.sun),
    'moon'     => NockPlanet(chart.moon),
    'mars'     => NockPlanet(chart.mars),
    'mercury'  => NockPlanet(chart.mercury),
    'jupiter'  => NockPlanet(chart.jupiter),
    'venus'    => NockPlanet(chart.venus),
    'saturn'   => NockPlanet(chart.saturn),
    'rahu'     => NockPlanet(chart.rahu),
    'ketu'     => NockPlanet(chart.ketu),
    'uranus'   => NockPlanet(chart.uranus),
    'neptune'  => NockPlanet(chart.neptune),
    'pluto'    => NockPlanet(chart.pluto),
    'asc'      => NockCusp(chart.ascendant),
    'mc'       => NockCusp(chart.mc),
    'houses'   => NockList(chart.cusps.map(NockCusp.new).toList()),
    'planets'  => NockList(chart.planets.map(NockPlanet.new).toList()),
    'grahas'   => NockList(chart.grahas.map(NockPlanet.new).toList()),
    'karakas'  => NockList(chart.karakas.map(NockPlanet.new).toList()),
    _ => throw NockError('chart has no property "$field"'),
  };

  Future<NockValue> call(String method, ...) => switch (method) {
    'navamsa' => _varga(VargaType.navamsha),
    'varga'   => _vargaFromArg(positional),
    'dashas'  => _dashas(positional),    // gated on arrow_calc
    'shadbala' => _shadbala(),            // gated on arrow_calc
    _ => throw NockError('chart has no method "$method"'),
  };
}
```

`chart.planets` etc. depend on the typed accessors from arrow/core completion Step 1. If those return `Planet` at the base level, `NockPlanet` wraps uniformly. The NockPlanet wrapper doesn't care whether the inner object is `Planet`, `Graha`, or `Karaka` — it checks at access time whether the underlying type supports the property (e.g., `.dignity` checks if it's a Karaka).

### NockPlanet

**File:** `nock/lib/src/repl/types/planet.dart`

Wraps `Planet` (or `Graha`/`Karaka` — after Step 0, these are all subtypes of `Planet`).

```dart
class NockPlanet extends NockValue {
  final Planet planet;

  String display() => formatPlanetOneLiner(planet);

  NockValue access(String field) => switch (field) {
    'longitude'  => NockNumber(planet.rawLongitude),
    'latitude'   => NockNumber(planet.position.latitude),
    'speed'      => NockNumber(planet.position.speedLongitude),
    'sign'       => NockSign(planet.sign, planet.longitude),
    'nakshatra'  => NockNakshatra(planet.nakshatra, planet.pada),
    'house'      => _resolveHouse(),
    'dignity'    => _resolveDignity(),
    'retrograde' => NockBool(planet.isRetrograde),
    'pada'       => NockNumber(planet.pada.toDouble()),
    _ => throw NockError('planet has no property "$field"'),
  };
}
```

`.dignity` checks `planet is Karaka` (after inheritance refactor). If not a Karaka (e.g., Rahu, Uranus), throws a descriptive error: `"rahu has no dignity (not a karaka)"`.

`.house` requires knowing which house the planet occupies — this needs the cusp list from the Chart. Either NockPlanet holds a back-reference to the Chart, or the evaluator resolves `.house` specially. Back-reference is simpler: store the `Chart` alongside the `Planet` in NockPlanet.

### NockCusp

**File:** `nock/lib/src/repl/types/cusp.dart`

```dart
class NockCusp extends NockValue {
  final Cusp cusp;

  String display() => formatCusp(cusp);

  NockValue access(String field) => switch (field) {
    'longitude' => NockNumber(cusp.longitude.eclipticLongitude),
    'sign'      => NockSign(cusp.sign, cusp.longitude),
    'nakshatra' => NockNakshatra(cusp.nakshatra, cusp.pada),  // after Step 3
    'house'     => NockNumber(cusp.house.toDouble()),
    _ => throw NockError('cusp has no property "$field"'),
  };
}
```

### NockSign, NockNakshatra, NockDignity

**File:** `nock/lib/src/repl/types/astro.dart` (small enough for one file)

Leaf display types. No property access, no methods.

```dart
class NockSign extends NockValue {
  final int number;     // 1-12
  final Longitude lon;  // for degree display
  String display();     // → "Gemini ♊" or "24°12' ♊"
}

class NockNakshatra extends NockValue {
  final int number;     // 1-27
  final int pada;       // 1-4
  String display();     // → "Punarvasu 1 (Jupiter)"
}

class NockDignity extends NockValue {
  final DignityType type;
  String display();     // → "Exalted" / "Debilitated" / "Own Sign" / etc.
}
```

### NockConfig

**File:** `nock/lib/src/repl/types/config.dart`

Immutable value object. Created by `config()` function.

```dart
class NockConfig extends NockValue {
  final String ayanamsa;     // "lahiri", "raman", "aditya", etc.
  final String houses;       // "placidus", "whole_sign", "equal", etc.
  final String circle;       // "aditya", "zodiac"
  final String node;         // "true", "mean"

  NockConfig({
    this.ayanamsa = 'aditya',
    this.houses = 'placidus',
    this.circle = 'aditya',
    this.node = 'true',
  });

  String display();  // formatted key-value table

  /// Convert to Arrow's SweConfig + CalcConfig.
  SweConfig toSweConfig();
  CalcConfig toCalcConfig();

  NockValue access(String field) => switch (field) {
    'ayanamsa' => NockString(ayanamsa),
    'houses'   => NockString(houses),
    'circle'   => NockString(circle),
    'node'     => NockString(node),
    _ => throw NockError('config has no property "$field"'),
  };
}
```

The mapping from string names to Arrow enum values (`"lahiri"` → `Ayanamsa.lahiri`, `"whole_sign"` → `HouseSystem.wholeSign`) lives in `toSweConfig()` and `toCalcConfig()`. Validation happens at construction: `config(ayanamsa: "garbage")` throws `NockError("unknown ayanamsa: garbage")`.

### NockVarga

**File:** `nock/lib/src/repl/types/varga.dart`

Wraps a `Varga` (divisional chart). Similar to `NockChart` but with a division label. Has the same planet accessors.

```dart
class NockVarga extends NockValue {
  final Varga varga;
  final VargaType type;
  String display();  // chart table with "Navamsa (D9)" header
  NockValue access(String field);  // same planet/cusp accessors as NockChart
}
```

### NockList

**File:** `nock/lib/src/repl/types/value.dart` (alongside NockValue base)

For `.planets`, `.houses`, `.karakas` — returns a list that displays each element.

```dart
class NockList extends NockValue {
  final List<NockValue> items;
  String display() => items.map((v) => v.display()).join('\n');
}
```

No index access for v1 (no `josh.planets[0]` syntax — that would need a `[]` operator in the grammar). Access by name (`josh.sun`) covers the common case.

---

## Phase 5: Evaluator

**Goal:** Walk the AST, resolve everything, return `NockValue` for display.

**File:** `nock/lib/src/repl/evaluator.dart`

### Session State

```dart
class ReplSession {
  final Map<String, NockValue> variables = {};
  final Vayu vayu;

  ReplSession({required this.vayu});
}
```

### Evaluator

```dart
class Evaluator {
  final ReplSession session;

  Evaluator(this.session);

  /// Execute a statement. Returns a value to display, or null (for assignment).
  Future<NockValue?> execute(Stmt stmt) async {
    return switch (stmt) {
      ExprStmt(:final expr) => await _eval(expr),
      Assignment(:final name, :final value) => _assign(name, value),
    };
  }
}
```

### Expression Evaluation

```dart
Future<NockValue> _eval(Expr expr) async {
  return switch (expr) {
    NumberLit(:final value) => NockNumber(value),
    StringLit(:final value) => NockString(value),
    Ident(:final name) => _resolveIdent(name),
    Call(:final name, :final positional, :final named) =>
        await _call(name, positional, named),
    Access(:final object, :final field) =>
        (await _eval(object)).access(field),
    MethodCall(:final object, :final method, :final positional, :final named) =>
        await (await _eval(object)).call(method,
            await _evalList(positional), await _evalNamed(named)),
  };
}
```

### Identifier Resolution

```dart
NockValue _resolveIdent(String name) {
  // Builtins
  if (name == 'help') return _help();
  if (name == 'vars') return _vars();

  // Variables
  final value = session.variables[name];
  if (value != null) return value;

  throw NockError('undefined: $name');
}
```

### Function Dispatch

```dart
Future<NockValue> _call(String name, List<Expr> positional, Map<String, Expr> named) async {
  return switch (name) {
    'chart'    => await _chartFn(positional, named),
    'config'   => _configFn(named),
    'synastry' => await _synastryFn(positional),
    'transits' => await _transitsFn(positional),
    'now'      => await _nowFn(positional, named),
    _ => throw NockError('unknown function: $name'),
  };
}
```

### The `chart()` Function

```dart
Future<NockValue> _chartFn(List<Expr> positional, Map<String, Expr> named) async {
  // chart("1990-06-15 14:30", 39.76, -86.15)
  // chart("1990-06-15 14:30", 39.76, -86.15, myConfig)
  if (positional.length < 3 || positional.length > 4) {
    throw NockError('chart() takes 3 or 4 arguments: date, lat, lon [, config]');
  }

  final dateStr = _expectString(await _eval(positional[0]), 'chart() date');
  final lat = _expectNumber(await _eval(positional[1]), 'chart() lat');
  final lon = _expectNumber(await _eval(positional[2]), 'chart() lon');

  NockConfig? config;
  if (positional.length == 4) {
    config = _expectConfig(await _eval(positional[3]), 'chart() config');
  }

  final jd = _dateToJd(dateStr);   // parse "YYYY-MM-DD HH:MM" → Julian Day
  final chart = await session.vayu.chart(jd, lat, lon, config?.toCalcConfig());

  return NockChart(chart, session.vayu);
}
```

### The `config()` Function

```dart
NockValue _configFn(Map<String, Expr> named) {
  // config()                                → default config
  // config(ayanamsa: "lahiri")             → one override
  // config(ayanamsa: "lahiri", houses: "whole_sign") → multiple
  final args = <String, String>{};
  for (final entry in named.entries) {
    args[entry.key] = _expectString(_eval(entry.value), 'config() ${entry.key}');
  }
  return NockConfig(
    ayanamsa: args['ayanamsa'] ?? 'aditya',
    houses: args['houses'] ?? 'placidus',
    circle: args['circle'] ?? 'aditya',
    node: args['node'] ?? 'true',
  );
}
```

### Assignment

```dart
Future<NockValue?> _assign(String name, Expr value) async {
  if (name == 'config' || name == 'help' || name == 'vars' || name == 'quit') {
    throw NockError('cannot assign to "$name"');
  }
  final result = await _eval(value);
  session.variables[name] = result;

  // Tag the value with its variable name for display purposes
  if (result is NockChart) result.label = name;

  // Display the value after assignment
  return result;
}
```

Assignment displays the result — `josh = chart(...)` both stores and prints the chart.

### Date Parsing

```dart
double _dateToJd(String dateStr) {
  // Accept: "1990-06-15 14:30" or "1990-06-15"
  final dt = DateTime.parse(dateStr);
  return 2440587.5 + dt.millisecondsSinceEpoch / 86400000.0;
}
```

Same formula as the existing `chart.dart` command. If DateTime.parse fails, throw `NockError` with a helpful message about the expected format.

### `help` and `vars` Builtins

```dart
NockValue _help() => NockString('''
  Variables:    name = expr
  Chart:        chart("YYYY-MM-DD HH:MM", lat, lon)
                chart("YYYY-MM-DD HH:MM", lat, lon, config)
  Config:       config(ayanamsa: "...", houses: "...", ...)
  Properties:   .sun .moon .mars .mercury .jupiter .venus .saturn
                .rahu .ketu .uranus .neptune .pluto
                .asc .mc .houses .planets .grahas .karakas
  Planet:       .nakshatra .dignity .sign .speed .house .retrograde
  Methods:      .navamsa() .varga(n) .dashas()
  Functions:    synastry(a, b)  transits(chart)
  Session:      vars  help  quit''');

NockValue _vars() {
  if (session.variables.isEmpty) return NockString('  (no variables)');
  final lines = session.variables.entries.map((e) {
    final type = e.value.runtimeType.toString().replaceFirst('Nock', '');
    return '  ${e.key}: $type';
  });
  return NockString(lines.join('\n'));
}
```

### Tests

`test/repl/evaluator_test.dart` — this is the integration test level. Requires a working Vayu (or a mock).

**Mock Vayu:** For unit testing the evaluator without SWE/ephemeris files, create a `MockVayu` that returns a canned `Chart` with known positions. The evaluator doesn't care where the Chart comes from.

Test cases:
- Assign and retrieve a variable.
- `chart()` returns a `NockChart`.
- `josh.sun` returns a `NockPlanet`.
- `josh.sun.nakshatra` returns a `NockNakshatra`.
- `config(ayanamsa: "lahiri")` returns a `NockConfig` with lahiri.
- `chart(date, lat, lon, config)` uses the provided config.
- Error on undefined variable.
- Error on wrong argument count.
- Error on wrong argument type.
- `help` and `vars` return strings.

---

## Phase 6: REPL Loop and Entry Point

**Goal:** Wire it all together. `nock repl` (or bare `nock`) enters the interactive session.

### REPL Command

**File:** `nock/lib/src/commands/repl.dart`

```dart
class ReplCommand extends Command<void> {
  @override
  final name = 'repl';

  @override
  final description = 'Interactive astrology session.';

  @override
  Future<void> run() async {
    final vayu = await Vayu.local();
    final session = ReplSession(vayu: vayu);
    final evaluator = Evaluator(session);

    stdout.writeln('nock repl — type help for commands, quit to exit');
    stdout.writeln('');

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

    await vayu.shutdown();
  }
}
```

### Entry Point Update

**File:** `nock/bin/nock.dart`

```dart
void main(List<String> args) async {
  final runner = CommandRunner<void>(
    'nock',
    'CLI astrology app — living API docs for Quiver.',
  )
    ..addCommand(HealthCommand())
    ..addCommand(ChartCommand())
    ..addCommand(ReplCommand());

  // Bare `nock` with no args → enter REPL
  if (args.isEmpty) {
    await ReplCommand().run();
    return;
  }

  await runner.run(args);
}
```

### NockError

**File:** `nock/lib/src/repl/error.dart`

```dart
class NockError implements Exception {
  final String message;
  NockError(this.message);

  @override
  String toString() => 'NockError: $message';
}
```

Used by lexer (bad token), parser (syntax error), and evaluator (type error, undefined variable, etc.). The REPL loop catches it and prints the message. All other exceptions (SWE crashes, etc.) propagate normally — they're bugs, not user errors.

### pubspec.yaml Update

Nock needs `arrow_core` as a direct dependency (for the REPL types that wrap domain objects):

```yaml
dependencies:
  quiver_embedded:
    path: ../quiver/embedded
  quiver_core:
    path: ../quiver/core
  arrow_core:
    path: ../arrow/core
  arrow_options:
    path: ../arrow/options
  grpc: ^5.0.0
  protobuf: ^6.0.0
  args: ^2.6.0
  logging: ^1.3.0
```

---

## File Summary

### New Files

```
quiver/embedded/lib/src/vayu.dart           ← Vayu class
quiver/embedded/test/vayu_test.dart

nock/lib/src/format/longitude.dart
nock/lib/src/format/chart.dart
nock/lib/src/format/planet.dart
nock/lib/src/format/cusp.dart
nock/lib/src/format/table.dart

nock/lib/src/repl/lexer.dart
nock/lib/src/repl/parser.dart
nock/lib/src/repl/ast.dart
nock/lib/src/repl/evaluator.dart
nock/lib/src/repl/session.dart
nock/lib/src/repl/error.dart
nock/lib/src/repl/types/value.dart
nock/lib/src/repl/types/chart.dart
nock/lib/src/repl/types/planet.dart
nock/lib/src/repl/types/cusp.dart
nock/lib/src/repl/types/astro.dart
nock/lib/src/repl/types/config.dart
nock/lib/src/repl/types/varga.dart

nock/lib/src/commands/repl.dart

nock/test/repl/lexer_test.dart
nock/test/repl/parser_test.dart
nock/test/repl/evaluator_test.dart
nock/test/format/longitude_test.dart
nock/test/format/chart_test.dart
```

### Modified Files

```
quiver/embedded/pubspec.yaml               ← add arrow_* deps
quiver/embedded/lib/quiver_embedded.dart   ← export Vayu
nock/pubspec.yaml                          ← add arrow_core, arrow_options deps
nock/bin/nock.dart                         ← add ReplCommand, bare-nock entry
nock/lib/src/commands/chart.dart           ← use shared formatters
```

### File Count

24 new files, 5 modified. Of those, ~8 are test files.

---

## Scope Estimate

| Phase | New Lines | Test Lines | Notes |
|-------|----------|------------|-------|
| 1. Vayu in-process | ~80 | ~40 | Small — it's a thin wrapper |
| 2. Formatters | ~200 | ~80 | Extract + enhance from chart.dart |
| 3. REPL language | ~300 | ~150 | Lexer ~80, parser ~150, AST ~60 |
| 4. NockValue types | ~400 | ~60 | Wrappers + display + property resolution |
| 5. Evaluator | ~250 | ~100 | Function dispatch, error handling |
| 6. REPL loop + entry | ~60 | — | Thin — just the loop and wiring |
| **Total** | **~1,290** | **~430** | |

~1,700 lines total including tests. The formatters and NockValue types are the bulk — straightforward but numerous. The interesting code is the parser (~150 lines) and evaluator (~250 lines).

---

## Implementation Order

```
Phase 1: Vayu ──────────────────┐
Phase 2: Formatters ────────────┤
Phase 3: REPL language ─────────┤ (all three can be parallel)
                                │
Phase 4: NockValue types ───────┤ (needs Phase 2 formatters + Phase 3 AST types)
                                │
Phase 5: Evaluator ─────────────┤ (needs Phase 1 Vayu + Phase 4 types)
                                │
Phase 6: REPL loop + entry ─────┘ (needs Phase 5 evaluator)
```

Phases 1, 2, 3 are independent of each other and can be built in parallel. Phase 4 needs the formatters (Phase 2) and AST types (Phase 3). Phase 5 needs Vayu (Phase 1) and the NockValue types (Phase 4). Phase 6 is wiring.

The entire plan assumes arrow/core completion Steps 0, 7, 1, 2 are done first. If they're not, the NockValue types (Phase 4) can still be written against the expected API and tested with mocks, but they can't be wired to real Arrow objects until the typed accessors exist.

---

## What Ships as v1

The minimum viable REPL:

- `nock` enters the REPL
- `josh = chart("1990-06-15 14:30", 39.76, -86.15)` calculates and displays a chart
- `josh.sun`, `josh.moon`, etc. display individual planets
- `josh.sun.nakshatra`, `josh.sun.sign`, `josh.sun.dignity`, `josh.sun.retrograde`
- `josh.asc`, `josh.mc`, `josh.houses`
- `vedic = config(ayanamsa: "lahiri")` then `chart(date, lat, lon, vedic)`
- `vars`, `help`, `quit`
- Multiple charts in variables simultaneously

NOT in v1:
- `.navamsa()`, `.varga(n)` — gated on Vayu supporting varga calculation
- `.dashas()` — gated on arrow_calc
- `synastry()`, `transits()` — gated on those calculations existing
- Line editing / history
- Tab completion
