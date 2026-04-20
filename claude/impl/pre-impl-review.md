# Pre-Implementation Review Summary (2026-03-07)

Comprehensive review of all Arjuna + Fletch architecture before coding begins.

## Overall Assessment

Architecture is ~85% consistent and well-designed. The 15% gap is doc contradictions (most now fixed), under-specified integration points, and unvalidated assumptions. Source material is excellent. No code exists yet.

## Top Risks (ordered by severity)

### 1. sweph.dart isolate behavior (could break server arch)
The concurrency model assumes each Dart isolate gets its own C library state via FFI. If sweph.dart uses process-global state, concurrent calculations will interfere. **Must test in Arrow 2A spike** with two isolates calling calcAll() simultaneously with different inputs.

### 2. System topology ambiguity (Quiver vs KalaBrain)
grpc-server-proposal.md (historical) described: Client → KalaBrain (HTTP) → Arrow Server (internal gRPC). Quiver base.md (current) describes: Client → Vayu → Quiver (primary gRPC) → KalaBrain (broadhead). These are fundamentally different architectures. The proposal is now marked historical; current truth is in base.md.

### 3. Vayu under-specification
Vayu is the most important user-facing abstraction, but routing criteria, offline behavior, JWT lifecycle, state persistence, and sync protocol are all open questions. Added to `arjuna/todo.md` for deeper examination.

### 4. EphSnapshot is the single biggest ripple point
Changes to EphSnapshot ripple to: proto definitions, Quiver mapping layer, Fletch adapter, Supabase cache schema. No explicit "design freeze" gate exists before Quiver starts depending on it.

### 5. Three-way consensus can hide inherited bugs
KalaNG bug → libkala inherits (wraps same engine via pythonnet) → Arrow ports faithfully → Fletch shows 100% agreement on wrong value. **Note:** libkala also has native Python Chart objects — testing those provides a partially independent validation path.

## Non-Obvious Architectural Risks (items 5-10)

Detailed in `memory/architectural-risks.md`:
- **EphSnapshot versioning**: no version field for Supabase cache invalidation
- **Ephemeris .se1 files**: bundling/location unspecified across platforms
- **Circular fallback**: Arrow device → HTTP → KalaBrain → gRPC → Arrow server
- **CalcConfig "free" changes**: still require full Chart reconstruction
- **Multi-tradition routing**: no designed mechanism for which tradition modules run
- **Proto-domain divergence**: growing maintenance burden in mapping layer

## Strengths

- 3-layer pipeline is architecturally sound
- SweConfig/CalcConfig split is elegant and enforces boundaries at the type level
- Source material is complete with working validation API (KalaEngine.Api)
- Fletch as independent validation framework is well-designed
- Deferred decisions are well-reasoned with saved blueprints
- Implementation plans have clear phase gates and parallelism
- Domain model hierarchy (Planet > Graha > Karaka) is clean

## Doc Contradictions (status)

| Issue | Status |
|-------|--------|
| base.md interfaces vs universal-options.md composition | FIXED |
| EphSnapshot: full ArrowOptions vs SweConfig only | FIXED (SweConfig only) |
| Body vs BodyId naming | Noted, not yet in code |
| types-sketch.dart references | FIXED (all removed) |
| grpc-server-proposal.md old topology | FIXED (marked historical) |
| Broadhead system designed but deferred | Still needs "Future Design" label |
| Nock in unified timeline | FIXED |
| 1B enum file structure | FIXED (tradition-scoped) |

## Before First Line of Code

1. ~~Fix doc contradictions~~ (mostly done)
2. Decide buf vs protoc (or defer proto and start with direct Dart imports)
3. Extract 5 reference charts from KalaEngine.Api as test fixtures
4. Verify KalaEngine.Api runs on current machine
5. Add EphSnapshot version field to design (deferred to 2B spike)
6. ~~Mark grpc-server-proposal.md as historical~~ (done)
7. ~~Update unified timeline for Nock deferral~~ (done)
