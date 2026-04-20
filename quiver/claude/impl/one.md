# Quiver Implementation Plan

> **EARLY VALIDATION: Dart gRPC JSON codec.** The architecture assumes gRPC binary + JSON on the same port via a codec registry. Dart's `grpc` package may not have built-in JSON codec support — this could require custom implementation or a third-party library. Phase 1B (proto setup) MUST verify that JSON codec works with Dart gRPC. If it requires significant custom work, the "same port, two codecs" design may need revision.

## Guiding Principle

Same as all Arjuna projects: build thoroughly, intentionally, methodically from the ground up. Every layer includes logging, error handling, and testing as it is built.

## Conventions

- **Directory names**: short. `quiver/core/` not `quiver/quiver_core/`. Dart package name in pubspec.yaml is `quiver_core`.
- **Logging**: `package:logging`. Hierarchy: `Quiver.Server`, `Quiver.Core`, `Quiver.Embedded`.
- **Proto**: all `.proto` files live in `arjuna/proto/`. Generated code goes into each consumer package.
- **No broadhead abstraction yet.** KalaBrain is the only external service. Integrate it directly. See `claude/arch/future.md`.
- **No caching yet.** Build without it. Add when real usage data shows necessity.

## Directory Structure

```
quiver/
├── core/        # quiver_core: shared logic (arrow gateway, models, config)
├── server/      # quiver_server: remote gRPC server (auth, routing, services)
├── embedded/    # quiver_embedded: local embedded library (Vayu)
└── claude/
```

Dependency graph:
```
quiver_core       (depends on: arrow_options, arrow_swe, arrow_core)
     ^
quiver_server     (depends on: quiver_core, grpc)
quiver_embedded   (depends on: quiver_core)
```

---

## Phase 1: Scaffold and Health Check

### 1A. Scaffold packages

Create the three package directories with pubspec.yaml files and barrel exports. Wire up melos (or standalone pubspecs with path deps). Verify everything resolves.

```
quiver/
├── core/
│   ├── pubspec.yaml          # name: quiver_core
│   └── lib/
│       └── quiver_core.dart
├── server/
│   ├── pubspec.yaml          # name: quiver_server
│   ├── bin/
│   │   └── server.dart       # entry point
│   └── lib/
│       └── quiver_server.dart
└── embedded/
    ├── pubspec.yaml          # name: quiver_embedded
    └── lib/
        └── quiver_embedded.dart
```

Done when: `dart analyze` passes on all three packages.

**Sync point**: can start immediately. No Arrow dependency.

### 1B. Proto setup — health check

Create the first proto file. This validates the proto toolchain, code generation, and that Dart gRPC works at all.

```
arjuna/proto/
└── quiver/
    └── health.proto
```

```protobuf
syntax = "proto3";
package quiver;

service HealthService {
  rpc Check (HealthRequest) returns (HealthResponse);
}

message HealthRequest {}

message HealthResponse {
  bool healthy = 1;
  string version = 2;
  int64 uptime_seconds = 3;
}
```

Generate Dart server stubs into quiver_server. Verify the generated code compiles.

Done when: generated Dart code exists and compiles.

### 1C. Health check server

The absolute minimum gRPC server. One service, one RPC. This answers:
- Does Dart gRPC server startup/shutdown work cleanly?
- Does the JSON codec work? (request with `application/grpc+json`)
- What does graceful shutdown look like?
- What's the connection lifecycle?

```
server/lib/src/
├── server.dart                # QuiverServer class — start, stop, configure
└── services/
    └── health_service.dart    # HealthService implementation
```

```
server/bin/
└── server.dart                # main() — parse args, start server
```

Tests:
- Server starts, responds to health check, stops cleanly
- JSON codec request returns valid JSON response
- Graceful shutdown waits for in-flight requests

Done when: `dart run quiver_server` starts a gRPC server on a port, `grpcurl` can hit the health endpoint with both binary and JSON, server shuts down cleanly on SIGINT.

**Sync point**: Nock 1A (scaffold) and Bowyer 1A (scaffold) can start after this — they now have a server to talk to. Fletch is independent.

---

## Phase 2: Arrow Gateway

Gates on: **Arrow 2C** (SWE facade producing EphSnapshot).

### 2A. Proto — chart calculation

