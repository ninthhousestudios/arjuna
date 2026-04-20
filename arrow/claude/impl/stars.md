# Arrow Stars — Implementation Plan

Port `libaditya/libaditya/stars` into arrow as a first-class subsystem.
Originally scoped for sunflare; elevated to its own arrow feature because
the surface area (fixed-star catalog + true-sidereal 13-constellation
zodiac + domain wrappers) is too large to live inside a UI app.

---

## Assumptions going in

- **Ephe path is solved by time of execution.** `SweFacade` can call
  `setEphePath()` with a real directory containing the `.se1` files **and
  `sefstars.txt`**. The fixstar machinery requires `sefstars.txt` at that
  path — SWE parses it internally on `fixstar2Ut`. No Dart-side parser
  needed. (`sefstars.txt` lives at `libaditya/libaditya/ephe/sefstars.txt`
  and must ship to whichever ephe path is configured.)
- Arrow's 3-layer pipeline holds: `options → swe → core → calc`.
  Stars must respect layer boundaries — non-SWE code never calls SWE,
  only sees `EphSnapshot`.
- `SweConfig` remains the "triggers SWE recalc" boundary; stars live here.
- `CalcConfig` covers derived-only work (constellation placement, 13-zodiac
  assignment).

## What we are NOT porting

- **`make_swe_stars.py`** (407 LOC) — SIMBAD HTTP scraping + sefstars
  format generator. Standalone CLI, catalog build-time only. Python can
  stay authoritative for catalog regeneration.
- **`utilities.py` SIMBAD helpers** — `swe_make_star`, `swe_write_stars`,
  `swe_consolidate_sefstars`, `swe_populate_stars`, `parse_simbad_ascii_response`,
  `swe_write_multiline_sefstars`, `swe_star_to_python`. Same reason.
- **`stellarium/` subtree** (~490 LOC) — HTTP client for the Stellarium
  desktop app. Not runtime-critical, not architecturally clean, not
  portable. If Stellarium integration is ever wanted, it belongs in a
  separate `arrow_stellarium` package, not inside `arrow_core`.

Runtime-essential subset: `fixed_star.py` (216), `the_stars.py` (522),
portions of `utilities.py` (`nomen_to_long_form`, `correct_nomen_name`).
Total port target ≈ 800 LOC Python → ~1200 LOC Dart with types + tests.

---

## Open decisions with recommended answers

**D1. Star set scope.**
Recommend **(c) typed enum + string escape hatch**:
- `Star` enum with ~60 curated entries — 27 nakshatra junction stars +
  ~25 Bayer-named brights + Galactic Center + a handful of deep-sky
  (M31, M42) if sefstars has them. Typed API, IDE autocomplete,
  serializable.
- `SweConfig.customStarNames: Set<String>` for anything else (arbitrary
  SWE nomen strings, including `%` wildcard fallback).

**D3. 13-constellation true-sidereal ecliptic.**
Recommend **include, but in its own `zodiac/` subdir under `arrow_calc`.**
It is a distinct feature from fixstar lookup; Python entangled them,
arrow shouldn't. Order: fixstar plumbing first (waves 1–3), ecliptic13
after (wave 4).

**D5. Stellarium bridge.**
Recommend **don't port.** If ever needed, new package. Don't contaminate
`arrow_core`.

**D6. Nakshatra junction stars — unify or duplicate?**
Arrow's `nakshatra_data.dart` already has nakshatra metadata (lord,
deity, symbol). libaditya's nakshatra→star mapping is a separate concern
(which bright star marks the nakshatra boundary). Recommend **keep
separate.** Add a `Star.nakshatra` field on stars that happen to be
junction stars, not a back-reference from nakshatra to star. Nakshatras
are mathematical divisions; stars are empirical objects. Don't couple.

**D7. Star catalog versioning.**
sefstars.txt changes over time (SWE releases). Stars deleted/renamed
between versions will break the `Star` enum. Recommend **pin sefstars.txt
version in arrow repo or vendor it alongside the enum.** Mismatch
between enum and catalog = runtime errors. Regenerate enum when updating.

---

## Wave structure

Ordered by dependency. Each wave is independently shippable.

### Wave 1 — Star enum + SWE wiring

**Goal:** `EphSnapshot` carries position data for a requested set of
typed stars.

**Files:**

