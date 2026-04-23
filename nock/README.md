# Nock

CLI astrology app and living API docs for the Arjuna astrological calculation service. Every Quiver endpoint has a corresponding Nock command.

## Quick start

```
dart run bin/nock.dart              # enter the REPL
dart run bin/nock.dart repl         # same thing, explicit
dart run bin/nock.dart chart ...    # one-shot CLI mode
```

No ephemeris files required — Nock uses Swiss Ephemeris's built-in Moshier analytical ephemeris by default.

## The REPL

Bare `nock` drops you into an interactive astrology session. Charts are objects, planets are properties, and everything displays itself.

```
nock> josh = chart("1990-06-15 14:30", 39.76, -86.15)
┌──────────────────────────────────────────────┐
│ josh                                         │
├──────────────────────────────────────────────┤
│ Body       Longitude     Speed               │
├──────────────────────────────────────────────┤
│ ☉ Sun      24°12' ♊   +0.96                 │
│ ☽ Moon      8°45' ♏   +13.21                │
│ ...                                          │
└──────────────────────────────────────────────┘

nock> josh.sun
☉ Sun  24°12' ♊  speed +0.96

nock> josh.sun.nakshatra
Punarvasu 1 (jupiter)

nock> josh.sun.dignity
Friend

nock> josh.sun.retrograde
false

nock> josh.asc
Virgo ♍

nock> josh.navamsa().sun
☉ Sun  ... (navamsa position)
```

### Functions

| Function | Example | Description |
|----------|---------|-------------|
| `chart` | `chart("1990-06-15 14:30", 39.76, -86.15)` | Calculate a chart |
| `chart` | `chart("1990-06-15", 39.76, -86.15, cfg)` | Chart with explicit config |
| `read` | `read("path/to/chart.chtk")` | Load chart from file |
| `config` | `config(ayanamsa: "lahiri", houses: "wholeSigns")` | Set session config |
| `now` | `now(lat: 39.76, lon: -86.15)` | Chart for current moment |

Date formats: `YYYY-MM-DD`, `YYYY-MM-DD HH:MM`, or full ISO 8601 (`1990-06-15T14:30:00`). Times without a timezone are treated as UTC. To specify a different timezone, append a UTC offset:

```
chart("1990-06-15 14:30", ...)           # 14:30 UTC
chart("1990-06-15T14:30:00Z", ...)       # 14:30 UTC (explicit)
chart("1990-06-15T14:30:00+05:30", ...)  # 14:30 IST = 09:00 UTC
chart("1990-06-15T14:30:00-05:00", ...)  # 14:30 EST = 19:30 UTC
```

### Reading charts from files

Load charts from `.chtk` (Kala), `.jhd` (Jagannatha Hora), or `.toml` files:

```
nock> jung = read("/path/to/carl-jung.chtk")
┌──────────────────────────────────────────────┐
│ Carl Jung                                    │
├──────────────────────────────────────────────┤
│ ...                                          │
└──────────────────────────────────────────────┘

nock> jung.sun.sign
Leo ♌

nock> jung.sun.nakshatra
Pushya 4 (saturn)
```

The chart file provides the birth time, timezone offset, and coordinates. The chart is recalculated through Vayu using the current session config. When assigned to a variable, the variable name replaces the file's label.

### Chart properties

| Property | Returns | Example |
|----------|---------|---------|
| `.sun`, `.moon`, `.mars`, `.mercury`, `.jupiter`, `.venus`, `.saturn` | planet | `josh.sun` |
| `.rahu`, `.ketu` | planet | `josh.rahu` |
| `.asc` | sign | `josh.asc` |
| `.mc` | sign | `josh.mc` |
| `.planets` | list | `josh.planets` |
| `.grahas` | list | `josh.grahas` (9 vedic) |
| `.karakas` | list | `josh.karakas` (7 embodied) |
| `.houses` | list | `josh.houses` |

### Chart methods

| Method | Returns | Example |
|--------|---------|---------|
| `.navamsa()` | varga chart | `josh.navamsa()` |
| `.varga(n)` | varga chart | `josh.varga(9)` |

### Planet properties

| Property | Returns | Example |
|----------|---------|---------|
| `.sign` | sign name + glyph | `josh.sun.sign` |
| `.nakshatra` | nakshatra + pada + lord | `josh.sun.nakshatra` |
| `.dignity` | dignity level | `josh.sun.dignity` |
| `.house` | house number | `josh.sun.house` |
| `.longitude` | ecliptic degrees | `josh.sun.longitude` |
| `.speed` | degrees/day | `josh.sun.speed` |
| `.retrograde` | true/false | `josh.saturn.retrograde` |
| `.pada` | pada number | `josh.sun.pada` |
| `.combust` | true/false | `josh.mercury.combust` |

Dignity and combust are only available on karakas (Sun through Saturn). Calling them on nodes (Rahu/Ketu) throws an error.

