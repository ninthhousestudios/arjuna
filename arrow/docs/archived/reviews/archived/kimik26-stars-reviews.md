# Code Review: Fixed Star & 13-Constellation Ecliptic Subsystem

**Commits reviewed:**
- `d11bf966` — Add fixed star subsystem (Waves 1-3): Star enum, SWE wiring, domain model
- `18c8bfe8` — Add star data subsystem (Wave 4) and 13-constellation ecliptic (Wave 5)
- `81d04855` — Wire star rise/set in SweFacade, add buildEcliptic13 convenience function

**Author:** josh (with Claude Opus 4.6)
**Date:** 2026-04-24
**Scope:** `arrow/` (Dart/Flutter astrology engine)

---

## Overall Assessment

A well-structured, incremental port of fixed-star and true-sidereal-13 functionality from libaditya into Arrow. The three commits follow a sensible wave pattern: (1) core enum + SWE wiring, (2) data layer + constellation model, (3) rise/set integration + convenience APIs. The architecture is clean, tests are comprehensive, and the domain model (SkyObject → CelestialBody / FixedStar) is an improvement over the prior flat design.

**Risk level: Medium-Low.** Most issues are documentation gaps, edge-case handling, and serialization fragility. No critical correctness bugs found, but two areas (circumpolar detection and JSON backward compatibility) need attention before this code is considered production-stable.

---

## Commit-by-Commit Review

### Commit `d11bf966` — Fixed Star Subsystem (Waves 1-3)

#### What Changed
- **`Star` enum** (`arrow/options/lib/src/star.dart`): 54 entries — 27 nakshatra junction stars (yogatara), 26 bright navigational stars, and Galactic Center. Each entry carries `sweName` (passed directly to SWE `fixstar2Ut`), `label`, `traditionalMag`, and optional `nakshatra` (1-27).
- **`SweConfig`**: Added `Set<Star> stars` and `Set<String> customStarNames` fields.
- **`EphSnapshot`**: Added `starsEcliptic`, `starsEquatorial`, `customStarsEcliptic`, `customStarsEquatorial` maps.
- **`SweFacade.calcAll()`**: Loop calling `fixstar2Ut` for enum stars; custom names with `%` wildcard fallback on failure.
- **`SkyObject`** (`arrow/core/lib/src/sky_object.dart`): New abstract base extracting sign/nakshatra/pada/varga logic formerly in `CelestialBody`.
- **`FixedStar`** (`arrow/core/lib/src/fixed_star.dart`): New domain wrapper extending `SkyObject`.
- **`CelestialBody`**: Refactored to extend `SkyObject`.
- **`Chart`**: Added `fixedStars` and `customFixedStars` maps, eagerly populated in constructor.
- **Tests**: `star_test.dart` (unit), `fixed_star_test.dart` (integration), `swe_facade_star_test.dart` (integration).

#### Design & Architecture

**Good:**
- The `SkyObject` abstraction is a genuine improvement. It eliminates duplicated longitude/sign/nakshatra logic and mirrors libaditya's `CelestialObject` pattern without over-engineering.
- Using `BodyPosition` for stars (despite the name) is pragmatic — stars have longitude, latitude, distance, and speed, so the shape fits. A future rename to `SkyPosition` could be considered but is not urgent.
- The `%` wildcard fallback for custom star names reproduces libaditya's retry behavior and is gated behind the escape-hatch `customStarNames` field.
- `Star.sweName` uniqueness is tested. The `junctionStars` getter and the "exactly one star per nakshatra" test prevent data-entry errors.

**Concerns:**
- **`FixedStar.vargaType` hardcodes `VargaType.rashi`**. Fixed stars conceptually do not have vargas (divisional charts). The `varga(VargaType)` method inherited from `SkyObject` will happily compute a navamsha or drekkana longitude for a star, which is astrologically meaningless. Consider overriding `varga()` to throw `UnsupportedError`, or at least document this limitation.
- **`Chart` constructor now does more work**. Eagerly building `FixedStar` objects for every requested star is fine for 50–100 stars, but if future use cases scale to thousands of stars (e.g., full Tycho-2 catalog), this will become a bottleneck. Document the O(N) constructor cost or consider lazy initialization.
- **No `@override` on `FixedStar.toString()`**. Minor style issue.

