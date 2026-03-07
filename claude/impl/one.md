# Implementation Phase One

## Guiding Principle

Build thoroughly, intentionally, methodically from the ground up. Every layer, every step includes logging, error handling, and testing as it is built — not bolted on afterward. This is not "get it working then clean it up." Each piece is complete before the next begins.

---

## Arrow — Steps

### Step 1: Start arrow_swe

Create the arrow_swe package. This is the foundation everything else rests on. The goal is a complete, tested SWE wrapper that — once built — rarely needs to change.

```
arrow/
└── packages/ !!! Claude: no packages/ directories like this arjuna/arrow/arrow_swe; arjuna/quiver/embedded for example
    └── arrow_swe/
        ├── lib/
        │   ├── arrow_swe.dart          # barrel export
        │   └── src/
        │       ├── swe_config.dart     # every option sweph.dart accepts
        │       ├── eph_snapshot.dart    # complete output of a single SWE call
        │       ├── swe_facade.dart     # the public API: calcAll, sunrise, etc.
        │       └── types/              # PlanetPosition, AscMcPoints, etc.
        ├── test/
        └── pubspec.yaml
```

### Step 2: Explore sweph.dart

Before designing SweConfig or EphSnapshot, understand the actual library. This is a spike — write throwaway code to answer real questions.

Questions to answer:
- What does initialization look like? (`swe_set_ephe_path`, any global setup?)
- What's the full function surface? (List every function we might call)
- What inputs does each function require? (flags, mode constants, etc.)
- What outputs does each function return? (array shapes, special values)
- What error conditions exist? (invalid dates, missing bodies, bad flags)
- How does cleanup work? (`swe_close`, resource management?)
- What ephemeris files are needed and how are they loaded?
- How does the true/mean node toggle work at the SWE level?
- How does topocentric vs geocentric work?
- How are ayanamsas set? (global state? per-call?)
- What are the actual flag constants for body calculation?
- How do hypothetical planets (Uranian) work in sweph?
- What's the fixed star API look like?

Approach:
```dart
// throwaway spike — not production code
import 'package:sweph/sweph.dart';

void main() {
  // 1. Initialize
  final swe = Sweph();  // or however it works

  // 2. Try calculating Sun position for a known date
  //    Compare output to known values from libkala/KalaNG

  // 3. Try houses

  // 4. Try ayanamsa

  // 5. Try sunrise/sunset

  // 6. Note every parameter, every flag, every option
}
```

The output of this spike is a complete inventory of sweph.dart's API and the knowledge needed for Step 3.

### Step 3: Design SweConfig from the sweph.dart inventory

After the spike, SweConfig should contain every option that affects SWE output. The goal: one SweConfig + a julian day + a location = one complete EphSnapshot. No ambiguity, no missing parameters, no "oh we also need to set this flag."

SweConfig should be exhaustive so that:
- EphSnapshot is fully determined by (jd, location, SweConfig)
- Changing any SweConfig field invalidates the snapshot
- Once arrow_swe is built and tested, it becomes a stable foundation

EphSnapshot should capture everything SWE returns so downstream code never needs to call SWE. The snapshot IS the complete result.

Then: implement SweConfig, EphSnapshot, and the facade. Test against known-good values from KalaNG and libkala. Include logging (package:logging with Arrow.SweWrapper hierarchy), error types, and thorough tests at every step.

---

## Quiver — Steps

### Step 1: Build basic gRPC server

Set up quiver/server with a minimal Dart gRPC server. This validates the Dart gRPC ecosystem and establishes the communication backbone that Bowyer and Nock will also use.

```
quiver/
└── server/
    ├── lib/
    │   └── src/
    │       ├── server.dart              # gRPC server setup, codec registration
    │       └── services/
    │           └── health_service.dart   # simple health check RPC
    ├── bin/
    │   └── server.dart                  # entry point
    ├── test/
    └── pubspec.yaml
```

Start with a health check service — just enough to prove gRPC works in Dart, JSON codec works, and the server starts/stops cleanly. Include logging and error handling from the start.

```protobuf
// proto/quiver/health.proto
service HealthService {
  rpc Check (Empty) returns (HealthResponse);
}
```

This is also where we verify: does Dart gRPC support the JSON codec? How does graceful shutdown work? What does the connection lifecycle look like?

### Step 2: Build quiver/core once Arrow produces output

Once arrow_swe can produce an EphSnapshot, connect Quiver to Arrow:

```
quiver/
├── core/
│   └── arrow_gateway.dart    # calls Arrow, returns results
└── server/
    └── services/
        └── arrow_service.dart  # gRPC service wrapping the gateway
```

Define the proto contract for chart calculation. Implement the bridge between proto types and Arrow domain types. This gives Nock and Bowyer something real to talk to.

---

## Parallel Build — All Five Apps

As Arrow and Quiver mature, the other three apps grow alongside them:

```
Phase    Arrow              Quiver             Nock           Bowyer         Fletch
─────    ─────              ──────             ────           ──────         ──────
  1      arrow_swe spike    health check       -              -              -
  2      arrow_swe impl     arrow service      chart cmd      status cmd     -
  3      arrow_core         -                  more cmds      logs cmd       -
  4      arrow_calc         broadhead (KB)     interpret cmd  broadheads     engine adapters
  5      -                  -                  -              -              comparison UI
```

Each phase: logging, error handling, testing built in. Not deferred.

---

## Nock Connection Modes

Nock supports two modes through Vayu:

1. **Local gRPC server (default)** — Nock starts a local Quiver server process, connects via gRPC on localhost. Full Arrow calcs, no auth, no internet. This is the primary development and exploration mode.

2. **In-process via Vayu** — Direct Dart calls through the embedded Vayu library. No server, no gRPC serialization. Vayu handles the Arrow calls directly in the same process. Available because it's built into the architecture.

```dart
final vayu = args.contains('--embedded')
    ? Vayu.embedded()    // direct Dart calls, no server
    : Vayu.local();      // starts local Quiver, connects via gRPC

// same API either way
final chart = await vayu.calculateChart(birthData);
```

---

## Local vs Remote Routing (Vayu)

Deferred until we understand actual calc costs. Building and testing Arrow will reveal how long each calculation type takes on-device. The routing criteria will emerge from real performance data, not speculation.

What we need to measure:
- Single chart calc time on mobile
- Transit search over various date ranges
- Panchanga generation
- Batch operations (multiple charts)

This measurement happens naturally as part of building and testing arrow_swe and arrow_core.

---

## Caching

Most calcs happen on-device — cache may not be necessary. Explore later when there's real usage data showing what Remote Quiver actually handles and whether repeat calculations are common enough to warrant caching infrastructure.
