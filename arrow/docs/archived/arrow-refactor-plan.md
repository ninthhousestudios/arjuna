# Arrow Refactor — Implementation Plan

Companion to `docs/arrow-refactor.md` (the diagnosis). This is the
sequencing and per-step plan to implement those candidates.

Branch: `drona`. Each numbered step is one commit boundary unless noted.

## Status

- [x] **A1** — Move `nakAyanamsa` from `CalcConfig` to `SweConfig` (`931ce1b`)
- [x] **A2** — Wire `nakAyanamsa` through to `Longitude.nakshatra`/`pada` (`a009d22`)
- [ ] **A3** — Move `includeStarData` out of `SweConfig`
- [ ] **A4** — Seal SWE wire-format leaks (`Body.sweId`, `Star.sweName`, barrel exports)
- [ ] **C** — Flatten body hierarchy (`Graha`, `Sun`)
- [ ] **D** — Extract varga math from `Longitude`
- [x] **B.1** — Strip CalcConfig from EphSnapshot (`00f006d`)
- [x] **B.2** — Introduce StarPosition, collapse 6 star maps to 2 (`fa3fcd1`)
- [ ] **B.3** — Collapse/optimize JSON converters (deferred)

Waves C and D are independent of A and B. Wave B is the riskiest and is
deferred for an explicit decision after A/C/D land.

---

## Wave A3 — `includeStarData` out of `SweConfig`

**Why:** `includeStarData` is a runtime cost flag, not part of the
configuration that defines a snapshot's content shape. Charts with the
same `SweConfig` should be cache-equivalent regardless of whether you
asked for star magnitudes this run.

**Steps:**

1. Add an optional `bool includeStarData = false` parameter to
   `SweFacade.calcAll(jdUt, location, options, {includeStarData: false})`.
2. In `swe_facade.dart`, replace `if (sweConfig.includeStarData)` with the
   parameter value.
3. Remove `includeStarData` from `SweConfig` (`options/lib/src/swe_config.dart`).
4. Regenerate freezed for `options/`.
5. Update doc-comment on `StarData` (`swe/lib/src/star_data.dart:8`) and
   `FixedStar.starData` (`core/lib/src/fixed_star.dart:24`) — they
   currently reference `SweConfig.includeStarData`.
6. Update tests in `swe/test/swe_facade_star_test.dart` — three tests
   currently set `includeStarData` via `SweConfig`; switch them to the
   `calcAll` parameter.
7. Search for any external caller (`drishti/`, `aion/`, etc.) that builds
   `SweConfig(includeStarData: true)` and migrate.

**Verification:** all 4 packages' tests pass.

---

## Wave A4 — Seal the SWE boundary

**Why:** `Body.sweId` and `Star.sweName` are SWE-library wire-format
details leaking into options-layer enums. The barrel re-exports
`SwissEph` and `dhruvaGcEquatorial`, letting any consumer bypass the
facade. Concentrate SWE knowledge in `swe/`.

### A4.1 — Body → sweId

**Files:** `options/lib/src/body.dart`, new `swe/lib/src/body_swe_id.dart`,
`swe/lib/src/swe_facade.dart`.

1. Create `swe/lib/src/body_swe_id.dart` with a private const map:
   ```dart
   const Map<Body, int> _bodySweIds = { Body.sun: 0, Body.moon: 1, ... };
   int sweIdFor(Body body) => _bodySweIds[body]!;
   ```
2. Replace `body.sweId` with `sweIdFor(body)` everywhere in `swe/`. Right
   now the only call site is `SweFacade.calcAll`.
3. Remove the `sweId` field and constructor param from `Body`. Strip the
   `// SWE TRUE_NODE` and `// Computed from Rahu` comments — they're SWE
   implementation notes.
4. Verify nothing outside `swe/` references `body.sweId` (grep before
   removing; expect zero hits).

### A4.2 — Star → sweName

**Files:** `options/lib/src/star.dart`, new `swe/lib/src/star_swe_name.dart`,
`swe/lib/src/swe_facade.dart`.

Same shape as A4.1. Move the `sweName` mapping (53 stars) to a private
const map in `swe/`. `SweFacade.calcAll` uses it for `fixstar2Ut`. Remove
the `sweName` field from `Star`.

The `customStarNames` set on `SweConfig` stays as raw strings — those
*are* SWE nomen lookups, that's their purpose, not domain identifiers.

### A4.3 — Barrel hygiene

**Files:** `swe/lib/arrow_swe.dart`.

1. Stop re-exporting `package:swisseph/swisseph.dart` (`SwissEph` and
   friends).