#### Correctness & Edge Cases

**Issue: `StarMapConverter` deserialization fragility.**
```dart
Star.values.firstWhere((s) => s.name == key)
```
If a `Star` enum value is ever renamed (e.g., `zubenelgenubi` → `zubenelgenubiAlpha`), serialized JSON from older snapshots will fail to deserialize with a confusing `No element` error. The `BodyMapConverter` uses `Body.values.byName(key)` which throws a descriptive `ArgumentError`. Consider adding an `orElse` to `firstWhere` that throws a descriptive error, or use a private `byName` helper.

**Issue: Custom star `%` fallback may double-log.**
In `SweFacade.calcAll()`, if `name` already ends with `%`, the code logs a warning on the first catch and again on the second. This is minor but noisy.

**Issue: `find_ephe_path.dart` hardcodes paths.**
The helper searches `$HOME/nhs/soft/astrology/libaditya/libaditya/ephe` — a machine-specific path. This is acceptable for a test helper but should be noted as a portability concern.

#### Testing
- `star_test.dart` validates enum invariants (unique names, nakshatra range, junction-star completeness). **Good.**
- `fixed_star_test.dart` is tagged `@Tags(['integration'])` and properly skips when ephemeris files are missing. **Good.**
- Missing: No test for `FixedStar` equality/hashing. Since `FixedStar` is not `@freezed`, it uses identity equality. If users expect two `FixedStar` instances for the same star to be equal, they may be surprised. Document or implement `==`/`hashCode`.
- Missing: No test for `Chart.customFixedStars` with actual custom stars in the `Chart` (only tests empty case).

---

### Commit `18c8bfe8` — Star Data (Wave 4) & 13-Constellation Ecliptic (Wave 5)

#### What Changed
- **`StarData`** (`arrow/swe/lib/src/star_data.dart`): `@freezed` class holding `apparentMagnitude`, `riseJd`, `setJd`, `circumpolar`. Gated behind `SweConfig.includeStarData`.
- **`FixedStar`**: Added `starData` field and `magnitude` getter (falls back to `Star.traditionalMag`).
- **`ConstellationId`** (`arrow/options/lib/src/constellation_id.dart`): 13 entries including `ophiuchus`.
- **`constellationStarMap`** (`arrow/calc/lib/src/zodiac/constellation_star_map.dart`): Maps each `ConstellationId` to its first and last boundary `Star`.
- **`Constellation`** (`arrow/calc/lib/src/zodiac/constellation.dart`): Domain object with `beginning`/`end` longitudes, `contains()`, and mutable `_planets` / `_stars` lists.
- **`Ecliptic13`** (`arrow/calc/lib/src/zodiac/ecliptic13.dart`): Factory computing midpoint boundaries from boundary-star positions, then binning planets/stars into constellations.
- **`boundaryStars`** (`arrow/calc/lib/src/zodiac/boundary_stars.dart`): Convenience `Set<Star>` derived from `constellationStarMap`.
- **`ZodiacSystem`** enum and `CalcConfig.zodiacSystem` field.
- **22 new boundary stars** added to `Star` enum.
- **zubenelgenubi `sweName` fix**: `,alfLib` → `,alf02Lib` to match expanded SIMBAD catalog.
- **swisseph bumped** to `^0.4.5`.

#### Design & Architecture

**Good:**
- `Ecliptic13.build()` cleanly separates boundary computation from object placement. The `starLongitudes` parameter makes it testable without a real ephemeris.
- The 10° ecliptic-latitude filter for star placement is documented and reasonable for excluding far-off-ecliptic stars from constellation bins.
- `ConstellationId` order matches ecliptic longitude, and the enum `index` (0–12) is used implicitly by `values` ordering. This is a clean Dart idiom.

