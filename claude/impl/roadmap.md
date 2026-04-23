# Arjuna Roadmap

## Current State (April 2026)

**Arrow** — Core calculation engine. Options, SWE facade, domain model, and initial calc layer (avasthas, aspects, panchanga) are built and tested. The foundation is solid; remaining work is adding more calculations.

**Quiver** — gRPC server. Health check and chart calculation services working end-to-end. Proto contracts defined. No auth, no isolate pool, no embedded mode yet.

**Nock** — CLI app. Health and chart commands working against Quiver. Basic output formatting.

**Bowyer** — Scaffolded only. Core + CLI packages exist, no features.

**Proto** — Health, types, and chart contracts defined. Generated Dart stubs in quiver_core.

## Roadmap

### Phase A: Infrastructure

Make the dev experience smooth before adding more calculations.

- **Vayu** — Embedded Quiver (in-process Arrow, no server needed). Makes Nock usable standalone.
- **Isolate pool** — Concurrent request handling in Quiver server. Each isolate gets its own SwissEph C state.
- **Nock output** — Rich chart display using Arrow's domain model (signs, nakshatras, dignities, formatted degrees).
- **Proto codegen script** — Melos script to regenerate all proto stubs in one command.

### Phase B: More Calculations in Arrow

Pure Dart, no external deps. Each calculation gets wired through Quiver and exposed via Nock.

- **Vimshottari dasha** — Most common dasha system. `nock dasha`.
- **Panchanga through Quiver** — Already implemented in Arrow, needs proto + service + Nock command.
- **Ashtakavarga** — Depends on aspects (done).
- **Shadbala** — Six-component planetary strength.
- **Yogas** — Pattern matching on chart positions.
- **Jaimini** — Arudha padas, karakamsa. Depends on chara karakas (done).
- **Tajika** — Annual charts, sahams.

### Phase C: Auth and Remote

- **JWT validation** — Supabase Auth on every remote Quiver request. Health check exempt.
- **Vayu routing** — Local calcs stay local, remote-only features (broadheads) forward with JWT.
- **Nock --remote** — Connect to deployed Quiver with auth.

### Phase D: Admin and Monitoring

- **Bowyer health dashboard** — Server status, uptime, connected clients.
- **Bowyer calc debugger** — Send test calculations, inspect results.
- **Bowyer log viewer** — Stream server logs.
- **Bowyer metrics** — Request counts, latency, error rates.

### Phase E: KalaBrain Integration

- **Direct gRPC client** in Quiver to KalaBrain (no broadhead abstraction yet).
- **Request routing** — Arrow calcs handled locally, interpretation forwarded to KalaBrain.
- **Nock interpret commands** — `nock interpret` sends chart + question to KalaBrain.

### Phase F: Multi-Tradition

Arrow's CalcConfig is already modular with `Set<Tradition>`. Extend beyond Vedic:

- **Cards of Truth** — Uses equatorial sunrise + planet placements. `CardsOfTruthConfig` exists in options.
- **Human Design** — Precise planetary positions for gate/line placement. `HumanDesignConfig` planned.
- **Hellenistic, Modern Western** — Future tradition configs.

### Phase G: Fletch Integration

Fletch (comparison engine) validates Arrow against KalaNG and libkala.

- **Arrow adapter** — Arrow becomes a comparison target.
- **SWE-level comparison** — Positions, cusps, ayanamsa values.
- **Derived comparison** — Signs, nakshatras, vargas, dignities.
- **Dasha comparison** — Dates must match exactly.
- **Shadbala comparison** — Deepest numerical validation.

## Cross-Component Pattern

Every new Arrow calculation follows the same pipeline:
1. Implement in `arrow_calc` with tests
2. Define proto messages and RPC
3. Add Quiver service + gateway mapping
4. Add Nock command
5. (Eventually) Add Bowyer debug view
