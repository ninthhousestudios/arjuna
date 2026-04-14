# Arrow prep for Skybreath wiring

Two changes needed in Arrow before Skybreath's `wire-arrow-into-skybreath` plan starts. Both surfaced in the 2026-04-13 pre-mortem.

## 1. Add Chiron to the `Body` enum

**Where:** `arrow/options/lib/src/body.dart`

**Why:** Skybreath's `Planet` enum includes Chiron (`lib/models/planet.dart:chiron`), and an orb widget + artwork already ship. Arrow's `Body` enum currently stops at Ketu — every consumer that maps Skybreath's `Planet` → Arrow's `Body` would have to special-case or drop Chiron.

**What to change:**

- `Body` enum: add `chiron(sweId: 15)` (SWE constant `SE_CHIRON = 15`). Insert after `pluto` and before `rahu` so the 10-planet Western set stays contiguous.
- Decide whether to include Chiron in `Body.grahas`/`Body.karakas` — almost certainly **not**. Leave it off both. It's a body, not a graha or karaka.
- Callers to touch:
  - `arrow/swe/lib/src/swe_facade.dart` — `calcAll` iterates `options.sweConfig.bodies`; Chiron should come through the normal path. Confirm `_safePheno()` also works for Chiron (Swiss Ephemeris supports pheno on Chiron; should be fine).
  - `arrow/core/lib/src/nature.dart` — `Nature.of(Body.chiron)` should return `Nature.neutral` (keep the 13-body default table consistent).
  - `arrow/core/lib/src/body_motion.dart` — add `meanDailyMotion[Body.chiron]` and `stationThreshold[Body.chiron]`. Chiron's mean ≈ 0.026°/day (50-year orbit). Threshold at 10% → ~0.0026°/day.
  - Presets: `westernTropical` already lists Uranus/Neptune/Pluto; add Chiron to a new `westernEvolutionary` preset later if desired — no change needed now.
- Tests: golden fixtures (libaditya) don't include Chiron — skip it in the assertions rather than regenerating fixtures. Or add a unit test asserting `Nature.of(Body.chiron) == Nature.neutral` and `Body.chiron.sweId == 15`.

**Scope:** ~1 hour. Pure additive change, no breaking surface.

## 2. Move motion/synodic state onto the domain model

**Where:** `arrow/core/lib/src/planet.dart` (and subclasses).

**Why:** Right now, `SpeedClass`, `Direction`, `ElongationCategory` live in `arrow/calc/lib/src/vedic/{motion,synodic}.dart`. Any consumer asking "is Mars retrograde, fast, and waxing?" has to import `arrow_calc`, call three free functions, and pass `body + speed + pheno` around. Skybreath's `BodyView` currently has to do this, and exposing those calc enums across the domain boundary is awkward (pre-mortem finding pm-20260413-003).

These three classifiers are **per-body state** derived purely from already-cached fields on `Planet`. They belong on the domain object — same shape as `isRetrograde` (already on `Planet`) and `pheno` (already on `Planet`).

**What to change:**

- Move the `Direction`, `SpeedClass`, `ElongationCategory`, `SynodicState` enum/class definitions from `arrow_calc/vedic/*` to `arrow_core/src/body_motion.dart` (or a new `arrow_core/src/motion_state.dart`). `arrow_calc` re-exports them for backward compat.
- On `Planet` (`arrow/core/lib/src/planet.dart`):
  ```dart
  Direction  get direction    => /* from position.speedLongitude + body threshold */;
  SpeedClass get speedClass   => /* from position.speedLongitude + mean motion */;
  SynodicState? get synodicState => pheno == null ? null : SynodicState.from(pheno!);
  // ElongationCategory is reachable via synodicState?.category
  ```
- `arrow_calc/vedic/motion.dart` and `arrow_calc/vedic/synodic.dart` shrink to thin wrappers (or go away entirely if nothing else uses them).
- Tests in `arrow_calc/test/vedic/motion_test.dart` + `synodic_test.dart` move to `arrow_core/test/` alongside the migrated code.

**Scope:** ~2-3 hours. Low risk — pure relocation, same logic, existing tests port over.

**Consumer impact:** Skybreath's `BodyView._from` simplifies from reaching into `arrow_calc` to reading `planet.direction`, `planet.speedClass`, `planet.synodicState?.category`. Still formats to strings at the widget boundary — the string boundary is a Skybreath choice, not an Arrow requirement.

---

Once both are in, remove this file or mark it done.
