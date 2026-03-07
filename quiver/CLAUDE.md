# Quiver

Arrow's API server. The only way the outside world talks to Arrow.

## Architecture

Two deployment modes, same core code:
- **Remote Quiver** — standalone Dart gRPC server. Auth, routing, caching, Arrow via isolates.
- **Local Quiver (Vayu)** — embedded in-process Dart library. No auth, no port. Direct Arrow calls + forwarding to Remote.

```
quiver/
├── core/        # quiver_core: shared logic (arrow gateway, models)
├── server/      # quiver_server: remote gRPC server
└── embedded/    # quiver_embedded: local embedded library (Vayu)
```

gRPC with JSON codec support on the same port. Protobuf default, JSON for debugging.

## Key architecture docs

- `claude/arch/base.md` — full feature and decision reference
- `claude/arch/grpc-server-proposal.md` — gRPC topology and deployment
- `claude/arch/grpc-with-json-includes-dart-examples.md` — JSON codec + Dart examples
- `claude/arch/desktop.md` — desktop routing
- `claude/arch/future.md` — deferred decisions (broadheads, abstraction)

## Implementation guidance

### Current status

Pre-implementation. Architecture docs exist. No code yet.

### Rules for Quiver

- **Start with a health check service.** Validate Dart gRPC works, JSON codec works, server starts/stops cleanly. See `arrow/claude/impl/one.md` Phase: Quiver.
- **No broadhead system yet.** Integrate KalaBrain directly. The broadhead abstraction is deferred until a second external service exists. See `claude/arch/future.md`.
- **No caching yet.** Deferred until real usage data shows what Remote Quiver handles and whether repeat calculations justify caching infrastructure.
- **Auth is Supabase JWT.** Validate on every request in Remote. Skip in Local/embedded (same process). Broadheads re-validate independently.
- **Arrow runs in isolates** on the server side. Each isolate gets its own sweph.dart C state. Isolate pool sizing is an open question.
- **Vayu hides everything.** Frontends see only Vayu. Local vs remote routing, auth token forwarding, caching — all invisible to the caller.
- **`package:logging`** with hierarchy: `Quiver.Server`, `Quiver.Core`, `Quiver.Embedded`.
