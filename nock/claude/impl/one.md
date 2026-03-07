# Nock Implementation Plan

## Guiding Principle

Same as all Arjuna projects: build thoroughly, intentionally, methodically from the ground up. Every command includes logging, error handling, and testing as it is built.

Nock is living API documentation. Every command is an API usage example. If reading a command's source doesn't teach you how to use the corresponding Quiver endpoint, the command is wrong.

## Conventions

- **Dart CLI** using `package:args` (or a command-runner package — evaluate during scaffold).
- **Logging**: `package:logging`. Hierarchy: `Nock`.
- **Connection through Vayu.** Nock never talks to Arrow or Quiver directly — it goes through Vayu, which handles local vs remote transparently.
- **Rich terminal output.** Box-drawing characters, aligned columns, clear formatting. Evaluate Dart terminal libraries during scaffold.
- **Every command mirrors a Quiver endpoint.** If an endpoint exists without a Nock command, that's a bug.

## Directory Structure

```
nock/
├── bin/
│   └── nock.dart              # entry point
├── lib/
│   ├── nock.dart              # barrel export
│   └── src/
│       ├── cli.dart           # top-level CLI setup, command registration
│       ├── vayu.dart          # Vayu connection setup (local vs --remote)
│       ├── output/            # terminal formatting utilities
│       └── commands/          # one file per command
└── test/
```

---

## Phase 1: Scaffold and Connection

### 1A. Scaffold the package

Create `pubspec.yaml`, entry point, CLI runner. Evaluate command-runner packages (`package:args` with `CommandRunner`, or `package:dcli`, etc.). Pick one.

Implement `nock --help` and `nock --version`. Nothing else.

Done when: `dart run nock --help` prints usage and `nock --version` prints the version.

**Sync point**: can start immediately. No Quiver dependency.

### 1B. Connect to Vayu

Implement the connection modes. Nock talks to Vayu, Vayu handles the rest.

```dart
// bin/nock.dart
void main(List<String> args) async {
  final remote = args.contains('--remote');

  final vayu = remote
    ? Vayu.remote(url: config.remoteUrl, token: await getToken())
    : Vayu.local();  // starts local Quiver, connects via gRPC localhost

  final cli = NockCli(vayu);
  await cli.run(args);
}
```

**Local mode (default)**: Vayu starts a local Quiver server process (or connects to an already-running one on localhost). Full Arrow calcs, no auth, no internet.

**Remote mode (`--remote`)**: Vayu connects to Remote Quiver over gRPC. Auth required.

For Phase 1, implement local mode only. `--remote` comes with auth in Phase 3.

Gates on: **Quiver 1C** (health check server running).

Test: `nock server status` connects to local Quiver, gets health response.

### 1C. Server management commands

```
nock server start              # start local Quiver
nock server stop               # stop local Quiver
nock server status             # health check
```

These are the first real commands. They validate the Vayu connection and local server lifecycle.

Tests: start -> status shows healthy -> stop -> status shows not running.

---

## Phase 2: Chart Commands

Gates on: **Quiver 2C** (chart service operational) and **Arrow 2C** (SWE facade producing output).

### 2A. Basic chart command

The flagship command. This is what people will use most.

```
nock chart --date "1990-06-15 14:30" --lat 39.76 --lon -86.15
```

```
commands/
└── chart.dart                 # ChartCommand — parse args, call Vayu, format output
```

Implementation:
1. Parse date, lat, lon, optional flags (--houses, --ayanamsa)
2. Build a CalcRequest (or equivalent Vayu call)
3. Call `vayu.calculateChart(request)`
4. Format and print the result

Start with a simple tabular output. Refine formatting later.

```
Natal Chart
June 15, 1990 — 14:30 — Indianapolis

  Sun      24 Gem 12'    House 10
  Moon      8 Sco 45'    House  4
  Mercury  15 Can 03'    House 11
  ...

  Ascendant   2 Vir 15'
  Midheaven  28 Tau 44'
```

Tests: known date/location produces expected chart output (compare to KalaNG reference values).

### 2B. Output formatting

Build the terminal formatting utilities that all commands will use.

```
output/
├── formatter.dart             # base formatting (align columns, box drawing)
├── chart_formatter.dart       # chart-specific display (signs, degrees, glyphs)
└── table.dart                 # generic table renderer (headers, rows, alignment)
```

Sign display: degree-sign-minute format (`24 Gem 12'`). Retrograde indicator (`R` or ℞). House number alignment.

### 2C. Chart options

Add flags that map to Arrow options:

```
nock chart --date "1990-06-15 14:30" --lat 39.76 --lon -86.15 \
  --houses campanus \
  --ayanamsa lahiri \
  --circle aditya \
  --preset ernst
```

`--preset` loads an ArrowPreset by name. Individual flags override the preset. This mirrors how the API works — presets are convenience, options are explicit.

Tests: each flag produces the expected config change in the request.

---

## Phase 3: Extended Commands

### 3A. Remote mode and auth

Implement `--remote` mode and authentication.

```
nock login                     # authenticate with Supabase, store token
nock logout                    # clear stored token
nock --remote chart ...        # connect to Remote Quiver with auth
```

