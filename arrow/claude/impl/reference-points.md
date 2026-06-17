# Arrow Reference Points — Implementation Plan

Add barycentric + heliocentric position support to arrow.

Source design doc: `docs/reference-points.md` — has motivation, API shape,
and verified reference values. This file is the execution plan.

---

## Assumptions going in

- Design decisions in `docs/reference-points.md` are accepted as-is
  (ecliptic-only output, no equatorial/houses/pheno, fail-fast on
  Moshier+barycentric, `SwissEph`-only for extraFrames).
- SWE constants already present in `swisseph.dart`:
  `seFlgBaryCtr = 16384`, `seFlgHelCtr = 8`. No binding work needed.
- `SweFacade` now takes `ephePath` — required for any extra-frame work
  since Moshier can't do barycentric (and heliocentric isn't worth
  gating separately — plan requires `swissEph` or `jplEph` when
  `extraFrames` is non-empty; simpler rule).
- Ephe files include `sepl_*.se1` + `semo_*.se1`, not just asteroid
  files. Skybreath consequence (bundle size) is a skybreath concern,
  not arrow's.

## What we are NOT building

- Equatorial variants of bary/helio positions.
- Bary/helio houses, ascmc, pheno, synodic state, dignity, avasthas.
- Earth as a Body.
- Per-frame ayanamsa override (current ayanamsa applies to the requested
  frame, which is the correct semantic).
- Per-body frame selection (no "bary Jupiter but geo Saturn"). Whole
  chart gets the same extraFrames set.

---

## Open decisions (resolved, for the record)

**R1. `Longitude`-wrapping convenience getters vs. raw `double?`.**
Design doc proposes `CelestialBody.barycentricLongitude: Longitude?`.
But `Longitude(raw, rawEqu, varga, calcConfig)` needs an equatorial
counterpart, which we are **not** computing for extra frames. Consumer
code in the design doc passes `0` — meaningful for rashi but may corrupt
varga math that keys off equatorial.

**Decision:** convenience getters on `CelestialBody` return raw
`BodyPosition?` (which exposes `.longitude`, `.distance`, speeds).
Callers can build a `Longitude` themselves if they know equatorial
is irrelevant for their use case. This keeps arrow honest about what
it computed.

Optional thin helper `barycentricRashiLongitude: Longitude?` that
passes `0.0` for equatorial and only supports `VargaType.rashi`;
skybreath's actual use case. Include in Wave 3 — explicit rather than
implicit.

**R2. Sun in heliocentric frame.**
Sun is always at origin (0,0,0) helio. Design doc says "skip
automatically." Implementation: check `body == Body.sun && frame ==
heliocentric` in the facade loop, skip the SWE call, omit from the
output map. Null-on-lookup for consumers.

**R3. Rahu/Ketu in extra frames.**
Nodes are mathematical points (barycenter-of-Earth-Moon-system
derivatives). SWE computes them in any frame. Ketu = Rahu + 180° rule
should still hold in other frames. Implementation: do the same
"compute Rahu, mirror to Ketu" trick per frame, not a direct SWE call
for Ketu.

**R4. Moshier+barycentric error message.**
Design doc says fail fast before calling SWE. Error type: `ArgumentError`
with a message naming both the frame and the source. Throws from
`calcAll` (not from `SweFacade` constructor), because `SweConfig` is
per-call.

---

## Wave structure

Three waves. Total: ~1.5 days.

### Wave 1 — Options layer

**Goal:** `ReferencePoint` enum + `SweConfig.extraFrames` field land,
regenerate freezed/json, round-trip in presets.

**Files:**

```
options/lib/src/
  reference_point.dart      # NEW: enum with 3 values
  swe_config.dart           # MODIFIED: add extraFrames field
options/lib/arrow_options.dart         # MODIFIED: export new
options/test/
  reference_point_test.dart # NEW: enum size, label
  configs_test.dart         # MODIFIED: add extraFrames JSON round-trip
