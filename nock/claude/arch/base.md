# Nock — Architecture Document

---

## Identity

**Living documentation of the Quiver API.** Every API endpoint has a corresponding Nock command. If you want to know how to use the API, read Nock's source.

Nock is also a **full-featured CLI astrology app** in its own right.

---

## Tech

Dart CLI

---

## Philosophy

```
Nock is to Quiver what curl is to HTTP.

Every Quiver endpoint → a Nock command
Every Nock command    → an API usage example
Every flag            → maps to a request field

If an endpoint exists and Nock doesn't have a command for it,
that's a bug.
```

---

## Connection Modes

Nock connects through Vayu, which supports three modes:

### Mode 1: Local Full Server (Default)

```
┌──────────────────────────┐
│ Local Quiver Server       │
│ Running on localhost      │
│ All Arrow calcs available │
│ No auth needed            │
│ No internet needed        │
│ No broadheads             │
└─────────┬────────────────┘
          │ gRPC localhost
          │
┌─────────▼────────────────┐
│ Nock                      │
│ Pure API client           │
└──────────────────────────┘

$ nock chart --date "1990-06-15 14:30" --lat 39.76 --lon -86.15
```

Play with astrology. No account needed. Fully offline. This is the default and primary purpose.

### Mode 2: Remote

```
┌──────────────────────────┐
│ Remote Quiver             │
│ Full capabilities         │
│ Auth required             │
│ Broadheads available      │
│ KalaBrain, etc.           │
└─────────┬────────────────┘
          │ gRPC internet
          │
┌─────────▼────────────────┐
│ Nock --remote             │
│ Authenticated API client  │
└──────────────────────────┘

$ nock --remote interpret --chart saved:my_natal
```

Full system access. LLM interpretation, saved charts, everything.

### Mode 3: Embedded (Celestial)

```
┌──────────────────────────┐
│ Celestial App Process     │
│                           │
│ Flutter UI                │
│    ▼                      │
│  Vayu                     │
│    ├── Local Arrow        │
│    └── Remote Quiver ──── │ ──▶ internet
│                           │
└───────────────────────────┘
```

Not relevant to Nock — this is how Celestial uses Vayu. Listed here for completeness.

---

## Vayu in Nock

```dart
// Nock doesn't care which mode — Vayu handles it

void main(List<String> args) {
  final remote = args.contains('--remote');

  final vayu = remote
    ? Vayu.remote(url: 'grpc://quiver.example.com:50051', token: jwt)
    : Vayu.local();  // spins up local Quiver server

  // Same commands either way
  final result = await vayu.calculateChart(birthData);
  printChart(result);
}
```

---

## Command Structure

```
nock
├── chart                    ← Natal chart calculation
│   ├── --date
│   ├── --lat / --lon
│   ├── --houses placidus|wholesign|...
│   └── --ayanamsa lahiri|raman|...
│
├── transits                 ← Current transits to natal
│   ├── --chart saved:name
│   └── --date (default: now)
│
├── synastry                 ← Two chart comparison
│   ├── --chart1
│   └── --chart2
│
├── search                   ← Search ephemeris
│   ├── --planet
│   ├── --sign
│   └── --date-range
│
├── interpret                ← LLM interpretation (--remote only)
│   ├── --chart
│   └── --prompt
│
├── charts                   ← Saved chart management (--remote only)
│   ├── list
│   ├── save
│   ├── delete
│   └── export
│
├── server                   ← Local server management
│   ├── start
│   ├── stop
│   └── status
│
└── config                   ← Nock configuration
    ├── set
    ├── get
    └── show
```

---

## Rich Terminal Output

```
$ nock chart --date "1990-06-15 14:30" --lat 39.76 --lon -86.15

╔══════════════════════════════════════════════╗
║            Natal Chart                        ║
║    June 15, 1990 — 14:30 — Indianapolis      ║
╠══════════════════════════════════════════════╣
║                                               ║
║  ☉ Sun      24° ♊ 12'    House 10            ║
║  ☽ Moon      8° ♏ 45'    House  4            ║
║  ☿ Mercury  15° ♋ 03'    House 11            ║
║  ♀ Venus     1° ♋ 22'    House 10            ║
║  ♂ Mars     12° ♈ 58'    House  8            ║
║  ♃ Jupiter  27° ♋ 41'    House 11            ║
║  ♄ Saturn   24° ♑ 18'  ℞ House  5            ║
║                                               ║
╠══════════════════════════════════════════════╣
║  Ascendant   2° ♍ 15'                        ║
║  Midheaven  28° ♉ 44'                        ║
╚══════════════════════════════════════════════╝
```

---

## Self-Documenting Source

```dart
// Every command file is an API usage example

// commands/chart.dart
class ChartCommand extends Command {
  @override
  String get description => 'Calculate a natal chart';

  @override
  Future<void> run() async {
    // This is exactly how you use the API:
    final birthData = BirthData(
      julianDay: dateToJd(argResults!['date']),
      latitude: double.parse(argResults!['lat']),
      longitude: double.parse(argResults!['lon']),
      config: SweConfig(
        houseSystem: argResults!['houses'],
        ayanamsa: argResults!['ayanamsa'],
      ),
    );

    final result = await vayu.calculateChart(birthData);
    printChart(result);
  }
}
```

---

## Open Questions

- 🎨 **Rich terminal library** — Dart equivalent of Python-rich? TBD
- 🔐 **Auth flow for --remote** — Browser-based OAuth? Token paste? `nock login`?
- 📦 **Distribution** — `dart pub global activate nock`? Homebrew? Binary releases?
- 🖥️ **Local server lifecycle** — Does `nock chart` auto-start the local server? Or require explicit `nock server start`?
- 🔄 **Vayu.local()** — Does this spin up a full Quiver server process, or an in-process embedded version?
