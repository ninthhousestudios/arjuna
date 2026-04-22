---
id: plan-2026-04-21-phase-a-infrastructure
type: plan
date: 2026-04-21
source: "inline research + chitta memories (019db219-4966, 019db219-0262, 019db219-7709)"
---

# Plan: Phase A — Infrastructure (Vayu + Drishti + Isolate Pool + Proto Codegen)

## Context

Arrow's 4-layer pipeline (options → swe → core → calc) is solid and tested. Quiver serves gRPC with a working chart calculation RPC. But there's no way to use Arrow without either importing 4 packages and wiring them manually, or spinning up a gRPC server. Phase A creates the infrastructure that makes Arrow consumable: Vayu embeds it in-process, Drishti wraps it as MCP tools, the isolate pool makes Quiver concurrent, and proto codegen removes a manual maintenance step.

Drishti is the MCP server for the Aion desktop app. LLMs in Aion's chat panel call Drishti to compute charts, query positions, and get panchanga data. Per Aion architecture (Chitta), Drishti uses `mcp_dart v2.1.0` with stdio transport. It embeds Arrow via Vayu — no gRPC needed for local use.

Applied findings: none (first plan in this repo).

## Boundaries

**Always:**
- Port from existing code (arrow_swe, quiver_core), don't reinvent
- Tests alongside implementation — same commit
- Vayu must not depend on quiver_core's proto types — it returns native Dart objects (Chart, EphSnapshot)
- Drishti tools return structured JSON, not raw numbers
- swisseph.dart (our own package) is already isolate-safe — each isolate gets independent C state

**Ask First:**
- Drishti tool schema: which tools to ship in v1 vs defer
- Isolate pool sizing defaults
- Whether Vayu should expose a streaming/watch API for transit tracking

**Never:**
- Auth in this phase (Phase C)
- Remote Quiver routing in Drishti (later — Vayu only for now)
- Broadhead integration
- KalaBrain integration

## Files to Modify

| File | Change |
|------|--------|
| `arrow/swe/lib/src/julian_day.dart` | **NEW** — Julian Day utilities (DateTime ↔ JD) |
| `arrow/swe/lib/arrow_swe.dart` | Export `julian_day.dart` |
| `arrow/swe/test/julian_day_test.dart` | **NEW** — JD conversion tests |
| `quiver/embedded/pubspec.yaml` | Add arrow_swe, arrow_core, arrow_calc, swisseph deps |
| `quiver/embedded/lib/quiver_embedded.dart` | Vayu class implementation |
| `quiver/embedded/lib/src/vayu.dart` | **NEW** — core Vayu facade |
| `quiver/embedded/test/vayu_test.dart` | **NEW** — Vayu integration tests |
| `drishti/pubspec.yaml` | **NEW** — package manifest (mcp_dart, quiver_embedded) |
| `drishti/lib/drishti.dart` | **NEW** — barrel export |
| `drishti/lib/src/server.dart` | **NEW** — MCP server setup (stdio transport) |
| `drishti/lib/src/tools/calculate_chart.dart` | **NEW** — calculate_chart tool |
| `drishti/lib/src/formatting/chart_formatter.dart` | **NEW** — Chart → LLM-friendly JSON |
| `drishti/bin/drishti.dart` | **NEW** — CLI entry point (stdio MCP server) |
| `drishti/test/tools_test.dart` | **NEW** — MCP tool tests |
| `quiver/server/lib/src/isolate_pool.dart` | **NEW** — Isolate pool with per-isolate SweFacade |
| `quiver/server/lib/src/server.dart` | Integrate isolate pool into QuiverServer.start() |
| `quiver/server/test/isolate_pool_test.dart` | **NEW** — Pool concurrent correctness tests |
| `melos.yaml` | Add `protogen` script, add drishti to workspace |
| `pubspec.yaml` | Add `drishti` to workspace packages list |

## Baseline Audit