```

**`ReferencePoint` enum shape:**

```dart
enum ReferencePoint {
  geocentric(label: 'Geocentric'),
  barycentric(label: 'Barycentric'),
  heliocentric(label: 'Heliocentric');

  final String label;
  const ReferencePoint({required this.label});
}
```

No `sweFlag` field on the enum — the flag is a `SweFacade`-layer
concern, not an options concern. Keep the options layer SWE-agnostic.

**`SweConfig` addition:**

```dart
@Default(<ReferencePoint>{}) Set<ReferencePoint> extraFrames,
```

Default empty → no behavior change for existing callers. Geocentric
is always computed regardless (not included in the set).

**Constructor validation:** none in the options layer. Validation
(Moshier+bary rejection) lives in `SweFacade.calcAll` — it's a
runtime capability issue, not a config shape issue.

**Regen:** `swe_config.freezed.dart` + `swe_config.g.dart` need
`build_runner build --delete-conflicting-outputs` in `arrow/options`.

**Tests:**
- Enum has 3 values.
- Default `SweConfig().extraFrames` is empty.
- `SweConfig(extraFrames: {ReferencePoint.barycentric})` round-trips JSON.
- `ReferencePoint.geocentric` is never expected to appear in the set
  (it's the implicit default) but the enum permits it. Don't validate
  — keep the layer dumb.

**Est: 0.25 day.**

---

### Wave 2 — SWE layer

**Goal:** `EphSnapshot` carries optional per-frame position maps;
`SweFacade.calcAll` populates them when requested; Moshier+barycentric
fails fast.

**Files:**

```
swe/lib/src/
  eph_snapshot.dart         # MODIFIED: add optional bary/helio maps
  swe_facade.dart           # MODIFIED: extra-frame loop + guard
swe/test/
  swe_facade_test.dart      # MODIFIED: construction with new fields
  reference_points_test.dart # NEW: integration tests (require ephe path)
```

**`EphSnapshot` additions:**

```dart
@Default(null) Map<Body, BodyPosition>? bodiesEclipticBarycentric,
@Default(null) Map<Body, BodyPosition>? bodiesEclipticHeliocentric,
```

Nullable (not empty-map default) to distinguish "wasn't requested" from
"requested but no bodies". Empty non-null would also work but nullable
matches the doc.

**`SweFacade.calcAll` changes:**

1. **Early guard** (before setSidMode / base flags):
   ```dart
   if (sweConfig.extraFrames.contains(ReferencePoint.barycentric) &&
       sweConfig.ephemerisSource == EphemerisSource.moshier) {
     throw ArgumentError(
       'barycentric positions unsupported under Moshier; '
       'use EphemerisSource.swissEph or .jplEph',
     );
   }
   ```
2. **Pre-allocate output maps** when their frame is requested:
   ```dart
   final baryEcl = sweConfig.extraFrames.contains(ReferencePoint.barycentric)
       ? <Body, BodyPosition>{} : null;
   final helioEcl = sweConfig.extraFrames.contains(ReferencePoint.heliocentric)
       ? <Body, BodyPosition>{} : null;
   ```
3. **Inside the body loop, after existing geo calls**:
   ```dart
   if (baryEcl != null && body != Body.ketu) {
     final ecl = _swe.calcUt(jdUt, sweId, baseEclFlags | seFlgBaryCtr);
     baryEcl[body] = _fromCalcResult(ecl);
     if (body == Body.rahu) rahuBaryEcl = _fromCalcResult(ecl);
   }
   if (helioEcl != null && body != Body.ketu && body != Body.sun) {
     final ecl = _swe.calcUt(jdUt, sweId, baseEclFlags | seFlgHelCtr);
     helioEcl[body] = _fromCalcResult(ecl);
     if (body == Body.rahu) rahuHelioEcl = _fromCalcResult(ecl);
   }
   ```
   Sun skipped in helio per R2.
4. **Ketu mirror per frame** after the loop:
   ```dart
   if (baryEcl != null && sweConfig.bodies.contains(Body.ketu) && rahuBaryEcl != null) {
     baryEcl[Body.ketu] = _ketuFrom(rahuBaryEcl);
   }
   // same for helio
   ```
5. **Snapshot construction**: pass `baryEcl` / `helioEcl` through.

**Tests (`reference_points_test.dart`):**

These are **integration tests** — they need a real SWE library + ephe
files. Match existing `swe_facade_test.dart` pattern; guard the test
group behind a check for `ARROW_EPHE_PATH` env or a hardcoded path
that skips if absent.

1. **Barycentric Sun present under SwissEph.** Geocentric ≠ bary longitude.
   Distance < 0.01 AU. Reference numbers from design doc §"Verified numbers":
   ```
   JD 2026-04-14 12:00 UTC = 2461145.0
   bary_sun_tropical ≈ 247.21°
   distance ≈ 0.00594 AU
   ```
2. **Moshier + barycentric throws.** `ArgumentError`, message mentions
   both "barycentric" and "Moshier".
3. **Heliocentric omits Sun.** `bodiesEclipticHeliocentric![Body.sun]`
   is null / absent.
4. **Ayanamsa composition.** Tropical and Lahiri-sidereal runs —
   `(bary_trop - bary_sid) mod 360 ≈ (geo_trop - geo_sid) mod 360`
   within 1e-6°.
5. **Ketu mirror.** `baryKetu.longitude == (baryRahu.longitude + 180) % 360`.
6. **Default config unchanged.** `SweConfig()` snapshot has
   `bodiesEclipticBarycentric == null` and `bodiesEclipticHeliocentric
   == null`. No perf regression for existing charts.

**Regen:** `eph_snapshot.freezed.dart` + `.g.dart` in `arrow/swe`.

**Est: 0.75 day.**

---

### Wave 3 — Core convenience getters

**Goal:** `CelestialBody.barycentricPosition` / `heliocentricPosition`
and a typed `barycentricRashiLongitude`.

**Files:**

```
core/lib/src/celestial_body.dart       # MODIFIED: add getters
core/test/celestial_body_test.dart     # MODIFIED: null-when-absent, presence-when-set
```

**Getter additions:**

```dart
BodyPosition? get barycentricPosition =>
    snapshot.bodiesEclipticBarycentric?[body];