Auth flow: `nock login` opens a browser for Supabase auth (or accepts a token paste). Token stored in `~/.nock/credentials.json` (or XDG config).

Gates on: **Quiver 3A** (JWT validation).

### 3B. Varga command

Show divisional chart placements for a given chart.

```
nock varga --date "1990-06-15 14:30" --lat 39.76 --lon -86.15 --division 9
```

Output: body positions in the selected varga (navamsha, dashamsha, etc.).

Gates on: **Arrow 3B** (varga calculations).

### 3C. Dasha command

Show dasha periods for a chart.

```
nock dasha --date "1990-06-15 14:30" --lat 39.76 --lon -86.15
nock dasha --date "1990-06-15 14:30" --lat 39.76 --lon -86.15 --system vimshottari --levels 3
```

Output: hierarchical dasha tree (mahadasha > antardasha > pratyantardasha).

Gates on: **Arrow 4A** (Vimshottari dasha).

### 3D. Strength command

Show shadbala breakdown.

```
nock strength --date "1990-06-15 14:30" --lat 39.76 --lon -86.15
```

Output: table with all 6 bala components per planet + totals.

Gates on: **Arrow 4D** (shadbala).

### 3E. Transit command

Show current transits relative to a natal chart.

```
nock transits --chart saved:my_natal
nock transits --date "1990-06-15 14:30" --lat 39.76 --lon -86.15 --transit-date now
```

This requires Arrow to calculate a second chart (transit positions) and compare them to the natal.

### 3F. Interpret command (remote only)

LLM interpretation via KalaBrain.

```
nock --remote interpret --date "1990-06-15 14:30" --lat 39.76 --lon -86.15
nock --remote interpret --chart saved:my_natal --prompt "focus on career"
```

Gates on: **Quiver 4A-4B** (KalaBrain integration).

---

## Phase Ordering and Cross-Project Sync

```
Phase  Step   What                     Depends on                    Unlocks
─────  ────   ────                     ──────────                    ───────
  1     1A    Scaffold + CLI           nothing                       -
  1     1B    Vayu connection          Quiver 1C (health server)     -
  1     1C    Server management cmds   1B                            -

  2     2A    Chart command            Quiver 2C + Arrow 2C          -
  2     2B    Output formatting        2A                            -
  2     2C    Chart options            2A + Arrow 1B (enums)         -

  3     3A    Remote mode + auth       Quiver 3A (JWT)               -
  3     3B    Varga command            Arrow 3B                      -
  3     3C    Dasha command            Arrow 4A                      -
  3     3D    Strength command         Arrow 4D                      -
  3     3E    Transit command          Arrow 2C (second chart calc)  -
  3     3F    Interpret command        Quiver 4A-4B (KalaBrain)      -
```

### What can run in parallel

- **1A** (scaffold) has zero dependencies. Start immediately.
- **1B-1C** need only Quiver's health check server — can start early.
- **2A** is the critical gate: needs both Quiver chart service AND Arrow SWE output.
- **3A** (auth) can proceed independently once Quiver has JWT validation.
- **3B-3F** each gate on specific Arrow/Quiver capabilities. Build them as those capabilities land.

### Cross-project timeline

```
Arrow              Quiver                Nock
─────              ──────                ────
1A scaffold        1A scaffold           1A scaffold
1B enums           1B proto (health)
2A sweph spike     1C health server ───► 1B Vayu connection
                                         1C server mgmt cmds
2C SWE facade ──► 2A-2C chart service ─► 2A chart command
                                         2B formatting
                                         2C chart options
3A-3E core         3A JWT ─────────────► 3A remote + auth
3B vargas                                3B varga cmd
4A dashas                                3C dasha cmd
4D shadbala                              3D strength cmd
                   4A-4B KalaBrain ────► 3F interpret cmd
```

---

## Done Criteria

Nock Phase 1-2 is complete when:
- `nock server start/stop/status` manages local Quiver
- `nock chart` produces correctly formatted chart output matching KalaNG reference values
- All chart options (houses, ayanamsa, circle, preset) work

Nock Phase 3 is complete when:
- `nock --remote` authenticates and connects to Remote Quiver
- Varga, dasha, strength, transit commands produce correct output
- `nock --remote interpret` sends requests to KalaBrain and displays results

## Sonnet Guidance

- **Phase 1 is fully mechanical.** CLI scaffold, arg parsing, gRPC client connection.
- **Phase 2** is mostly formatting. The chart data comes from Vayu — Nock just displays it. Focus on clean, aligned terminal output.
- **Every command is documentation.** The source code of `chart.dart` should read as a tutorial for "how to request a chart from Quiver." Comments in command files should explain the API, not the CLI parsing.
- **Don't stub commands for capabilities that don't exist.** If Arrow can't calculate dashas yet, don't add a dasha command. Add it when the capability lands.
- **Don't build a custom terminal UI framework.** Use simple box-drawing and printf-style alignment. Evaluate existing Dart terminal libraries, pick one if suitable, otherwise keep it simple.
- **Match the command structure from `claude/arch/base.md`** but only build commands as their backing capabilities become available.