2. Stop re-exporting `dhruva.dart` (`dhruvaGcEquatorial`). It's an
   internal helper consumed by `SweFacade.calcDhruvaLongitude`.
3. Audit downstream packages (`core/`, `calc/`, `tool/`, `drishti/`,
   `aion/`) for direct `SwissEph` or `dhruvaGcEquatorial` use. Route
   through `SweFacade` methods. Add facade methods if a use case
   genuinely needs them.

**Commit boundary:** one commit per A4.1, A4.2, A4.3. They build on each
other but each leaves the tree green.

**Verification:** all tests pass; `grep -r "SwissEph\|dhruvaGcEquatorial"`
outside `swe/` returns no hits.

---

## Wave C — Flatten the body hierarchy

**Why:** `Graha` is an 11-line discriminator class with no behavior.
`Sun` is never constructed in the main path. The three-way hierarchy
(Planet → Graha → Karaka) forces `Varga._initMaps` to maintain three
parallel maps for what is really one concept (a body in a chart).

**Files:** `core/lib/src/graha.dart`, `core/lib/src/sun.dart`,
`core/lib/src/karaka.dart`, `core/lib/src/planet.dart`,
`core/lib/src/varga.dart`.

### C.1 — Karaka extends Planet

1. Read `karaka.dart` and `graha.dart`. Confirm `Karaka extends Graha
   extends Planet` and that `Graha` only adds a `toString()`.
2. Change `class Karaka extends Graha` to `class Karaka extends Planet`.
3. Remove `import 'graha.dart'` from `karaka.dart`.
4. Delete `core/lib/src/graha.dart`. Remove from the `core/lib/arrow_core.dart`
   barrel if exported.
5. Audit downstream for `Graha` references. Migrate:
   - `Varga.grahas()` returns `List<Graha>` → returns `List<Planet>` (or
     a renamed `bodies()`).
   - Tests calling `varga.grahas()`.

### C.2 — Rahu/Ketu as Planet

In `Varga._initMaps`, the current code likely does
`map[Body.rahu] = Graha(...)`. Change to `Planet(...)`. Rahu/Ketu lose
the type-level distinction from karakas, but the runtime distinction
(no pheno, no synodic) is enforced by `Planet.synodicState`/`pheno`
returning null for the nodes — that already works.

### C.3 — Fold Sun

If `Sun` is genuinely unused on the main path (per the doc), delete
`core/lib/src/sun.dart` and remove it from the barrel. If a couple of
tests import it, port them or delete them.

If `Sun` carries behavior (e.g., a special elongation calc), move that
to a guarded method on `Karaka` or a free function in a `sun_helpers.dart`.

### C.4 — Drop a map from Varga

`Varga._initMaps` builds three parallel maps (planets, grahas, karakas).
After C.1+C.2, you only need two: a karaka map (for the 7 + dignity) and
a planet map (for all 9 grahas + ascendant or whatever else is included).
Or one map keyed by `Body` if karakas can be derived by filtering.

Pick the simpler structure. Update `Varga.planet()`, `Varga.karaka()`,
`Varga.grahas()` accessors.

### C.5 — Dignity/synodic read through domain objects

`Karaka.dignity` (per the doc) reaches into `snapshot.bodiesEcliptic`
directly to look up the sign lord's longitude. After the flatten, the
sign lord *is* a `Planet` already constructed in the same `Varga`.
Look it up via `varga.planet(signLord)` instead.

Same for any place `Planet.synodicState` reaches into the raw snapshot.

**Commit boundary:** C.1 (most invasive), then C.2/C.3 in one commit if
small, then C.4/C.5 in one commit. ~3 commits total.

**Verification:** all 284 core tests + downstream tests pass.

---

## Wave D — Extract varga math from `Longitude`

**Why:** `core/lib/src/longitude.dart` is 681 lines with 14 private
varga methods carrying ~400 of those lines. They're pure math. Pulling
them out drops `Longitude` to ~250 lines and gives the varga math its
own test surface.

**Files:** `core/lib/src/longitude.dart`, new `core/lib/src/varga_math.dart`,
new `core/test/varga_math_test.dart`.

### D.1 — Extract pure functions

Create `core/lib/src/varga_math.dart`. For each of these 14 methods,
move the body to a top-level function with explicit parameters:

