# Nock REPL — Architecture

A domain-specific language for interactive astrology. Not a CLI-commands-in-a-loop — a small scripting environment where charts are objects, calculations are method calls, and multiple charts coexist in a session.

## Why

With libaditya you could open a Python REPL, create charts as objects, call methods on them, compare two charts side by side. The CLI mode (`nock chart --date ... --lat ... --lon ...`) is good for one-shot use, but flags are tedious for exploration. The REPL brings back that interactive workflow in Dart.

## What It Feels Like

```
nock> josh = chart("1990-06-15 14:30", 39.76, -86.15)

  Natal Chart — June 15, 1990 14:30 — 39.76N 86.15W
  ────────────────────────────────────────────────
  ☉ Sun      24°12' ♊   House 10
  ☽ Moon      8°45' ♏   House  4
  ♂ Mars     12°58' ♈   House  8
  ♄ Saturn   24°18' ♑ ℞ House  5
  ...
  Asc  2°15' ♍    MC 28°44' ♉

nock> josh.sun
  ☉ Sun  24°12' ♊  speed +0.96  House 10

nock> josh.sun.nakshatra
  Punarvasu 1 (Jupiter)

nock> josh.moon.dignity
  Debilitated

nock> josh.navamsa()
  Navamsa (D9) — June 15, 1990 14:30
  ────────────────────────────────────────────────
  ☉ Sun       6°48' ♓
  ☽ Moon     18°00' ♋
  ...

nock> sarah = chart("1992-03-22 08:15", 40.71, -74.01)

nock> synastry(josh, sarah)
  Synastry — josh / sarah
  ────────────────────────────────────────────────
  ☉—☉  Josh Sun 24°♊  /  Sarah Sun 1°♈   □ Square (83°)
  ☽—☽  Josh Moon 8°♏  /  Sarah Moon 22°♌  □ Square (76°)
  ...

nock> josh.dashas()
  Vimshottari Dasha
  ────────────────────────────────────────────────
  Jupiter  1983-09 → 1999-09
    Sub: Saturn  1996-01 → 1998-08  ← current
  Saturn   1999-09 → 2018-09
  ...

nock> vedic = config(ayanamsa: "lahiri", houses: "whole_sign")
  Config
  ────────────────────────────────────────────────
  ayanamsa:  lahiri
  houses:    whole_sign
  circle:    aditya
  node:      true

nock> josh_v = chart("1990-06-15 14:30", 39.76, -86.15, vedic)
  ...

nock> western = config(ayanamsa: "none", houses: "placidus")

nock> josh_w = chart("1990-06-15 14:30", 39.76, -86.15, western)
  ...
  # same birth data, different config — both charts coexist

nock> josh_v.sun.longitude
  0.7533  # sidereal

nock> josh_w.sun.longitude
  84.2033  # tropical

nock> transits(josh)
  Transits to josh — 2026-04-21
  ────────────────────────────────────────────────
  ♄ tr Saturn 3°♈ □ natal Moon 8°♏  (applying, 5°)
  ...

nock> help
  Variables:    name = expr
  Chart:        chart("YYYY-MM-DD HH:MM", lat, lon)
  Properties:   .sun .moon .mars .mercury .jupiter .venus .saturn
                .rahu .ketu .uranus .neptune .pluto
                .asc .mc .houses .planets .grahas .karakas
  Methods:      .nakshatra .dignity .sign .speed .house
                .navamsa() .dashas() .shadbala()
  Functions:    synastry(a, b)  transits(chart)  composite(a, b)
                search(planet, sign, from, to)
  Config:       config(ayanamsa: "...", houses: "...", ...)
  Session:      vars  help  quit
```

## Two Modes of Nock

```
nock chart --date "..." --lat 39.76 --lon -86.15    # CLI mode (unchanged)
nock                                                  # REPL mode (no args)
```

CLI mode stays exactly as-is — `CommandRunner`, flags, one-shot execution. The REPL is a separate entry point. They share formatters and the Vayu connection layer, but the REPL has its own parser, evaluator, and variable store.

