# Arjuna Architecture — First Draft Critique

## What It Does Well

**The pipeline is the best decision in here.** The 3-layer separation (swe → core → calc) with EphSnapshot as an immutable bridge is clean, testable, and enforced at the package boundary. arrow_core and arrow_calc are pure Dart — you can test the entire derived calculation engine without ever touching FFI or ephemeris files.

**SweConfig vs CalcConfig split is elegant.** Making CalcConfig changes free (same snapshot, new Chart) is a genuinely good insight. Users can flip between Aditya/Zodiac circle, change varga methods, toggle dasha options — all instant, no recalculation.

**Vayu as the frontend boundary** is the right abstraction. Frontends shouldn't know about local vs remote, gRPC, broadheads, or caching. One interface, everything hidden behind it.

**The rich-but-thin domain model** (Chart/Planet/Graha/Karaka as views over EphSnapshot, not owners of computation) avoids the Python problem (Planet as god object) and the C# problem (everything is static methods on data bags).

**Proto as single source of truth** with generated code on both sides eliminates an entire class of serialization bugs.

---

## What It Fails At / Potential Problems

### 1. Two conflicting ArrowOptions designs — RESOLVED

Use composition from universal-options.md. ArrowOptions composes SweConfig + CalcConfig as fields, not interfaces.

### 2. EphSnapshot also has two versions — RESOLVED

Existing sketches are prototypes, not code. EphSnapshot will be redesigned from scratch after exploring the sweph.dart API (impl/one.md Step 2). The goal: SweConfig covers every sweph.dart option, EphSnapshot captures every SWE output. Designed once from real API knowledge, not speculation. Previous prototypes saved in `arrow/future.md`.

### 3. The multi-tradition architecture is premature — DEFERRED

Build VedicConfig as CalcConfig for now. Multi-tradition design saved as blueprint in `arrow/future.md` and `arrow/claude/arch/universal-options.md` for when a second tradition is needed.

### 4. Local Quiver / Vayu raises hard unsolved questions — DEFERRED TO MEASUREMENT

Local vs remote routing criteria will emerge from real performance data as Arrow is built and tested. Building and testing arrow_swe/arrow_core will naturally reveal how long each calc type takes on-device.

Nock clarified: default mode is a local full gRPC server (separate process). Also supports in-process via Vayu (direct Dart calls, no server). Both modes exist because both are built into the architecture. See `claude/impl/one.md`.

### 5. The broadhead system is over-designed for what exists — DEFERRED

Build KalaBrain integration directly. Generic broadhead pattern saved as blueprint in `quiver/future.md` for when a second plugin is needed.

### 6. Quiver-to-Quiver sync is handwaved — DEFERRED

Most calcs happen on-device, so caching may not even be necessary. Sync protocol deferred until real usage data shows what Remote Quiver handles and whether repeat calculations are common. Notes in `quiver/future.md`.

### 7. No error handling strategy anywhere — WILL ADDRESS DURING BUILD

Error handling, logging, and testing are built into every layer as it is constructed. Not deferred. See project-wide principle in `claude/impl/one.md`.

### 8. Testing strategy is absent — WILL ADDRESS DURING BUILD

Testing is built into every layer as it is constructed. Test fixtures from KalaNG/libkala known-good outputs. Tolerance thresholds and regression strategy determined as arrow_swe is built. See project-wide principle in `claude/impl/one.md`.

### 9. EphSnapshot carrying full ArrowOptions is wasteful — RESOLVED

EphSnapshot will store only SweConfig, not full ArrowOptions. CalcConfig is irrelevant to the snapshot's data.

### 10. No versioning / migration strategy for serialized data

EphSnapshot gets stored in Supabase and serialized as JSON. When a field is added to EphSnapshot (and it will be), what happens to cached data? freezed + json_serializable doesn't give schema migration. Consider this early — even just "if deserialized snapshot has a version mismatch, discard and recalculate" would be enough.

---

## Things You Don't Know You Don't Know

**sweph.dart's actual API surface.** The architecture assumes ~15 SWE functions wrapped behind a facade. This is the first implementation step — explore sweph.dart, audit its full surface, and design SweConfig to cover every option. See `claude/impl/one.md` Steps 2-3.

**Dart gRPC server maturity.** Building Quiver's basic gRPC server is the second implementation track (parallel with Arrow). gRPC is the backbone for Bowyer and Nock too, so it gets validated naturally by building all five apps step-by-step. See `claude/impl/one.md` Quiver Step 1.

**Melos at this scale.** 8+ packages in a Dart monorepo. Will investigate as packages are created. May need repo splitting if friction appears.

**Freezed codegen at scale.** build_runner across many packages can become a bottleneck. Will investigate as types accumulate.

**Isolate startup cost.** Ephemeris files are read-only (~36MB total), mounted once for all isolates — concurrent read access is safe. The question is whether sweph.dart's C library initialization (calling `swe_set_ephe_path` etc.) is expensive per-isolate, since each isolate loads its own copy of the C library's memory. Will measure during arrow_swe implementation.

---

## Recommendation for Starting Implementation

The core architecture (Arrow pipeline, EphSnapshot bridge, SweConfig/CalcConfig split, Vayu boundary) is strong. Premature abstractions (multi-tradition, broadhead system) deferred as blueprints. Hard problems (error handling, testing) addressed as each layer is built.

Full implementation plan: `claude/impl/one.md`