| Metric | Command | Result |
|--------|---------|--------|
| Existing packages in workspace | `grep -c 'arrow\|quiver\|nock\|bowyer' pubspec.yaml` | 11 packages |
| quiver_embedded LOC | `wc -l quiver/embedded/lib/quiver_embedded.dart` | 1 line (comment) |
| drishti contents | `ls drishti/` | Empty directory |
| Proto files | `find proto/ -name '*.proto'` | 3 files (types, chart, health) |
| Generated proto files | `ls quiver/core/lib/src/generated/**/*.dart` | 11 files |
| protoc installed | `protoc --version` | libprotoc 34.1 |
| protoc-gen-dart installed | `dart pub global list` | protoc_plugin 25.0.0 |
| SweFacade.calcAll signature | `grep 'EphSnapshot calcAll' arrow/swe/lib/src/swe_facade.dart` | `calcAll(double jdUt, Location location, ArrowOptions options)` |
| Chart constructor | `grep 'Chart(' arrow/core/lib/src/chart.dart` | `Chart(EphSnapshot snapshot, CalcConfig config)` |

## Implementation

### 1. Julian Day Utility (arrow_swe)

Arrow has no public JD conversion. `SwissEph.julday()` exists in swisseph.dart but isn't re-exported by arrow_swe. Vayu needs DateTime → JD to hide this from consumers.

In `arrow/swe/lib/src/julian_day.dart` — **NEW**:

- **Add `julianDay(DateTime dt)`**: Convert UTC DateTime to Julian Day (UT). Delegate to `SwissEph.swe_julday()` or implement the Meeus algorithm (already exists privately in `arrow/tool/bin/generate_test_data.dart`). Pure function, no SwissEph instance needed if using Meeus.

- **Add `fromJulianDay(double jd)`**: Reverse conversion, JD → DateTime (UTC). Needed for dasha date display and transit queries.

- **Key reference**: `arrow/tool/bin/generate_test_data.dart` has a working Meeus implementation. Port it.

In `arrow/swe/lib/arrow_swe.dart`:
- Add `export 'src/julian_day.dart';`

### 2. Vayu — Embedded Arrow Facade (quiver_embedded)

The single entry point for in-process Arrow. Manages SwissEph lifecycle, converts DateTime to JD, runs the full pipeline.

In `quiver/embedded/lib/src/vayu.dart` — **NEW**:

```dart
class Vayu {
  Vayu({String? ephePath, String? jplFile});

  /// Full pipeline: DateTime + Location + Options → Chart
  Chart calculateChart(DateTime dateTimeUtc, Location location, ArrowOptions options);

  /// SWE layer only: DateTime + Location + Options → EphSnapshot
  EphSnapshot calculateSnapshot(DateTime dateTimeUtc, Location location, ArrowOptions options);

  /// Recalculate with different CalcConfig, reusing an existing snapshot
  Chart recalculate(EphSnapshot snapshot, CalcConfig config);

  /// Clean up SwissEph C resources
  void dispose();
}
```

Internal construction:
1. Constructor creates `SwissEph` (via `SwissEph.find()` or explicit path) and `SweFacade`
2. `calculateChart` calls `julianDay(dt)` → `SweFacade.calcAll(jd, loc, opts)` → `Chart(snapshot, opts.calcConfig)`
3. `recalculate` is free — just `Chart(existingSnapshot, newConfig)`, no SWE call
4. `dispose` calls `swe.close()`

**Key functions to reuse:**
- `SweFacade` constructor at `arrow/swe/lib/src/swe_facade.dart`
- `SweFacade.calcAll()` at `arrow/swe/lib/src/swe_facade.dart`
- `Chart()` constructor at `arrow/core/lib/src/chart.dart`
- `ArrowPresets` at `arrow/options/lib/src/presets.dart`

In `quiver/embedded/pubspec.yaml`:
- Add dependencies: `arrow_options`, `arrow_swe`, `arrow_core`, `arrow_calc`, `swisseph`, `logging`