## Language Design

### Not a general-purpose language

No if/else, no loops, no user-defined functions, no imports, no file I/O. It's a calculator with astrological types. This constraint is permanent — if someone needs programmability, they use Arrow as a Dart library.

### Grammar

```
program     = statement*
statement   = assignment | expr
assignment  = IDENT '=' expr
expr        = access
access      = call ( '.' IDENT ( '(' args? ')' )? )*
call        = IDENT '(' args? ')' | atom
args        = arg ( ',' arg )*
arg         = IDENT ':' expr | expr
atom        = STRING | NUMBER | IDENT | '(' expr ')'
```

That's the whole language. About 9 productions. The `arg` rule supports both positional and named arguments — named args are only used by `config()` but the grammar doesn't special-case it.

Examples parsed:

```
josh = chart("1990-06-15 14:30", 39.76, -86.15)
  → Assignment("josh", Call("chart", [String, Number, Number]))

josh.sun.nakshatra
  → Access(Access(Ident("josh"), "sun"), "nakshatra")

synastry(josh, sarah)
  → Call("synastry", [Ident("josh"), Ident("sarah")])

vedic = config(ayanamsa: "lahiri", houses: "whole_sign")
  → Assignment("vedic", Call("config", [], {ayanamsa: String, houses: String}))

chart("1990-06-15 14:30", 39.76, -86.15, vedic)
  → Call("chart", [String, Number, Number, Ident("vedic")])
```

### Types

| Type | What | Display |
|------|------|---------|
| `NockChart` | A calculated chart — wraps Arrow's `Chart` | Full chart table |
| `NockPlanet` | A single body in a chart — wraps `Planet`/`Graha`/`Karaka` | One-line summary |
| `NockCusp` | A house cusp | One-line summary |
| `NockSign` | A zodiac sign | Name + glyph |
| `NockNakshatra` | A nakshatra + pada | Name + pada + lord |
| `NockDignity` | Dignity status | Name (exalted/debilitated/own/etc.) |
| `NockDasha` | Dasha tree | Formatted period table |
| `NockSynastry` | Two-chart comparison | Aspect table |
| `NockTransits` | Transit-to-natal | Aspect table |
| `NockVarga` | Divisional chart | Chart table with division label |
| `NockConfig` | Immutable config object — passed to `chart()` | Key-value list |
| `String` | Literal string | As-is |
| `Number` | Literal number | As-is |

Every type knows how to display itself. Evaluating an expression at the top level calls `.display()` on the result and prints it. This is how `josh.sun.nakshatra` produces formatted output without a `print()` call.

### Property and Method Resolution

`NockChart` and `NockPlanet` are the two types with rich property access. Resolution is direct — no dynamic dispatch, no prototype chain.

**NockChart properties:**

| Access | Returns | Notes |
|--------|---------|-------|
| `.sun`, `.moon`, etc. | `NockPlanet` | Named planet accessors |
| `.rahu`, `.ketu` | `NockPlanet` | Nodes |
| `.uranus`, `.neptune`, `.pluto` | `NockPlanet` | Outers |
| `.asc`, `.mc` | `NockCusp` | Angles |
| `.houses` | `List<NockCusp>` | All 12 cusps |
| `.planets` | `List<NockPlanet>` | All bodies |
| `.grahas` | `List<NockPlanet>` | 9 Vedic |
| `.karakas` | `List<NockPlanet>` | 7 embodied |

**NockChart methods:**

| Call | Returns | Notes |
|------|---------|-------|
| `.navamsa()` | `NockVarga` | D9 |
| `.varga(n)` | `NockVarga` | Any divisional chart |
| `.dashas()` | `NockDasha` | Vimshottari by default |
| `.dashas("yogini")` | `NockDasha` | Named dasha system |
| `.shadbala()` | Display | Strength table |

**NockPlanet properties:**

