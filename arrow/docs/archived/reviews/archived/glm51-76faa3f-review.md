# Arrow Code Review — Commit `76faa3f`

**Reviewer:** GLM-5.1  
**Date:** 2026-04-22  
**Scope:** Port of four major Vedic calculation modules from `libaditya` into `arrow_calc` + `arrow_options`  
**Commit:** `76faa3fe9d22245277128b98cf7c93638ab4553b`  
**Author:** josh (Co-Authored-By: Claude Opus 4.6)  
**Lines Added:** +3,463 (15 files, 0 deletions)  
**Tests:** 354 total vedic tests — all passing  
**Static Analysis:** Zero issues (`dart analyze` clean)  

---

## 1. Executive Summary

This commit ports the Vimshottari dasha engine, Jaimini system (padas, argala, bandhana, three sign-strength systems), Shadbala six-fold planetary strength, and Nabhasa yoga calculator (32 nabhasa + 5 panchamahapurusha + 3 solar + 4 lunar yogas) from the Python `libaditya` codebase into Arrow's Dart monorepo. It also introduces a `DashaYearLength` enum in `arrow_options` and wires it into `VedicConfig`.

The code is **well-structured, idiomatic Dart 3, and thoroughly tested**. It leverages sealed classes, records, switch expressions with `||` patterns, and named parameters extensively. The barrel-file exports maintain alphabetical ordering. Test coverage is strong on boundary conditions and mathematical invariants.

**Overall Grade: A-**

Notable strengths: zero analyzer warnings, comprehensive test invariants (tree sums to 120 years, sub-periods sum to parent, `nowJd` inside every returned period), clean separation of concerns, good use of `const` for immutability. Issues identified below range from correctness concerns (one) to DRY/style/refinements.

---

## 2. Files Changed

| File | +/- | Role |
|------|-----|------|
| `calc/lib/src/vedic/vimshottari.dart` | +268 | Dasha engine: seed, currentDasha, specificPeriod, fullTree |
| `calc/lib/src/vedic/jaimini.dart` | +373 | Pada, argala, bandhana, first/second/third strength |
| `calc/lib/src/vedic/shadbala.dart` | +380 | 5 sthana-balas + dig + ayana + cheshta + drig bala |
| `calc/lib/src/vedic/shadbala_const.dart` | +98 | Exaltation points, digbala houses, mean-lon polynomials |
| `calc/lib/src/vedic/nabhasa_yoga.dart` | +580 | 32 Nabhasa + 5 Panchamahapurusha + 3 Solar + 4 Lunar |
| `calc/lib/src/vedic/rashi_aspect.dart` | +54 | Sign-to-sign aspect lookup table |
| `calc/lib/arrow_calc.dart` | +6 | Barrel-file exports (alphabetical) |
| `calc/test/vedic/vimshottari_test.dart` | +395 | ~21 tests |
| `calc/test/vedic/jaimini_test.dart` | +337 | ~17 tests |
| `calc/test/vedic/shadbala_test.dart` | +290 | ~19 tests |
| `calc/test/vedic/nabhasa_yoga_test.dart` | +512 | ~28 tests |
| `calc/test/vedic/rashi_aspect_test.dart` | +152 | ~14 tests |
| `options/lib/src/dasha_year_length.dart` | +14 | New enum (6 year lengths) |
| `options/lib/src/vedic_config.dart` | +3 | Added `dashaYearLength` field |
| `options/lib/arrow_options.dart` | +1 | Export `dasha_year_length.dart` |

---

## 3. Correctness Issues

### 3.1 [Medium] Moon uccha bala proportional fallback uses `moonExaltEnd` as point-lon, not the range midpoint

**File:** `calc/lib/src/vedic/shadbala.dart:86-96`

When the Moon is outside both the exaltation range (30–33°) and the debilitation range (210–213°), `virupasBetween(lon, ShadbalaCon.moonExaltEnd)` is called. This treats 33° as the "point" of full exaltation, producing 60 virupas at exactly 33° — which is correct at the range boundary. However, within the range 30–33°, the code returns a flat 60 via the first `if` check, so the proportional case only fires for longitudes *outside* the ranges.