**Concerns:**
- **`Ecliptic13` is not on `Chart`**. The commit message says "keeps it off Chart as a standalone utility" — this is a deliberate architectural choice, but it means consumers must manually call `buildEcliptic13(snap)`. If `ZodiacSystem.trueSidereal13` is selected in `CalcConfig`, there is no automatic wiring to produce an `Ecliptic13`. This is fine for now but should be tracked in a future issue.
- **`StarData` doc comment refers to non-existent `SweConfig.includeStarRiseSet`**. The actual field is `includeStarData`. See "Documentation" section below.
- **`riseJd` / `setJd` stubbed in this commit**. The commit message acknowledges this, but the `StarData` class ships with nullable fields that will be null for most stars until commit 3. This is acceptable for incremental delivery but confusing if someone inspects the class without reading the commit history.

#### Correctness & Edge Cases

**Issue: Boundary star longitude lookup throws `StateError` on missing data.**
```dart
if (lastLon == null || firstLon == null) {
  throw StateError('Missing boundary star longitude: ...');
}
```
This is the right failure mode — fail fast with a descriptive message. However, `buildEcliptic13(EphSnapshot)` (added in commit 3) does not validate that boundary stars are present before calling `Ecliptic13.build()`, so the `StateError` propagates to the caller. The doc comment warns about this, but a more explicit `AssertionError` or early check could be friendlier.

**Issue: `constellationAt()` silent fallback.**
```dart
Constellation constellationAt(double longitude) {
  final lon = longitude % 360;
  for (final c in _constellations.values) {
    if (c.contains(lon)) return c;
  }
  return _constellations.values.first; // fallback
}
```
If floating-point gaps or boundary computation errors create a void, this silently returns Aries. Consider asserting or throwing after the loop, since a gap indicates a bug in boundary computation. Given that `_computeBoundaries` + `length` should cover the full circle, a gap is truly exceptional.

**Issue: `ZodiacSystem` added to `CalcConfig` but unused.**
`CalcConfig.zodiacSystem` defaults to `sidereal12` and is never read by any calculation logic in these commits. It is a forward-looking field, which is fine, but it risks becoming stale if the `Ecliptic13` integration is delayed.

#### Testing
- `constellation_test.dart`: Tests map invariants, boundary-star distinctness, `Constellation.length` and `contains()` for wrapping/non-wrapping ranges. **Good coverage.**
- `ecliptic13_test.dart`: Synthetic boundary-star longitudes, tests length sum, `constellationAt`, `longitudeToConstellation`, missing-star error. **Good.**
- Missing: No test for `Constellation` planet/star placement (`addPlanet` / `addStar` are not directly tested). The integration test in commit 3 covers this indirectly.
- Missing: No test for `FixedStar.magnitude` fallback logic (`starData?.apparentMagnitude ?? star?.traditionalMag`).

#### Documentation

**Critical doc bug:**
`arrow/swe/lib/src/star_data.dart` line 8:
```dart
/// Rise/set fields require [SweConfig.includeStarRiseSet] — they are null
```
The field `includeStarRiseSet` does **not exist**. The correct field is `SweConfig.includeStarData`. This will mislead IDE hover-tooltips and dartdoc consumers.

**Minor doc issue:**
`arrow/calc/lib/src/zodiac/ecliptic13.dart` line 172 says "Stars with |ecliptic latitude| > 10° are excluded" but the actual check is `star.position.latitude.abs() <= 10.0`. The comment and code match; this is just noting the magic number 10° is not configurable.

---

### Commit `81d04855` — Star Rise/Set Wiring + buildEcliptic13

#### What Changed
- **`SweFacade._calcStarData`**: Now calls `riseTrans` with `starName:` parameter (requires swisseph `^0.4.6`). Populates `riseJd`, `setJd`, `circumpolar`.
- **`buildEcliptic13(EphSnapshot)`**: Convenience top-level function in `arrow/calc/lib/src/zodiac/ecliptic13.dart`.
- **`ecliptic13_integration_test.dart`**: Integration test using real SWE star positions at J2000. Verifies Aldebaran → Taurus, Antares → Scorpio, Regulus → Leo, Sun → Sagittarius.
- **swisseph bumped** to `^0.4.6` in `arrow/swe/pubspec.yaml` and `arrow/tool/pubspec.yaml`.

