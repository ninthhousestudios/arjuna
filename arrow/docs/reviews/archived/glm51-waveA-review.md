# Wave A Review — Fix config contracts and seal the SWE boundary

**Reviewer:** GLM-5.1
**Date:** 2026-05-04
**Commits:** `931ce1b`..`7d8ec85` (6 commits)

---

## Summary

Wave A enforces the SweConfig/CalcConfig contract and moves all SWE
wire-format knowledge out of the options layer. The structural refactor
(A1, A3, A4.1–A4.3) is clean and well-executed. The critical bug fix
in A2 has a **double-subtraction defect** that will produce wrong
nakshatras for any fully-sidereal chart (e.g. the `lahiriVedic` preset).

---

## Verdict by commit

| Commit | Verdict | Notes |
|--------|---------|-------|
| A1 `931ce1b` | **Accept** | Clean field relocation, tests updated correctly |
| A2 `a009d22` | **Request changes** | Double-subtraction bug (see below) |
| A3 `fa0c627` | **Accept** | Sound design, minimal blast radius |
| A4.1 `04c7dc9` | **Accept** | Clean extraction |
| A4.2 `4f5d120` | **Accept** | Clean extraction |
| A4.3 `7d8ec85` | **Accept** | Correct barrel hygiene |

---

## A1 — Move `nakAyanamsa` from CalcConfig to SweConfig

**Correct.** The two-config contract is:

- **SweConfig** — changes require SWE recalculation (new EphSnapshot)
- **CalcConfig** — changes are free (same EphSnapshot, new Chart)

`nakAyanamsa` feeds directly into `_calcNakAyanamsa` which calls SWE,
so it belongs on SweConfig. The move is minimal: field relocation,
preset adjustments, test reshuffling. No logic changes. The `Ayanamsa`
import is removed from `calc_config.dart`, which is correct.

Minor: the `CalcConfig.copyWith` test was weakened — the old test
asserted `zodiac.nakAyanamsa == dhruva`, the new test asserts
`zodiac.nakEquatorial == true`. This is fine (the field no longer
exists on CalcConfig), but the test now duplicates the `defaults` test
above it. Could be collapsed; not blocking.

---

## A2 — Wire `nakAyanamsa` through `Longitude.nakshatra`/`pada` — **BUG**

### What the commit does

1. Adds `nakAyanamsaValue` to `EphSnapshot` (default 0.0)
2. Computes it in `SweFacade._calcNakAyanamsa()`
3. Propagates it through `CelestialBody` and `FixedStar` → `SkyObject`
4. Subtracts it in `Longitude._nakshatraLon()` before nakshatra/pada lookup
5. Adds regression tests

### Critical bug: double subtraction on sidereal charts

When `SweConfig.signAyanamsa` is sidereal, `calcAll` computes body
longitudes with `seFlgSidereal` (swe_facade.dart:84). SWE returns
longitudes **with the sign ayanamsa already subtracted**. Then
`_nakshatraLon()` subtracts `nakAyanamsaValue` again:

```dart
// longitude.dart:89-93
double _nakshatraLon() {
  final rawLon =
      config.nakEquatorial ? equatorialLongitude : eclipticLongitude;
  final adjusted = (rawLon - nakAyanamsaValue) % 360;
  return adjusted < 0 ? adjusted + 360 : adjusted;
}
```

For the `lahiriVedic` preset (Lahiri signs + Lahiri nakshatras):
- `eclipticLongitude` ≈ 0° (SWE already subtracted ~24.1° from tropical)
- `nakAyanamsaValue` ≈ 24.1° (computed from the same Lahiri sidereal mode)
- `adjusted` = 0° − 24.1° = −24.1° → 335.9° → **nakshatra 26** (Uttara Bhadrapada)
- Expected: **nakshatra 1** (Ashvini) for a body at sidereal 0°

The existing regression tests only cover the **tropical case**
(Ernst preset: tropical signs, dhruva nakshatras), where the longitude
is genuinely tropical and the subtraction is correct. The sidereal case
is untested and broken.