In `quiver/embedded/lib/quiver_embedded.dart`:
- Replace the comment with barrel that exports `src/vayu.dart` and re-exports the public barrels of `arrow_core`, `arrow_options`, and `arrow_swe`. This lets consumers (Drishti, Nock) use a single import for Vayu + all domain types without depending on arrow_* packages directly. Can tighten later if needed.

### 3. Drishti — MCP Server

Dart MCP server using `mcp_dart` v2.1.0, stdio transport. Embeds Arrow via Vayu.

**3a. Package scaffold**

In `drishti/pubspec.yaml` — **NEW**:
- name: `drishti`
- dependencies: `mcp_dart: ^2.1.0`, `quiver_embedded`, `logging`, `json_annotation`
- dev_dependencies: `test`, `build_runner`, `json_serializable`

In `drishti/bin/drishti.dart` — **NEW**:
- Parse `--ephe-path` CLI arg (fallback: `DRISHTI_EPHE_PATH` env var) for ephemeris data directory
- Create `Vayu` instance with ephePath
- Create MCP server with stdio transport
- Register tools
- Start listening

**3b. MCP tool (v1 — 1 tool)**

`calculate_chart` tool:
- Input: `date` (ISO 8601), `latitude`, `longitude`, `altitude?`, `preset?` (ernst/lahiri/western), `options?` (override object)
- Calls: `Vayu.calculateChart()`
- Output: Formatted chart summary — all planets with sign, nakshatra, pada, dignity, retrograde status; house cusps with signs; ascendant, MC

Additional tools (get_panchanga, get_varga, get_aspects, etc.) will be added as needed.

**3c. Response formatting**

In `drishti/lib/src/formatting/chart_formatter.dart` — **NEW**:
- `Map<String, dynamic> formatChart(Chart chart)` — structured JSON with human-readable strings
- Each planet entry includes: `name`, `longitude`, `sign` (name + number), `nakshatra` (name + pada), `dignity`, `is_retrograde`, `speed_class`, `house`
- House entries include: `number`, `sign`, `longitude`

### 4. Isolate Pool (quiver_server)

swisseph.dart is our own package and is already isolate-safe — each Dart isolate gets independent C state via dart:ffi. No safety validation gate needed.

**4a. Pool implementation**

In `quiver/server/lib/src/isolate_pool.dart` — **NEW**:

```dart
class IsolatePool {
  IsolatePool({required int size, String? ephePath});

  /// Send a calc request to the next available isolate
  Future<EphSnapshot> calculate(double jdUt, Location location, ArrowOptions options);

  /// Graceful shutdown — drain queue, close all isolates
  Future<void> dispose();
}
```

Internal design:
- `size` worker isolates, each constructed with its own `SwissEph` + `SweFacade`
- Round-robin or shortest-queue dispatch via `SendPort`/`ReceivePort`
- Each isolate runs an event loop: receive request → calcAll → send response
- Pool startup is async (isolates spawn in parallel)

**4b. Server integration**

In `quiver/server/lib/src/server.dart`:
- Replace single `SweFacade` in `QuiverServer.start()` with `IsolatePool`
- `ArrowGateway` needs to accept pool-based async calculation (currently synchronous)
- Modify `ArrowGateway.calculateChart()` to return `Future<CalcResponse>` instead of `CalcResponse`
- `ChartService.calculate()` already returns `Future` (gRPC is async), so the service layer change is minimal

**Key functions to modify:**
- `QuiverServer.start()` — construct `IsolatePool` instead of `SweFacade`
- `ArrowGateway.calculateChart()` — make async, delegate to pool
- `QuiverServer.stop()` — dispose pool

### 5. Proto Codegen Script

In `melos.yaml`:
- Add `protogen` script:
```yaml
protogen:
  run: |
    protoc \
      --proto_path=proto \
      --dart_out=grpc:quiver/core/lib/src/generated \
      proto/arrow/types.proto \
      proto/arrow/chart.proto \
      proto/quiver/health.proto
  description: Regenerate Dart proto stubs from .proto files
```