```
options/lib/src/
  star.dart                 # NEW: Star enum, ~60 entries

options/lib/src/swe_config.dart       # MODIFIED: add `Set<Star> stars`
options/lib/arrow_options.dart        # MODIFIED: export star.dart

swe/lib/src/
  eph_snapshot.dart         # MODIFIED: add starsEcliptic, starsEquatorial
  swe_facade.dart           # MODIFIED: loop fixstar2Ut per requested star

swe/test/
  swe_facade_star_test.dart # NEW: golden-value tests for 3–5 stars
options/test/
  star_test.dart            # NEW: enum integrity (unique sweNames, labels)
```

**`Star` enum shape:**

```dart
enum Star {
  aldebaran(sweName: 'Aldebaran', label: 'Aldebaran',
            traditionalMag: 0.87, nakshatra: Nakshatra.rohini),
  spica(sweName: 'Spica', label: 'Spica',
        traditionalMag: 1.04, nakshatra: Nakshatra.chitra),
  // ... ~60 entries
  galacticCenter(sweName: 'Gal.Center', label: 'Galactic Center',
                 traditionalMag: null, nakshatra: null),
  ;

  final String sweName;         // passes directly to fixstar2Ut
  final String label;           // display
  final double? traditionalMag; // fallback if SWE doesn't return
  final Nakshatra? nakshatra;   // if junction star, which
  const Star({required this.sweName, required this.label,
              this.traditionalMag, this.nakshatra});
}
```

**`SweConfig` addition:**

```dart
@Default(<Star>{}) Set<Star> stars,
```

Default empty so existing charts pay zero cost.

**`EphSnapshot` addition:**

```dart
Map<Star, BodyPosition> starsEcliptic,
Map<Star, BodyPosition> starsEquatorial,
```

Reuse `BodyPosition` — same 6 fields. Don't create `StarPosition` unless
a star-specific field (magnitude override?) appears later.

**`SweFacade.calcAll` addition:** after the `for (final body in
sweConfig.bodies)` loop, add:

```dart
for (final star in sweConfig.stars) {
  final ecl = _swe.fixstar2Ut(star.sweName, jdUt, baseEclFlags);
  final equ = _swe.fixstar2Ut(star.sweName, jdUt, equatorialFlags);
  starsEcl[star] = _fromFixstarResult(ecl);
  starsEqu[star] = _fromFixstarResult(equ);
}
```

`_fromFixstarResult` mirrors `_fromCalcResult`. Check `FixstarResult` type
in swisseph.dart — if field names differ from `CalcResult`, adapter needed.

