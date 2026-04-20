# Arjuna Implementation Plan — Unified Timeline

## Guiding Principle

Build thoroughly, intentionally, methodically from the ground up. Every layer, every step includes logging, error handling, and testing as it is built — not bolted on afterward. Each piece is complete before the next begins.

This is the unified view across all five Arjuna components plus Fletch. Each component has its own detailed plan:

| Component | Plan |
|-----------|------|
| Arrow | `arrow/claude/impl/one.md` |
| Quiver | `quiver/claude/impl/one.md` |
| Nock | `nock/claude/impl/one.md` |
| Bowyer | `bowyer/claude/impl/one.md` |
| Fletch | `../fletch/claude/impl/one.md` |

---

## The Dependency Chain

Arrow is the foundation. Everything else depends on it at different stages.

```
Arrow produces output
  -> Quiver serves it over gRPC
    -> Nock consumes it as a CLI
    -> Bowyer inspects it as admin tooling
  -> Fletch validates it against other engines
```

The critical path is: **Arrow SWE facade -> Quiver chart service -> Nock chart command**. Everything else branches off this spine.

---

## Unified Timeline

### Wave 1: Scaffolding (no dependencies)

All projects scaffold simultaneously. Zero cross-project dependencies.

```
Arrow     1A  Monorepo scaffold (melos, 4 packages)
Quiver    1A  Package scaffold (core, server, embedded)
Bowyer    1A  Package scaffold (core, web, cli)
Fletch    --  Package scaffold (core, astro)
(Nock     1A  DEFERRED)
```

### Wave 2: Foundation types + gRPC validation (parallel tracks)

Two independent tracks run simultaneously:

**Track A: Arrow types (Sonnet)**
```
Arrow     1B  All enums and config types (arrow_options)
Arrow     1C  Location type
```

**Track B: gRPC ecosystem validation**
```
Quiver    1B  Proto setup (health.proto, code generation)
Quiver    1C  Health check server (first gRPC server in Dart)
```

**Track C: Fletch core (independent)**
```
Fletch    1   Contracts and types (adapter, schema, tolerance)
Fletch    2   Diff engine
Fletch    3   Execution + comparison engine
```

### Wave 3: SWE exploration + early consumers

**Track A: Arrow SWE (Josh)**
```
Arrow     2A  sweph.dart spike (exploratory, throwaway)
Arrow     2B  EphSnapshot design (from spike findings)
```

below was originally under Wave 4. obviously, this is asap. we need this to know that
building this is actually feasible, so this comes first
Arrow SWE facade produces real output. This is the single most important milestone.

**Track B: Pure Dart derivation (Sonnet — can start during 2A)**
```
Arrow     3A  Sign + nakshatra placement (needs only arrow_options)
Arrow     3B  Varga calculations
```

**Track C: First consumers of Quiver health check**
```
Bowyer    1B  Quiver health client
Bowyer    1C  Status command (CLI)
Bowyer    1D  Status page (Web)
(Nock     1B-1C  DEFERRED)
```

**Track D: Fletch astro (independent)**
```
Fletch    4   Astro schema + tolerances
Fletch    5   KalaNG adapter (calls existing KalaEngine.Api)
```

### Wave 4: Arrow goes live — the critical unlock

Arrow SWE facade produces real output. This is the single most important milestone.

```
Arrow     2C  SWE facade implementation (calcAll -> EphSnapshot)
```

This unlocks everything:

```
Quiver    2A  Proto (chart calculation contract)
Quiver    2B  Arrow gateway (core)
Quiver    2C  Chart service (server)
Quiver    2D  Isolate management
```

Which in turn unlocks:

```
Bowyer    2A  Debug calc tool
Fletch    6   Arrow adapter (Arrow becomes a comparison target)
(Nock     2A-2C  DEFERRED)
```

### Wave 5: Arrow core + domain model

```
Arrow     3C  Rich domain model (Chart, Planet/Graha/Karaka, Cusp)
Arrow     3D  Dignity + friendship
Arrow     3E  Chara karakas
```

### Wave 6: Auth + analysis

**Track A: Authentication**
```
Quiver    3A  JWT validation
Quiver    3B  Vayu (embedded + forwarding)
(Nock     3A  DEFERRED)
```

**Track B: Arrow calc (all mostly independent once 3C exists)**
```
Arrow     4A  Vimshottari dasha
Arrow     4B  Aspects
Arrow     4C  Ashtakavarga
Arrow     4D  Shadbala
Arrow     4E  Yogas
Arrow     4F  Jaimini
Arrow     4G  Avasthas + Tajika
```

**Track C: Fletch validation**
```
Fletch    7   libkala adapter (3-way comparison)
Fletch    8   Input generators
```

### Wave 7: KalaBrain + extended features

```
Quiver    4A  KalaBrain client (direct, no broadhead abstraction)
Quiver    4B  Request routing
Bowyer    4A  KalaBrain monitoring
(Nock     3F  DEFERRED)
```

### Wave 8: Advanced (as needed)

```
Bowyer    3A  Log streaming
Bowyer    3B  Metrics
Fletch    9   Consensus + outlier detection
Fletch    10  Web UI
(Nock     all remaining  DEFERRED)
```

---

## What To Start Immediately

Five things can start right now with zero dependencies:

1. **Arrow 1A** — scaffold the monorepo
2. **Quiver 1A** — scaffold packages
3. **Nock 1A** — scaffold CLI
4. **Bowyer 1A** — scaffold packages
5. **Fletch scaffold** — scaffold packages

After scaffolding:
- **Arrow 1B** (enums — Sonnet) and **Arrow 2A** (sweph spike — Josh) run in parallel
- **Quiver 1B-1C** (proto + health server) runs in parallel with Arrow
- **Fletch 1-3** (core engine) runs in parallel with everything

---

## Deferred Decisions

These are NOT in this plan. They are documented as blueprints for when they become relevant:

| Decision | Blueprint location | Trigger |
|----------|-------------------|---------|
| Additional traditions (Hellenistic, Western, etc.) | `arrow/claude/arch/universal-options.md` | When tradition #4+ is being built (Vedic, Cards of Truth, and Human Design are active) |
| Broadhead abstraction | `quiver/claude/arch/future.md` | When external service #2 appears |
| Caching | - | When real usage data shows repeated calcs |
| Local/remote routing criteria | - | When Arrow calc performance is measured |
| Vayu for non-Dart frontends | - | When a non-Flutter frontend is being built |

---

## Sonnet Session Guide

When starting a session with Sonnet, provide:

1. This unified plan (for context on where things stand)
2. The detailed plan for the specific component being worked on
3. The actual code built so far
4. A clear directive: "We are on Step X. Here's what exists. Build Y."

Keep sessions focused — one step per session. Feed the output of one session as input to the next.

### What Sonnet handles well

- Arrow 1B (enums — large, mechanical, clear source material)
- Arrow 3A-3E (pure Dart derivation — port from C#/Python)
- Arrow 4A-4G (analysis — port from C#/Python)
- Quiver 1A-1C (gRPC scaffold — well-documented patterns)
- Nock commands (CLI arg parsing + Vayu calls + output formatting)
- Fletch core (contracts, diff engine — well-defined abstractions)

### What needs Josh

- Arrow 2A (sweph.dart spike — exploratory, needs judgment)
- Arrow 2B (EphSnapshot design — architectural decision from spike)
- Proto contract design (what the wire format looks like)
- Any "source material disagrees" situations
