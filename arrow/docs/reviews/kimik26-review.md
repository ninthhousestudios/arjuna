# Arrow Code Review (Model: kimi-k2.6)

**Date:** 2026-04-21
**Scope:** Full repository (`arrow_workspace` Dart monorepo)
**Lines of Code:** ~6,100 total (~4,500 Dart source, ~1,600 test)
**Packages Reviewed:** `options`, `core`, `swe`, `calc`, `tool`

---

## 1. Executive Summary

Arrow is a well-architected Dart monorepo implementing a Vedic/Western astrology calculation engine. It demonstrates excellent **domain modeling**, strong **type safety** (heavy use of `freezed`, enums, sealed patterns), and clear **package boundaries**.

However, it suffers from a **severe lack of automated testing** for business logic, a few **complex god functions**, **dead archived code** left in the tree, and **missing root-level project documentation**. Several small but genuine **longitude arithmetic bugs** were identified in the core domain model.

**Overall Grade: B+** (strong design, fragile execution on edges)

---

## 2. Architecture & Monorepo Health

### 2.1 Package Structure

| Package | Role | Health |
|---------|------|--------|
| `options` | Configuration, enums, presets | Excellent — pure data, no side effects |
| `swe` | Swiss Ephemeris FFI facade | Good — clean abstraction over `swisseph` |
| `core` | Domain model (Chart, Graha, Longitude) | Good — dense logic, well-commented |
| `calc` | High-level calculations (avasthas, aspects) | Good — logically layered |
| `tool` | Fixture generation & CLI helpers | Fair — mixes I/O with parsing |

The dependency graph is sensible and acyclic:
```
options → core → calc
  ↓       ↓
  swe ←───┘
```

**Observation:** `calc/pubspec.yaml` declares a direct `arrow_swe` dependency, but no file in `calc/lib/` imports it. The transitive path through `arrow_core` is sufficient. Removing this reduces coupling.

### 2.2 Workspace Tooling

- Uses Dart 3 workspace resolution (`resolution: workspace`).
- **No `melos.yaml` found.** For a monorepo of this size, Melos (or similar) is recommended for unified testing, versioning, and local linking.
- **No CI/CD configuration** (`.github/workflows` absent). This is a major gap for a project that relies on golden fixture comparisons and native FFI bindings.

### 2.3 Documentation

- **Root `README.md` is missing.** There is no landing page for new contributors.
- **Root `AGENTS.md` is missing.**
- `docs/c4/README.md` contains excellent C4 architecture diagrams and a self-critical "Architecture review" table — this is best-in-class practice.
- `calc/test/fixtures/README.md` is thorough and explains how to regenerate golden fixtures from upstream Python (`libaditya`).
- Inline doc comments are consistently high quality across all packages.

### 2.4 Dead Code

The directory `claude/archived/` contains two files (`core-types.dart`, `varga-constants.dart`) that duplicate logic already present in `core/lib/src/`.

- **Risk:** These files are excluded from analyzer runs (`analyzer: exclude: - claude/**`), so they bitrot silently. They are pure liability.
- **Recommendation:** Delete `claude/archived/`. If history is needed, `git` already stores it.

---

## 3. Code Quality & Smells

### 3.1 God Functions (High Cyclomatic Complexity)

Qartez identified **2 god functions** (CC ≥ 15 and ≥ 50 lines):

#### `lookupDeity` — `core/lib/src/varga_deities.dart` (CC 25, 71 lines)
A massive `switch (amsha)` over 16 cases. Each case performs sign-parity checks and table lookups.

**Recommendation:** Extract a `DeityTable` class (or a `Map<int, List<VargaDeity>>` with an optional reversal predicate). The switch could collapse to a lookup into a config-driven table, shrinking the function to ~15 lines and making it data-driven.

#### `calcAll` — `swe/lib/src/swe_facade.dart` (CC 23, 147 lines)
Configures SWE flags, then iterates bodies computing ecliptic, equatorial, pheno, barycentric, and heliocentric positions. Handles Ketu derivation, house cusps, ayanamsa, and sunrise/sunset.

**Recommendation:** Extract private helpers:
- `_configureFlags(...)`
- `_computeBody(...)`
- `_deriveKetu(...)`
- `_computeHouses(...)`
This also makes unit testing the individual phases possible.

### 3.2 Clone Groups (Duplicate Code)

Qartez found **14 clone groups** (30 duplicate symbols). Notable ones:

