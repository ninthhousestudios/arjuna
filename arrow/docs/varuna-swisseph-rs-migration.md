# Migrating Varuna off the C `swisseph` binding

Written for the owner of `varuna/mobile`. This describes a change on Arrow's
side that makes the app's current two-engine setup actively wrong, and what to
do about it.

## TL;DR

Arrow has migrated from the C binding (`package:swisseph`) to the Rust one
(`package:swisseph_rs`). The app currently runs **both** — Arrow's `SweFacade`
for the displayed chart, and a second raw `SwissEph` handle for eclipses,
strength, tropical longitudes, and cross-Tajika.

Today those two share the same native library, so they agree. Once you
re-vendor the new Arrow they no longer will: charts would come from the Rust
engine while eclipses and Digbala still come from the C engine — **different
Delta-T, different ayanamsa evaluation, different rounding, in the same app, on
the same chart.** The divergence is small but real, and it shows up as
features disagreeing with each other rather than as an error.

So the migration isn't optional cleanup; it has to land in lockstep with
re-vendoring Arrow.

The good news: swisseph-rs implements everything you're calling, Arrow now
wraps the two primitives that were awkward to call correctly, and the
statelessness of the Rust engine deletes a whole class of hazard you're
currently working around.

## What Arrow now gives you

Two new/extended typed methods on `SweFacade`, both taking only Arrow types:

```dart
/// Continuous house position 1.0–13.0. Derives ARMC and true obliquity
/// internally. longitude/latitude are in SweConfig.signAyanamsa's frame
/// (i.e. straight from EphSnapshot); tropicalization is handled inside.
/// houseSystem defaults to SweConfig.houseSystem — pass it explicitly for
/// Campanus Digbala.
double housePosition(
  double jdUt,
  Location location,
  SweConfig sweConfig, {
  required double longitude,
  double latitude = 0.0,
  HouseSystem? houseSystem,
});

/// Ayanamsa in arc-degrees. 0.0 for tropical. Dhruva returns the
/// equatorial Ashvini-start offset. Custom codes 97, 99–101 throw.
double getAyanamsaUt(double jdUt, Ayanamsa ayanamsa);
double getAyanamsa(double jdEt, Ayanamsa ayanamsa); // rejects Dhruva: UT-only
```

`housePosition` replaces the manual ARMC + `SE_ECL_NUT` obliquity + `housePos`
sequence in `strength_service.dart:70-73,109`. `getAyanamsaUt` replaces the
`setSidMode(code)` + `getAyanamsaUt(jd)` pairs in `eclipse_calculator.dart:231`
and `eclipse_zone_calculator.dart:471`.

**Eclipse search is deliberately *not* wrapped.** Its parameters are app-owned
and its results are ayanamsa-independent, so wrapping it would re-own an
already well-typed result surface and force every future event-search need
through Arrow. See [direct-swisseph-usage.md](direct-swisseph-usage.md) for the
supported pattern: a direct `swisseph_rs` dependency plus your own `Ephemeris`
built from the same `ephePath`/source Arrow uses.

## The conceptual change: no more process-global state

This is the part that changes how the code is shaped, so it's worth reading
before touching any file.

The C binding mutates process globals — `setEphePath`, `setSidMode`. That is
why `swe_engine.dart` enforces one handle per isolate, why
`strength_service.dart:136-138` documents "never `close()` this," and why
`eclipse_calculator.dart` can call `setSidMode` and then `getAyanamsaUt` as two
separate statements and have it work.

swisseph-rs has none of that. Configuration lives in an `EphemerisConfig`
supplied at `Ephemeris` construction, with per-call `*WithConfig` override
variants. Consequences:

- **`setSidMode` doesn't exist.** Sidereal mode is a construction parameter
  (`EphemerisConfig(siderealMode: …)`) or a per-call override. The
  mutate-then-read pattern must become one call with explicit config — or just
  a call to `facade.getAyanamsaUt(jd, ayanamsa)`.
- **A second handle is safe.** It cannot corrupt Arrow's. The
  "shares process-global ephemeris state" comment in `swe_engine.dart:23-28`
  and `strength_service.dart:136` becomes false and should be deleted, not
  reworded.