### Config

Calling `config()` updates the session default — subsequent `chart()` calls use it automatically.

```
nock> config(ayanamsa: "lahiri")
  ayanamsa : lahiri
  houses   : campanus
  circle   : aditya
  node     : true

nock> josh = chart("1990-06-15 14:30", 39.76, -86.15)
  (uses lahiri ayanamsa)
```

You can also pass a config explicitly to `chart()`:

```
nock> vedic = config(ayanamsa: "lahiri", houses: "wholeSigns")
nock> western = config(ayanamsa: "tropical", houses: "placidus")
nock> josh_v = chart("1990-06-15 14:30", 39.76, -86.15, vedic)
nock> josh_w = chart("1990-06-15 14:30", 39.76, -86.15, western)
```

Config options:

| Key | Values | Default |
|-----|--------|---------|
| `ayanamsa` | `tropical`, `lahiri`, `raman`, `dhruva`, `fagan`, ... | `tropical` |
| `houses` | `campanus`, `placidus`, `wholeSigns`, `koch`, `equalAsc`, ... | `campanus` |
| `circle` | `aditya`, `zodiac` | `aditya` |
| `node` | `true`, `mean` | `true` |

### Variables and session

Assign any value to a name with `=`:

```
nock> josh = chart("1990-06-15 14:30", 39.76, -86.15)
nock> sarah = chart("1992-03-22 08:15", 40.71, -74.01)
```

Built-in session commands:

| Command | Description |
|---------|-------------|
| `help` | Show available commands and properties |
| `vars` | List all session variables and their types |
| `quit` | Exit the REPL |

### Error handling

User errors (bad dates, undefined variables, invalid properties) print a message and return to the prompt. The session is never corrupted by an error.

```
nock> undefined_var
  error: undefined: undefined_var

nock> chart("not-a-date", 39.76, -86.15)
  error: invalid date: "not-a-date" (expected YYYY-MM-DD or YYYY-MM-DD HH:MM)

nock> josh.rahu.dignity
  error: rahu has no dignity (not a karaka)
```

## CLI mode

One-shot commands via subcommands:

```
dart run bin/nock.dart chart --date "1990-06-15 14:30" --lat 39.76 --lon -86.15
dart run bin/nock.dart health
```

## Architecture

```
bin/nock.dart                 # entry point: no args → REPL, with args → CLI
lib/src/
├── commands/
│   ├── chart.dart            # CLI chart command
│   ├── health.dart           # CLI health check
│   └── repl.dart             # REPL loop
├── repl/
│   ├── lexer.dart            # string → tokens
│   ├── parser.dart           # tokens → AST
│   ├── ast.dart              # AST node types (sealed classes)
│   ├── evaluator.dart        # AST → NockValue (dispatches to Vayu)
│   ├── error.dart            # NockError
│   └── types/
│       ├── value.dart        # NockValue base + primitives
│       ├── chart.dart        # NockChart wraps Arrow Chart
│       ├── planet.dart       # NockPlanet wraps Planet/Graha/Karaka
│       ├── cusp.dart         # NockCusp wraps Cusp
│       ├── varga.dart        # NockVarga wraps Varga
│       ├── astro.dart        # NockSign, NockNakshatra, NockDignity
│       └── config.dart       # NockConfig → ArrowOptions
└── format/
    ├── longitude.dart        # longitude formatting + sign glyphs
    ├── planet.dart           # planet one-liners + glyphs
    ├── cusp.dart             # cusp formatting
    ├── chart.dart            # full chart table
    └── table.dart            # box-drawing utilities
```

The REPL is a small domain-specific language — not a CLI-commands-in-a-loop. It has its own lexer, recursive-descent parser, and tree-walking evaluator. NockValue types are thin wrappers around Arrow's domain model that add display formatting and property resolution.

## Tests

```
dart test                     # run all 135 tests
```

| Suite | Tests | What |
|-------|-------|------|
| `format/format_test.dart` | 13 | Longitude, planet, cusp, chart formatters |
| `repl/lexer_test.dart` | 10 | Tokenization |
| `repl/parser_test.dart` | 12 | AST construction |
| `repl/types/` | 29 | NockValue display + property resolution |
| `repl/evaluator_test.dart` | 47 | Function dispatch, variables, UTC handling |
| `repl/read_test.dart` | 14 | Chart file reading (.chtk, .toml) |
| `repl/repl_pipeline_test.dart` | 10 | End-to-end lexer → parser → evaluator |

All tests use real Vayu with Moshier ephemeris — no mocks.

## Not yet implemented

These are gated on Arrow/Quiver capabilities that don't exist yet:

- `synastry(a, b)` — two-chart comparison
- `transits(chart)` — current transits to a natal chart
- `.dashas()` — Vimshottari and other dasha systems
- `.shadbala()` — planetary strength
- Line editing, history, and tab completion