The problem: if `lon = 34°`, we are 1° past the exaltation range end. `virupasBetween(34, 33) = 59.67`. But is the correct model that exaltation *gradually* decays from the *center* of the range (31.5°)? Many classical references place the Moon's exaltation at exactly 3° Taurus (33° ecliptic), not at a range center. If the source `libaditya` uses 33° as the exaltation point for all proportional computation, this is intentional and correct. But if `libaditya` treats the 30–33° range as a "plateau" with a midpoint at 31.5°, the proportional fallback should use 31.5° instead.

**Verdict:** Likely correct given the `moonExaltEnd = 33.0` matches the classical exaltation point in `ShadbalaCon.exaltationPoint[Body.moon]`. Worth a one-line comment to clarify that `moonExaltEnd` doubles as both the plateau boundary and the virupas target.

### 3.2 [Low] `saptavargajaBala` fallback for exalted/debilitated uses natural friendship only

**File:** `calc/lib/src/vedic/shadbala.dart:122-135`

The comment is admirably honest about the limitation: when a planet is exalted or debilitated in a varga, the code falls back to *natural* friendship because the sign lord's current position (needed for temporal/compound friendship) is unavailable at this layer. The comment says "callers who have it should pre-resolve DignityType via Dignity.calculate()". This is acceptable for now but should be tracked — compound friendship can significantly change the points (difference of up to 18 virupas per varga, ×7 = up to 126 virupas).

**Recommendation:** Add a `TODO` or issue tracker reference so this known gap doesn't get forgotten.

### 3.3 [Low] Vimshottari `_calcCurrent` loop guard uses `count < 9` but could infinite-loop on corrupt input

**File:** `calc/lib/src/vedic/vimshottari.dart:131-155`

The `while (thisLord != target && count < 9)` loop in `specificPeriod` is correctly bounded. But `_calcCurrent` uses a `for (var n = 0; n < 9; n++)` loop that iterates through all 9 lords; if `nowJd` is beyond the 120-year cycle (e.g. >120 years after birth), the function silently returns an empty list rather than signaling an error. This is probably fine — the caller can check the result — but it's worth documenting.

---

## 4. Design & Architecture

### 4.1 Good: Private constructor pattern (`ClassName._()`) consistently used

All four calculator classes (`Vimshottari`, `Jaimini`, `ShadbalaCalc`, `NabhasaYogaCalc`, `RashiAspect`) use `const ClassName._();` with all-static methods. This is the established pattern in this codebase (matching `aspect.dart`, `baladi.dart`, etc.). No instances can be created — these are pure-function namespaces.

### 4.2 Good: Sealed class hierarchy for `YogaResult`

`nabhasa_yoga.dart` uses a `sealed class YogaResult` with `NabhasaYoga`, `MahapurushaYoga`, and `SolarLunarYoga` subtypes. This forces exhaustive matching at call sites and is idiomatic Dart 3. The `toMove` / `isPresent` design (0 = present, N = how many planets need to move to complete the yoga) is a pragmatic "distance from formation" metric.

### 4.3 Good: `DashaYearLength` in `arrow_options`, not `arrow_calc`

The year-length enum lives in the options package where it belongs (configuration), not in the calc package (computation). Wired into `VedicConfig` with `@Default(DashaYearLength.saura)`. Clean boundary.

### 4.4 [Low] Jaimini `firstStrength` is a 60-line comparator closure

**File:** `calc/lib/src/vedic/jaimini.dart:186-250`

The `compareSignPair` closure inside `firstStrength` implements 8 comparison levels. It's functional but hard to unit-test in isolation. Consider extracting the comparator as a named static method for direct testing, or at minimum testing the ranking output more thoroughly (the current test only checks `allPadas` delegates correctly).

### 4.5 [Low] `Shadbala` data class vs. calculator class separation

`Shadbala` is a pure data class, `ShadbalaCalc` is the calculator. This is clean. However, `Shadbala` has a `totalRupas` getter but no `isStrongEnough` threshold check (each planet has a minimum required Shadbala in virupas). This is presumably out of scope for this commit but is a natural extension point.

---

## 5. Code Quality

### 5.1 [Medium] DRY violation: benefic/malefic lists duplicated in `nabhasa_yoga.dart`

The `dalaYogas` method (line ~175) and the `akritiYogas` method (line ~248) each construct identical `benefics` and `malefics` local variables:

```dart
final benefics = <Body>[Body.mercury, Body.jupiter, Body.venus];
final malefics = <Body>[Body.sun, Body.mars, Body.saturn];
if (moonIsBenefic) { benefics.add(Body.moon); } else { malefics.add(Body.moon); }
```