- **Ordering constraints go away.** No more "all sign-frame work must finish
  before any nak-frame call."
- **`close()` is a normal lifecycle operation** on handles you constructed. The
  refcounted engine (`Arc`) means any close order is safe. Still don't close a
  handle Arrow owns — that's ordinary ownership, not a global-state hazard.

## API mapping

| C `swisseph` | `swisseph_rs` |
|---|---|
| `SwissEph.find()` / `SwissEph('libswisseph.so')` | `Ephemeris(EphemerisConfig(ephemerisSource:, ephePath:, jplFilename:))` |
| `SwissEph.load(path)` (web) | `await initializeWasm([modulePath])`, then construct `Ephemeris` normally; `loadEpheFile(name, bytes)` for MEMFS ephemeris data |
| `swe.setSidMode(code)` then `swe.getAyanamsaUt(jd)` | `facade.getAyanamsaUt(jd, ayanamsa)`, or a handle built with `siderealMode:` |
| `swe.calcUt(jd, intId, intFlags)` | `eph.calcUt(JdUt1(jd), Body.sun, CalcFlags.swiEph \| CalcFlags.speed)` — typed body + flag set |
| `swe.calcUt(jd, seEclNut, 0).longitude` | `eph.calcUt(jd, Body.eclipticNutation, CalcFlags.none).longitude`, or let `facade.housePosition` do it |
| `swe.houses(jd, lat, lon, hsysInt)` | `eph.housesEx2(JdUt1(jd), flags, geolat, geolon, HouseSystem)` |
| `houses.ascmc[0]` / `ascmc[2]` | `result.ascmc.ascendant` / `.armc` — named fields, no index convention to get wrong |
| `swe.housePos(armc, lat, eps, hsys, lon, lat)` | `facade.housePosition(...)` (preferred), or top-level `housePos(...)` |
| `swe.solEclipseWhenGlob(jd, 0)` | `eph.solEclipseWhenGlob(JdUt1(jd), flags)` → typed `SolarEclipseGlobal` |
| `swe.solEclipseWhere` / `solEclipseHow` | `eph.solEclipseWhere` → `EclipseWhere`; `eph.solEclipseHow` → `EclipseHow` |
| `swe.lunEclipseWhen` / `lunEclipseHow` | `eph.lunEclipseWhen` → `LunarEclipseGlobal`; `eph.lunEclipseHow` → `LunarEclipseHow` |
| `swe.revjul` / `swe.julday` | `revjul` / `julday` with `CalendarType.gregorian` |
| one handle per isolate, never closed | `eph.share()` → token → `Ephemeris.fromShareToken(token)` in the receiving isolate |

Integer body ids and flag ints become typed `Body` and `CalcFlags`; house
system chars become `HouseSystem`. Most of the migration is mechanical
re-typing, and the analyzer will find the call sites for you.

## File-by-file

Nine files import `package:swisseph`. Several others mention it only in
comments documenting that they are deliberately swisseph-free — those need no
change.

### Engine seam — do this first

**`lib/src/services/swe_engine.dart`** — the factory everything funnels
through. Rewrite to return a configured `Ephemeris`. The per-isolate-handle
discipline is no longer forced by native globals, so you can either keep it as
a convention or switch to `share()`/`fromShareToken`. Delete the
process-global-state comments; they are now false.

**`lib/src/services/swe_platform.dart`** + `_io`/`_web` — keep the conditional
export, but the web branch changes from "async `SwissEph.load(modulePath)`" to
"`await initializeWasm(modulePath)` once at startup, then construct handles
synchronously." That may let you simplify the async/sync split at call sites.

### Strength — biggest simplification

**`lib/src/services/strength_service.dart`** — the ARMC/obliquity/`housePos`
block (L66-78, L109) collapses into `facade.housePosition(jd, location,
sweConfig, longitude: lon, houseSystem: HouseSystem.campanus)`.

Two things to preserve carefully:

