# Arrow Refactoring Candidates

Architecture review conducted 2026-04-29 on branch `drona`. Findings organized as deepening opportunities — refactors that turn shallow modules into deep ones, improving testability and locality.

## 1. Seal the SWE boundary

**Files:** `options/lib/src/body.dart`, `options/lib/src/star.dart`, `swe/lib/src/dhruva.dart`, `swe/lib/src/swe_facade.dart`, `swe/lib/arrow_swe.dart`

**Problem:** SWE wire-format details leak in both directions across the options-swe seam. `Body.sweId` (raw integers like `0 = SE_SUN`, `11 = SE_TRUE_NODE`) and `Star.sweName` (comma-prefixed SWE lookup strings like `',betAri'`) live on options-layer enums, visible to core and calc. Going the other direction, the barrel re-exports `SwissEph` and `dhruvaGcEquatorial` (which takes raw `SwissEph` + `int planet`), so any downstream consumer can bypass `SweFacade`.

**Context:** Stars and ayanamsa were retroactively ported from a different library and didn't fully adopt Arrow's layering patterns.

**Solution direction:** Move `Body → sweId` and `Star → sweName` mappings to private const maps inside the swe layer. Stop exporting `SwissEph` and `dhruva.dart` from the barrel.

**Benefits:** All SWE wire-format knowledge concentrates in `swe/`. Options enums become pure domain identifiers.

## 2. Make EphSnapshot an honest seam

**Files:** `swe/lib/src/eph_snapshot.dart`, `options/lib/src/arrow_options_data.dart`, `swe/lib/src/json_converters.dart`

**Problem:** `EphSnapshot` carries full `ArrowOptions` including `CalcConfig`, which was never used to produce the snapshot's data. Stars are stored in six parallel maps (two coordinate systems x enum-keyed/string-keyed x position/rise-set data), each needing its own JSON converter. No unifying type — every consumer queries two maps per star lookup.

**Solution direction:** EphSnapshot carries only `SweConfig` + input params (`jdUt`, `location`). Introduce a `StarSnapshot` that unifies enum-keyed and string-keyed lookups.

**Benefits:** Snapshot tells you exactly what produced it. Star consumers get one lookup path. Five custom JSON converters collapse.

## 3. Fix the config contract

**Files:** `options/lib/src/swe_config.dart`, `options/lib/src/calc_config.dart`

**Problem:** The stated contract — "SweConfig changes require recalculation; CalcConfig changes are free" — is violated both ways. `nakAyanamsa` on `CalcConfig` triggers SWE ayanamsa calls downstream. `includeStarData` on `SweConfig` is a cost toggle that doesn't change any planet longitude.

**Context:** `nakAyanamsa` ended up on `CalcConfig` because it was ported from a library that didn't have this two-config split.

**Solution direction:** Move `nakAyanamsa` to `SweConfig`. Move `includeStarData` out of `SweConfig` (runtime flag). Make the contract enforceable.

**Benefits:** Caching decisions become reliable — unchanged `SweConfig` means reusable snapshot.

## 4. Flatten the hollow middle of the body hierarchy

**Files:** `core/lib/src/graha.dart`, `core/lib/src/sun.dart`, `core/lib/src/karaka.dart`, `core/lib/src/planet.dart`, `core/lib/src/varga.dart`

**Problem:** `Graha` (11 lines) adds only a `toString()` — zero behavior. Exists solely as a type discriminant for Rahu/Ketu. `Sun` is never constructed in the main chart-building path (`Varga._initMaps` builds `Karaka(Body.sun)`, not `Sun`). The inheritance forces a three-map tax in Varga. `Karaka.dignity` and `Planet.synodicState` reach back into raw snapshot instead of through constructed domain objects.

**Deletion test:** Removing `Graha` and making `Karaka` extend `Planet` directly loses compile-time Rahu/Ketu type safety but the runtime logic is identical. The distinction was never enforced at runtime anyway.

**Solution direction:** `Karaka` extends `Planet` directly. Rahu/Ketu are `Planet` instances. `Sun` folds into utility or guarded method. Varga drops from three maps to two.

**Benefits:** Two fewer types. Simpler Varga construction. Dignity/synodic computations read from one path.

## 5. Extract varga computation from Longitude

**Files:** `core/lib/src/longitude.dart` (682 lines)

**Problem:** Longitude is the deepest module in the codebase — 14 varga methods (~400 lines), sign/nakshatra/pada lookups, angular distance helpers. It earns its depth, but at 682 lines it's hard to navigate. Aditya circle offset logic is woven into every varga method.

**Solution direction:** Extract varga methods to a private module of pure functions. Longitude delegates to it. Public interface unchanged.

**Benefits:** Longitude drops to ~250 lines. Varga math gets its own test surface. Aditya circle handling isolated.

## 6. Fix the silent nakshatra ayanamsa gap

**Files:** `core/lib/src/longitude.dart:77`, `core/test/helpers/stub_snapshot.dart`

**Problem:** `Longitude.nakshatra` and `Longitude.pada` ignore the sidereal ayanamsa offset. Line 77 has a TODO comment; the offset is never applied. All nakshatra computations are tropical. For any real Vedic chart, this silently produces wrong results. Test stub uses `ayanamsaValue: 0.0`, masking the gap.

**Context:** Same retroactive porting origin as candidates 1 and 3 — the ayanamsa wiring wasn't completed.

**Solution direction:** Wire `nakAyanamsa` through from config to Longitude. Update test stub to use non-zero ayanamsa.

**Benefits:** Correctness — nakshatra subsystem stops producing silently wrong results for sidereal charts.

## Priorities and dependencies

Candidates 1, 3, and 6 share a root cause (incomplete porting from the external library) and are likely best tackled together.

Candidate 2 (EphSnapshot reshaping) is the highest-impact change but also the broadest — it touches the central seam.

Candidates 4 and 5 are independent of the others and can be done anytime.

## Exploration gaps

The calc layer was only partially explored (2 of ~20 files read). The two files examined (`aspect.dart`, `rashi_aspect.dart`) showed good depth and consistent interface patterns (static methods on sealed classes). Panchanga's 7-file split is a yellow flag for shallowness but was not confirmed. A deeper calc-layer review should happen before planning work there.