BodyPosition? get heliocentricPosition =>
    snapshot.bodiesEclipticHeliocentric?[body];

/// Rashi-only longitude in the barycentric frame.
///
/// Equatorial longitude is passed as 0.0 — varga calculations beyond
/// rashi that depend on equatorial will give wrong answers. Use the
/// raw [barycentricPosition] and construct [Longitude] manually if you
/// need more than sign/degree-in-sign.
Longitude? get barycentricRashiLongitude {
  final pos = barycentricPosition;
  if (pos == null) return null;
  return Longitude(pos.longitude, 0.0, VargaType.rashi, config);
}

Longitude? get heliocentricRashiLongitude { /* symmetric */ }
```

Return `null` (not throw) when the frame wasn't requested, per R in
design doc §open questions.

**Tests:**
- `CelestialBody` over snapshot with no extra frames → both getters null.
- Over snapshot with barycentric only → bary getter populated, helio null.
- `barycentricRashiLongitude.sign` matches skybreath's expected sign
  for a known fixture.

**Est: 0.25 day.**

No `Planet` / `Graha` / `Karaka` specialization needed — they extend
`CelestialBody` and inherit the getters.

---

## Cross-cutting concerns

### Performance

Each extra frame adds one `swe_calc_ut` call per body. 9 bodies × 2
frames = 18 extra calls if both bary and helio requested. ~9ms added
per snapshot (0.5ms/call). Acceptable for chart generation, tight for
animation. Callers who don't need extra frames pay zero.

### JSON round-trip

`EphSnapshot` is freezed — nullable maps round-trip naturally. `Set<
ReferencePoint>` on SweConfig serializes as a JSON array of enum names.
Verify in Wave 1 test.

### Logging

Existing `Arrow.Swe` logger. `fine` when computing extra-frame body;
`info` one-liner at facade entry naming which frames are active; the
fail-fast `ArgumentError` speaks for itself.

### Layer boundaries

`ReferencePoint` lives in options (pure enum). SWE flag mapping lives
in swe_facade (imports `swisseph`). No SWE import in options. Same
pattern as `EphemerisSource` / `ephemerisFlag`.

### Backwards compatibility

Default `SweConfig()` has `extraFrames = {}` → existing behavior
unchanged. All existing tests should stay green with zero edits.
Presets (`ArrowPresets.aditya` etc.) do not need updating unless we
want a preset to enable barycentric — defer.

---

## Files inventory

### New files

```
options/lib/src/reference_point.dart
options/test/reference_point_test.dart
swe/test/reference_points_test.dart
```

### Modified files

```
options/lib/arrow_options.dart
options/lib/src/swe_config.dart
options/test/configs_test.dart
swe/lib/src/eph_snapshot.dart
swe/lib/src/swe_facade.dart
swe/test/swe_facade_test.dart
core/lib/src/celestial_body.dart
core/test/celestial_body_test.dart
```

### Regen required

```
cd arrow/options && dart run build_runner build --delete-conflicting-outputs
cd arrow/swe     && dart run build_runner build --delete-conflicting-outputs
```

---

## Risk register

1. **Ephe files incomplete.** `seas_*` alone isn't enough for
   barycentric — needs `sepl_*` + `semo_*`. If skybreath's bundle
   strategy lags, Wave 2 integration tests fail with an opaque
   "file not found" from SWE. Mitigation: detect missing files in the
   test setup and skip with a clear reason, rather than hard-failing.
2. **Sun helio skip trips a caller.** If a consumer writes
   `snapshot.bodiesEclipticHeliocentric![Body.sun]!` they crash with
   null-check. Mitigation: document in the `CelestialBody` getter and
   in `docs/reference-points.md`. Null-return pattern already flags it.
3. **Longitude with equatorial=0.** `barycentricRashiLongitude` is
   a leaky convenience. Vedic varga systems that use equatorial
   longitude (hora variants?) will give wrong answers if someone
   copies the pattern. Mitigation: restrict the convenience to
   `VargaType.rashi` in the getter; doc-comment the leak.
4. **`SEFLG_BARYCTR` + topocentric flag interaction.** Topocentric is
   observer-at-surface; barycentric is observer-at-SSB. They're mutually
   exclusive in meaning. SWE behavior: unclear. Mitigation: test
   with `topocentric: true` + `extraFrames: {barycentric}` — if SWE
   returns nonsense, add a guard that strips `seFlgTopoCtr` from the
   bary-frame flag composition (topo applies to geo only). Fix in
   Wave 2 if observed.
5. **Rahu/Ketu in helio frame.** Not astronomically meaningful (nodes
   are defined w.r.t. Earth's orbit). SWE still returns values. Not
   fixing; consumer's problem if they query. Document.

---

## Done criteria

- `SweConfig(extraFrames: {ReferencePoint.barycentric})` under
  `EphemerisSource.swissEph` produces an `EphSnapshot` where
  `bodiesEclipticBarycentric[Body.sun]` matches the verified
  numbers in `docs/reference-points.md` §"Verified numbers".
- Same config under `EphemerisSource.moshier` throws `ArgumentError`.
- `bodiesEclipticHeliocentric[Body.sun]` absent when helio requested.
- `CelestialBody.barycentricPosition` returns null when frame not
  configured, populated when it is.
- All pre-existing tests remain green with zero edits.
- Skybreath's barycentric-Sun use case works end-to-end with the
  consumer example in `docs/reference-points.md` §"Consumer example".

---

## When to revisit

- If a consumer asks for equatorial bary/helio (straightforward add
  — mirror the ecliptic scaffolding).
- If skybreath needs per-body frame selection (non-trivial — would
  need a redesign of `extraFrames` as `Map<Body, Set<ReferencePoint>>`
  or similar).
- If Moshier gains barycentric support upstream (check SWE CHANGELOG
  at bump time; relax the fail-fast guard if so).