1. **Keep computing fresh tropical longitudes.** The R1 invariant ("NEVER reuse
   arrow's display-frame longitudes") still holds. Note that `housePosition`
   interprets `longitude` in `SweConfig.signAyanamsa`'s frame — so pass a
   tropical `SweConfig` alongside tropical longitudes and the frames agree.
2. **Your `catch` around `housePos` no longer fires.** In swisseph-rs,
   `house_pos` only errors for the Sunshine and APC house systems, neither of
   which Arrow exposes; Placidus above the polar circle now degrades to a value
   instead of throwing. `housePosition` returns a non-nullable `double`. Your
   `digbalaFromCusp` fallback becomes dead code on that path — verify against
   your polar test cases before deleting it, since the *numbers* in degenerate
   geometry will change where you were previously falling back.

**`lib/src/calc/strength.dart`** is pure Dart (`digbalaFromHousePos`,
`digbalaFromCusp`) — no import, no change beyond whatever the fallback decision
above implies.

### Eclipses

**`lib/src/services/eclipse_calculator.dart`** — the biggest surface: `revjul`,
`julday`, `calcUt`, `setSidMode`+`getAyanamsaUt`, `solEclipseWhenGlob/Where/How`,
`lunEclipseWhen/How`. Mechanical, except: the `setSidMode`/`getAyanamsaUt` pair
at L231-232 must become a single explicit call, and your local eclipse-type
bitflags (`_eclCentral` … `_eclPenumbral`) should be checked against
`EclipseFlags` rather than kept as hand-rolled ints.

**`lib/src/services/eclipse_zone_calculator.dart`** — `houses(...).ascmc[0]`
becomes `housesEx2(...).ascmc.ascendant`, and the L471 `setSidMode` pair gets
the same treatment. This one runs the ascendant probe 1,700+ times per zone
sweep, so it's the place to check performance after switching; construct the
handle once outside the loop.

**`eclipse_service.dart`, `eclipse_zone_service.dart`** — isolate/web
front-ends. The `close()`-in-`finally` blocks stay valid (you constructed those
handles). On native, consider `share()` instead of opening a fresh handle per
`Isolate.run`.

### Tropical longitudes, compat, chart pipeline

**`lib/src/services/tropical_longitudes_service.dart`** — `houses(...).ascmc[0]`
→ `.ascmc.ascendant`; typed bodies and flags. Straightforward.

**`lib/src/pro/tajika_cross/tajika_cross_extraction.dart`** — same shape, 10
bodies including the outers. **`lib/src/pro_registry.dart`** only names
`SwissEph` in two signatures; swap the type.

**`lib/src/services/chart_service.dart`** — the only file importing both Arrow
and raw swisseph. It threads the shared handle into the three side-channel
computations. Once those are migrated, this becomes a handle-type change plus
deleting the "never close while `_facade` is alive" invariant. The
Arrow-vs-raw split itself is still correct and worth keeping: Arrow drives the
displayed chart, raw calls drive the fresh-tropical recomputes that must bypass
the display frame.

## Suggested order

1. `swe_engine.dart` + `swe_platform*` — get a configured `Ephemeris` flowing.
2. `tropical_longitudes_service.dart` — smallest real call site; shakes out the
   typed-body/flag ergonomics.
3. `strength_service.dart` — adopt `facade.housePosition`; settle the fallback
   question.
4. `eclipse_calculator.dart` + `eclipse_zone_calculator.dart` — the bulk.
5. Services and `chart_service.dart` — handle plumbing, delete the stale
   global-state comments.
6. Re-vendor the new Arrow **last**, or at least verify steps 1-5 against it
   before shipping. Landing Arrow first is the window where the two engines
   disagree.

## Verification

The failure mode here is quiet numerical drift, not crashes, so diff numbers
rather than eyeballing screens. Before migrating, capture from the current
build: eclipse times for a few known events, Digbala values for a fixture
chart, and the tropical longitudes for the 7 planets. After migrating, compare.
Expect small Delta-T-scale differences against the *old* build; what matters is
that eclipse-derived and chart-derived values now agree **with each other**.

Worth an explicit check: a chart at high latitude with Placidus, where the old
`housePos` fallback used to trigger.
