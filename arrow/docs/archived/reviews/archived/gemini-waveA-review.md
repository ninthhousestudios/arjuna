# Code Review: Wave A (SWE Boundary Hygiene)

## Overview
This review covers the six commits comprising **Wave A** of the `drona` branch refactoring, focusing on the separation of configuration contracts and the encapsulation of the Swiss Ephemeris (`swisseph`) dependency.

| Commit | Description |
|---|---|
| `931ce1b` | Move `nakAyanamsa` from CalcConfig to SweConfig |
| `a009d22` | Wire nakAyanamsa through `Longitude.nakshatra`/`pada` |
| `fa0c627` | Move `includeStarData` from SweConfig to `SweFacade.calcAll` |
| `04c7dc9` | Move `Body.sweId` to swe/ as `sweIdFor()` |
| `4f5d120` | Move `Star.sweName` to swe/ as `sweNameFor()` |
| `7d8ec85` | Stop re-exporting `SwissEph` and `dhruva` from barrel |

## Detailed Analysis

### 1. Configuration Contracts & the ~24° Nakshatra Bug (A1 + A2)
- **Design Assessment:** Moving `nakAyanamsa` into `SweConfig` correctly aligns the responsibility of coordinate frame generation within the SWE layer. `CalcConfig` is strictly for derived logic (e.g., traditions, circle formats), whereas `nakAyanamsa` physically alters the reference frame from which nakshatras and padas are derived.
- **Bug Fix:** The implementation in `Longitude._nakshatraLon()` clearly subtracts the pre-computed `nakAyanamsaValue` from the target longitude (ecliptic or equatorial). The formula `(rawLon - nakAyanamsaValue) % 360` with a negative coordinate check ensures the wheel strictly wraps within `[0, 360)`. This resolves the ~24° offset bug by ensuring the dhruva galactic-center offset (or any other ayanamsa) is properly subtracted prior to nakshatra division.
- **Conclusion:** Excellent state management. The `SweFacade` computes the offset once and passes it via `EphSnapshot` down to the domain logic. 

### 2. Transient Output Detail (A3)
- **Design Assessment:** Changing `includeStarData` from a field on `SweConfig` to a parameter on `SweFacade.calcAll()` is a solid API design improvement. The `SweConfig` struct represents invariant mathematical state for a given snapshot calculation; whether the consumer requires the expensive rise/set/magnitude calculations (`includeStarData`) is a retrieval option, not a fundamental property of the sky state. This prevents unnecessary snapshot cache invalidation.

### 3. SWE Boundary Encapsulation (A4.1, A4.2, A4.3)
- **Design Assessment:** The domain enumerations `Body` and `Star` (residing in `arrow_options`) previously held direct dependencies on `swisseph` wire-format integer codes and internal query strings (e.g., `seMeanNode`, `,SgrA*`). 
- **Implementation:** Extracting these mappings into `body_swe_id.dart` and `star_swe_name.dart` completely isolates the `options` package from knowing about the underlying ephemeris engine. 
- **Barrel Hygiene:** The `arrow_swe` barrel file (`swe/lib/arrow_swe.dart`) correctly exports only the internal facade and value objects (`SweFacade`, `EphSnapshot`, `StarPosition`, etc.). It purposefully omits the export of `SwissEph`. 
- **Conclusion:** This creates a strict, highly cohesive module boundary. Consumers of the system can no longer accidentally bypass the facade or rely on SWE internals.

## Final Verdict
The Wave A commits are a textbook example of enforcing architectural boundaries. The separation of concerns between `options`, `core`, and `swe` is now cleanly delineated. The fix for the nakshatra offset is mathematically sound and idiomatically integrated into the coordinate model.

**Status:** Approved. No regressions or code smells detected in the final state of these commits.
