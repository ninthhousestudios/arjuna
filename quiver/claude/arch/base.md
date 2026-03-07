# Quiver — Complete Feature & Decision Reference

---

## Identity

**Arrow's API server.** That is its primary job. Everything else is secondary.

Quiver is the only way the outside world talks to Arrow. It runs in two modes — as a remote server and as an embedded library — using the same core code.

---

## Vayu — The Frontend Boundary

Vayu is the **only thing any frontend needs to know about**. It is the true boundary between front and back. The frontend doesn't know about Arrow, Quiver, broadheads, KalaBrain, gRPC, local vs remote, caching, or auth token forwarding. None of it.

```dart
class Vayu {
  Future<ChartResult> calculateChart(BirthData data);
  Future<TransitResult> calculateTransits(TransitRequest request);
  Future<Interpretation> interpret(InterpretRequest request);
  Future<List<SavedChart>> getSavedCharts();
  // ...
}
```

To build a different frontend, you only need to know Vayu.

```
Celestial (Flutter)  ──▶ Vayu (direct Dart call)
Some Web App         ──▶ Vayu (via gRPC/JSON — deferred decision)
Nock (CLI)           ──▶ Vayu (direct Dart call)
```

---

## Folder Structure

```
arjuna/
├── proto/                    ← Shared proto contracts
├── arrow/                    ← Calc engine (pure Dart library)
├── quiver/                   ← All Quiver code
│   ├── core/                 ← Shared logic (arrow gateway, models)
│   ├── server/               ← Remote gRPC server
│   └── embedded/             ← Local embedded library (Vayu)
├── fletch/                   ← Validation client (Flutter Web)
├── bowyer/                   ← Admin panel (Flutter Web)
├── nock/                     ← CLI client (Dart CLI)
└── melos.yaml
```

---

## Deployment Modes

### Remote Quiver (Backend Server)

```
Standalone Dart process
Listens on a port
Speaks gRPC (protobuf default, JSON codec supported)
Full capabilities: auth validation, routing, caching, broadheads, Arrow
```

### Local Quiver (Embedded in Celestial via Vayu)

```
In-process Dart library
No port, no serialization
Direct Dart function calls through Vayu
Subset of capabilities: Arrow, forwarding to Remote
No auth (same process as the user — no need)
```

### Same Core, Different Shells

```
quiver/core/                      ← Shared between both modes
├── arrow_gateway.dart            ← Arrow calc interface
└── models.dart                   ← Shared types

quiver/server/                    ← Remote only
├── main.dart                     ← Listens on port
├── grpc_service.dart             ← Serialization layer
├── auth.dart                     ← JWT validation
├── cache.dart                    ← Caching logic
├── router.dart                   ← Request routing
├── broadhead_registry.dart       ← Module config/forwarding
└── imports quiver/core

quiver/embedded/                  ← Local only
├── vayu.dart                     ← Frontend-facing API
├── local_arrow.dart              ← Direct Arrow calls
├── remote_forwarder.dart         ← gRPC stub to Remote Quiver
└── imports quiver/core
```

---

## Communication Protocol

### gRPC with JSON Codec Support

Single gRPC server that speaks binary protobuf by default but accepts JSON-encoded protobuf on the same port, same service, same endpoints.

```
content-type: application/grpc+proto    →  binary (default, production)
content-type: application/grpc+json     →  JSON (debugging, development)
```

```
Production:   KalaBrain ── gRPC (protobuf) ──▶ Quiver Server   (fast)
Development:  grpcurl    ── gRPC (JSON)     ──▶ Quiver Server   (readable)
Future:       Any client ── gRPC (protobuf) ──▶ Quiver Server   (typed)
```

---

## Proto Ownership — Hybrid Model

Arjuna owns the generic contracts. Broadheads own their specific protos.

```
arjuna/proto/                              ← Arjuna repo
├── arrow/
│   ├── chart.proto
│   ├── options.proto
│   └── swe.proto
├── quiver/
│   ├── routing.proto
│   └── auth.proto
└── broadheads/
    └── broadhead.proto                    ← generic contract ALL modules must implement

kalabrain/proto/                           ← KalaBrain repo (separate)
├── llm.proto                              ← KalaBrain-specific
├── interpret.proto
└── buf.yaml
    dependencies:
      - buf.build/kala/arjuna              ← pulls generic contract from BSR
```

### Generic Broadhead Contract