| Method | New signature |
|---|---|
| `_parivritti(lon, amsha)` | `parivritti(double lon, int amsha, int adityaOffset) → VargaResult` |
| `_parivrittiDeity(amsha, whichAmsha, realSign)` | private helper of `parivritti` |
| `_hora(lon)` | `hora(double lon, int adityaOffset)` |
| `_drekkana(lon)` | `drekkana(double lon, int adityaOffset)` |
| `_chaturthamsha(lon)` | etc. |
| `_dashamsha(lon, {evenReversed})` | |
| `_dvadashamsha(lon)` | |
| `_shodashamsha(lon)` | |
| `_vimshamsha(lon)` | |
| `_siddhamsha(lon, {parashara})` | |
| `_bhamsha(lon)` | |
| `_khavedamsha(lon)` | |
| `_akshavedamsha(lon)` | |
| `_saptamsha(lon)` | |
| `_trimsamsha(lon)` | |
| `_shashtyamsha(lon)` | |

Each function takes raw inputs and returns `VargaResult`. They depend
on three things from `Longitude`: `lon` (passed in), `_adityaOffset()`
(passed as `int`), and `_baseLon()` / `_eclipticSignNum()` /
`_eclipticInSign()` (small helpers — duplicate as private free
functions in `varga_math.dart` or pass in computed values).

The `VargaDeity` lookups stay nearby — either inline them in the
functions that use them, or extract to `varga_math.dart` privates.

### D.2 — Longitude delegates

Replace each `Longitude._parivritti(lon, amsha)` body with
`return parivritti(lon, amsha, _adityaOffset());`. Same for the other 13.

The `_computeVarga` switch dispatcher stays in `Longitude`, since it
keys off `vargaType` which lives on `Longitude`.

After this, `Longitude` should be ~250 lines: constructor, public
getters (`sign`, `nakshatra`, `pada`, etc.), the `_computeVarga`
dispatcher, and the small geometric helpers (`degreesApart`,
`signsApart`, `isBetween`, `inSignLongitude`).

### D.3 — Test surface

Create `core/test/varga_math_test.dart`. For each varga function, a
small group of tests with input/output pairs. The existing varga tests
in the broader test suite still pass through the `Longitude` interface
and serve as integration coverage.

Don't replicate every existing test — focus on edge cases that were
previously hard to reach: signs at boundaries, sign-1 vs sign-12 wrap,
parivritti with various amsha counts, hora odd vs even sign behavior.

**Commit boundary:** one commit. The change is mechanical — extract,
delegate, test. Do not refactor the math while moving it.

**Verification:** all tests pass. `Longitude` line count drops by ~400.

---

## Wave B — Reshape `EphSnapshot` (paused)

This wave is the broadest and the riskiest. It's paused intentionally —
decide direction before starting.

### Open questions to settle first

1. **CalcConfig on the snapshot — keep or remove?** The doc argues
   remove. But after Wave A, `CalcConfig` is much smaller (no
   `nakAyanamsa`). Is the cost of removing it (audit every consumer
   that reads `snapshot.options.calcConfig`) worth the gain?
2. **`StarSnapshot` shape.** Does it unify by enum/string, or also by
   ecliptic/equatorial? Six maps → one map of `StarPosition` records?
   Or two maps (enum/string) of `StarPosition`?
3. **Custom JSON converters — replace with what?** `freezed`'s default
   serialization for nested `Map<Star, StarPosition>` may need a custom
   `@JsonKey(fromJson/toJson)` regardless. Need to prototype.
4. **API stability.** `EphSnapshot` is exposed via `arrow_swe`. External
   consumers (drishti, aion) read fields directly. The reshape probably
   breaks them. Plan migration or do it as a coordinated bump.

### Sketch (not commitments)

**B.1 — Strip CalcConfig from snapshot.** Replace
`options: ArrowOptions` field with `sweConfig: SweConfig`. Audit every
`snapshot.options.calcConfig` and `snapshot.options.sweConfig` reference,
migrate. `Chart` becomes the carrier of `CalcConfig`.

**B.2 — Introduce StarPosition / StarSnapshot.** A record/freezed class
holding ecliptic + equatorial + optional `StarData`. `EphSnapshot` keeps
two maps: `Map<Star, StarPosition>` and `Map<String, StarPosition>`. Six
maps collapse to two.

**B.3 — Collapse JSON converters.** With unified types, the five custom
converters in `swe/lib/src/json_converters.dart` should reduce to one or
two. Verify round-trip tests still pass.

### Risk gates

- Run drishti/aion/skybreath integration tests (or smoke them
  manually) before merging.
- Bump `arrow_swe` version.
- Update `docs/api-reference.md`.

---

## Out of scope

Not part of this plan:

- Calc layer review (the doc's "Exploration gaps" section). Deferred
  until calc work surfaces a concrete need.
- Performance tuning. Refactor preserves behavior; perf is separate.
- Drishti/Aion downstream changes beyond what's required to keep the
  build green after each wave.
