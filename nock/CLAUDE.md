# Nock

Full CLI astrology app + living API docs for Quiver. Every Quiver endpoint has a corresponding Nock command. If an endpoint exists and Nock doesn't have a command for it, that's a bug.

## Architecture

Dart CLI. Connects through Vayu (same boundary as Celestial).

Two connection modes:
- **Local (default)** — starts a local Quiver server, connects via gRPC on localhost. Full Arrow calcs, no auth, no internet.
- **Remote (`--remote`)** — connects to Remote Quiver over gRPC. Auth required. Broadheads available.

```
nock/
├── bin/nock.dart            # entry point
├── lib/
│   └── src/
│       └── commands/        # one file per command (chart, transits, synastry, etc.)
└── pubspec.yaml
```

## Key architecture docs

- `claude/arch/base.md` — full command structure, connection modes, terminal output design

## Implementation guidance

### Current status

Pre-implementation. Architecture docs and implementation plan exist. No code yet.

### Rules for Nock

- **Every command is an API usage example.** Nock source IS the Quiver API documentation. Write commands so that reading the source teaches you the API.
- **Nock follows Arrow + Quiver.** Add chart commands when Arrow can calculate charts. Add interpret commands when KalaBrain broadhead works. Don't stub commands for capabilities that don't exist yet.
- **Rich terminal output.** Use box-drawing characters, alignment, and clear formatting. Find or evaluate a Dart terminal library for this.
- **`package:logging`** with hierarchy: `Nock`.
