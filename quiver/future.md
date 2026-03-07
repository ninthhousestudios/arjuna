# Quiver — Future Blueprints

Designs saved here for later extraction when the need arises. Not implemented now.

## Broadhead System

When a second external service is needed beyond KalaBrain, extract the generic broadhead pattern. Full design in `claude/arch/base.md`.

Key points:
- Generic broadhead contract (HealthCheck, Capabilities RPCs)
- Static config with pattern-matched routing (`handles: [llm.*, interpret.*]`)
- Each broadhead owns its own service-specific protos
- Dynamic registration as a future option
- Proto distribution via buf Schema Registry (BSR)

For now: integrate KalaBrain directly. Extract the plugin pattern when there's a second plugin.

## Quiver-to-Quiver Sync

Sync protocol between Local and Remote Quiver is deferred. When needed, consider:
- What gets cached locally vs stored remotely
- Conflict resolution for offline edits
- Device-switching scenarios
- Whether caching is even necessary given most calcs happen on-device

Note: if most calcs are on-device, cache may not be necessary at all. Explore this when there's real usage data.
