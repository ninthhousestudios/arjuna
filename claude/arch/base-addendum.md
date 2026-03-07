# Four Questions — Updated

---

## 1. Dart Logging

**`package:logging`** across the entire monorepo.

### Why
- Official Dart team package
- Hierarchical — granular control per subsystem
- Output-agnostic — same log calls, different destinations per environment
- One system across all Arjuna packages

### Hierarchy

```
Arrow
├── Arrow.SweWrapper
├── Arrow.Houses
├── Arrow.Aspects
├── Arrow.Transits

Quiver
├── Quiver.Core
├── Quiver.Server
├── Quiver.Server.Auth
├── Quiver.Server.Cache
├── Quiver.Server.Router
├── Quiver.Server.Broadhead

Vayu
├── Vayu.LocalRouter
├── Vayu.RemoteClient

Bowyer
├── Bowyer.Core
├── Bowyer.Web
├── Bowyer.CLI

Nock
├── Nock.Commands
├── Nock.Output
```

### Per-Environment Output

```
Dev (local, Nock, Bowyer CLI):
    └── Pretty print to console
        Filter by hierarchy
        Logger('Arrow.Houses').level = Level.FINE

Production (Remote Quiver on Railway):
    └── Structured JSON to stdout
        Railway/logging service picks it up
        Search by hierarchy, level, timestamp

Test:
    └── Capture in memory
        Assert specific logs were emitted
```

### Decision
- Chosen: `package:logging`
- Output formatting: TBD per environment
- Structured JSON package: TBD (custom or `package:json_log` or similar)

---

## 2. Swiss Ephemeris Thread Safety & Isolates

### The Concern
Swiss Ephemeris is a C library with **global internal state**:

```
swe_set_ephe_path()    ← global state
swe_set_topo()         ← global state
swe_calc_ut()          ← reads global state
```

Two calculations sharing these globals in the same process = danger.

### Why Dart Isolates Solve This

```
Isolate A                      Isolate B
┌────────────────────┐        ┌────────────────────┐
│ sweph.dart (FFI)   │        │ sweph.dart (FFI)   │
│ Own copy of C state │        │ Own copy of C state │
│ Own swe_set_*       │        │ Own swe_set_*       │
│                    │        │                    │
│ Reads ephe files ──┼────────┼── Reads ephe files │
│    (read-only)     │        │    (read-only)     │
└────────────────────┘        └────────────────────┘

Each isolate loads its own instance of the C library.
Each has its own global state.
They cannot interfere with each other.
Ephemeris files are read-only — safe for concurrent access.
```

### Does sweph.dart Run in a Dart Isolate?
Yes. Every Dart isolate that uses sweph.dart via FFI gets its own copy of the C library's memory space. This is how FFI + isolates work in Dart — each isolate is essentially its own process memory.

### Decision
- Dart isolates provide natural thread safety for SWE
- No mutex or locking needed
- Ephemeris files are read-only, concurrent access is safe
- Can spawn many isolates for heavy batch work (e.g., million chart calc)

---

## 3. Remote Quiver Deployment & Scaling

### Revised Understanding of Load

```
Arrow calcs:
├── Single chart           → trivial, milliseconds
├── Short transit search   → light, sub-second
├── Panchanga search       → light to moderate
└── This is WHY local Quiver exists
    A phone can handle this fine

Remote Quiver traffic:
├── ~50% Arrow calcs       → light, fast
├── ~50% LLM (KalaBrain)  → heavy, slow, the real bottleneck
└── LLM is the priority
    A user chatting with AI should not wait
    because someone else's transit search is in the queue
```

### The Key Insight

```
The bottleneck is NOT Arrow.
The bottleneck is LLM.

Most Arrow calcs happen on-device (Local Quiver).
Remote Arrow calcs are cheap and fast.
LLM requests are expensive and slow.
Quiver itself is a lightweight traffic cop.
```

### Railway Deployment

```
┌──────────────────────────────────────────────────┐
│                    Railway                         │
│                                                    │
│   Quiver Service (Dart)                           │
│   ├── Lightweight                                 │
│   ├── Routes requests                             │
│   ├── Arrow calcs in isolates when needed         │
│   └── Forwards LLM requests to KalaBrain         │
│                                                    │
│   KalaBrain Service (Python)                      │
│   ├── The heavy one                               │
│   ├── LLM API calls (OpenAI, Anthropic, etc.)    │
│   ├── Scale this independently                    │
│   └── Priority: user actively chatting > all else │
│                                                    │
│   Supabase (Auth + DB)                            │
│   └── External, managed                           │
│                                                    │
└──────────────────────────────────────────────────┘
```

### Scaling Strategy

```
Quiver:
├── Single instance handles a LOT
│   Arrow calcs are fast
│   It's mostly routing
├── Horizontal scale: just add instances
│   Each instance is stateless
│   Railway load balancer distributes
└── Each instance spawns isolates for Arrow as needed

KalaBrain:
├── THIS is what you scale
├── LLM calls are slow (seconds, not milliseconds)
├── Queue-based: user chat requests get priority
├── Scale independently from Quiver
└── Multiple instances behind Quiver's broadhead config
```

### How Quiver Manages Instances
Quiver itself doesn't need gunicorn/uvicorn equivalent. Dart's gRPC server handles concurrent requests natively. For heavy Arrow batch jobs, it spawns isolates internally. For scaling across machines, Railway's load balancer handles it — each Quiver instance is stateless.

---

## 4. Supporting ~100,000 Concurrent Users

### The Math

```
100,000 users online
├── Most doing local calcs on device    → zero server load
├── Maybe 10% hitting remote at any moment → 10,000 requests
│   ├── 5,000 Arrow calcs              → fast, Quiver handles easily
│   └── 5,000 LLM requests             → THIS is the challenge
```

### Arrow Side (Easy)

```
5,000 concurrent Arrow calcs:
├── Each takes milliseconds
├── A single Quiver instance with isolate pool handles hundreds/sec
├── 2-4 Quiver instances on Railway handles this comfortably
└── Not the bottleneck
```

### LLM Side (The Real Challenge)

```
5,000 concurrent LLM requests:
├── Each takes 2-10 seconds
├── Each costs real money (API tokens)
├── This is a queuing/prioritization problem
│
├── Active chat (user waiting for response)  → HIGH priority
├── Background interpretation                → LOW priority
├── Batch reports                            → LOWEST priority
│
└── KalaBrain needs:
    ├── Request queue with priority levels
    ├── Multiple instances (scale horizontally)
    ├── Rate limiting per user
    ├── Cost controls
    └── This is KalaBrain's problem, not Quiver's
```

### Infrastructure Estimate

```
Quiver:     2-4 Railway instances     ← cheap
KalaBrain:  8-16 Railway instances    ← the expensive part
Supabase:   Pro plan                  ← managed
LLM APIs:   $$$                       ← the real cost

The bottleneck is money, not architecture.
```

---

## Open Questions

- 🏗️ **Vayu as a server for non-Dart frontends** — Deferred
- 📊 **Structured JSON logging package** — TBD
- ⚖️ **KalaBrain priority queue design** — TBD
- 💰 **LLM cost controls and rate limiting** — TBD
- 📦 **Arrow isolate pool sizing** — TBD (how many isolates per Quiver instance?)
