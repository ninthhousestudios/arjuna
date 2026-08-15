# arjuna

Universal astrological calculation service. Dart-first monorepo: one calc engine
(**Arrow**) runs unchanged on-device and server-side.

Architecture, component roles, and the on-device/remote split live in `README.md`
— read it once for orientation. This file is agent operating instructions.

## Trunk

`main` is trunk. Commit to `main` at logical boundaries; push is Josh's call.
"Done" means committed to `main`. There is no separate integration branch to
merge into.

## Workspace layout

Melos-managed Dart workspace (`pubspec.yaml` → `workspace:` list). Each component
below its own directory; the load-bearing ones carry their own `CLAUDE.md` with
the detail — start there before editing:

| Dir | Role | Deep docs |
|-----|------|-----------|
| `arrow/` | Calc engine — `options → swe → core → calc` layered Dart packages | `arrow/CLAUDE.md` (read before touching Arrow) |
| `quiver/` | gRPC server + embeddable engine (`core`, `server`, `embedded`) | `quiver/CLAUDE.md` |
| `nock/` | CLI astrology client + living API docs | `nock/CLAUDE.md`, `nock/README.md` |
| `drishti/` | MCP server exposing Arrow to agents (wraps `quiver_embedded`) | — |
| `bowyer/` | Admin panel (Flutter Web + CLI) — scaffold today | — |
| `proto/` | Shared `.proto` contracts — single source of truth for gRPC | — |

## Commands (run from repo root)

```bash
melos bootstrap     # resolve + link workspace deps (run after pubspec changes)
melos analyze       # dart analyze across all packages
melos test          # dart test across all packages
melos generate      # build_runner (freezed, json) for packages that need it
melos protogen      # regenerate Dart gRPC stubs from proto/ (see pubspec note)
```

`melos protogen` needs `protoc` and `protoc-gen-dart`
(`dart pub global activate protoc_plugin`). Regenerate stubs whenever a `.proto`
changes — generated code lives in `quiver/core/lib/src/generated`, don't hand-edit.

## Conventions

- **Arrow's two-config boundary** (`SweConfig` = expensive ephemeris recompute vs
  `CalcConfig` = free reinterpretation) governs most calc work. It's the single
  most important concept for changes touching charts — see `arrow/CLAUDE.md`.
- Layer dependencies flow one way: `options → swe → core → calc`. Non-SWE code
  never calls Swiss Ephemeris directly; it goes through `arrow_swe`.
- Native lib: `arrow_swe` binds Swiss Ephemeris via `dart:ffi`
  (`swisseph.dart`). `scripts/check-quiver-native-lib.sh` and
  `docs/swisseph-rs-native-lib.md` cover the native-library plumbing.
- Verify with `melos analyze` + `melos test` before claiming work done.