## Tests

**`arrow/swe/test/julian_day_test.dart`** — **NEW**:
- `testJulianDay_knownEpoch`: J2000.0 (2000-01-01 12:00 UTC) = 2451545.0
- `testJulianDay_roundTrip`: DateTime → JD → DateTime preserves to millisecond
- `testJulianDay_negativeYear`: BCE dates work correctly

**`quiver/embedded/test/vayu_test.dart`** — **NEW**:
- `testVayu_calculateChart_returnsChart`: Ernst preset, known date → Chart with 9 grahas
- `testVayu_recalculate_reuseSnapshot`: Same snapshot, different CalcConfig → different sign placements
- `testVayu_dispose_cleansUp`: dispose() doesn't throw, subsequent calls do

**`drishti/test/tools_test.dart`** — **NEW**:
- `testCalculateChart_validInput_returnsFormattedChart`: ISO date + coords → JSON with planet entries
- `testCalculateChart_withPreset_usesPreset`: preset="lahiri" → Lahiri sidereal chart

**`quiver/server/test/isolate_pool_test.dart`** — **NEW**:
- `testPool_concurrentRequests`: 10 concurrent requests complete without error
- `testPool_resultsMatchSequential`: Pool results match single-threaded SweFacade results
- `testPool_dispose_drainsQueue`: In-flight requests complete before shutdown

## Conformance Checks

| Issue | Check Type | Check |
|-------|-----------|-------|
| Issue 1 (Vayu) | content_check | `{file: "arrow/swe/lib/src/julian_day.dart", pattern: "double julianDay"}` |
| Issue 1 (Vayu) | content_check | `{file: "quiver/embedded/lib/src/vayu.dart", pattern: "class Vayu"}` |
| Issue 1 (Vayu) | tests | `cd arrow/swe && dart test test/julian_day_test.dart && cd ../../quiver/embedded && dart test` |
| Issue 2 (Drishti) | files_exist | `["drishti/pubspec.yaml", "drishti/bin/drishti.dart", "drishti/lib/src/server.dart"]` |
| Issue 2 (Drishti) | content_check | `{file: "drishti/lib/src/tools/calculate_chart.dart", pattern: "calculate_chart"}` |
| Issue 2 (Drishti) | tests | `cd drishti && dart test` |
| Issue 3 (Isolates) | content_check | `{file: "quiver/server/lib/src/isolate_pool.dart", pattern: "class IsolatePool"}` |
| Issue 3 (Isolates) | tests | `cd quiver/server && dart test test/isolate_pool_test.dart` |
| Issue 4 (Proto) | command | `melos run protogen && git diff --exit-code quiver/core/lib/src/generated/` |

## Verification

1. **JD tests**: `cd arrow/swe && dart test test/julian_day_test.dart -v`
2. **Vayu integration**: `cd quiver/embedded && dart test -v`
3. **Drishti tools**: `cd drishti && dart test -v`
4. **Pool integration**: `cd quiver/server && dart test test/isolate_pool_test.dart -v`
6. **Proto codegen idempotent**: `melos run protogen && git diff --exit-code quiver/core/lib/src/generated/`
7. **Full suite**: `melos run test`
8. **Manual Drishti smoke test**:
   ```bash
   # Start drishti via stdio
   echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | dart run drishti/bin/drishti.dart
   # Should list calculate_chart
   ```

## Issues

