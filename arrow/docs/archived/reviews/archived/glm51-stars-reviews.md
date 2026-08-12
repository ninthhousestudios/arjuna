# Code Review: Fixed Star Subsystem (Waves 1–5)

**Commits under review:**
- `d11bf966` — Add fixed star subsystem (Waves 1–3): Star enum, SWE wiring, domain model
- `18c8bfe8` — Add star data subsystem (Wave 4) and 13-constellation ecliptic (Wave 5)
- `81d04855` — Wire star rise/set in SweFacade, add buildEcliptic13 convenience function

**Reviewer:** GLM-5.1
**Date:** 2026-04-24
**Scope:** ~1,700 lines added across 22 files (16 + 22 + 6)

---

## Summary

Three commits that port fixed-star support from libaditya into arrow as a first-class feature. The work is organized into five waves that layer cleanly: (1) Star enum + SWE calculation, (2) custom star name escape hatch, (3) SkyObject/CelestialBody refactoring + FixedStar domain model, (4) StarData with magnitude/rise-set, (5) 13-constellation true-sidereal ecliptic. The overall architecture is sound, the layering is well-sequenced, and test coverage is good for an initial port. Below are findings grouped by severity.

---

## Critical Issues

### C1. `_computeBoundaries` rotation logic is fragile and under-tested

**File:** `arrow/calc/lib/src/zodiac/ecliptic13.dart:116–153`

The boundary rotation uses `removeLast()` + `insert(0, ...)` with a comment explaining that `boundaries[i]` is the boundary between constellation `i` and `i+1`, but the comment and the code are contradictory:

```dart
// boundaries[i] is the boundary between constellation i-1 and i,
// but we computed boundary between i and i+1. The boundary at index
// ordered.length-1 is between Pisces(last) and Aries(first) = Aries start.
final ariesBoundary = boundaries.removeLast();
boundaries.insert(0, ariesBoundary);
```

The loop computes `midpoint = (lastLon_of_i + gap/2) % 360` where the gap is between `lastStar_of_i` and `firstStar_of_(i+1)`. This midpoint sits *between* constellation `i` and constellation `i+1`. So `boundaries[i]` is the boundary *after* constellation `i` — i.e., `boundaries[i]` is the *end* of constellation `i`, which is the same as the *beginning* of constellation `i+1`. The rotation moves the Pisces→Aries boundary to position 0, making it the *beginning* of Aries. After rotation, `boundaries[i]` becomes the beginning of constellation `i`.

The comment says "boundaries[i] is the boundary between constellation i-1 and i" — which is true *after* rotation — but then says "we computed boundary between i and i+1" — which describes the *pre-rotation* state. The two sentences describe different states of the same array. This is confusing rather than wrong, but the lack of a direct invariant test (e.g., "Aries begins near 0° sidereal") makes the rotation hard to verify without reading the algorithm very carefully.

