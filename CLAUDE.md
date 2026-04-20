# Arjuna

Universal astrological calculation service. Components follow an archery metaphor.

## Components

| Component | Name | Role | Tech |
|-----------|------|------|------|
| Calc Engine | **Arrow** | Pure Dart library, on-device and server | Dart |
| Server | **Quiver** | gRPC API server, broadhead proxy, auth | Dart gRPC |
| Admin | **Bowyer** | Management, logs, metrics, debugging | Flutter Web + Dart CLI |
| CLI | **Nock** | CLI astrology app + living API docs | Dart CLI |
| Contracts | **proto/** | Shared .proto files, single source of truth | Protocol Buffers |

## Architecture

```
Flutter App → Vayu ─── Local Arrow (on-device)
                   └── gRPC to Remote Quiver → Arrow (isolates) + Broadheads + Auth
```

**Vayu** is the frontend boundary — hides local vs remote routing.

### Arrow — 3-Layer Pipeline

```
arrow_options  ← enums, configs, ArrowOptions (freezed)
arrow_swe      ← sweph.dart (dart:ffi) → EphSnapshot
arrow_core     ← pure Dart: domain model (Chart, Planet/Graha/Karaka, Cusp)
arrow_calc     ← pure Dart: dashas, yogas, shadbala, per-tradition subdirs
```

Each layer depends only on the previous. Non-SWE code never calls SWE — only sees EphSnapshot.

### Config Split

- **SweConfig** — changes raw positions, triggers SWE recalc (ayanamsa, house system, node type, bodies)
- **CalcConfig** — derived calculations only (tradition modules, circle, varga variants, dasha options). Same EphSnapshot, new Chart.

### Coordinate Systems

Default: tropical with **Aditya Circle** (sign 1 at 330 ecliptic). `Circle.ZODIAC` starts at 0. Signs and nakshatras have independent ayanamsas. Default nakAyanamsa: dhruva (Galactic Center / mid-Mula, equatorial).

## Naming Convention — Sub-packages

Short directory names. `arrow/swe/` not `arrow/arrow_swe/`. Dart package name is `{component}_{short}`. No `packages/` intermediary.

## Directory Structure

```
arjuna/
├── arrow/           ← Calc engine (options/, swe/, core/, calc/, claude/)
├── quiver/          ← Server (core/, server/, embedded/)
├── proto/           ← Shared .proto contracts
├── bowyer/          ← Admin (core/, web/, cli/)
├── nock/            ← CLI client
fletch/              ← Comparison engine (peer to arjuna/, not inside)
├── core/, astro/, web/
```

## Implementation Rules

- **Port from libaditya, don't invent.** Surface discrepancies rather than silently picking one.
- **Write tests alongside code.** Test file created in same step as implementation.
- **Log levels:** `fine` per-calc, `info` facade, `warning` fallback, `severe` error. `package:logging` with hierarchy (`Arrow.Swe`, `Quiver.Server`).
- **No premature abstraction.** No ABC/registry/plugin until two real implementations exist.
- **Broadheads are deferred.** Integrate KalaBrain directly.
- **Don't add features not in the plan.**
- **Sub-package dirs are short.** `arrow/swe/` not `arrow/packages/arrow_swe/`.

## Key Architecture Docs

| Doc | Path |
|-----|------|
| Arrow architecture | `arrow/claude/arch/base.md` |
| Arrow domain model | `arrow/claude/arch/domain-model.md` |
| Universal options | `arrow/claude/arch/universal-options.md` |
| Quiver architecture | `quiver/claude/arch/base.md` |
| gRPC proposal | `quiver/claude/arch/grpc-server-proposal.md` |
| Proto ownership | `proto/claude/arch/proto-arch.md` |
| Implementation plan | `arrow/claude/impl/one.md` |
