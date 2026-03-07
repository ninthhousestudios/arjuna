# Bowyer Implementation Plan

## Guiding Principle

Same as all Arjuna projects: build thoroughly, intentionally, methodically from the ground up. Every feature includes logging, error handling, and testing as it is built.

Bowyer follows Quiver. Don't build admin features for capabilities that don't exist yet.

## Conventions

- **Directory names**: short. `bowyer/core/` not `bowyer/bowyer_core/`.
- **Logging**: `package:logging`. Hierarchy: `Bowyer.Core`, `Bowyer.Web`, `Bowyer.Cli`.
- **Core first, shells second.** All logic lives in bowyer_core. Web and CLI are thin presentation layers.
- **Auth**: same Supabase JWT as everything else, but requires admin role.

## Directory Structure

```
bowyer/
├── core/        # bowyer_core: pure Dart library — all admin logic
├── web/         # bowyer_web: Flutter Web shell
├── cli/         # bowyer_cli: Dart CLI shell
└── claude/
```

Dependency graph:
```
bowyer_core     (depends on: quiver proto stubs for gRPC client)
     ^
bowyer_web      (depends on: bowyer_core, Flutter)
bowyer_cli      (depends on: bowyer_core, package:args)
```

---

## Phase 1: Scaffold and Status

### 1A. Scaffold packages

Create the three package directories. Core is a pure Dart package. Web is a Flutter Web project. CLI is a Dart CLI.

```
bowyer/
├── core/
│   ├── pubspec.yaml          # name: bowyer_core
│   └── lib/
│       └── bowyer_core.dart
├── cli/
│   ├── pubspec.yaml          # name: bowyer_cli
│   ├── bin/
│   │   └── bowyer.dart       # entry point
│   └── lib/
│       └── bowyer_cli.dart
└── web/
    ├── pubspec.yaml          # name: bowyer_web
    └── lib/
        └── main.dart
```

Done when: `dart analyze` passes on core and cli, `flutter analyze` passes on web.

**Sync point**: can start immediately. No Quiver dependency.

### 1B. Quiver health client (core)

bowyer_core connects to Remote Quiver over gRPC and checks health. This is the foundation — every other Bowyer feature talks to Quiver the same way.

```
core/lib/src/
├── client/
│   └── quiver_client.dart     # gRPC client to Remote Quiver (health, later: admin endpoints)
├── auth/
│   └── admin_auth.dart        # JWT with admin role validation
└── models/
    └── server_status.dart     # ServerStatus (healthy, version, uptime)
```

Gates on: **Quiver 1C** (health check server).

Tests: connect to Quiver health endpoint, parse response into ServerStatus.

### 1C. Status commands (cli)

The first real Bowyer commands.

```
cli/lib/src/
└── commands/
    └── status.dart            # `bowyer status` — show Quiver health
```

```
$ bowyer status
Quiver v0.1.0 | healthy | Uptime: 2h 15m
```

Tests: `bowyer status` connects, displays health info, exits cleanly.

### 1D. Status page (web)

Simplest possible Flutter Web page. Shows the same health info as the CLI.

```
web/lib/src/
├── pages/
│   └── dashboard.dart         # Dashboard page — health status
└── services/
    └── quiver_service.dart    # Calls bowyer_core, provides to UI
```

Keep it minimal. No routing framework, no state management beyond StatefulWidget. Just a page that shows server status. Refine architecture later as complexity warrants it.

Done when: Flutter Web app builds, loads in browser, shows Quiver health status.

---

## Phase 2: Debug and Inspection

Gates on: **Quiver 2C** (chart service operational).

### 2A. Arrow debug calc (core + cli + web)

The most useful Bowyer feature for development: send a chart calculation request and inspect the raw result.

**Core:**
```
core/lib/src/
├── debug/
│   └── arrow_debug.dart       # Send calc request, return raw response
```

**CLI:**
```
$ bowyer calc --jd 2460345.5 --lat 40.7128 --lon -74.006
$ bowyer calc --jd 2460345.5 --lat 40.7128 --lon -74.006 --raw    # show raw proto response
$ bowyer calc --date "1990-06-15 14:30" --lat 39.76 --lon -86.15  # with date parsing
```

**Web:**
Input form (JD or date, lat, lon, house system dropdown) -> calculate -> display results in a formatted table. "View Raw Response" toggle shows the raw proto JSON.

This is essentially the same as `nock chart` but with a different audience (admin/debugging vs user) and raw inspection capabilities.

### 2B. Config inspection (core + cli)

View and understand the current Quiver configuration.

