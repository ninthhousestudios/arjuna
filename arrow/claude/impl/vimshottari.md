# Vimshottari Dasha — Implementation Plan

Port the Vimshottari dasha engine from `libaditya/calc/vimshottari.py` into Arrow's calc layer.

## What exists in Arrow

- `core/lib/src/nakshatra_data.dart` — `NakshatraData.lords` maps nakshatra 1–27 to `Body` (the dasha lord). This is the seed table.
- No dasha period arithmetic, no tree builder, no current-period finder.

## What libaditya provides

- Full dasha tree to arbitrary depth (mahadasha → antardasha → pratyantardasha → ...)
- Current dasha lord(s) at any moment
- Specific period lookup without computing the full tree
- Multiple year-length options (Saura, Savana, Chandra)

## Core algorithm

### Constants

```
dashaYears = [Ketu:7, Venus:20, Sun:6, Moon:10, Mars:7, Rahu:18, Jupiter:16, Saturn:19, Mercury:17]
totalYears = 120
nakSize = 360 / 27  (13.333...°)
```

Year-length options (days per dasha-year):
- Saura: 365.2422 (default)
- Savana: 360.0
- Chandra: 364.2888

### Seeding from Moon nakshatra

```
moonSiderealLon = sidereal ecliptic longitude of the Moon (0–360)
nindex = floor(moonSiderealLon / nakSize)            # 0-based nakshatra index
elapsed = moonSiderealLon - (nindex * nakSize)        # degrees into the nakshatra
elapsedFraction = elapsed / nakSize                   # 0.0–1.0
firstDasha = nindex % 9                               # which of the 9 lords starts
yearsElapsed = dashaYears[firstDasha] * elapsedFraction
dashaStartJd = birthJd - (yearsElapsed * yrlen)
```

The mahadasha containing birth has already started before birth by `yearsElapsed` years.

### Period duration formula

For a period defined by lord indices `[l0, l1, l2, ...]` of depth `n`:

```
years = product(dashaYears[li] for li in lords) / 120^(n-1)
days = years * yrlen
```

This single formula is the mathematical core. Examples:
- Mahadasha Sun: `6 / 1 = 6 years`
- Sun-Moon antardasha: `6 * 10 / 120 = 0.5 years`
- Sun-Moon-Mars pratyantardasha: `6 * 10 * 7 / 14400`

### Sub-dasha sequencing

At any level, the first sub-dasha lord is the **same as the parent lord**. The sequence then cycles through all 9 in order (mod 9). So within Sun mahadasha: Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury, Ketu, Venus.

### Current dasha finder

Recursive descent. At each level, iterate through 9 periods from the start. When `start + duration > nowJd`, that's the active period. Recurse into it for the next level. Returns `[lord0, lord1, ..., lordN, endJd]`.

### Specific period lookup

Avoids building the full tree. Given `lords = [l0, l1, l2]`, walks forward at each level, skipping periods until the target lord is found, accumulating days. Returns `(startJd, durationDays)`.

## Implementation

### New file: `calc/lib/src/vedic/vimshottari.dart`

#### Data

```dart
enum DashaYearLength {
  saura(365.2422),
  savana(360.0),
  chandra(364.2888);
  const DashaYearLength(this.days);
  final double days;
}
```

Module-private constants:
- `_dashaYears` — 9-entry `List<double>` indexed 0=Ketu ... 8=Mercury
- `_nakSize = 360.0 / 27.0`
- `_totalYears = 120.0`

#### Result type

```dart
class DashaPeriod {
  final double startJd;
  final double durationDays;
  final List<Body> lords;
  double get endJd => startJd + durationDays;
}
```

#### API (static methods on `Vimshottari` class)

| Method | Signature | Notes |
|--------|-----------|-------|
| `periodDuration` | `(List<int> lordIndices, double yrlen) -> double` | Core formula, returns days |
| `seed` | `(double moonSiderealLon, double birthJd, double yrlen) -> (int firstDasha, double dashaStartJd)` | Seeding helper |
| `currentDasha` | `({moonSiderealLon, birthJd, nowJd, int levels, double yrlen}) -> List<DashaPeriod>` | Returns active periods at each level |
| `specificPeriod` | `({moonSiderealLon, birthJd, List<int> lords, double yrlen}) -> DashaPeriod` | Targeted lookup |
| `fullTree` | `({moonSiderealLon, birthJd, int levels, double yrlen}) -> List<DashaPeriod>` | Full tree, recursive |

All take primitives (doubles, ints), not domain objects — matching Arrow's calc layer convention.

### Barrel export

Add to `calc/lib/arrow_calc.dart`:
```dart
export 'src/vedic/vimshottari.dart';
```

### Options layer

Add `DashaYearLength` enum to `arrow_options` (or keep it in the calc file if it's only used there — follow the pattern of other calc-local enums).

## Testing

### Unit tests — `calc/test/vedic/vimshottari_test.dart`

- `periodDuration` with known inputs vs hand-calculated results
- `seed` with known Moon longitudes → expected firstDasha and dashaStartJd
- Sub-dasha sequencing: verify the cycle starts from the parent lord
- Edge case: Moon exactly on nakshatra boundary (elapsedFraction = 0)

### Golden tests — `calc/test/vedic/vimshottari_golden_test.dart`

Generate fixtures from libaditya:
- 3–5 known charts with `calculate_specific_period` and `current_vimshottari_dasha` outputs
- JSON format matching the existing `calc/test/fixtures/libaditya-golden/` pattern
- Compare `startJd` within 0.001 days (~86 seconds), `durationDays` within 1e-6

## Edge cases

1. Moon exactly on nakshatra boundary — `elapsedFraction = 0`, `dashaStartJd = birthJd`. Math is stable, no special handling.
2. 1-based vs 0-based nakshatra indexing — use `floor(lon / nakSize)` for 0-based; Arrow's `Longitude.nakshatra` is 1-based (subtract 1).
3. Sub-dasha starting lord — at every level, starts from the **same lord as the parent**, not from Ketu.
4. JD arithmetic is plain `double` addition — `jd + days`. No wrapper needed.
5. Year-length must flow through every duration calculation — no hardcoded 365.2422.

## Dependencies

- `arrow_options` — for `Body` enum (mapping lord indices to `Body`)
- `core/lib/src/nakshatra_data.dart` — existing lord-per-nakshatra table (for cross-validation, not direct use)
- No dependency on `arrow_swe` or `arrow_core` domain objects

## Sequence

1. Add `DashaYearLength` enum and `_dashaYears` constants
2. Implement `periodDuration` + unit tests
3. Implement `seed` + unit tests
4. Implement `currentDasha` (recursive) + unit tests
5. Implement `specificPeriod` + unit tests
6. Implement `fullTree` + unit tests
7. Generate libaditya golden fixtures, write golden tests
8. Export from barrel
