# Quiver

gRPC service layer over Arrow. Exposes astrological chart calculation as a protobuf API with two deployment modes: in-process embedded (`Vayu`) and multi-isolate gRPC server.

## Package structure

```
core/  ←  embedded/
core/  ←  server/
```

| Package | Role |
|---------|------|
| `quiver_core` | Proto-generated types, `ArrowGateway`, request/response mappers. Shared by both deployment modes. |
| `quiver_server` | gRPC server. `IsolatePool` runs one independent `SweFacade` per isolate (round-robin, 2–16). |
| `quiver_embedded` | `Vayu` — in-process facade. Direct `SweFacade` calls, no isolates, no gRPC. |

`embedded/` and `server/` do not depend on each other.

## Proto

Source protos live at `proto/arrow/` and `proto/quiver/` (monorepo root). Generated Dart lands in `core/lib/src/generated/`. Regenerate with `melos protogen` from the monorepo root.

- `chart.proto` — `ChartService.Calculate` RPC, `CalcRequest`, `CalcResponse`
- `being_health.proto` — `BeingHealthService.RankBeings` RPC; wraps `PlanetHealth.rank`, returns one `BeingRanking` per computed chart (7 karakas ranked, full `PlanetHealthScore` breakdown). Rank by `strong_virupas` then `aspect_virupas`, never the total.
- `types.proto` — `Body`, `CalculationPreset`, `BeingType`, `Hora`, `Being`, `PlanetPlacement`, `EphSnapshot`, etc.
- `health.proto` — `HealthService`

Proto conventions: `_PRESET`, `_BEING`, `_HORA` suffixes avoid proto3 package-scoped name collisions (e.g. `ADITYA_PRESET` vs `Circle.ADITYA`, `SUN_HORA` vs `Body.SUN`).

## Preset-only API

Clients send a `CalculationPreset` enum, not raw config fields. `RequestMapper` resolves presets to `ArrowOptions` via `ArrowPresets.aditya`, `.lahiriVedic`, `.westernTropical`. Unspecified defaults to Aditya.

Raw config fields (ayanamsa, house system, circle, bodies) were removed and reserved in the proto.

## ArrowGateway

Abstracts over sync vs async calculation via `SnapshotCalculator` typedef:
```
Future<EphSnapshot> Function(double jdUt, Location, ArrowOptions)
```
- Server wraps `IsolatePool.calculate` (async, multi-isolate)
- Embedded wraps `SweFacade.calcAll` (sync, in-process)

`ResponseMapper` receives the snapshot and builds `Chart` (from `arrow_core`) to extract being/placement data. Chart construction is pure Dart computation — no FFI, no isolate boundary concerns.

## IsolatePool

Pool of worker isolates for CPU parallelism over synchronous `SweFacade.calcAll`. Each worker owns an independent `SweFacade` backed by a swisseph_rs engine with no shared mutable state. Serializes across isolate boundaries via JSON (`jsonEncode`/`jsonDecode` of freezed models).

## Testing

```bash
# from monorepo root
dart test quiver/server/test/
dart test quiver/embedded/test/
```

All server tests are integration tests that spin up `QuiverServer(port: 0)` with a real `IsolatePool`. Test fixture: J2000.0 (2451545.0), New York or New Delhi, `ADITYA_PRESET`.

`quiver_core` has no tests — its logic is covered by server/embedded integration tests.

## Server CLI

```bash
dart run quiver/server/bin/quiver_server.dart \
  --port 50051 --ephe-path <path> --pool-size 4 --log-level info
```

## Key files

| File | What |
|------|------|
| `core/lib/src/gateway/arrow_gateway.dart` | SnapshotCalculator abstraction |
| `core/lib/src/mapping/request_mapper.dart` | Preset → ArrowOptions resolution |
| `core/lib/src/mapping/response_mapper.dart` | EphSnapshot + CalcConfig → CalcResponse with placements |
| `server/lib/src/isolate_pool.dart` | Multi-isolate SweFacade pool |
| `server/lib/src/server.dart` | QuiverServer wiring |
| `embedded/lib/src/vayu.dart` | In-process facade |
