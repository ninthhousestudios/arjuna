# Arjuna

Universal astrological calculation service.

## Components

| Component | Name | Role | Tech |
|-----------|------|------|------|
| Calc Engine | **Arrow** | Astrology calculations — pure Dart library, runs on-device and server | Dart |
| Server | **Quiver** | Arrow's API server, gRPC primary, broadhead proxy, auth | Dart gRPC |
| Validation | **Fletch** | Cross-engine comparison tool | Flutter Web |
| Admin | **Bowyer** | Server management, logs, metrics, debugging | Flutter Web + Dart CLI |
| CLI | **Nock** | Full CLI astrology app + living API docs for Quiver | Dart CLI |
| Contracts | **proto/** | Shared .proto files — single source of truth for all gRPC contracts | Protocol Buffers |

## Architecture

```
Flutter App (Celestial, etc.)              Remote Quiver (Dart gRPC)
    │                                          │
    └── Vayu ─── Local Arrow (on-device)       ├── Arrow (server-side, isolates)
              └── gRPC to Remote Quiver        ├── Broadhead proxy
                                               ├── Auth (Supabase JWT)
                                               └── Caching
```

Arrow is the same Dart engine running on-device and server. One engine everywhere.

### Arrow — 3-Layer Pipeline

```
arrow_swe    ← sweph.dart (dart:ffi) → EphSnapshot (immutable bridge)
arrow_core   ← pure Dart: signs, nakshatras, vargas, dignities, karakas
arrow_calc   ← pure Dart: dashas, yogas, shadbala, ashtakavarga
```

Each layer depends only on the previous. Non-SWE code never calls SWE directly.

## Directory Structure

```
arjuna/
├── arrow/       ← Calc engine (Dart monorepo, Melos)
├── quiver/      ← Server (Dart gRPC)
├── proto/       ← Shared .proto contracts
├── fletch/      ← Validation client (Flutter Web)
├── bowyer/      ← Admin panel (Flutter Web + CLI)
└── nock/        ← CLI client (Dart)
```

## Status

Pre-implementation — architecture designed, code coming.