**Risk:** If `ConstellationId.values` ever changes order (unlikely since it's an enum, but still), the rotation silently produces wrong boundaries. The integration test at J2000 checks that Aldebaran falls in Taurus, which is a good sanity check, but doesn't directly validate the rotation.

**Recommendation:**
1. Add a unit test that verifies `boundaries[0]` (Aries beginning) is near the expected sidereal longitude (~0° under Lahiri, or whatever the reference is).
2. Rewrite the comment to be clearer about pre/post-rotation semantics.
3. Consider computing boundaries directly in "beginning-of-constellation" order instead of needing a post-hoc rotation.

### C2. `constellationAt` fallback returns first constellation silently

**File:** `arrow/calc/lib/src/zodiac/ecliptic13.dart:84–90`

```dart
Constellation constellationAt(double longitude) {
  final lon = longitude % 360;
  for (final c in _constellations.values) {
    if (c.contains(lon)) return c;
  }
  return _constellations.values.first;
}
```

If no constellation claims the longitude (which shouldn't happen if boundaries cover 360°, but could happen with floating-point edge cases at exact boundary points where `contains` uses `>=` on one side and `<` on the other), this falls back to Aries. A silent fallback to Aries is the worst possible default — it will produce plausible-looking wrong results. The `contains` method uses half-open intervals (`>= beginning && < end`) which means the exact endpoint `end` is not contained, and it falls to the next constellation. This is correct when boundaries are properly contiguous, but a NaN or degenerate boundary would silently place everything in Aries.

**Recommendation:** Replace the silent fallback with an assertion or `StateError`:

```dart
throw StateError('No constellation contains longitude $lon — boundary coverage gap?');
```

This makes boundary bugs immediately visible instead of silently corrupting downstream data.

---

## Major Issues

### M1. StarMapConverter / StarDataMapConverter use `firstWhere` without `orElse`

**File:** `arrow/swe/lib/src/json_converters.dart:36, 77`

```dart
Star.values.firstWhere((s) => s.name == key)
```

`firstWhere` throws `StateError` when no match is found. This is acceptable if JSON is only produced by the same code, but if a serialized snapshot was produced when the `Star` enum had entries that were later renamed/removed, deserialization will crash with an unhelpful error. The existing `BodyMapConverter` uses `Body.values.byName(key)` which also throws, so this is consistent — but it's still a latent fragility point for any serialized data that crosses Star enum versions.

**Recommendation:** At minimum, catch and wrap with a more helpful message:

```dart
Star.values.firstWhere(
  (s) => s.name == key,
  orElse: () => throw FormatException('Unknown Star enum value: $key'),
);
```

This pattern should be applied consistently to `BodyMapConverter` as well, but that's outside the scope of this review.

### M2. `_calcStarData` conflation of error categories: circumpolar vs. genuine failure

**File:** `arrow/swe/lib/src/swe_facade.dart:336–366`

```dart
try {
  final r = _swe.riseTrans(...);
  riseJd = r.transitTime;
} catch (e) {
  _log.fine('star rise failed for $sweName: $e');
  circumpolar = true;
}
```

Any exception from `riseTrans` — whether it's a circumpolar star, a bad star name, a missing ephemeris file, or an internal SWE error — sets `circumpolar = true`. This is incorrect: a star that simply doesn't rise at the observer's latitude is circumpolar, but a star whose name SWE can't find is an input error, not a geographic condition. The `circumpolar` flag and the `riseJd == null` condition then convey ambiguous information to downstream consumers.

**Recommendation:** Distinguish at least two failure categories:
- `circumpolar`: set only when SWE returns the specific error code for circumpolar stars (SWE returns -1 for rise/set with the `SE_CALC_RISE`/`SE_CALC_SET` flag when the body never sets/rises).
- Input/ephemeris error: leave `riseJd` null but don't set `circumpolar`.

This may require inspecting the exception type or error code from the swisseph binding, which may not expose it cleanly. If the binding doesn't differentiate, add a `TODO` with the intent.

### M3. `boundaryStars` set may include duplicate stars silently

**File:** `arrow/calc/lib/src/zodiac/boundary_stars.dart`

```dart
final Set<Star> boundaryStars = constellationStarMap.values
    .expand((e) => [e.first, e.last])
    .toSet();
```

The `.toSet()` deduplicates, which is correct behavior, but the test `all boundary stars are distinct` in `constellation_test.dart` actually verifies this at the `constellationStarMap` level (checking that `all.length == unique.length`). However, that test is in the `calc` package while `boundaryStars` is also in `calc`. The concern is: if a boundary star appears in two constellations (as both `last` of one and `first` of the next), the set quietly drops it. The `Ecliptic13.build` code then iterates `sweConfig.stars` and the boundary map independently, so a star that's the boundary of two constellations only needs to be computed once — the set behavior is correct. But it means `boundaryStars.length` is not simply `13 * 2 = 26`. There could be fewer entries, and downstream code that assumes 26 would be surprised.

**Recommendation:** Add a test that `boundaryStars.length` equals the expected count (currently 26 — all are distinct, which the existing test confirms). This documents the invariant.

### M4. `Ecliptic13` depends on `arrow_swe` via `buildEcliptic13` — layering violation

**File:** `arrow/calc/lib/src/zodiac/ecliptic13.dart:3`

```dart
import 'package:arrow_swe/arrow_swe.dart';
```

The `arrow_calc` package now imports `arrow_swe` for the `buildEcliptic13` convenience function, which takes an `EphSnapshot` (defined in `arrow_swe`) and extracts star longitudes. Previously, `arrow_calc` only depended on `arrow_core` and `arrow_options`. This creates a new transitive dependency: `arrow_calc → arrow_swe → arrow_options`. The `Ecliptic13` class itself is cleanly independent (takes `Map<Star, double>`), but the top-level `buildEcliptic13` function drags `arrow_swe` in.

**Recommendation:** Move `buildEcliptic13` to a separate file (e.g., `arrow/calc/lib/src/zodiac/build_ecliptic13.dart`) and only export it conditionally, or move it to `arrow_swe/test/` as a test helper. Alternatively, accept the dependency but document it explicitly in `arrow_calc`'s pubspec as a new intentional dependency. The current state is that anyone who uses `arrow_calc` transitively pulls in the SWE native library, which may be undesirable for pure-calculation use cases.

### M5. `Constellation` is mutable — `addPlanet`/``addStar`` are public

**File:** `arrow/calc/lib/src/zodiac/constellation.dart:39–40`

```dart
void addPlanet(CelestialBody planet) => _planets.add(planet);
void addStar(FixedStar star) => _stars.add(star);
```

The `Constellation` class exposes `addPlanet`/`addStar` as public mutation methods, but the lists are returned as unmodifiable views. This means any external caller can add to a constellation's planet/star list after construction, which is likely not intended — only `Ecliptic13._placePlanet`/`_placeStar` should call these. The current design works because the only consumers are internal, but the API surface is wider than necessary.

**Recommendation:** Make `addPlanet`/`addStar` package-private (Dart doesn't have this, but the convention is to use `_` prefix and `@visibleForTesting` or simply document that they're internal). Alternatively, make `Constellation` immutable by having `Ecliptic13.build` pass in pre-binned lists.

---

## Minor Issues

### m1. `StarData` doc comment references non-existent field `SweConfig.includeStarRiseSet`

**File:** `arrow/swe/lib/src/star_data.dart:8`

```dart
/// Rise/set fields require [SweConfig.includeStarRiseSet] — they are null
/// when that flag is off (or when the star is circumpolar / never rises).
```

There is no `SweConfig.includeStarRiseSet` field. The actual gate is `SweConfig.includeStarData`, which controls both magnitude and rise/set computation. The doc comment is stale from when rise/set was planned as a separate flag.

**Recommendation:** Update to `SweConfig.includeStarData`.

### m2. `FixedStar.custom` uses raw SWE name as display name

**File:** `arrow/core/lib/src/fixed_star.dart:16`

```dart
/// Display name — [Star.label] for enum stars, the raw SWE name for custom.
final String name;
```

For custom stars like `,alfCMa`, the display name would be `,alfCMa` — a raw SWE nomenclature code, not a human-readable name. The `%` wildcard fallback in `SweFacade` means the key in the snapshot is the original input (e.g., `,alfCMa`), not the resolved star name.

**Recommendation:** Consider stripping the leading comma and uppercasing the first letter for display, or storing the SWE-resolved star name from `FixstarResult.starName` (which Swiss Ephemeris returns as the full traditional name).

### m3. Duplicate `find_ephe_path.dart` helper across test directories

**Files:**
- `arrow/core/test/helpers/find_ephe_path.dart`
- `arrow/swe/test/helpers/find_ephe_path.dart` (pre-existing)

The same helper is copied into two test directories. The hardcoded path `$home/nhs/soft/astrology/libaditya/libaditya/ephe` is developer-specific and will fail on other machines.

**Recommendation:** Extract to a shared test utility package (e.g., `arrow_test_helpers`) or at minimum, a symlink.

### m4. `sweName` uniqueness not enforced by the type system

**File:** `arrow/options/lib/src/star.dart`

The test `sweNames are unique` verifies uniqueness, but nothing prevents a future contributor from adding a duplicate `sweName` to the enum. A duplicate would cause `SweFacade` to compute the same star twice and silently overwrite one entry in the map.

**Recommendation:** Add an `assert` in the `Star` enum's constructor or a static initializer check. Or use a `const` `Set` to validate at compile time:

```dart
static const _sweNames = {for (final s in values) s.sweName: s};
```

(Not possible with enum constructors in Dart, but a runtime check in a static getter would work.)

### m5. `_fromFixstarResult` duplicates `_fromCalcResult`

**File:** `arrow/swe/lib/src/swe_facade.dart:268–275`

Both `FixstarResult` and `CalcResult` have the same field names (`longitude`, `latitude`, `distance`, `longitudeSpeed`, `latitudeSpeed`, `distanceSpeed`). The two conversion methods are identical except for the input type. If the swisseph package defined a shared interface or extension, this could be a single method.

**Recommendation:** Not blocking, but worth a `TODO` or a shared extension method to reduce duplication.

### m6. Custom star `%` fallback is applied to *all* custom star names, not just short-form ones

**File:** `arrow/swe/lib/src/swe_facade.dart:179–193`

The `%` wildcard fallback is applied when the exact match fails, but it's also applied to user-provided names like `Sirius`. If a user provides `Sirius` and the exact match fails (e.g., wrong case), the fallback `Sirius%` could match a different star (unlikely but possible). The libaditya precedent justifies this behavior, but it's worth documenting that it's intentional.

**Recommendation:** Add a doc comment on `SweConfig.customStarNames` explaining the `%` fallback behavior.

### m7. `Constellation.contains` uses strict `<` on upper bound, but `longitudeToConstellation` can produce `degreesInto == 0` at boundaries

**File:** `arrow/calc/lib/src/zodiac/ecliptic13.dart:97`

```dart
final degreesInto = ((longitude % 360) - c.beginning + 360) % 360;
```

At the exact boundary `longitude == c.beginning`, `degreesInto` is 0.0 and `percent` is 0.0%. This is mathematically correct but might surprise users who expect "being right at the start" to show some small positive offset. Not a bug, just a UX consideration.

### m8. `ZodiacSystem` enum is defined but not consumed

**File:** `arrow/options/lib/src/zodiac_system.dart`

The `ZodiacSystem` enum is added to `CalcConfig` with a default of `ZodiacSystem.sidereal12`, but no code in the reviewed commits reads it. The `Ecliptic13.build` factory doesn't check `CalcConfig.zodiacSystem` before running — it's purely opt-in via calling `buildEcliptic13` directly.

**Recommendation:** This is fine for a feature flag that gates future UI/selection logic. Add a `TODO` or doc comment noting that the enum is not yet consumed by calculation code.

---

## Positive Observations

1. **Clean wave decomposition.** The five waves layer cleanly: each builds on the previous without backtracking. The refactoring of `CelestialBody → SkyObject` in Wave 3 is well-executed and doesn't break existing functionality.

2. **Good test coverage.** The Star enum tests (uniqueness, nakshatra coverage, junction star count) are thorough. The SWE facade star tests cover both enum and custom stars with real ephemeris data. The Ecliptic13 integration test at J2000 with known star positions is a strong sanity check.

3. **Defensive error handling.** `SweFacade` catches exceptions from `fixstar2Ut` and logs warnings instead of propagating crashes. The `StateError` in `_computeBoundaries` for missing star longitudes is helpful.

4. **`zubenelgenubi` sweName fix.** The correction from `,alfLib` to `,alf02Lib` to match the expanded SIMBAD catalog is a good catch — it would have silently computed the wrong star position otherwise.

5. **`buildEcliptic13` as a standalone function.** Keeping the convenience builder off `Chart` is the right call — not every chart needs 13-constellation data, and the function is easy to compose.

6. **Boundary star latitude filter.** The 10° ecliptic latitude cutoff for star placement in `Ecliptic13.build` is a sensible approximation of "near the ecliptic plane" and matches libaditya.

---

## Architecture Notes

1. **`arrow_swe → arrow_options` dependency direction** is correct (SWE depends on options, not vice versa). The `Star` enum living in `arrow_options` is the right place — it's configuration surface, not calculation logic.

2. **`SkyObject` abstraction** is clean. Moving `rawLongitude`, `longitude`, `sign`, `nakshatra`, `pada` up to `SkyObject` so both `CelestialBody` and `FixedStar` share them is exactly the libaditya `CelestialObject` pattern, and it's done without over-abstracting.

3. **`EphSnapshot` growing with star fields** follows the existing pattern (body maps, pheno maps, etc.). The `@Default` annotations ensure backward compatibility with serialized snapshots that predate the star fields.

4. **swisseph version bumps** (`0.4.4 → 0.4.5 → 0.4.6`) are done in lockstep across `arrow/swe/pubspec.yaml` and `arrow/tool/pubspec.yaml`, which is correct for workspace resolution.

---

## Verdict

The code is well-structured and the port from libaditya is faithful. The two critical issues (C1: boundary rotation fragility, C2: silent Aries fallback) should be addressed before this code is relied upon for production astrology calculations — a silent wrong constellation assignment is worse than an explicit error. The major issues (M2: circumpolar conflation, M4: layering violation) are important but not blocking for initial use. The minor issues are quality-of-life improvements.
