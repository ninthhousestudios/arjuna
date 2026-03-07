# Bowyer

Quiver's admin panel. Internal tool for managing, monitoring, and debugging the Arjuna backend. Not user-facing — developers and admins only.

## Architecture

Two interfaces, one core:
- **bowyer/core** — pure Dart library (health, logs, metrics, broadhead admin, debug tools)
- **bowyer/web** — Flutter Web shell (visual dashboards, real-time log streaming)
- **bowyer/cli** — Dart CLI shell (SSH-friendly, scriptable, CI/CD integration)

```
bowyer/
├── core/    # bowyer_core: pure Dart, shared logic
├── web/     # bowyer_web: Flutter Web UI
└── cli/     # bowyer_cli: Dart CLI
```

Both shells import bowyer/core. Core talks to Remote Quiver over gRPC/JSON.

## Key architecture docs

- `claude/arch/base.md` — full feature reference (status, logs, broadheads, debug, metrics, users)

## Implementation guidance

### Current status

Pre-implementation. Architecture doc exists. No code yet. Bowyer depends on Quiver being operational.

### Rules for Bowyer

- **Bowyer follows Quiver.** Don't build Bowyer features before the Quiver endpoints they manage exist.
- **Core first, shells second.** Build bowyer_core logic, then wrap it in web and CLI interfaces.
- **Auth requires admin role.** Same Supabase JWT as everything else, but Bowyer checks `role == admin`.
- **`package:logging`** with hierarchy: `Bowyer.Core`, `Bowyer.Web`, `Bowyer.Cli`.
