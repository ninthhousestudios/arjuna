# Arrow C4 Architecture Diagrams

C4 model of the Arrow calculation engine, generated from source analysis.

## Diagrams

| File | Level | Description |
|------|-------|-------------|
| [c1-system-context](c1-system-context.png) | C1 | External actors and systems around Arrow |
| [c2-container](c2-container.png) | C2 | Arrow's sub-packages and their dependencies |
| [c3-component-arrow-swe](c3-component-arrow-swe.png) | C3 | Internal components of the arrow_swe ephemeris layer |
| [c3-component-arrow-core](c3-component-arrow-core.png) | C3 | Internal components of the arrow_core domain model |
| [c3-component-arrow-calc](c3-component-arrow-calc.png) | C3 | Internal components of the arrow_calc calculations layer |
| [c4-chart-calculation-pipeline](c4-chart-calculation-pipeline.png) | C4 | Sequence: full chart calculation from options to calc results |
| [c4-panchanga-pipeline](c4-panchanga-pipeline.png) | C4 | Sequence: panchanga (five-limbed calendar) calculation flow |

## Architecture review

| # | Issue | Severity | Diagram evidence | Code evidence | Status |
|---|-------|----------|-----------------|---------------|--------|
| 1 | **Swiss Ephemeris is a single point of failure.** C1 and C4 show all calculations flowing through SweFacade -> Swiss Ephemeris native FFI. KalaBrain is shown as an HTTP fallback, but no fallback code exists. Web/WASM targets cannot use dart:ffi. | high | C1 shows `Rel(arrow, kalabrain, "HTTP fallback")`. C4 chart pipeline shows no alt path when SWE is unavailable. | `grep -ri kalabrain swe/lib/` returns zero results. No HTTP client in any Arrow pubspec.yaml. KalaBrain exists only in `claude/arch/base.md` as a planned data source. | confirmed |
| 2 | **Supabase cache shown but not implemented.** C2 shows `Rel(swe, supabase, "Cache read/write")` as an active connection, but no Supabase dependency or code exists in Arrow. | medium | C2 container diagram shows Supabase as `System_Ext` with a relationship to arrow_swe. | `grep -ri supabase */pubspec.yaml` returns zero results. No Supabase imports anywhere in Arrow source. Architecture doc mentions it as a future EphSnapshot source. | confirmed |
| 3 | **arrow_calc declares unnecessary arrow_swe dependency.** calc/pubspec.yaml lists `arrow_swe: path: ../swe` but no file in `calc/lib/` imports from arrow_swe. The transitive dependency via arrow_core is sufficient. | low | C2 shows `Rel(calc, swe, "Imports", "path dep")`. | `grep -r "import.*arrow_swe" calc/lib/` returns zero results. All calc code accesses ephemeris data through arrow_core's Chart/Graha types, never EphSnapshot directly. | confirmed |
| 4 | **No error path in chart calculation pipeline.** The C4 sequence shows only the barycentric+Moshier fail-fast guard. If `calcUt` fails for a specific body (corrupted ephemeris file, unsupported body ID), no recovery or skip-and-continue path is visible. | medium | C4 chart pipeline shows a linear loop over bodies with no `alt` for failure cases. | `swe_facade.dart` calls `_swe.calcUt()` in a loop without try/catch per body. A single body failure would abort the entire `calcAll()`. | unconfirmed |
| 5 | **C1 layout renders vertically.** Mermaid's C4Context renderer does not support `UpdateLayoutConfig`, so all 10 nodes stack one-per-row, making relationships hard to trace. | low | C1 PNG is extremely tall with overlapping relationship labels. | N/A (rendering limitation, not code issue). Consider splitting into fewer nodes or using C4Container for the context level. | confirmed |
