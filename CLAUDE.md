# Arjuna

Arjuna is a universal astrological calculation service. It is named for the archer — the components follow an archery metaphor.

## Components

| Component | Name | Role | Tech |
|-----------|------|------|------|
| Calc Engine | **Arrow** | Astrology calculations — pure Dart library, runs on-device and server | Dart |
| Server | **Quiver** | Arrow's API server, gRPC primary, broadhead proxy, auth | Dart gRPC |
| Admin | **Bowyer** | Quiver management, logs, metrics, debugging | Flutter Web + Dart CLI |
| CLI | **Nock** | Full CLI astrology app + living API docs for Quiver | Dart CLI |
| Contracts | **proto/** | Shared .proto files — single source of truth for all gRPC contracts | Protocol Buffers |

## Architecture

```
Client Device                              Server
─────────────                              ──────
Flutter App (Celestial, etc.)              Remote Quiver (Dart gRPC)
    │                                          │
    └── Vayu ─── Local Arrow (on-device)       ├── Arrow (server-side, isolates)
              └── gRPC to Remote Quiver        ├── Broadhead proxy → KalaBrain, etc.
                                               ├── Auth (Supabase JWT)
                                               └── Caching
```

**Vayu** is the frontend boundary. Frontends only know Vayu — it handles local vs remote routing transparently.

### Arrow — 3-Layer Pipeline

```
arrow_options   ← enums, SweConfig, CalcConfig, ArrowOptions (freezed)
     ↑
arrow_swe       ← sweph.dart (dart:ffi), ~15 SWE functions → EphSnapshot
     ↑
arrow_core      ← pure Dart: signs, nakshatras, vargas, dignities, karakas
     ↑              rich domain model (Chart, Planet/Graha/Karaka, Cusp)
arrow_calc      ← pure Dart: dashas, yogas, shadbala, ashtakavarga, jaimini
                    per-tradition subdirectories (vedic/, hellenistic/, western/, etc.)
```

Each layer depends only on the previous. Non-SWE code never calls SWE — it only sees EphSnapshot.

### Config Split

- **SweConfig** — changes raw positions, triggers SWE recalculation (ayanamsa, house system, node type, topocentric, bodies, fixed stars)
- **CalcConfig** — affects derived calculations only (tradition modules, circle, varga variants, dasha options). Changes are free — same EphSnapshot, new Chart.
- **ArrowOptions** composes SweConfig + CalcConfig

### Multi-Tradition Support

CalcConfig is modular: a core `Set<Tradition>` plus optional typed configs (VedicConfig, HellenisticConfig, ModernWesternConfig, UranianConfig, PersianConfig, CardsOfTruthConfig, HumanDesignConfig). Named presets: `ArrowPresets.ernst`, `.lahiriVedic`, `.hellenistic`, `.modernWestern`, etc. All traditions flow through the same Arrow pipeline — every system is fundamentally based on birth time, place, and planetary positions.

### Domain Model

Rich objects that don't own their data. They wrap EphSnapshot + CalcConfig.

- **Planet** (base, all bodies) > **Graha** (+ Rahu/Ketu = 9) > **Karaka** (7 embodied). Dignity/combustion on Karaka only.
- **Cusp** — house cusp as longitude point with derived getters
- **Chart** — top-level entry point: `chart.sun.nakshatra`, `chart.cusps`, etc.

On-object: isolated properties. Functions: relationships and multi-body analysis.

### Coordinate Systems

Default: tropical coordinates with the **Aditya Circle** (sign 1 starts at 330 ecliptic). `Circle.ZODIAC` starts at 0 (standard). Circle and ayanamsa are independent. Signs and nakshatras have independent ayanamsas (`signAyanamsa`, `nakAyanamsa`). Default nakAyanamsa: dhruva (Galactic Center / mid-Mula, equatorial).

### Quiver — Server

Two deployment modes, same core code:
- **Remote Quiver** — standalone gRPC server on Railway. Auth, routing, caching, broadheads, Arrow via isolates.
- **Local Quiver (Vayu)** — embedded in-process Dart library. No auth, no port. Direct Arrow calls + forwarding to Remote.

gRPC with JSON codec support on the same port. Protobuf default, JSON for debugging.

### Broadhead System

Quiver proxies to registered external services (KalaBrain for LLM, future modules). Static config, pattern-matched routing. Broadheads implement a generic health/capabilities contract. Each broadhead owns its own service-specific protos.

### Authentication

Supabase Auth issues JWTs. Celestial authenticates once. Quiver validates on every request. Broadheads re-validate independently. Local Quiver (embedded) skips auth — same process.

### Proto Ownership

All .proto files in `arjuna/proto/`. Single source of truth. Code generated into each consumer package. Managed with buf (linting, breaking change detection, BSR distribution for external consumers like KalaBrain).

## Naming Convention — Sub-packages

Sub-packages within a component use **short directory names**, not prefixed names. The Dart package name (in `pubspec.yaml`) is `{component}_{short}`, but the directory is just `{short}`.

```
Directory name:    arrow/swe/         (not arrow/arrow_swe/ or arrow/packages/arrow_swe/)
Package name:      arrow_swe          (in pubspec.yaml, for Dart imports)

Directory name:    quiver/embedded/
Package name:      quiver_embedded
```

No `packages/` intermediary directories. The component directory IS the container.

## Directory Structure

```
arjuna/
├── arrow/                    ← Calc engine (Dart monorepo)
│   ├── options/              ← Enums, config interfaces, ArrowOptions
│   ├── swe/                  ← SWE bindings, EphSnapshot
│   ├── core/                 ← Derivation, rich domain model
│   ├── calc/                 ← Analysis (per-tradition subdirs)
│   ├── claude/arch/          ← Architecture docs
│   ├── claude/struct/        ← Structure proposals, type sketches
│   └── melos.yaml
├── quiver/                   ← Server (core/, server/, embedded/)
├── proto/                    ← Shared .proto contracts
├── bowyer/                   ← Admin panel (core/, web/, cli/)
├── nock/                     ← CLI client
└── CLAUDE.md

soft/back/fletch/             ← Universal comparison engine (peer to arjuna/, not inside it)
├── core/                     ← fletch_core: domain-agnostic engine
├── astro/                    ← fletch_astro: astrology domain package
└── web/                      ← fletch_web: Flutter Web UI
```

## Key Design Decisions

| Decision | Status |
|----------|--------|
| Arrow is standalone Dart library, runs on-device and server | Decided |
| 3-layer pipeline (swe → core → calc) with EphSnapshot bridge | Decided |
| sweph.dart for SWE bindings, freezed for immutability | Decided |
| gRPC between all services, JSON codec fallback | Decided |
| Vayu as frontend boundary (hides local/remote split) | Decided |
| Multi-tradition via modular CalcConfig + per-tradition arrow_calc subdirs | Decided |
| Supabase Auth with JWT passthrough | Decided |
| Dart isolates for SWE thread safety (each isolate = own C state) | Decided |
| Melos for Arrow monorepo management | Decided |
| `package:logging` across all packages | Decided |
| Railway for deployment | Decided |

## Open Questions

- Sync protocol between Local and Remote Quiver (conflict resolution, eventual consistency)
- What determines local vs remote calc routing in Vayu
- Broadhead registration (static config vs dynamic discovery)
- Broadhead-to-Arrow access (through Quiver or direct?)
- Storage layer details (what database, shared between local/remote?)
- Offline queue behavior for broadhead requests
- Vayu for non-Dart frontends (deferred)
- Rate limiting / quotas
- Arrow isolate pool sizing per Quiver instance
- KalaBrain priority queue design for LLM requests
- Aspect and dignity systems: tradition-scoped vs shared engine

## Implementation Guidance

Read the implementation plan before writing code: `arrow/claude/impl/one.md` (Arrow), `../fletch/claude/impl/one.md` (Fletch).

### Rules

- **Read source material before implementing.** Every enum, every calculation has a reference in KalaNG (C#) and/or libkala (Python). Don't invent — port. If the sources disagree, surface the discrepancy rather than silently picking one.
- **Write tests alongside code.** The test file is created in the same step as the implementation file. Not after.
- **Log at appropriate levels.** `fine` for per-calculation details, `info` for facade-level operations, `warning` for fallbacks, `severe` for errors. Use `package:logging` with hierarchical names (`Arrow.Swe`, `Arrow.Core`, `Quiver.Server`).
- **No premature abstraction.** Don't create abstract base classes, registries, or plugin systems until you have two real implementations. See `arrow/claude/arch/future.md` and `quiver/claude/arch/future.md` for rationale.
- **Multi-tradition is deferred.** Build CalcConfig as flat Vedic config. Don't add HellenisticConfig, UranianConfig, etc. The blueprint is in `arrow/claude/arch/universal-options.md` for when the second tradition arrives.
- **Broadheads are deferred.** Integrate KalaBrain directly into Quiver. No abstract broadhead contract. See `quiver/claude/arch/future.md`.
- **Don't add features not in the plan.** No "while I'm here" improvements.
- **Sub-package directory names are short.** `arrow/swe/` not `arrow/arrow_swe/` or `arrow/packages/arrow_swe/`. No `packages/` intermediary. See Naming Convention section above.

## Source Material

Arrow is ported from:
- **KalaNG / KalaC#** — `soft/back/kala/kalang/Astro/` (C# .NET 9)
- **libkala / libaditya** — `soft/back/libkala/` (Python)

## Key Architecture Docs

| Doc | Path |
|-----|------|
| Arjuna overview | `claude/arch/base.md` |
| Scaling, isolates, deployment | `claude/arch/base-addendum.md` |
| Arrow architecture | `arrow/claude/arch/base.md` |
| Arrow domain model | `arrow/claude/arch/domain-model.md` |
| Arrow types sketch | `arrow/claude/arch/types-sketch.dart` |
| Universal options (multi-tradition) | `arrow/claude/arch/universal-options.md` |
| Tropical vs Aditya (Circle) | `arrow/claude/arch/tropical-aditya-distinction.md` |
| Varga constants | `arrow/claude/arch/varga-constants.dart` |
| Arrow package structure | `arrow/claude/struct/detailed-struct-proposal.md` |
| Core types (code sketch) | `arrow/claude/struct/core-types.dart` |
| Quiver full architecture | `quiver/claude/arch/base.md` |
| gRPC server proposal | `quiver/claude/arch/grpc-server-proposal.md` |
| gRPC with JSON + Dart examples | `quiver/claude/arch/grpc-with-json-includes-dart-examples.md` |
| Desktop routing | `quiver/claude/arch/desktop.md` |
| Proto ownership | `proto/claude/arch/proto-arch.md` |
| Fletch architecture | `../fletch/claude/arch/base.md` |
| Bowyer architecture | `bowyer/claude/arch/base.md` |
| Nock architecture | `nock/claude/arch/base.md` |