**Wildcard fallback (libaditya's `%` retry):** if `fixstar2Ut` throws
with `Star.*` from the enum, do NOT retry with `%` — enum names must match
sefstars exactly. For `customStarNames` (Wave 2), do retry.

**Tests:**
- Golden: `aldebaran` at JD 2451545.0 → known ecliptic longitude ~68°59'…
- Pheno/magnitude via `fixstar2Mag` — separate wave if needed.
- Empty `stars` set → no fixstar calls (keep existing tests green).

**Deliverable:** A `SweConfig` with `{Star.aldebaran, Star.spica}` yields
an `EphSnapshot` with correctly populated `starsEcliptic`.

**Est: 1–1.5 days.**

---

### Wave 2 — Custom star names (escape hatch)

**Goal:** Support arbitrary SWE nomen strings for stars not in the enum.

**Files:**

```
options/lib/src/swe_config.dart       # MODIFIED: Set<String> customStarNames
swe/lib/src/eph_snapshot.dart         # MODIFIED: Map<String, BodyPosition>
swe/lib/src/swe_facade.dart           # MODIFIED: custom-name loop w/ % fallback
swe/test/swe_facade_star_test.dart    # MODIFIED: add custom-name + wildcard tests
```

**`SweConfig` addition:**

```dart
@Default(<String>{}) Set<String> customStarNames,
```

**`EphSnapshot` addition:**

```dart
Map<String, BodyPosition> customStarsEcliptic,
Map<String, BodyPosition> customStarsEquatorial,
```

**Wildcard fallback behavior:** mirror `libaditya/stars/fixed_star.py`
init path — if `fixstar2Ut(name, ...)` throws, retry with `name + '%'`.
Log a `fine` on fallback. If second attempt throws, log `warning` and
omit from snapshot (do not crash).

**Tests:**
- `"Sirius"` — exact-match success
- `"Arcturus%"` — explicit wildcard pass-through
- `"Betelgeuse"` — fallback retry success
- Invalid name `"xyz_not_a_star"` — logged warning, omitted from output,
  no exception bubbled.

**Est: 0.5 day.**

---

### Wave 3 — `FixedStar` domain wrapper in `arrow_core`

**Goal:** Pure-Dart wrapper analogous to `Planet`. Derived state
(longitude → sign/nakshatra/pada/varga) accessible without touching SWE.

**Files:**

```
core/lib/src/
  fixed_star.dart           # NEW: FixedStar class
  chart.dart                # MODIFIED: add `fixedStars`, `customFixedStars`
core/test/
  fixed_star_test.dart      # NEW
```

**`FixedStar` shape:**

```dart
class FixedStar {
  final Star? star;                 // null if from customStarNames
  final String name;                // enum label, or custom name
  final BodyPosition eclipticPos;
  final BodyPosition equatorialPos;
  final double? magnitude;          // from fixstar2_mag or Star.traditionalMag
  final Longitude longitude;        // derived: sign/nakshatra/pada via ayanamsa
  final Nakshatra? junctionOf;      // Star.nakshatra if set
  // No MotionState (stars don't retrograde meaningfully on human timescales)
  // No Dignity, no Avasthas — these are graha-specific.
}
```

Two constructor paths: `FixedStar.fromEnum(Star, snapshot)` and
`FixedStar.custom(String name, snapshot)`.

**`Chart` addition:**

```dart
Map<Star, FixedStar> fixedStars;
Map<String, FixedStar> customFixedStars;
```

Built by the chart-assembly code from `EphSnapshot`. If snapshot has
no stars, these are empty maps (not null). Same pattern as current
`planets` map.

**Tests:**
- `FixedStar.fromEnum(Star.aldebaran, snapshot)` resolves into Rohini
  nakshatra under Lahiri ayanamsa.
- `FixedStar.custom('Sirius', snapshot)` populates without crashing when
  pheno fields absent.
- Chart construction with empty star set yields empty `fixedStars`.

**Est: 0.5 day.**

---

### Wave 4 — Magnitude + rise/set (if wanted)

**Goal:** Expose star magnitudes and daily rise/set times.

Split from Wave 1 because it needs extra SWE calls (`fixstar2_mag`,
`riseTrans` per star) and meaningfully increases per-snapshot cost.

**Files:**

```
swe/lib/src/
  star_data.dart            # NEW: StarData (magnitude, rise, set)
  eph_snapshot.dart         # MODIFIED: Map<Star, StarData> starData
  swe_facade.dart           # MODIFIED: call fixstar2Mag + riseTrans per star
options/lib/src/swe_config.dart       # MODIFIED: bool includeStarRiseSet
core/lib/src/fixed_star.dart          # MODIFIED: consume StarData
```

**`StarData` shape:**

```dart
class StarData {
  final double? apparentMagnitude;
  final double? riseJd;              // null if never rises at latitude
  final double? setJd;
  final bool circumpolar;
}
```

**Why gated behind `includeStarRiseSet`:** `riseTrans` per star is
expensive and most use cases (chart placement) don't need it. Opt-in.

**Est: 1 day.**

---

### Wave 5 — 13-constellation true-sidereal ecliptic

**Goal:** Port libaditya's `Ecliptic` + `Constellation` as a derived-only
calc module. This is the "true sidereal 13-sign zodiac" feature — includes
Ophiuchus, uses actual bounding stars to compute sign boundaries.

**Files:**

```
calc/lib/src/zodiac/
  ecliptic13.dart           # NEW: Ecliptic13 — 13-constellation map
  constellation.dart        # NEW: Constellation — boundaries, contents
  constellation_star_map.dart  # NEW: const data — first/last star per constellation
calc/test/zodiac/
  ecliptic13_test.dart      # NEW
  constellation_test.dart   # NEW
options/lib/src/
  zodiac_system.dart        # NEW: enum ZodiacSystem { tropical12, sidereal12, trueSidereal13 }
options/lib/src/calc_config.dart      # MODIFIED: add zodiacSystem field
```

**Algorithm (from `the_stars.py:Ecliptic.__init__`):**

1. Fix ayanamsa to `Ayanamsa.trueSidereal` (sweCode 97) for boundary
   computation, regardless of chart ayanamsa. Boundaries are a property
   of the sky, not the chart.
2. For each of the 13 constellations, look up its `firstStar` and `lastStar`
   (const data in `constellation_star_map.dart`).
3. Compute boundary between adjacent constellations N and N+1:
   `boundary[N] = (lastStar[N].longitude + gap_to_next_first / 2) % 360`
   where `gap_to_next_first = (firstStar[N+1].longitude - lastStar[N].longitude + 360) % 360`.
4. Each `Constellation` holds `beginning`, `end`, `length` in degrees.
5. `Ecliptic13.longitudeToConstellation(double lon)` → `(Constellation,
   degreesInto, percentThrough)`.
6. `Ecliptic13.placeStars(List<FixedStar>)` → fills
   `Constellation.stars`. Skip stars with |ecliptic latitude| > 10°.
7. `Ecliptic13.placePlanets(List<Planet>)` → fills
   `Constellation.planets`.

**`Constellation` shape:**

```dart
class Constellation {
  final ConstellationId id;         // enum: aries..pisces + ophiuchus (13)
  final FixedStar firstStar;
  final FixedStar lastStar;
  final double beginning;           // degrees 0..360
  final double end;
  double get length => (end - beginning + 360) % 360;
  List<Planet> get planets;         // populated by Ecliptic13.placePlanets
  List<FixedStar> get stars;        // populated by Ecliptic13.placeStars
}
```

**`ConstellationId` enum:** 13 entries — the 12 zodiacal + `ophiuchus`.
Ordered by ecliptic longitude of first star.

**Const data — `constellationStarMap`:** which sefstars entries mark
the first (easternmost by longitude) and last (westernmost) star of each
constellation. Port verbatim from `the_stars.py` subclass definitions.
Example: `Taurus.firstStar = Star.elNath` (or whichever libaditya uses),
`lastStar = Star.aldebaran`.

**Important:** these boundary stars MUST be present in the `Star` enum
from Wave 1. Check during enum design that all ~26 required boundary
stars are included.

**Tests:**
- 13 constellations total, boundaries monotonically increasing mod 360.
- Sum of lengths = 360° ± float epsilon.
- Known planet placement: Sun on 2000-01-01 → Sagittarius (or
  Ophiuchus per 13-sign scheme).
- Star self-placement: `Aldebaran` falls into `Taurus`.

**Est: 2 days.**

---

## Total effort

| Wave | Scope | Est |
|------|-------|-----|
| 1 | Star enum + SWE fixstar wiring | 1–1.5d |
| 2 | Custom star names + wildcard fallback | 0.5d |
| 3 | `FixedStar` domain in `arrow_core` | 0.5d |
| 4 | Magnitude + rise/set (opt-in) | 1d |
| 5 | 13-constellation Ecliptic | 2d |
| **Total** | | **~5–6 days** |

---

## Cross-cutting concerns

### Thread safety / isolate behavior

`fixstar2Ut` reads `sefstars.txt` once then caches internally. Isolates
each get their own copy of the SWE C library state (per
`base-addendum.md` §2). Safe for concurrent use. No extra locking.

### JSON round-trip

`Star` enum is `String`-backed via name; `Map<Star, BodyPosition>`
serializes as keyed-by-name map. Existing `freezed` + `json_serializable`
handling should work — verify in Wave 1 tests.

### Performance

Each requested star costs 2 `fixstar2Ut` calls (ecl + equ). Budget:
~0.5ms per call. 60 stars ≈ 60ms. Acceptable for chart generation,
potentially tight for animation/scanning. If Wave 4 (rise/set) is
included, add ~2ms per star for `riseTrans` → 180ms. Consider
`SweConfig.stars = {}` as fast path.

### Logging

Use the existing `Arrow.Swe` logger. Star-specific events at `fine`;
fallback retries at `fine`; missing/invalid star names at `warning`.

### Ayanamsa interplay

Star longitudes from SWE come in whatever frame the current
`setSidMode` is configured for. This is already handled by SweFacade's
ayanamsa setup before the body loop — stars are calculated after bodies
using the same flags, so they inherit the chart's ayanamsa. This is
correct for chart placement.

However, the Ecliptic13 constellation boundaries need ayanamsa 97
(trueSidereal) independently. Solution: Ecliptic13 calls a separate
`SweFacade.computeConstellationBoundaries()` or — better — boundaries
are precomputed as const data for a reference epoch and stored in
`constellation_star_map.dart`. Proper motion of boundary stars is
small enough that epoch-2000 boundaries are good for centuries of charts.
**Recommend: const data, not runtime recomputation.** Saves 26
fixstar calls per snapshot.

If high-precision boundaries are ever needed: add an opt-in flag
`CalcConfig.recomputeConstellationBoundaries` that triggers the runtime
path.

---

## Files to be added or modified (full inventory)

### New files

```
options/lib/src/star.dart
options/lib/src/zodiac_system.dart
swe/lib/src/star_data.dart                  (Wave 4)
core/lib/src/fixed_star.dart
calc/lib/src/zodiac/ecliptic13.dart
calc/lib/src/zodiac/constellation.dart
calc/lib/src/zodiac/constellation_star_map.dart
options/test/star_test.dart
swe/test/swe_facade_star_test.dart
core/test/fixed_star_test.dart
calc/test/zodiac/ecliptic13_test.dart
calc/test/zodiac/constellation_test.dart
```

### Modified files

```
options/lib/arrow_options.dart              (export new)
options/lib/src/swe_config.dart             (stars, customStarNames)
options/lib/src/calc_config.dart            (zodiacSystem — Wave 5)
swe/lib/arrow_swe.dart                      (export star_data — Wave 4)
swe/lib/src/eph_snapshot.dart               (stars maps, customStars maps, starData)
swe/lib/src/swe_facade.dart                 (fixstar loops)
core/lib/src/chart.dart                     (fixedStars, customFixedStars)
```

### Regeneration required

After editing freezed-annotated files:
```
cd arrow/options && dart run build_runner build --delete-conflicting-outputs
cd arrow/swe     && dart run build_runner build --delete-conflicting-outputs
```

---

## Risk register

1. **sefstars.txt drift.** Upstream SWE catalog renames break `Star`
   enum. Mitigation: vendor the `.txt`, regenerate enum from it via
   codegen script (or a Dart `tool/bin/regenerate-star-enum.dart`).
2. **Wildcard fallback unpredictability.** `fixstar2Ut("Betelgeuse%")`
   matches the first star whose trad-name starts with "Betelgeuse" —
   ambiguous for common prefixes. Mitigation: prefer exact nomen names
   in enum; reserve `%` for custom-name use only.
3. **Constellation boundary staleness.** Const boundaries assume
   epoch-2000. Proper motion of boundary stars is sub-arcminute per
   century — negligible for astrology. If a 10,000-year chart is
   requested, re-evaluate.
4. **Ophiuchus controversy.** Some clients won't want 13-sign output.
   `CalcConfig.zodiacSystem` enum gates it cleanly.
5. **Magnitude conventions.** SWE `fixstar2_mag` returns V-band apparent
   magnitude. libaditya sometimes used absolute mag or other bands.
   Verify during Wave 4 — if libaditya conventions diverge from SWE,
   document per-star exceptions.
6. **Name collision with `Body`.** `Body.sun` and `Star.sun` cannot
   coexist cleanly — don't add the Sun to `Star` enum (it's in sefstars
   but arrow already has it as `Body.sun`). Same for Moon.

---

## Done criteria

- `SweConfig(stars: {Star.aldebaran, Star.spica}, customStarNames:
  {"Sirius"})` produces an `EphSnapshot` with all three populated.
- `Chart.fromSnapshot(snapshot)` exposes `fixedStars` and
  `customFixedStars` maps.
- Under `CalcConfig(zodiacSystem: ZodiacSystem.trueSidereal13)`, chart
  includes an `Ecliptic13` object binning planets into 13 constellations.
- All new tests pass; all pre-existing tests remain green.
- `arrow_calc` integration test covers: tropical chart + Aldebaran →
  correct nakshatra; 13-sign chart + Sun on 2000-01-01 → Sagittarius
  (or Ophiuchus per boundary data).
- No runtime cost to existing charts that don't request stars.

---

## When to revisit this plan

- After ephe path plumbing lands (D2 resolved).
- Before Wave 1 starts — re-confirm `Star` enum contents against any
  nakshatra-junction-star work done in the interim.
- Before Wave 5 — re-examine whether 13-sign zodiac is still in scope
  or whether clients only want fixstar lookup.
