# Bowyer — Architecture Document

---

## Identity

**Quiver's admin panel.** The craftsman's workbench for managing, monitoring, and debugging the entire Arjuna backend.

Bowyer is an internal tool. It is not user-facing. Only developers and admins use it.

---

## Two Interfaces, One Core

```
bowyer/
├── core/                          ← Pure Dart library
│   ├── quiver_admin.dart          ← Health, restart, config
│   ├── log_reader.dart            ← Log fetching/streaming
│   ├── broadhead_admin.dart       ← Register, monitor modules
│   ├── debug_tools.dart           ← Arrow calc inspection
│   ├── user_admin.dart            ← User management
│   └── metrics.dart               ← Stats and monitoring
│
├── web/                           ← Flutter Web shell
│   ├── main.dart
│   ├── pages/
│   │   ├── dashboard.dart
│   │   ├── logs.dart
│   │   ├── broadheads.dart
│   │   └── debug.dart
│   └── imports bowyer/core
│
└── cli/                           ← CLI shell
    ├── bin/bowyer.dart
    ├── commands/
    │   ├── status.dart
    │   ├── logs.dart
    │   ├── restart.dart
    │   └── broadheads.dart
    └── imports bowyer/core
```

### Why Both

```
Web:
    Visual dashboards
    Real-time log streaming
    Point-and-click broadhead management
    Good for monitoring at a glance

CLI:
    SSH into server, check status
    Script automated health checks
    CI/CD integration
    Quick one-off commands

    $ bowyer status
    🟢 Quiver v0.4.2 | Uptime: 4d 12h | Arrow v0.3.1

    $ bowyer logs --tail 50 --level error

    $ bowyer broadheads list
    kalabrain    🟢 healthy    grpc://kalabrain:50051

    $ bowyer restart --graceful
```

---

## Who Bowyer Talks To

```
Bowyer (web or cli)
    │
    │  Both shells use bowyer/core
    │  Core talks to the same backends
    │
    ├── Remote Quiver (gRPC/JSON)
    │   ├── Health, config, restart
    │   ├── Arrow calc debugging
    │   ├── Broadhead management
    │   └── Request tracing
    │
    ├── Auth Service (Supabase)
    │   └── Admin login
    │
    └── Broadheads directly? ← Open question
```

---

## Core Features

### 1. Quiver Instance Management

```
┌─────────────────────────────────────────┐
│  Quiver Status                          │
│                                         │
│  Status:     🟢 Healthy                 │
│  Uptime:     4d 12h 33m                 │
│  Version:    0.4.2                      │
│  Arrow:      0.3.1                      │
│  Proto:      buf.build/kala/arjuna@v12  │
│                                         │
│  [Restart]  [View Config]  [Edit]       │
└─────────────────────────────────────────┘

CLI equivalent:
$ bowyer status
$ bowyer config show
$ bowyer config set cache.ttl 3600
$ bowyer restart --graceful
```

### 2. Log Streaming

```
┌─────────────────────────────────────────┐
│  Logs                    [Live ●]       │
│                                         │
│  Filter: [ERROR ▼] [All Services ▼]    │
│                                         │
│  12:03:01 ERROR quiver  JWT expired     │
│  12:03:00 ERROR arrow   SWE init fail   │
│  12:02:58 WARN  router  Timeout 2.3s    │
│  12:02:55 INFO  cache   Hit rate: 94%   │
│                                         │
└─────────────────────────────────────────┘

CLI equivalent:
$ bowyer logs --tail --level error
$ bowyer logs --service arrow --since 1h
```

### 3. Broadhead Management

```
┌──────────────────────────────────────────────────────┐
│  Broadheads                                          │
│                                                      │
│  ┌────────────────────────────────────────────────┐  │
│  │ kalabrain              🟢 healthy              │  │
│  │ grpc://kalabrain:50051                         │  │
│  │ Handles: llm.*, interpret.*                    │  │
│  │ Avg latency: 340ms   Requests/hr: 1,204       │  │
│  │ [Health Check]  [Disable]  [Configure]         │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  [+ Register New Broadhead]                          │
└──────────────────────────────────────────────────────┘

CLI equivalent:
$ bowyer broadheads list
$ bowyer broadheads health kalabrain
$ bowyer broadheads disable kalabrain
$ bowyer broadheads register --name reports --url grpc://reports:50052
```

### 4. Arrow Debug Tools

```
┌─────────────────────────────────────────┐
│  Arrow Calculator                       │
│                                         │
│  Julian Day: [2460345.5    ]            │
│  Latitude:   [40.7128      ]            │
│  Longitude:  [-74.0060     ]            │
│  Houses:     [Placidus  ▼  ]            │
│                                         │
│  [Calculate]                            │
│                                         │
│  Result:                                │
│  ☉ Sun:    12°34'22" ♈                  │
│  ☽ Moon:   05°11'03" ♋                  │
│  ...                                    │
│                                         │
│  [View Raw Response]  [Compare w/SWE]   │
└─────────────────────────────────────────┘

CLI equivalent:
$ bowyer calc --jd 2460345.5 --lat 40.7128 --lon -74.006 --houses placidus
$ bowyer calc --jd 2460345.5 --raw
```

### 5. Monitoring & Metrics

```
┌─────────────────────────────────────────┐
│  Metrics                                │
│                                         │
│  Requests/min:  ████████████░░  847     │
│  Cache hit:     █████████████░  94%     │
│  Avg latency:   ██░░░░░░░░░░░  23ms    │
│  Error rate:    ░░░░░░░░░░░░░  0.1%    │
│                                         │
│  Arrow calcs:   12,847 today            │
│  Broadhead fwd: 3,201 today             │
│                                         │
└─────────────────────────────────────────┘

CLI equivalent:
$ bowyer metrics
$ bowyer metrics --watch
$ bowyer metrics --service arrow --period 24h
```

### 6. User Management

```
┌──────────────────────────────────────────────────────┐
│  Users                                               │
│                                                      │
│  Search: [____________]                              │
│                                                      │
│  user_123  josh@example.com   Admin   Active  [Edit] │
│  user_456  test@example.com   User    Active  [Edit] │
│                                                      │
└──────────────────────────────────────────────────────┘

CLI equivalent:
$ bowyer users list
$ bowyer users show user_123
$ bowyer users set-role user_123 admin
```

---

## Auth

Bowyer authenticates via the same external auth service (Supabase) as everything else. But it requires an **admin role** on the JWT. Regular users cannot access Bowyer.

```
Admin logs into Bowyer
    │
    ▼
Supabase Auth → JWT with role: admin
    │
    ▼
Bowyer validates JWT
Checks role == admin
    │
    ├── YES → full access
    └── NO  → rejected
```

---

## Open Questions

- 🔌 **Broadhead direct access** — Should Bowyer talk to broadheads directly for health/metrics, or always go through Quiver?
- 📊 **Metrics storage** — Where do metrics live? Quiver collects and stores? Separate metrics service?
- 🔔 **Alerting** — Should Bowyer have alerting (email/push when something goes down), or is that a separate concern?
- 🔐 **Role granularity** — Just admin/not-admin, or finer-grained (read-only admin, super admin, etc.)?
- 🌐 **Deployment** — Bowyer web hosted alongside Quiver? Separate static hosting?