This logic is also partially duplicated in `jaimini.dart` with `_isMalefic(Body)`. Across the two files, the benefic/malefic classification (especially Moon's conditional status) is built three different ways. Extract a shared helper, either as a static method on a shared utility or as a top-level function.

### 5.2 [Low] `_isMalefic` in Jaimini doesn't match `_solarLunarYogas` eligible lists

`Jaimini._isMalefic` considers Sun, Mars, Saturn, Rahu, Ketu as malefics. `NabhasaYogaCalc._solarLunarYogas` filters for "eligible" planets as Mars, Mercury, Jupiter, Venus, Saturn — excluding Sun, Moon, Rahu, Ketu from the eligible set for solar/lunar yogas. These are *different concepts* (natural malefic vs. yoga-eligible), but having two overlapping-but-different body classification schemes without cross-referencing comments is confusing. A brief comment in each file linking to the other would help.

### 5.3 [Low] `NabhasaYogaCalc._tm` and `_tmDist` names are inscrutable

One-letter and two-letter method names (`_tm`, `_tmDist`) save keystrokes but cost readability. Consider `_toMoveCount` and `_toMoveDistCount` or similar. The doc comments help, but the names themselves should convey meaning.

### 5.4 [Low] Named parameters used consistently — good

Every public method uses named required parameters, matching the codebase convention. This is especially important here since many methods have 4-6 parameters of the same type (`int`, `Map<int, ...>`) and positional parameters would be error-prone.

### 5.5 [Info] `vimshottari.dart:_pow120` is O(n) with a loop

```dart
static double _pow120(int exp) {
  var result = 1.0;
  for (var i = 0; i < exp; i++) result *= 120.0;
  return result;
}
```

Since `exp` is bounded by the dasha depth (typically ≤5), this is fine. But `math.pow(120.0, exp.toDouble())` would be one line. Minor.

---

## 6. Test Quality

### 6.1 Excellent: Invariant-based testing in `vimshottari_test.dart`

The tests check crucial mathematical invariants:
- 9 mahadashas sum to exactly 120 years
- Sub-period durations sum to their parent period
- `nowJd` falls within `[startJd, endJd)` for every returned period
- Lord chain prefixes are consistent across levels
- Mahadasha sequence follows the expected Vimshottari lord order

This is significantly better than just testing "expected output for one input."

### 6.2 Good: Boundary condition coverage

`shadbala_test.dart` tests exaltation/debilitation boundaries (30°, 33° for Moon; 10° for Sun), same-point (60 virupas), opposite-point (0 virupas), and cross-360° wrapping. `jaimini_test.dart` tests pada special cases (apart=1,4,7,10), sign wrapping, and Ketu-in-target reversal for argala.

### 6.3 [Medium] No integration test for the full Shadbala pipeline

The individual sub-bala functions (`uccaBala`, `saptavargajaBala`, `digBala`, etc.) are tested in isolation, but there is no test that constructs a `Shadbala` record end-to-end for a real chart and verifies that `sthanaBala` + `digBala` + `ayanaBala` + `cheshtaBala` + `drigBala` produces a reasonable total. A "smoke test" with known reference values (e.g. from a classical text or from `libaditya` output) would catch integration bugs.

### 6.4 [Medium] No test for `cheshtaBala` with Moon/inner/outer planet branches

`cheshtaBala` tests are absent from `shadbala_test.dart`. The Sun branch (same as ayanaBala) is implicitly exercised since the code path is identical, but the Moon branch (`sunEclipticLon` parameter) and the inner/outer planet branches (`_innerPlanetCheshta` / `_outerPlanetCheshta`) with their mean longitude polynomial evaluation have zero test coverage. These contain non-trivial arithmetic that would benefit from at least one golden-value test per branch.

### 6.5 [Low] `saptavargajaBala` has no direct test

The `saptavargajaBala` function is untested. Its `_saptavargajaPoints` helper handles the exalted/debilitated fallback, which is exactly the branch that could silently produce wrong results (see 3.2). At minimum, a test that passes 7 vargas with known dignities and checks the total would be valuable.

### 6.6 [Low] `firstStrength` sorting is not tested

`Jaimini.firstStrength` has 8 comparison levels with subtle tiebreakers (modality, dignity-score lexicographic comparison, KN Rao mode). The existing `jaimini_test.dart` does not test this function at all. Given its complexity, it should be exercised.

---

## 7. Rashi Aspect Table Verification

The rashi aspect table in `rashi_aspect.dart` encodes the Jaimini sign-aspect rules:
- Cardinal signs (1,4,7,10) aspect fixed signs except the adjacent one
- Fixed signs (2,5,8,11) aspect cardinal signs except the adjacent one
- Dual signs (3,6,9,12) aspect all other dual signs

I verified a sample of entries against the classical rule:
- Sign 1 (cardinal): fixed signs are {2,5,8,11}, adjacent=2, so aspects = {5,8,11} ✓
- Sign 2 (fixed): cardinal signs are {1,4,7,10}, adjacent=1, so aspects = {4,7,10} ✓
- Sign 3 (dual): other duals are {6,9,12} ✓
- Sign 5 (fixed): cardinals = {1,4,7,10}, adjacent = sign 4, so aspects = {1,7,10} ✓
- Sign 10 (cardinal): fixed = {2,5,8,11}, adjacent = sign 11, so aspects = {2,5,8} ✓
- Sign 12 (dual): other duals = {3,6,9} ✓

All entries in `_table` are consistent with the rule. The test file exhaustively verifies every aspect and non-aspect for all 12 signs. **Table is correct.**

---

## 8. Documentation & Naming

### 8.1 Good: Extensive doc comments on public APIs

Every public method has a doc comment describing parameters, return values, and the Vedic concept being calculated. Classical Sanskrit terms are preserved (uccha bala, saptavargaja, virupas) with clear English explanations.

### 8.2 Good: `ShadbalaCon` clearly documents provenance

"Constants for Shadbala calculations. All values ported from libaditya." The mean-longitude polynomial coefficients cite "T = Julian centuries from J2000". Exaltation points specify "ecliptic degrees, 0–360".

### 8.3 [Low] `ArdhaChandra${i + 1}` naming

The Ardha Chandra yogas are named `ArdhaChandra1` through `ArdhaChandra8`. These correspond to 8 different starting positions but carry no meaningful naming. Classical texts don't distinguish sub-types of Ardha Chandra, so arbitrary numbering is fine, but a brief comment explaining what the numbering means would help.

---

## 9. Summary of Recommendations

| # | Severity | Issue | File | Action |
|---|----------|-------|------|--------|
| 1 | Medium | DRY violation: benefic/malefic lists duplicated 3× | `nabhasa_yoga.dart`, `jaimini.dart` | Extract shared helper |
| 2 | Medium | No cheshtaBala test coverage (Moon, inner, outer branches) | `shadbala_test.dart` | Add golden-value tests |
| 3 | Medium | No saptavargajaBala test coverage | `shadbala_test.dart` | Add dignity-matrix test |
| 4 | Medium | No Shadbala end-to-end integration test | `shadbala_test.dart` | Add real-chart smoke test |
| 5 | Medium | saptavargajaBala natural-friendship fallback undocumented scope | `shadbala.dart:122-135` | Add TODO/issue ref |
| 6 | Low | `firstStrength` not tested | `jaimini_test.dart` | Add ranking test |
| 7 | Low | `_tm`/`_tmDist` names inscrutable | `nabhasa_yoga.dart` | Rename for clarity |
| 8 | Low | `_pow120` could use `math.pow` | `vimshottari.dart` | Minor refactor |
| 9 | Low | Moon uccha bala fallback-target could use a clarifying comment | `shadbala.dart:93` | Add 1-line comment |
| 10 | Info | `_calcCurrent` returns `[]` for nowJd beyond 120-year cycle | `vimshottari.dart` | Document behavior |

---

## 10. Conclusion

This is a high-quality port of complex Vedic calculation logic. The code demonstrates strong command of Dart 3 idioms (sealed classes, records, pattern matching), follows project conventions rigorously (private constructors, named parameters, barrel-file ordering, `const` usage), and passes all 354 tests with zero analyzer warnings. The identified issues are at the "refinement" level — primarily test gaps for cheshtaBala and saptavargajaBala, and a DRY violation in benefic/malefic classification. No correctness bugs were found in the core logic. The rashi aspect table was verified against the classical rule and is correct. Recommended to merge with follow-up items tracked.