```protobuf
// arjuna/proto/broadheads/broadhead.proto

service Broadhead {
  rpc HealthCheck (Empty) returns (HealthResponse);
  rpc Capabilities (Empty) returns (CapabilityList);
}

message HealthResponse {
  bool healthy = 1;
  string version = 2;
}

message CapabilityList {
  repeated string handles = 1;
}
```

Every broadhead implements this. This is how Quiver discovers and health-checks modules. Beyond this, each broadhead defines its own service-specific protos in its own repo.

### Proto Distribution via buf Schema Registry (BSR)

```
arjuna/proto/
    │
    │  buf push
    ▼
BSR (buf.build/kala/arjuna)           ← hosted registry
    │
    │  buf generate
    │
    ├──▶ KalaBrain pulls + generates Python classes
    ├──▶ Future module pulls + generates whatever language
    └──▶ Anyone pulls + generates anything
```

---

## Authentication

### External Auth Service (Supabase Auth)

```
┌──────────────┐
│ Auth Service  │  ← Supabase Auth (already in use)
│ (standalone)  │
└──────┬───────┘
       │ JWT
       ▼
   Celestial ──JWT──▶ Quiver ──JWT──▶ Broadheads
```

### Auth Flow

```
1. Celestial authenticates with Supabase Auth, gets JWT
2. Every request to Quiver carries the JWT
3. Quiver validates JWT on ALL incoming requests
4. For Arrow calcs: Quiver handles it, auth already validated
5. For broadhead requests: Quiver passes JWT through
6. Broadhead validates JWT again independently
7. Double validation — Quiver catches bad tokens early,
   broadheads don't blindly trust Quiver
```

### Local Quiver (Embedded)

No auth. It's running in the same process as the user. The JWT is attached when forwarding to Remote Quiver.

---

## Smart Routing

### Remote Quiver

```
Request comes in
│
▼
Validate JWT
│
▼
Is this an Arrow calc?
├── YES → Check cache → Arrow gateway → cache result → return
│
▼
NO → Check broadhead registry
├── Match found → Forward request (with JWT) → return response
└── No match → Return error
```

### Local Quiver (Vayu)

```
Vayu receives call from Celestial
│
▼
Can device handle this locally?
├── YES → Local Arrow (direct Dart call) → return
└── NO  → Forward to Remote Quiver (gRPC with JWT) → return
```

---

## Broadhead System

Quiver doesn't understand what broadheads do. It knows:
- I am Arrow's server. That's my job.
- I have a list of registered broadheads with their endpoints and the request types they handle.
- If it's not for me, I check the list and forward.
- If nobody claims it, return error.

```yaml
broadheads:
  kalabrain:
    url: "grpc://kalabrain.example.com:50051"
    handles: [llm.*, interpret.*]
  future_mod:
    url: "grpc://whatever:50052"
    handles: [reports.*]
```

---

## Quiver-to-Quiver Communication

```
┌──────────────────────┐              ┌──────────────────────┐
│    Local Quiver       │    gRPC     │    Remote Quiver      │
│    (embedded/Vayu)    │────────────▶│    (server)           │
│                       │             │                       │
│  - Local Arrow        │             │  - Auth validation    │
│  - Simple calcs       │             │  - Full routing       │
│  - Forward complex    │             │  - Caching            │
│                       │             │  - Broadheads         │
│                       │             │  - Arrow (heavy calc) │
└───────────────────────┘             └───────────────────────┘
```

---

## Open Questions

- 🔄 **Sync protocol** — How does Local Quiver sync with Remote Quiver? Conflict resolution? Eventual consistency?
- 📦 **What determines local vs remote calc?** — What criteria does Vayu use to decide? Calc type? Device capability? Data availability?
- 🔌 **Broadhead registration** — Static config file vs dynamic discovery? Can broadheads register themselves?
- 📡 **Broadhead-to-Arrow** — Do broadheads ever need calcs from Arrow? If so, do they go through Quiver?
- 💾 **Storage layer** — What database? Shared between Local and Remote Quiver?
- 🔌 **Offline queue** — When Local Quiver is offline and gets a broadhead request, queue it? Reject it?
- 🏗️ **Vayu for non-Dart frontends** — Web apps and third parties would need a gRPC client or JSON gateway. Is Vayu also a server-side component for these cases? *(Deferred)*
- ⚖️ **Rate limiting / quotas** — Handled at Quiver level? Per-broadhead?
- 🔄 **Multiple Arrow instances** — Can multiple Quiver Server instances sit behind a load balancer?