| Access | Returns |
|--------|---------|
| `.longitude` | `Number` |
| `.latitude` | `Number` |
| `.speed` | `Number` |
| `.sign` | `NockSign` |
| `.nakshatra` | `NockNakshatra` |
| `.house` | `Number` |
| `.dignity` | `NockDignity` |
| `.retrograde` | Boolean display |

**Top-level functions:**

| Function | Args | Returns |
|----------|------|---------|
| `chart(date, lat, lon)` | String, Number, Number | `NockChart` (default config) |
| `chart(date, lat, lon, cfg)` | String, Number, Number, `NockConfig` | `NockChart` |
| `config(key: val, ...)` | Named args | `NockConfig` |
| `synastry(a, b)` | Two `NockChart` | `NockSynastry` |
| `transits(chart)` | `NockChart` | `NockTransits` |
| `transits(chart, date)` | `NockChart`, String | `NockTransits` |
| `composite(a, b)` | Two `NockChart` | `NockChart` |
| `search(planet, sign, from, to)` | Various | Search results |
| `now(lat, lon)` | Number, Number | `NockChart` for current moment |
| `now(lat, lon, cfg)` | Number, Number, `NockConfig` | `NockChart` for current moment with config |

### Config

Config is a regular value, not session state. Created with `config()` using named arguments, stored in variables like anything else.

```
vedic = config(ayanamsa: "lahiri", houses: "whole_sign")
western = config(houses: "placidus", circle: "zodiac")

josh_v = chart("1990-06-15 14:30", 39.76, -86.15, vedic)
josh_w = chart("1990-06-15 14:30", 39.76, -86.15, western)
```

`config()` with no arguments returns the default config. Any unspecified keys use defaults. Config objects are immutable — to change a setting, create a new config.

Every chart knows which config produced it. There is no hidden session-level config. If you omit the config argument to `chart()`, it uses the default.

## Session State

Minimal. Just variables and a connection.

```dart
class ReplSession {
  final Map<String, NockValue> variables = {};
  final Vayu vayu;
}
```

No mutable config, no implicit state. `vars` lists all current variables and their types. This is the only introspection command.

## Implementation Architecture

```
nock/lib/src/
├── commands/
│   ├── chart.dart              # existing CLI command
│   ├── health.dart             # existing CLI command
│   └── repl.dart               # ReplCommand — enters the REPL loop
│
├── repl/
│   ├── lexer.dart              # String → Token stream
│   ├── parser.dart             # Token stream → AST
│   ├── ast.dart                # AST node types
│   ├── evaluator.dart          # AST → NockValue (executes against Vayu)
│   ├── session.dart            # ReplSession state
│   └── types/
│       ├── value.dart          # NockValue base + display protocol
│       ├── chart.dart          # NockChart — wraps Arrow Chart
│       ├── planet.dart         # NockPlanet — wraps Planet/Graha/Karaka
│       ├── cusp.dart           # NockCusp
│       ├── config.dart         # NockConfig — immutable config object
│       ├── dasha.dart          # NockDasha
│       ├── synastry.dart       # NockSynastry
│       └── varga.dart          # NockVarga
│
├── format/
│   ├── chart.dart              # chart table formatter (shared CLI + REPL)
│   ├── planet.dart             # single-body formatter
│   └── table.dart              # box-drawing utilities
│
└── vayu.dart                   # connection abstraction (shared CLI + REPL)
```

### Lexer

Tokens: `IDENT`, `STRING` (double-quoted), `NUMBER` (int or float), `LPAREN`, `RPAREN`, `DOT`, `COMMA`, `COLON`, `EQUALS`, `EOF`.

No keywords. `config`, `help`, `vars`, `quit` are just identifiers that the evaluator handles specially.

### Parser

Recursive descent. ~150 lines. Produces an AST of:

```dart
sealed class Expr {}
class NumberLit extends Expr { final double value; }
class StringLit extends Expr { final String value; }
class Ident extends Expr { final String name; }
class Call extends Expr {
  final String name;
  final List<Expr> positional;
  final Map<String, Expr> named;
}
class Access extends Expr { final Expr object; final String field; }
class MethodCall extends Expr { final Expr object; final String method; final List<Expr> args; }

sealed class Stmt {}
class ExprStmt extends Stmt { final Expr expr; }
class Assignment extends Stmt { final String name; final Expr value; }
```