Define the chart calculation proto. This is the core contract.

```
arjuna/proto/
└── arrow/
    ├── chart.proto            # ChartService, CalcRequest, CalcResponse
    └── types.proto            # Shared types (Location, BodyPosition, etc.)
```

The proto types mirror Arrow's domain model but are NOT the same classes — they're the wire format. Mapping between proto types and Arrow domain types happens in quiver_core.

### 2B. Arrow gateway (quiver_core)

The bridge between gRPC and Arrow. Takes proto requests, calls Arrow, returns proto responses.

```
core/lib/src/
├── gateway/
│   └── arrow_gateway.dart     # ArrowGateway — calls SweFacade, builds Chart, maps to proto
├── mapping/
│   ├── request_mapper.dart    # Proto CalcRequest -> Arrow types (Location, SweConfig, etc.)
│   └── response_mapper.dart   # Arrow Chart/EphSnapshot -> Proto CalcResponse
└── config/
    └── quiver_config.dart     # Server configuration (port, log level, Arrow settings)
```

ArrowGateway:
```dart
class ArrowGateway {
  final SweFacade _swe;

  Future<CalcResponse> calculateChart(CalcRequest request) async {
    final location = RequestMapper.toLocation(request);
    final config = RequestMapper.toSweConfig(request);
    final jd = RequestMapper.toJulianDay(request);

    final snapshot = await _swe.calcAll(jd, location, config);
    final chart = Chart(snapshot, RequestMapper.toCalcConfig(request));

    return ResponseMapper.fromChart(chart, snapshot);
  }
}
```

Tests: given a CalcRequest proto, ArrowGateway produces a CalcResponse with correct values. Test the full round-trip: proto in -> Arrow calc -> proto out.

### 2C. Chart service (quiver_server)

Wire the ArrowGateway into a gRPC service.

```
server/lib/src/
└── services/
    └── chart_service.dart     # ChartService — gRPC service wrapping ArrowGateway
```

Tests: gRPC client sends CalcRequest, receives CalcResponse with real chart data.

**Sync point**: Arrow is now accessible over gRPC. This unlocks:
- **Nock 2A** — chart command (first real CLI command)
- **Bowyer 2A** — debug calc tool
- **Fletch 6** — Arrow adapter (can compare Arrow output via Fletch)

### 2D. Isolate management

Arrow's SWE layer uses dart:ffi to a C library with global state. Each isolate gets its own C state. Quiver needs an isolate pool to handle concurrent requests.

```
server/lib/src/
├── isolate/
│   ├── arrow_isolate.dart     # Single Arrow isolate (SweFacade instance)
│   └── isolate_pool.dart      # Pool of Arrow isolates, request dispatch
```

Start simple: fixed pool size (e.g., 4). Make it configurable. Measure actual concurrency needs later.

Tests: concurrent chart requests return correct results without interference.

---

## Phase 3: Authentication

### 3A. JWT validation

Supabase Auth issues JWTs. Quiver validates on every request.

```
server/lib/src/
├── auth/
│   ├── jwt_validator.dart     # Validate JWT signature, expiry, claims
│   └── auth_interceptor.dart  # gRPC interceptor — validates before service handler
```

Use a Dart JWT library. Validate against Supabase's JWKS endpoint (or a configured public key).

The interceptor rejects requests with missing/invalid/expired tokens. Health check is exempt (no auth needed for health).

Tests: valid JWT passes, expired JWT rejected, missing JWT rejected, health check works without JWT.

### 3B. Auth in embedded mode

Local Quiver (Vayu) skips auth — it's in the same process as the user. But when forwarding to Remote Quiver, it attaches the JWT.

```
embedded/lib/src/
└── vayu.dart                  # Vayu — local Arrow calls + remote forwarding with JWT
```

This is a simple routing decision:
- Can handle locally? -> call ArrowGateway directly (no auth)
- Needs remote? -> forward via gRPC client with JWT in metadata

For now, "can handle locally" means "is it an Arrow calc?" (yes = local). The routing criteria will evolve based on real performance data.

---

## Phase 4: KalaBrain Integration

### 4A. Direct KalaBrain client

KalaBrain is the only external service. No broadhead abstraction — just a direct gRPC client.

