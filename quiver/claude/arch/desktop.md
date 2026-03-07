# Quiver — Renamed from Arrow Server

Arrow Server is renamed to **Quiver**. Arrow is the calculation engine (the packages). Quiver is the server that holds the arrows — the gRPC service that wraps Arrow and serves computation requests.

## Naming

```
Arrow      -- the calculation engine (arrow_swe, arrow_core, arrow_calc)
Quiver     -- the gRPC server that wraps Arrow (runs locally or remotely)
```

## Desktop Professional App

On a desktop machine, Quiver runs locally with full resources. The topology is the same as mobile but the routing is simpler — almost everything stays local:

```
Desktop App (Flutter)
    |
    +-- gRPC to localhost --> Quiver (local, full power)
    |       everything computational:
    |       chart calculation, dashas, transits, muhurtha,
    |       compatibility, shadbala, panchanga, event search,
    |       varshaphala, prasna, eclipses, etc.
    |
    +-- HTTP to KalaBrain --> Aditi only
            AI chat, RAG queries, LLM orchestration,
            conversation persistence
```

### Why this works well for desktop

- **Full ephemeris data** — no need to trim for app bundle size. Include everything.
- **No battery concern** — heavy batch operations (transit search over decades, muhurtha scanning) run freely.
- **No latency** — all computation is localhost gRPC. Sub-millisecond round trips.
- **Same packages** — identical `arrow_client`, `arrow_server`, `.proto` contract as mobile. The router just has a simpler policy.

### Router policy for desktop

```dart
// Desktop router: everything local except Aditi
Future<ChartResponse> calcChart(ChartRequest req) async {
  return await _local.calcChart(req);
  // no fallback needed — desktop always has local Quiver
}

// Aditi goes to KalaBrain
Future<AditiResponse> askAditi(AditiRequest req) async {
  return await _kalabrain.chat(req);
}
```

### Professional features that benefit from local power

- **Batch transit search** — find all dates when Saturn aspects natal Moon over 20 years
- **Muhurtha scanning** — score every 15-minute window over a month
- **Multi-chart comparison** — compatibility between many chart pairs
- **Animated transits** — continuous recalculation as time scrubs forward
- **Rectification** — iterative chart calculation with event fitting

All of these are CPU-intensive and benefit from running on a desktop machine with no network round-trip.