### Evaluator

Walks the AST, resolves identifiers against `ReplSession.variables`, dispatches function calls to Vayu, resolves property/method access on `NockValue` subtypes. Returns a `NockValue` which the REPL loop displays.

### The REPL Loop

```dart
class ReplCommand extends Command {
  @override
  String get name => 'repl';

  @override
  String get description => 'Interactive astrology session';

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

Entry via `nock repl` or (later) bare `nock` with no args.

### Line Editing

v1: `stdin.readLineSync()`. Functional but no history or tab completion.

v2: `cli_repl` package or equivalent — adds readline-style history (up-arrow), basic editing. Tab completion over variable names, planet names, and method names is a natural fit since the namespace is small and fixed.

## Relationship to Arrow's Domain Model

The Nock REPL types (`NockChart`, `NockPlanet`, etc.) are thin wrappers around Arrow's domain model (`Chart`, `Planet`/`Graha`/`Karaka`, `Cusp`). They add:

1. **Display formatting** — `NockPlanet.display()` produces the `☉ Sun 24°12' ♊` string
2. **REPL-specific property resolution** — `.nakshatra` on a `NockPlanet` returns a `NockNakshatra` (displayable), not a raw `Nakshatra` enum
3. **Method dispatch** — `.navamsa()` triggers a varga calculation and returns a `NockVarga`

They do NOT duplicate Arrow's calculation logic. A `NockChart` holds an Arrow `Chart` and delegates everything to it.

```
REPL input → Lexer → Parser → AST → Evaluator
                                        ↓
                                    NockValue types (display + property resolution)
                                        ↓
                                    Arrow domain model (Chart, Planet, Graha, Cusp)
                                        ↓
                                    Vayu → Arrow/Quiver (actual calculation)
```

## What Needs to Exist First

The REPL depends on Arrow's domain model being implemented. Specifically:

| Dependency | In | Status |
|---|---|---|
| `Chart`, `Planet`/`Graha`/`Karaka`, `Cusp` | arrow/core | Designed, not yet implemented |
| `EphSnapshot` calculation | arrow/swe | Implemented |
| Varga calculations | arrow/calc | Not yet implemented |
| Dasha calculations | arrow/calc | Not yet implemented |
| Vayu connection abstraction | nock or shared | Not yet implemented |
| Chart formatter (box-drawing) | nock | Partial (in chart.dart command) |

The REPL can ship incrementally. v1 needs only `chart()`, planet properties, and `.sign`/`.nakshatra`/`.dignity`. Vargas, dashas, synastry, and transits arrive as Arrow gains those capabilities.

## Scope Estimate

| Component | Approx Lines | Complexity |
|-----------|-------------|------------|
| Lexer | ~80 | Straightforward |
| Parser | ~150 | Straightforward |
| AST types | ~60 | Data classes |
| Evaluator | ~200 | Medium — function/property dispatch |
| NockValue types | ~300 total | Thin wrappers + display |
| Formatters | ~200 | Shared with CLI |
| REPL loop + session | ~80 | Straightforward |
| **Total** | **~1,100** | |

The parser and evaluator are the only parts that require real thought. Everything else is plumbing and formatting.

## Future Possibilities (Not Now)

Things that are natural extensions but should NOT be built until there's a real need:

- **Scripting from file** — `nock run script.nock` — execute a file of REPL commands. Free once the parser exists.
- **Output redirection** — `josh.navamsa() > navamsa.txt` — save display output to file.
- **History persistence** — save REPL history to `~/.nock_history` across sessions.
- **Multiline input** — detect incomplete expressions (unclosed parens) and prompt for continuation.
- **List operations** — `josh.planets.filter(p => p.retrograde)` — this is where "not a general-purpose language" gets tested. Resist.