```
server/lib/src/
├── kalabrain/
│   ├── kalabrain_client.dart  # gRPC client to KalaBrain
│   └── kalabrain_config.dart  # URL, timeout, retry settings
```

KalaBrain has its own proto definitions (in its own repo). Quiver imports them. The client is straightforward — call KalaBrain, pass through JWT, return response.

### 4B. Request routing

Simple routing: is this an Arrow calc? Handle it. Is it for KalaBrain? Forward it. Neither? Error.

```
server/lib/src/
├── routing/
│   └── router.dart            # Route request to Arrow or KalaBrain
```

No pattern matching, no registry. Just a conditional. When a second external service arrives, extract the pattern.

Tests: Arrow requests go to Arrow, KalaBrain requests go to KalaBrain, unknown requests return error.

**Sync point**: Nock `--remote` interpret commands now work. Bowyer can show KalaBrain health.

---

## Phase Ordering and Cross-Project Sync

```
Phase  Step   What                          Depends on                  Unlocks
─────  ────   ────                          ──────────                  ───────
  1     1A    Scaffold packages             nothing                     -
  1     1B    Proto setup (health)          1A                          -
  1     1C    Health check server           1B                          Nock 1B, Bowyer 1B

  2     2A    Proto (chart)                 Arrow 2B (EphSnapshot)      -
  2     2B    Arrow gateway (core)          Arrow 2C (SweFacade)        -
  2     2C    Chart service (server)        2A + 2B                     Nock 2A, Bowyer 2A, Fletch 6
  2     2D    Isolate management            2C                          -

  3     3A    JWT validation                1C                          -
  3     3B    Vayu (embedded + forwarding)  2B + 3A                     -

  4     4A    KalaBrain client              3A                          -
  4     4B    Request routing               2C + 4A                     Nock interpret
```

### What can run in parallel

- **Phase 1** (scaffold + health check) has zero Arrow dependency. Start immediately.
- **Phase 3** (auth) needs only the health check server — can proceed while Phase 2 waits for Arrow.
- **Phase 2** gates on Arrow 2C (SweFacade). This is the critical dependency. While waiting, do Phase 1 and Phase 3.
- **Phase 4** (KalaBrain) can proceed once auth works, independent of Arrow progress.

### Cross-project timeline

```
Arrow                    Quiver                 Nock              Bowyer           Fletch
─────                    ──────                 ────              ──────           ──────
1A scaffold              1A scaffold            -                 -                1 contracts
1B enums                 1B proto (health)      -                 -                2 diff engine
2A sweph spike           1C health server       1B scaffold       1B scaffold      3 execution
2B EphSnapshot           3A JWT validation      -                 -                4 astro schema
2C SWE facade ─────────► 2A-2C chart service ──► 2A chart cmd ──► 2A debug calc   5 KalaNG adapter
3A-3E core               2D isolates            2B display        2B logs          6 Arrow adapter
4A-4G calc               4A-4B KalaBrain        3A more cmds      3A metrics       7+ later
```

---

## Done Criteria

Quiver Phase 1-2 is complete when:
- Health check responds over gRPC (binary and JSON)
- Chart calculation request produces correct results matching Arrow directly
- Isolate pool handles concurrent requests without interference
- Server starts and stops cleanly

Quiver Phase 3-4 is complete when:
- JWT validation rejects bad tokens, passes good ones
- Vayu routes local calcs to Arrow, remote requests with JWT
- KalaBrain requests forward correctly with JWT passthrough
- Unknown request types return appropriate errors

## Sonnet Guidance

- **Phase 1 is fully mechanical.** Scaffold, proto generation, basic gRPC server — well-defined, no judgment calls needed.
- **Phase 2 requires Arrow to exist.** Don't stub Arrow — wait for real SweFacade output. The mapping between proto types and Arrow types is mechanical once both sides exist.
- **Phase 3 (auth)** is standard JWT validation. Use a well-maintained Dart JWT library. Don't roll your own crypto.
- **Phase 4 (KalaBrain)** is a direct gRPC client. No abstraction layer, no plugin system, no registry.
- **Don't build caching.** It's not in this plan.
- **Don't build a broadhead system.** Just call KalaBrain directly.
- **Don't anticipate Vayu routing logic.** For now, "is it a calc?" is the only question. The criteria will evolve from real performance data.
