# Arjuna 🏹

| Component | Name | Purpose | Tech |
|-----------|------|---------|------|
| Calc Engine | **Arrow** | Astrology calculations | Dart library |
| Server | **Quiver** | Arrow's API server + broadhead proxy | Dart backend (gRPC primary, HTTP/JSON fallback) |
| Validation Client | **Fletch** | Cross-engine comparison & validation webapp | Flutter Web (+ mobile later) |
| Admin Panel | **Bowyer** | Quiver management, logs, testing, debugging | Flutter Web |
| CLI Client | **Nock** | CLI astrology app + living API docs | Dart CLI |

---

## Arrow — Calc Engine

### Core Responsibilities
- 🔢 **Planetary position calculations** (ephemeris computations)
- 🏠 **House system calculations** (Placidus, Whole Sign, etc.)
- 📐 **Aspect calculations** (conjunctions, squares, trines, etc.)
- 📅 **Transit & progression calculations**
- 🗺️ **Chart generation** (natal, synastry, composite, solar return, etc.)
- 📊 **Dignity/debility scoring**
- 🔄 **Coordinate system conversions** (ecliptic, equatorial, etc.)

### Design Goals
- Pure Dart — zero platform dependencies
- Standalone library — usable without Quiver
- Deterministic — same input always produces same output
- Port from KalaNG/KalaC#/libaditya lineage

---

## Quiver — Server

### Core Identity
**Arrow's API server.** That is its primary job. Everything else is secondary.

### API Layer
- **gRPC** — Primary protocol for all inter-service and client communication
- **HTTP/JSON** — Fallback for web clients and third-party integrations

### Core Services
- 🏹 **Arrow gateway** — Expose Arrow calculations via API
- 🗄️ **Session/chart management** — Store and retrieve chart data
- 🔐 **Authentication/authorization** — JWT-based, single auth for clients
- ⚡ **Caching layer** — Avoid redundant Arrow calculations

### Smart Routing (Local vs Remote)
Local Quiver decides what it can handle:

```
Request comes in
      │
      ▼
  Is this an Arrow calc?
      ├─ YES → Can I handle locally?
      │         ├─ YES → Local Arrow
      │         └─ NO  → Forward to Remote Arrow
      │
      ▼
  NO → Pass to broadhead system
```

### Broadhead System (Module Proxy)
Quiver doesn't need to understand what broadheads do. It just knows:
- **I am Arrow's server. That's my job.**
- **I have a list of registered broadheads with their endpoints and the request types they handle.**
- **If it's not for me, I check the list and forward.**
- **If nobody claims it, return error.**

```yaml
broadheads:
  kalabrain:
    url: "grpc://kalabrain.example.com:50051"
    handles: [llm.*, interpret.*]
  future_mod:
    url: "grpc://whatever:50052"
    handles: [reports.*]
```

### Quiver-to-Quiver Communication

```
┌─────────────────┐         ┌─────────────────┐
│  Local Quiver    │  gRPC   │  Remote Quiver   │
│  (user device)   │◄───────►│  (main server)   │
│                  │         │                  │
│  - Local Arrow   │         │  - Auth/sessions │
│  - Local cache   │         │  - Chart storage │
│  - Smart routing │         │  - Broadheads    │
│  - Offline-first │         │  - KalaBrain     │
│                  │         │                  │
└──────────────────┘         └─────────────────┘
```

### Authentication Flow
- Single auth system — JWT issued by Remote Quiver
- Client authenticates once with Remote Quiver
- Local Quiver validates JWT locally (self-contained)
- KalaBrain and other broadheads are accessed through Quiver — credentials stay server-side, never exposed to client

---

## Fletch — Cross-Engine Validation Tool

### Primary Mission
Visual inspection and validation tool for comparing outputs across multiple calculation engines:

| Engine | Language | Origin |
|--------|----------|--------|
| **Arrow** | Dart | New implementation |
| **KalaNG** | C# | Original C# base |
| **KalaC#** | C# | Port from C++ |
| **libaditya** | Python | Python library |

### Core Features
- 🔍 **Side-by-side comparison** — Run the same calculation across 2-4 engines, display results in parallel
- 🎯 **Diff highlighting** — Instantly spot discrepancies between engines
- 📊 **Tolerance configuration** — Define acceptable variance thresholds
- 📋 **Batch validation** — Run suites of test cases across all engines
- 📈 **Historical tracking** — Track convergence as ports improve

### Integration Challenge
Communicating with 4 engines across 3 languages. Suggested approach: **All engines expose a common gRPC or HTTP/JSON interface.** Fletch talks to a uniform API regardless of what's behind it.

### Tech
- Flutter Web (primary)
- Mobile version later as learning exercise

---

## Bowyer — Admin Panel

### Core Features
- 🔧 **Quiver instance management** (health, restart, config)
- 📊 **Monitoring/metrics dashboards**
- 🪵 **Log reading/streaming**
- 🧪 **Test runner/results viewer**
- 🐛 **Debug tools** (inspect Arrow calc results, trace requests)
- 👥 **User management**
- 🔌 **Broadhead management** (register, monitor, configure modules)

### Tech
- Flutter Web

---

## Nock — CLI Client

### Philosophy
Living documentation of the Quiver API. Every API call has a corresponding Nock command. If you want to know how to use the API, read Nock's source.

### Core Features
- 🌟 **Full-featured CLI astrology app** (natal charts, transits, synastry, etc.)
- 📖 **Comprehensive API coverage** — Every Quiver endpoint has a Nock command
- 🎨 **Rich terminal output** (Dart equivalent of Python-rich TBD)
- 📚 **Self-documenting** — Source code serves as API usage examples

### Tech
- Dart CLI

---

## Open Questions for Deeper Dive

### Quiver Architecture
- 🔄 **Sync protocol** — How does Local Quiver sync with Remote Quiver? Conflict resolution? Eventual consistency?
- 📦 **What determines "simple" vs "complex" calc?** — What criteria does Local Quiver use to decide local vs remote Arrow?
- 🔌 **Broadhead registration** — Static config file vs dynamic discovery? Can broadheads register themselves?
- 📡 **Broadhead communication** — Do broadheads ever need to request calcs from Arrow? If so, do they go through Quiver or directly to Arrow?
- 🔐 **Broadhead auth** — Does Quiver authenticate with each broadhead separately? Service-to-service tokens?
- 💾 **Storage layer** — What database? Shared between Local and Remote Quiver?
- 🔌 **Offline queue** — When Local Quiver is offline and gets a broadhead request, queue it? Reject it?
- 📊 **gRPC service definitions** — Who owns the .proto files? Arrow? Quiver? Each broadhead?
- 🏗️ **Local Quiver packaging** — Embedded in the client app? Separate process? Background service?
- ⚖️ **Rate limiting / quotas** — Handled at Quiver level? Per-broadhead?