| Group | Location | Issue |
|-------|----------|-------|
| #4 | `swe/lib/src/json_converters.dart` | `BodyMapConverter` and `BodyPhenoMapConverter` are identical except for the generic type parameter. They should be a single `EnumMapConverter<E>` or a factory mixin. |
| #5 | `core/lib/src/celestial_body.dart` | `barycentricRashiLongitude` and `heliocentricRashiLongitude` are identical except for the source map (`bodiesEclipticBarycentric` vs `bodiesEclipticHeliocentric`). Extract a private `_rashiLongitude(Map<Body, BodyPosition>?)` helper. |
| #2, #3, #13 | `core/lib/src/varga_deities.dart` | Multiple deity table declarations (`_d4`, `_d12`, `_d16`, `_d20Even`, `_d20Odd`, `_d24`, `_d40`) are structurally identical 4–20 line lists. A macro or code-generator would be safer, or at least a `const _table([...])` helper. |
| #7, #11 | `pubspec.yaml` files | `dev_dependencies` blocks are copy-pasted across packages. This is normal for Dart workspaces but could be tightened with workspace-level dev deps if Melos is adopted. |
| #8 | `claude/archived/varga-constants.dart` vs `core/lib/src/varga_deities.dart` | Confirms the archived file is a stale duplicate. |

### 3.3 Unused Exports

**295 unused exports** were detected. Many are public API symbols (e.g., `Aspect`, `Baladi`, `Deeptadi`) that are likely intended for external consumers. However, some may genuinely be dead code.

**Recommendation:** Perform a manual audit of the top 50 unused exports. For symbols that are strictly internal, remove the `public` modifier or prefix them with `_`. For symbols intended to be public, document them in package-level `README.md` files so consumers know they exist.

---

## 4. Testing

### 4.1 Coverage Gap

**75 of 83 source files are untested** (90% untested).

The few files with tests are mostly **value-object / enum smoke tests**:
- `options/test/configs_test.dart` — JSON round-trips and default values.
- `options/test/enums_test.dart` — `Body.sweId` values, `Ayanamsa` codes.
- `swe/test/swe_facade_test.dart` — **Only** tests `BodyPosition`, `AscMcPoints`, `SunTimes`, and `EphSnapshot` construction + JSON round-trip. It does **not** test the actual `SweFacade.calcAll` method, which is the most critical and complex function in the package.

### 4.2 Missing Integration Tests

There are three integration tests in `swe/test/`, but `qartez_test_gaps` still flags `swe_facade.dart` as a high-risk untested file. This suggests the integration tests may not be wired to run in the standard `dart test` suite, or they test adjacent files rather than the facade itself.

### 4.3 Business Logic Untested

The following high-risk files have **zero tests**:
- `core/lib/src/longitude.dart` — Varga mathematics (D2, D3, D9, D60, etc.)
- `core/lib/src/dignity.dart` — Exaltation / debilitation / moolatrikona logic
- `calc/lib/src/vedic/aspect.dart` — Parashara aspect strength formulas
- `calc/lib/src/vedic/lajjitaadi.dart` — Complex relational state machine (~450 lines)
- `calc/lib/src/vedic/deeptadi.dart` — Cascading priority avastha logic

**Impact:** A single typo in the `Aspect._baseStrength` piecewise function or the `Longitude._hora` logic would silently corrupt chart interpretations. These are the exact files that should have **property-based or golden-fixture tests** (the project already maintains a `libaditya-golden/` directory for this purpose, but the tests appear not to exercise them yet).

---

## 5. Bugs & Logic Issues

### 5.1 `Longitude.degreesApart` — Negative Distance Bug

```dart
// core/lib/src/longitude.dart:93
double degreesApart(double other) => ((other - eclipticLongitude) % 360);
```

**Issue:** In Dart, the `%` operator on doubles preserves the sign of the dividend. If `other < eclipticLongitude`, the result is negative (e.g., `(10 - 350) % 360 == -340`).

**Fix:** Normalize to `[0, 360)`:
```dart
double degreesApart(double other) {
  var d = (other - eclipticLongitude) % 360;
  if (d < 0) d += 360;
  return d;
}
```

(Note: `Aspect._degreesApart` in `calc` already does this correctly. The core version does not.)

### 5.2 `Longitude.signsApart` — Negative Distance Bug

```dart
// core/lib/src/longitude.dart:96
int signsApart(int otherSign) => ((otherSign - sign) % 12);
```

**Issue:** Same Dart `%` semantics. `(1 - 5) % 12 == -4`.

**Fix:**
```dart
int signsApart(int otherSign) {
  var d = (otherSign - sign) % 12;
  if (d < 0) d += 12;
  return d;
}
```

### 5.3 `ChtkFormat._parseDms` — Silent Failure on Bad Input

```dart
// tool/lib/src/chtk.dart:72-83
static double _parseDms(String s) {
  ...
  if (match == null) return 0.0;
  ...
}
```

**Issue:** Returns `0.0` when the regex fails. A malformed DMS string (e.g., missing seconds) silently produces a coordinate of `0.0`, which is a real longitude/latitude (prime meridian / equator). This is a data-corruption risk during fixture generation.

**Fix:** Throw a `FormatException` with the offending input.

### 5.4 `SweFacade.calcAll` — No Per-Body Error Recovery