### Issue 1: Julian Day utility + Vayu facade
**Dependencies:** None
**Files:** `arrow/swe/lib/src/julian_day.dart`, `arrow/swe/lib/arrow_swe.dart`, `arrow/swe/test/julian_day_test.dart`, `quiver/embedded/pubspec.yaml`, `quiver/embedded/lib/quiver_embedded.dart`, `quiver/embedded/lib/src/vayu.dart`, `quiver/embedded/test/vayu_test.dart`
**Acceptance:** `Vayu.calculateChart()` returns a valid Chart for a known date/location. JD round-trips correctly. Tests pass.
**Description:** Add DateTime ↔ JD conversion to arrow_swe. Implement the Vayu class in quiver_embedded — full pipeline from DateTime + Location + ArrowOptions → Chart. Manage SwissEph lifecycle. See Implementation sections 1 and 2.

### Issue 2: Drishti MCP server
**Dependencies:** Issue 1 (Vayu)
**Files:** All `drishti/` files, `melos.yaml` (add package), `pubspec.yaml` (add to workspace)
**Acceptance:** `dart run drishti/bin/drishti.dart` starts an MCP server on stdio. `tools/list` returns calculate_chart. Valid input returns formatted chart JSON. Tests pass.
**Description:** Scaffold the drishti Dart package. Set up mcp_dart v2.1.0 MCP server with stdio transport. Implement calculate_chart tool. Format response as LLM-friendly JSON. See Implementation section 3.

### Issue 3: Isolate pool + Quiver integration
**Dependencies:** None (swisseph.dart is already isolate-safe)
**Files:** `quiver/server/lib/src/isolate_pool.dart`, `quiver/server/lib/src/server.dart`, `quiver/server/test/isolate_pool_test.dart`
**Acceptance:** QuiverServer uses isolate pool. Concurrent gRPC requests are handled in parallel. Pool results match sequential SweFacade results. Tests pass.
**Description:** Implement IsolatePool with configurable size. Each isolate gets its own SwissEph + SweFacade. Integrate into QuiverServer, making ArrowGateway async. See Implementation section 4.

### Issue 4: Proto codegen script
**Dependencies:** None
**Files:** `melos.yaml`
**Acceptance:** `melos run protogen` regenerates all stubs. Output matches committed files (idempotent).
**Description:** Add `protogen` melos script that runs protoc with dart_out for all .proto files. See Implementation section 5.

## File-Conflict Matrix

| File | Issues |
|------|--------|
| `arrow/swe/lib/arrow_swe.dart` | Issue 1 |
| `quiver/embedded/pubspec.yaml` | Issue 1 |
| `quiver/embedded/lib/quiver_embedded.dart` | Issue 1 |
| `quiver/server/lib/src/server.dart` | Issue 3 |
| `melos.yaml` | Issue 2, Issue 4 | ← CONFLICT: serialize (Wave 1 then Wave 2) |
| `pubspec.yaml` | Issue 2 |

## Cross-Wave Shared Files

| File | Wave 1 Issues | Wave 2 Issues | Mitigation |
|------|---------------|---------------|------------|
| `melos.yaml` | Issue 4 | Issue 2 | Issue 2 adds drishti package; Issue 4 adds protogen script. Non-overlapping sections, but serialize to avoid merge conflict. |

## Execution Order

**Wave 1** (parallel): Issue 1 (JD + Vayu), Issue 3 (isolate pool), Issue 4 (proto codegen)
**Wave 2** (after Wave 1): Issue 2 (Drishti — needs Vayu from Issue 1)

```
Wave 1:  [Issue 1: Vayu]  [Issue 3: Isolate pool]  [Issue 4: Proto codegen]
              │
              v
Wave 2:  [Issue 2: Drishti]
```

## Post-Merge Cleanup

After wave merges:
- Verify `melos bootstrap` still works with drishti added
- Run `melos run analyze` across all packages
- Check that drishti's mcp_dart dependency resolves correctly in the workspace
- Verify `melos run protogen` is idempotent against committed generated code

## Next Steps
- Review plan, adjust tool selection for Drishti v1
- Run `/pre-mortem` to validate plan
- Execute Wave 1 (3 parallel workers: Vayu, isolate pool, proto codegen)
- Execute Wave 2 (1 worker: Drishti)