```
$ bowyer config show           # display running Quiver config
$ bowyer config show arrow     # show Arrow-specific settings
```

Gates on: Quiver having a config introspection endpoint (proto).

---

## Phase 3: Logs and Monitoring

### 3A. Log streaming (core + cli + web)

Fetch and stream logs from Quiver.

**Core:**
```
core/lib/src/
├── logs/
│   └── log_reader.dart        # Fetch logs, stream live logs
```

**CLI:**
```
$ bowyer logs --tail 50
$ bowyer logs --tail --level error
$ bowyer logs --service arrow --since 1h
```

**Web:**
Live log streaming page with filters (level, service, time range). Auto-scroll. Color-coded by level.

Gates on: Quiver having a log streaming endpoint (gRPC server-streaming or similar).

### 3B. Basic metrics (core + cli + web)

Request counts, latency, cache stats (when caching is added), error rates.

```
$ bowyer metrics
Requests/min:  847
Avg latency:   23ms
Error rate:    0.1%
Arrow calcs:   12,847 today
```

Gates on: Quiver collecting and exposing metrics (proto endpoint).

---

## Phase 4: KalaBrain Monitoring

Gates on: **Quiver 4A-4B** (KalaBrain integration).

### 4A. KalaBrain health and stats

Monitor the KalaBrain connection from Bowyer.

```
$ bowyer kalabrain status      # health check
$ bowyer kalabrain stats       # request count, latency, error rate
```

**Web:** KalaBrain card on the dashboard showing health, latency, request volume.

When broadheads are eventually abstracted, this becomes generic broadhead monitoring. Until then, it's just KalaBrain.

---

## Phase Ordering and Cross-Project Sync

```
Phase  Step   What                    Depends on                    Unlocks
─────  ────   ────                    ──────────                    ───────
  1     1A    Scaffold                nothing                       -
  1     1B    Health client (core)    Quiver 1C (health server)     -
  1     1C    Status commands (cli)   1B                            -
  1     1D    Status page (web)       1B                            -

  2     2A    Debug calc              Quiver 2C (chart service)     -
  2     2B    Config inspection       Quiver config endpoint        -

  3     3A    Log streaming           Quiver log endpoint           -
  3     3B    Metrics                 Quiver metrics endpoint       -

  4     4A    KalaBrain monitoring    Quiver 4A-4B (KalaBrain)      -
```

### What can run in parallel

- **1A** (scaffold) has zero dependencies. Start immediately.
- **1B-1D** need only Quiver health check — can start early.
- **2A** gates on Quiver chart service (which gates on Arrow). This is the critical wait.
- **Phases 3-4** depend on Quiver endpoints that don't exist yet. Don't build Bowyer features for capabilities Quiver doesn't expose.

### Cross-project timeline

```
Arrow              Quiver                 Bowyer
─────              ──────                 ──────
1A scaffold        1A scaffold            1A scaffold
                   1C health server ────► 1B health client
                                          1C status (cli)
                                          1D status (web)
2C SWE facade ──► 2C chart service ─────► 2A debug calc
                   3A JWT                  (auth for Bowyer)
                   log endpoint ─────────► 3A log streaming
                   metrics endpoint ─────► 3B metrics
                   4A-4B KalaBrain ──────► 4A KB monitoring
```

---

## Done Criteria

Bowyer Phase 1 is complete when:
- `bowyer status` shows Quiver health via CLI
- Flutter Web dashboard shows Quiver health in browser
- Both connect over gRPC with admin-role JWT

Bowyer Phase 2 is complete when:
- `bowyer calc` sends chart requests and displays results
- Raw proto response is inspectable
- Config can be viewed

## Sonnet Guidance

- **Bowyer is the last priority.** Arrow and Quiver come first. Nock is more useful during development than Bowyer. Build Bowyer features only as Quiver endpoints become available.
- **Core first.** Always implement the logic in bowyer_core, then wrap it in CLI and Web. Don't put logic in the shells.
- **Keep the web UI simple.** StatefulWidget is fine to start. Don't add Riverpod, Bloc, or any state management framework until complexity demands it. A dashboard with a few cards doesn't need architecture.
- **Don't build features for endpoints that don't exist.** If Quiver doesn't have a metrics endpoint, don't build Bowyer metrics. If Quiver doesn't have log streaming, don't build Bowyer log viewer.
- **Auth is admin-only.** Every Bowyer request carries a JWT. Bowyer validates the admin role client-side before sending requests (and Quiver validates server-side).
- **`package:logging`** — not print statements, not custom loggers.