#### Design & Architecture

**Good:**
- `buildEcliptic13` is a pure function over `EphSnapshot`, keeping the 13-constellation system decoupled from `Chart`. This respects the layered architecture.
- The integration test uses `setUpAll` / `tearDownAll` to amortize the expensive SWE call across all tests. **Good pattern.**

**Concerns:**
- **Circumpolar detection is imprecise.**
```dart
try {
  final r = _swe.riseTrans(..., rsmi: seCalcRise, ...);
  riseJd = r.transitTime;
} catch (e) {
  _log.fine('star rise failed for $sweName: $e');
  circumpolar = true;
}
```
This catches **all** exceptions, not just "star never rises." If `riseTrans` throws because of a missing ephemeris file, an invalid star name, or a bug in the swisseph binding, the star is incorrectly marked as `circumpolar = true`. This is a real correctness issue.

**Recommendation:** Inspect the exception (or the SWE return code, if accessible through the binding) to distinguish "circumpolar" from "calculation error." At minimum, log at `warning` level when marking circumpolar, so users can audit false positives. If the swisseph Dart binding exposes error codes, check for the specific circumpolar code.

- **`riseJd` / `setJd` ordering assumptions in tests.**
The test expects:
```dart
expect(aldeb.riseJd!, greaterThan(jdUt));
expect(aldeb.setJd!, greaterThan(jdUt));
```
At J2000 noon, this is likely true, but rise could occur earlier in the day (before noon) and set later. A more robust test would check that `|riseJd - setJd|` is roughly half a sidereal day, or simply assert non-null without ordering constraints. The current test may flake depending on the star and location.

#### Correctness & Edge Cases

**Issue: `buildEcliptic13` silently ignores non-boundary stars.**
```dart
for (final entry in snap.starsEcliptic.entries) {
  starLongitudes[entry.key] = entry.value.longitude;
}
```
It copies **all** stars into `starLongitudes`, but `Ecliptic13.build()` only reads the boundary stars. This is harmless but slightly wasteful. A stricter implementation could filter to `boundaryStars` and assert their presence.

**Issue: `circumpolar` can be `true` even when one of rise/set succeeds.**
If rise succeeds and set fails, `circumpolar = true`. This is astrologically correct (star rises but never sets, or vice versa). However, the `StarData` doc comment says "null when ... the star is circumpolar / never rises" — but `riseJd` or `setJd` may be non-null while the other is null. This is a nuanced state that consumers should be aware of. Consider adding a getter:
```dart
bool get isCircumpolar => circumpolar;
bool get neverRises => circumpolar && riseJd == null;
bool get neverSets => circumpolar && setJd == null;
```

#### Testing
- The integration test is tagged `integration` and properly gated on ephemeris path. **Good.**
- The test asserts Sun at J2000 is in Sagittarius under true sidereal. This is a strong, opinionated assertion that validates the entire boundary-computation pipeline end-to-end. **Excellent.**
- Missing: No test for a genuinely circumpolar star (e.g., Polaris at high latitude). This would validate the `circumpolar` flag logic.
- Missing: No test for a star that rises but never sets (or vice versa) — difficult to construct without location-specific fixtures.

---

## Cross-Cutting Concerns

### Serialization & Backward Compatibility

The `EphSnapshot` gained four new map fields in commit 1 and two more in commit 2. Because they are all `@Default({})`, existing JSON without these keys will deserialize correctly. **Good.**

However, if an `EphSnapshot` is serialized from code after these commits and then deserialized by code before these commits (older Arrow version), the older code will ignore the unknown keys. This is safe because `EphSnapshot` uses `json_annotation` default behavior (no `disallowUnrecognizedKeys`).

The reverse scenario (old JSON → new code) is also safe due to `@Default`.

### Dependency Management

- swisseph bumped from `^0.4.4` → `^0.4.5` → `^0.4.6` across three commits. The bump to `0.4.6` is **required** for the `starName` parameter in `riseTrans`. If a consumer pins `0.4.5`, commit 3 code will fail at runtime. The `pubspec.yaml` constraints are correct, but this rapid version churn suggests the binding API was unstable. Consider pinning to exact versions (`0.4.6`) or adding a runtime check for the `starName` parameter support with a graceful fallback.

