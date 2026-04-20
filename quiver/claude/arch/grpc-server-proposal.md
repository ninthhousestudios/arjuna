# Arrow Server — Backend Communication Architecture

> **HISTORICAL DOCUMENT.** This was the first document explaining the gRPC server concept. The architecture has since evolved — Arrow Server is now called Quiver, and Quiver is the primary server (not KalaBrain). See `base.md` for the current architecture. This document is preserved for reference and context on how the design evolved.

## Overview

Arrow runs as a **standalone Dart server** alongside KalaBrain. KalaBrain (Python/FastAPI) remains the orchestrator — handling auth, Aditi/LLM, and business logic — but delegates all astrological calculation to Arrow Server over a local network boundary.

The same Arrow engine runs on both the device (Flutter) and the server (Dart). No Python ephemeris code. No duplicate logic. One engine everywhere.

---

## Topology

```
┌─────────────────────────────────────────────────────┐
│                    Client Device                     │
│                                                      │
│   Celestial (Flutter)                                │
│       │                                              │
│       ├── Arrow (on-device, direct Dart call)        │
│       │       └── sweph.dart (ffi)                   │
│       │                                              │
│       └── HTTP to KalaBrain (when needed)            │
└───────────────────────┬─────────────────────────────┘
                        │ internet
┌───────────────────────▼─────────────────────────────┐
│                    Server                            │
│                                                      │
│   KalaBrain (Python/FastAPI)                         │
│       │                                              │
│       ├── Auth, Aditi/LLM, business logic            │
│       │                                              │
│       └── gRPC ──▶ Arrow Server (Dart)               │
│                       └── sweph.dart (ffi)           │
│                                                      │
│   Supabase (data)                                    │
└─────────────────────────────────────────────────────┘
```

---

## Communication Protocol: gRPC

### Why gRPC over HTTP/REST?

gRPC is the right long-term choice for the KalaBrain ↔ Arrow Server boundary:

- **Protocol Buffers** — typed, versioned contracts. Both sides always agree on the shape of requests and responses. No hand-maintained JSON parsing.
- **Performance** — binary serialization over HTTP/2. Faster than JSON/REST for the volume of numerical data Arrow produces (planet positions, house cusps, full chart payloads).
- **Streaming** — server-side streaming is built in. If Arrow ever needs to push transit updates or batch results incrementally, the protocol already supports it.
- **Code generation** — `.proto` files generate Dart server stubs AND Python client stubs. Neither side hand-writes serialization.
- **Strong ecosystem** — `grpc` package for Dart, `grpcio` / `grpcio-tools` for Python. Both are mature.

### The Contract

A shared `.proto` file lives in the monorepo and is the single source of truth:

```
arrow/
├── proto/
│   └── arrow.proto          # shared contract
├── packages/
│   ├── arrow_server/        # Dart gRPC server (generated stubs + handlers)
│   ├── arrow_swe/
│   ├── arrow_core/
│   └── arrow_calc/
```

KalaBrain generates Python client code from the same `.proto`:

```
kalabrain/
├── generated/
│   └── arrow_pb2.py         # generated from arrow.proto
│   └── arrow_pb2_grpc.py
```

### Example `.proto` Sketch

```protobuf
syntax = "proto3";
package arrow;

service ArrowService {
  rpc CalcChart (ChartRequest) returns (ChartResponse);
  rpc CalcTransits (TransitRequest) returns (TransitResponse);
  rpc CalcMuhurta (MuhurtaRequest) returns (MuhurtaResponse);
}

message ChartRequest {
  double jd = 1;              // Julian date
  double lat = 2;
  double lon = 3;
  SweConfig swe_config = 4;
  CalcConfig calc_config = 5;
}

message ChartResponse {
  EphSnapshot snapshot = 6;
  // ... derived data
}

message SweConfig {
  Ayanamsa ayanamsa = 1;
  HouseSystem house_system = 2;
  NodeType node_type = 3;
  // ...
}
```

---

## Client ↔ Server: When Does the Client Talk to the Server?

### Option A: Client Never Talks to Arrow Server Directly

```
Celestial ──HTTP──▶ KalaBrain ──gRPC──▶ Arrow Server
```

- Client only knows about KalaBrain
- KalaBrain is the single API gateway for everything
- Simplest auth model — one boundary to secure
- KalaBrain translates between its REST API and Arrow's gRPC interface

### Option B: Client Talks to Arrow Server Directly

```
Celestial ──gRPC──▶ Arrow Server     (calculations)
Celestial ──HTTP──▶  KalaBrain       (auth, Aditi, business logic)
```

- Client bypasses KalaBrain for pure calculation
- Lower latency for calc-heavy operations
- But: two server boundaries to secure, more complex client logic
- Flutter has a gRPC client package, so this is technically feasible

### Recommendation

**Option A** for now. Keep it simple — one gateway, one auth boundary. KalaBrain is the only public-facing server. Arrow Server is internal, never exposed to the internet. If latency becomes an issue later, Option B is always available.

---

## Scaling: Can Arrow Server Run Behind a Load Balancer?

### Open Question

Arrow Server instances are **stateless** — they take a request, calculate, return a response. No session state, no in-memory caches that need sharing. This makes them natural candidates for horizontal scaling:

```
KalaBrain ──gRPC──▶ Load Balancer
                        │
                  ┌─────┼─────┐
                  ▼     ▼     ▼
               Arrow  Arrow  Arrow
               Srv 1  Srv 2  Srv 3
```

**Things to investigate:**
- Does `sweph.dart` (the Swiss Ephemeris FFI binding) hold any global state that prevents multiple isolates or instances?
- Ephemeris data files — are they read-only at runtime? If so, multiple instances can share the same mounted volume.
- Should we use Dart isolates within a single Arrow Server process before scaling to multiple processes/containers?
- gRPC load balancing — client-side (KalaBrain picks the instance) vs proxy-side (Envoy, nginx, etc.)?

---

## Deployment

### Open Question

How do KalaBrain and Arrow Server get deployed together?

**Options to evaluate:**
- **Single Docker Compose** — KalaBrain container + Arrow Server container, shared network, gRPC on an internal port
- **Single container, two processes** — supervisord or similar runs both. Simpler to deploy, harder to scale independently
- **Kubernetes** — each as a separate deployment/service. Full scaling control, more infrastructure overhead
- **Railway / Fly.io** — each as a separate service with internal networking

**The core constraint:** Arrow Server should never be publicly accessible. It only listens on an internal network interface that KalaBrain can reach.

---

## Summary

| Decision | Status |
|---|---|
| Arrow runs on device AND server | ✅ Decided |
| Same Dart engine both places | ✅ Decided |
| KalaBrain orchestrates, Arrow calculates | ✅ Decided |
| gRPC between KalaBrain and Arrow Server | ✅ Decided |
| `.proto` as shared contract in monorepo | ✅ Decided |
| Client talks only to KalaBrain (Option A) | ✅ Decided |
| Horizontal scaling of Arrow Server | ❓ Open — needs investigation |
| Deployment model | ❓ Open — needs evaluation |