**Fix:** The effective offset should be the *difference* between the
nakshatra-frame ayanamsa and the sign-frame ayanamsa already baked into
the longitude:

```
effectiveOffset = nakAyanamsaValue - ayanamsaValue
```

NO! we should NEVER calculate sidereal longitudes using subtraction. ALWAYS use the
builtin swe methods, or the special ones for non-swe ayanamshas

This yields the correct value for all three regimes:
- Tropical signs + sidereal nakshatras (Ernst): 24 − 0 = 24°
- Sidereal signs + same sidereal nakshatras (Lahiri): 24.1 − 24.1 = 0°
- Sidereal signs + different sidereal nakshatras: delta only

The `ayanamsaValue` is already on `EphSnapshot`, so the fix can be
computed in `SkyObject` (or `CelestialBody`/`FixedStar`) before passing
it to `Longitude`, keeping Longitude unaware of sign-ayanamsa internals.

### Secondary issue: coordinate system mismatch on ecliptic subtraction

For the dhruva ayanamsa, `_calcNakAyanamsa` returns an **equatorial**
value (right ascension of Ashvini's start), but `_nakshatraLon()`
subtracts it from the **ecliptic** longitude when `nakEquatorial` is
false. Equatorial and ecliptic coordinates differ by the obliquity of
the ecliptic (~23.4°), so subtracting an equatorial ayanamsa from an
ecliptic longitude is a category error.

This is currently masked because:
- The Ernst preset uses dhruva + `nakEquatorial=true` → equatorial
  minus equatorial ✓
- The Lahiri preset uses an ecliptic ayanamsa + `nakEquatorial=false`
  → ecliptic minus ecliptic ✓

But a dhruva + `nakEquatorial=false` configuration would silently
produce wrong nakshatras. Consider either:
- Documenting the constraint (dhruva requires `nakEquatorial=true`)
- Computing the ayanamsa in the same coordinate system as the
  longitude being adjusted

### Tertiary: `barycentricRashiLongitude` and `heliocentricRashiLongitude`

These convenience methods in `CelestialBody` (celestial_body.dart:47-59)
construct `Longitude` without passing `nakAyanamsaValue`, so it defaults
to 0.0. For sidereal charts, these positions were computed with
`seFlgSidereal` (the `extraBase` flags inherit it), so their nakshatra
would be computed from a sidereal longitude with offset 0 — correct for
the Lahiri/Lahiri case but wrong for the Ernst case.

The doc comments explicitly limit these to "sign/degree-in-sign" and
advise using `barycentricPosition` directly for anything beyond, so
this is a footgun rather than a live bug. Still, `Longitude.nakshatra`
is a public getter, and calling it on these objects will return wrong
values silently.

---

## A3 — Move `includeStarData` from SweConfig to `SweFacade.calcAll` parameter

**Correct and clean.** The argument is sound: two charts with the same
SweConfig should be cache-equivalent regardless of whether star data
was requested. A runtime cost switch is not part of a snapshot's
identity.

The `calcAll` signature changes from:
```dart
EphSnapshot calcAll(double jdUt, Location location, ArrowOptions options)
```
to:
```dart
EphSnapshot calcAll(double jdUt, Location location, SweConfig sweConfig, {
  bool includeStarData = false,
})
```

Note: the third positional parameter also changed from `ArrowOptions` to
`SweConfig` (that's from a later commit `00f006d`, already applied at
HEAD). The `includeStarData` default is `false`, preserving backward
compatibility. The test file was properly updated.

One minor observation: the comment in `fixed_star.dart:25` still says
"Null when `includeStarData` is not requested" — this is accurate but
could now link to the `SweFacade.calcAll` parameter rather than the
defunct `SweConfig.includeStarData`.

---

## A4.1 — Move `Body.sweId` to `swe/` as `sweIdFor()`

**Correct.** `Body` is now a pure domain type. The SWE body IDs are in
a `const` map in `body_swe_id.dart` — the map literal syntax enforces
key uniqueness at compile time, which is stronger than the deleted test
that checked at runtime.

`Body.ketu: -1` is retained in the map even though the `ketu` branch is
skipped in the calculation loop (`if (body == Body.ketu) continue`).
The -1 value is never used. This is harmless, but a `throw` or omission
would make the "never passed to SWE" contract explicit. Not blocking.

---

## A4.2 — Move `Star.sweName` to `swe/` as `sweNameFor()`

**Correct.** Same pattern as A4.1. The `Star` enum dropped from 312
lines to 102, removing all SWE nomenclature strings. The 78-entry
`const` map in `star_swe_name.dart` enforces uniqueness at compile time,
stronger than the deleted `sweNames are unique` runtime test.

The deleted `well-known stars have expected names` test (aldebaran →
`Aldebaran`, spica → `Spica`, etc.) was also wire-format coverage.
Since the map values are compile-time constants and any typo would break
SWE at integration-test time, the coverage gap is acceptable.

---

## A4.3 — Stop re-exporting `SwissEph` and `dhruva` from barrel

**Correct.** Two re-exports removed from `arrow_swe.dart`:

1. `export 'package:swisseph/swisseph.dart' show SwissEph;` — consumers
   that need `SwissEph` now import it directly. Three test files and one
   tool script updated.
2. `export 'src/dhruva.dart';` — `dhruvaGcEquatorial` is an internal
   helper used only by `SweFacade`. No external consumer needed it.

Both changes reduce the barrel's API surface without breaking any
consumer that matters. The `dhruva.dart` file remains importable within
the `arrow_swe` package; it's just not re-exported to the world.

---

## Test coverage assessment

| Area | Coverage | Notes |
|------|----------|-------|
| A1 field relocation | Good | Config defaults, presets, copyWith all tested |
| A2 tropical nakshatra | Good | Offset shift + below-zero wrap |
| A2 **sidereal nakshatra** | **Missing** | No test for sidereal charts where ayanamsa is pre-baked |
| A2 equatorial/ecliptic mix | **Missing** | dhruva + `nakEquatorial=false` not tested |
| A3 includeStarData | Good | `true` and `false` cases covered |
| A4.1 sweIdFor | Adequate | Old runtime test deleted; compile-time map is stronger |
| A4.2 sweNameFor | Adequate | Same as A4.1 |
| A4.3 barrel | Implicit | Tests compile and pass; no dedicated barrel test needed |

All 830 tests pass (options 52, swe 67, core 317, calc 394). However,
the passing suite does not exercise any sidereal chart's nakshatra
through the full `calcAll → EphSnapshot → CelestialBody → Longitude`
pipeline, so the double-subtraction bug is not caught.

---

## Recommended follow-ups

1. **[Critical] Fix double-subtraction in `Longitude._nakshatraLon()`.**
   Compute `effectiveOffset = nakAyanamsaValue - ayanamsaValue` in
   `SkyObject`/subclasses, or pass both values to `Longitude` and
   compute the delta there. Add a test with a Lahiri sidereal snapshot
   that verifies a body at sidereal 0° has nakshatra 1 (Ashvini).

2. **[Medium] Document or enforce dhruva+nakEquatorial constraint.**
   If dhruva ayanamsa requires `nakEquatorial=true`, add a `assert` or
   validation in `SweConfig`/`ArrowOptions`. Otherwise, compute the
   offset in the same coordinate system as the longitude being adjusted.

3. **[Low] Pass `nakAyanamsaValue` to `barycentricRashiLongitude` and
   `heliocentricRashiLongitude`.** Or mark their `nakshatra`/`pada`
   getters as unreliable in the doc comment.

4. **[Low] Remove `Body.ketu: -1` from `body_swe_id.dart`** or replace
   with a `throw UnimplementedError()` to make the "never called"
   contract explicit.