### Performance

- `SweFacade.calcAll()` now makes `2 × (stars + customStars)` additional `fixstar2Ut` calls, plus `2 × (stars + customStars)` additional `riseTrans` + `fixstar2Mag` calls if `includeStarData` is on. For the default empty-star case, this is zero overhead. For a full boundary-star set (22 stars) + junction stars (27 stars), that's ~98 extra SWE calls. SWE fixed-star lookup is fast (in-memory `sefstars.txt` parse), but this could add ~10–20 ms per snapshot. Document this in `SweConfig` dartdoc.

### Naming & Consistency

- `Star` enum lives in `arrow_options` but is used as a key in `arrow_swe` (`EphSnapshot`) and `arrow_core` (`FixedStar`, `Chart`). This is the same pattern as `Body` and is correct — `arrow_options` is the shared kernel.
- `BodyPosition` is used for stars. A future rename to `SkyPosition` would improve readability but is a breaking change across all three packages.
- Some `Star` enum names mix CamelCase with embedded numbers (`fortyOneArietis`, `oneGeminorum`, `zetaPiscium`). This is consistent internally but slightly awkward. Not a blocker.

---

## Recommendations (Priority Order)

### High Priority
1. **Fix `StarData` doc comment**: Replace `[SweConfig.includeStarRiseSet]` with `[SweConfig.includeStarData]` in `arrow/swe/lib/src/star_data.dart`.
2. **Improve circumpolar detection**: Distinguish SWE "circumpolar" errors from other exceptions in `_calcStarData`. If the binding doesn't expose error codes, at least log at `warning` when marking circumpolar and document the imprecision.
3. **Add `orElse` to `StarMapConverter` and `StarDataMapConverter`**: Provide a descriptive error on unknown star names during deserialization, or add a helper method `Star.byName(String)` for consistency with `Body.values.byName`.

### Medium Priority
4. **Consider overriding `FixedStar.varga()` to throw**: Fixed stars should not compute divisional-chart longitudes. If throwing is too aggressive, document that varga results for fixed stars are mathematically valid but astrologically undefined.
5. **Strengthen `constellationAt` fallback**: Replace the silent "return first" fallback with an assertion or `throw StateError` if no constellation contains the longitude.
6. **Add test for `FixedStar.magnitude` fallback**: Verify that `starData?.apparentMagnitude ?? star?.traditionalMag` resolves correctly when `starData` is null.
7. **Add `@override` to `FixedStar.toString()`** and any other overridden members.

### Low Priority / Future Work
8. **Lazy initialization for `Chart.fixedStars`**: If star counts grow beyond the current ~80, make the maps lazy.
9. **Expose `Ecliptic13` through `Chart` or a calculator method**: When `CalcConfig.zodiacSystem == ZodiacSystem.trueSidereal13`, provide a first-class API rather than requiring manual `buildEcliptic13` calls.
10. **Add `Star.byName` factory**: Like `Body.values.byName`, for safer deserialization and consumer convenience.
11. **Test circumpolar star behavior**: Add a location-specific test for Polaris at a high latitude to validate `circumpolar = true` and `riseJd == null`.
12. **Document performance impact of `includeStarData`**: Mention the extra `riseTrans` + `fixstar2Mag` calls per star in `SweConfig` dartdoc.

---

## Conclusion

The subsystem is well-architected, thoroughly tested, and follows Arrow's existing patterns. The `SkyObject` refactor is a genuine cleanup. The 13-constellation ecliptic is a clean port from libaditya with good test coverage. The main blockers before calling this production-ready are:

1. Fix the `StarData` doc bug.
2. Harden circumpolar detection against false positives.
3. Harden `StarMapConverter` deserialization against enum renames.

Once those are addressed, this is approve-for-merge with minor follow-up items.

**Reviewer:** OpenCode (kimi-k2.6)
**Date:** 2026-04-24