The loop over `sweConfig.bodies` calls `_swe.calcUt()` for each body without any `try/catch`. If the Swiss Ephemeris FFI throws for a single body (corrupted `.se1` file, unsupported body ID, out-of-range date), the entire `calcAll()` call aborts and returns nothing.

**Fix:** Consider wrapping each body computation in a `try/catch` that logs the failure and skips the body, allowing partial snapshots to be returned (or changing the return type to include an error map).

---

## 6. Security & Dependencies

### 6.1 Dependency Scan

Qartez flagged **4 "path-traversal" findings** in `pubspec.yaml` files. These are false positives — they are local path dependencies (`path: ../options`) inside a workspace monorepo. No action needed.

### 6.2 External FFI Risk

`arrow_swe` depends on `swisseph: ^0.4.4`, which uses `dart:ffi` to bind to the C Swiss Ephemeris library. This means:
- **No Web / WASM support.** The architecture review in `docs/c4/README.md` already notes this (Issue #1: "Web/WASM targets cannot use dart:ffi").
- **Platform-specific `.se1` data files** must be present at runtime. The `ephePath` parameter is required for precision, but there is no runtime validation that the directory exists or contains the needed files until SWE silently falls back to Moshier.

---

## 7. Performance Observations

### 7.1 `calcAll` Batch Size

For a typical chart request (9 bodies + 12 cusps + sun times), `calcAll` performs:
- ~18 `_swe.calcUt()` calls (ecliptic + equatorial)
- Up to 9 additional `_swe.calcUt()` calls for barycentric frames
- Up to 8 additional calls for heliocentric frames
- 1 `_swe.housesEx()` call
- 1 `_swe.pheno_ut()` per body (via `_safePheno`)

This is roughly **30–40 native FFI round-trips per chart**. For a server computing thousands of charts per second, this will be a bottleneck. There is no batch API in SWE, so the only optimization is caching `EphSnapshot` objects (which the `Chart` class already does via `_vargaCache`). Documenting this cost in the API docs is recommended.

### 7.2 `Lajjitaadi.compute` — O(n²) but Bounded

The algorithm scans 7 karakas against 9 grahas with nested loops. At N=9, this is trivial (~63 iterations). The complexity is not a practical concern.

---

## 8. Positive Highlights

1. **Excellent C4 Architecture Documentation.** The self-maintained architecture review table with severity ratings is a model for other projects.
2. **Strong Domain Modeling.** The `Longitude` class encapsulating varga-aware sign/nakshatra/pada logic is elegant and avoids primitive obsession.
3. **Type Safety.** Extensive use of `freezed` for immutable data classes, `@freezed` unions for configs, and enums with typed payload fields.
4. **Clear Porting Annotations.** Comments like "ported from `libaditya/calc/avasthas.py:252-309`" make auditability and cross-reference verification straightforward.
5. **Fixture-Driven Testing Strategy.** The `calc/test/fixtures/` directory and the `gen-libaditya-fixtures.py` script show intent toward golden-master testing, even if the Dart tests are not yet wired to consume them.
6. **Fail-Fast Guards.** `calcAll` explicitly throws if barycentric is requested with Moshier, preventing subtle silent precision loss.

---

## 9. Actionable Recommendations (Prioritized)

| Priority | Task | File(s) |
|----------|------|---------|
| **P0** | Fix `Longitude.degreesApart` and `signsApart` negative-modulo bugs | `core/lib/src/longitude.dart` |
| **P0** | Add tests for `Longitude` varga computations (D2–D60) | `core/test/` |
| **P1** | Wire golden fixtures to `calc` tests (Lajjitaadi, Deeptadi, Baladi, Jagradadi) | `calc/test/` |
| **P1** | Extract `calcAll` into smaller private methods and add unit tests for each phase | `swe/lib/src/swe_facade.dart` |
| **P1** | Remove dead `claude/archived/` directory | `claude/archived/*` |
| **P1** | Add `try/catch` per-body in `calcAll` or document the all-or-nothing contract | `swe/lib/src/swe_facade.dart` |
| **P2** | Generic `EnumMapConverter` to deduplicate `BodyMapConverter` / `BodyPhenoMapConverter` | `swe/lib/src/json_converters.dart` |
| **P2** | Extract `_rashiLongitude` helper in `CelestialBody` to deduplicate barycentric/heliocentric getters | `core/lib/src/celestial_body.dart` |
| **P2** | Add a root `README.md` and `AGENTS.md` | `/` |
| **P2** | Set up GitHub Actions CI for `dart analyze` + `dart test` across all packages | `.github/workflows/` |
| **P3** | Consider Melos or a `Makefile` for cross-package commands | `/` |
| **P3** | Refactor `lookupDeity` into a data-driven lookup table | `core/lib/src/varga_deities.dart` |

---

*End of review.*
