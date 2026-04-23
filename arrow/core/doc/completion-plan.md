# Arrow Core Domain Model — Completion Plan

What remains to bring arrow/core from its current state to REPL-ready, then calculation-complete.

## Current State

Substantially built. `Chart(EphSnapshot, CalcConfig)` works. `Varga`/`Rashi` construct planet objects with positions, motion state, synodic state, pheno data. `Longitude` handles 14 varga divisions. `Dignity`, `CharaKaraka`, `Nature`, `NakshatraData`, `SignData` are all complete as data/utilities. 12 test files cover the existing code.

The gaps are wiring (making the domain model ergonomic to use) and a few missing calculations.

## Step 0: Decide on Graha's Composition vs. Inheritance

**The question:** The design doc specified `Planet → Graha → Karaka` inheritance. The implementation has `Graha` wrapping `Planet` via composition (delegating positional access), with `Karaka extends Graha`. This means `Graha` and `Karaka` are not `Planet` in the Dart type system.

**Why it matters:** `chart.planets` should return all bodies as a uniform list. If Karaka is not a Planet, we can't include it without unwrapping. The REPL needs `josh.planets` to work.

**Options:**

A. **Change to inheritance** — `Planet → Graha → Karaka` as designed. Clean type hierarchy. Karaka IS-A Planet. `chart.planets` returns `List<Planet>` containing everything. Breaking change to existing code — Graha goes from composition wrapper to subclass, all delegation boilerplate goes away.

B. **Keep composition, add a shared interface** — define `abstract class CelestialAccessor` (or similar) that both `Planet` and `Graha` implement. `chart.planets` returns `List<CelestialAccessor>`. More Dart-idiomatic than option A, but introduces an extra type. The interface would define the common surface: `longitude`, `sign`, `nakshatra`, `isRetrograde`, `speed`, etc.

C. **Keep composition, expose both maps** — `chart.planets` returns `List<Planet>` (the raw planets), `chart.karakas` returns `List<Karaka>` (the wrappers). Two different views of the same data. Simpler but means `chart.planets` and `chart.sun` return unrelated types.

**Recommendation:** Option A. The composition wrapper was probably a caution against inheriting too much from Planet, but Graha/Karaka already delegate everything Planet has. The inheritance chain is simpler, the types compose naturally, and it matches the design doc. Karaka adds dignity/combustion (on the object), Graha adds Vedic-specific properties (when they exist), Planet has the positional base. If Graha needs to restrict some Planet behavior, override and throw — but in practice there's nothing on Planet that doesn't apply to Graha.

**This decision must be made before anything else.** The typed accessors, dignity wiring, and REPL types all depend on it.

Files affected: `graha.dart`, `karaka.dart`, `varga.dart` (map construction), all tests that construct Graha/Karaka directly.

## Step 1: Typed Accessors on Chart

**Goal:** `chart.sun` returns `Karaka`, `chart.rahu` returns `Graha`, `chart.uranus` returns `Planet`. Also `chart.karakas` → `List<Karaka>`, `chart.grahas` → `List<Graha>`, `chart.planets` → `List<Planet>`, `chart.cusps` → `List<Cusp>`.

**Depends on:** Step 0 (type hierarchy settled).

**What to do:**

Currently `Chart` only exposes `rashi` (the D1 Varga) and `varga(VargaType)`. Named planet accessors live on `Varga`, returning `Planet`. We need:

1. `Varga` already builds `_karakaMap`. Change its named accessors to return typed narrowings: `sun` → `Karaka`, `rahu` → `Graha`, `uranus` → `Planet`. (If step 0 chose inheritance, Karaka IS-A Planet, so this is just narrowing the return type.)

2. Add convenience accessors on `Chart` that delegate to `rashi`:
   ```dart
   Karaka get sun => rashi.sun;
   Graha get rahu => rashi.rahu;
   Planet get uranus => rashi.uranus;
   List<Karaka> get karakas => rashi.karakas;
   List<Graha> get grahas => rashi.grahas;
   List<Planet> get planets => rashi.planets;
   ```

3. Expose cusps on `Chart`:
   ```dart
   List<Cusp> get cusps => rashi.cusps;
   Cusp get ascendant => cusps[0];
   ```

   This requires `Varga` to retain its `Cusp` list (currently constructed but not stored as a field).

4. Expose ascendant and MC. These come from `EphSnapshot.cusps` (indices 0 and 1 in the cusps array, or possibly separate fields). Check what `EphSnapshot` provides and add `chart.asc` and `chart.mc`.

**Files:** `chart.dart`, `varga.dart`, `rashi.dart`.

**Tests:** Add to `chart_test.dart` — verify `chart.sun` returns Karaka with correct longitude, `chart.rahu` returns Graha, `chart.planets` includes all bodies, `chart.cusps` has 12 entries.

## Step 2: Wire Dignity to Karaka

**Goal:** `chart.sun.dignity` works. Returns a `DignityResult` or similar.

**Depends on:** Step 1 (chart.sun returns Karaka).

**What to do:**

`Dignity.calculate()` already exists and works. It takes body, sign, and context. Karaka has access to all of this through its position data.

1. Add a `dignity` getter to `Karaka`:
   ```dart
   DignityResult get dignity => Dignity.calculate(body, sign, ...);
   ```

2. Add an `isCombust` getter to `Karaka`:
   ```dart
   bool get isCombust => Dignity.isCombust(body, longitude, sunLongitude);
   ```

   `isCombust` needs the Sun's longitude. The Karaka doesn't inherently know the Sun's position — it only knows its own. Two options:
   - Pass the Sun's longitude at construction time (Varga already has access to all planets when building the map).
   - Make `isCombust` a method on `Chart` or `Varga` instead: `chart.isCombust(chart.mercury)`.

   The first is cleaner for the REPL (`josh.mercury.isCombust`). Store a `double? _sunLongitude` in Karaka, set during Varga construction. The Sun itself gets `isCombust = false` always.

3. Decide on the return type of `.dignity`. Currently `Dignity.calculate` returns... need to check. It should return a structured result: exalted/debilitated/own/moolatrikona/friend/neutral/enemy. Not just a bool.

**Files:** `karaka.dart`, `dignity.dart` (if return type needs a class), `varga.dart` (pass sun longitude at construction).

**Tests:** Add dignity tests that go through the object model: `chart.sun.dignity` for a chart where the Sun is in Aries (exalted), etc. Combustion tests for Mercury near Sun.

## Step 3: Cusp Nakshatra

**Goal:** `cusp.nakshatra` works, returning the same `Nakshatra` type that planets use.

**Depends on:** Nothing (independent).

**What to do:**

`Cusp` currently has `house`, `longitude` (a `Longitude` object), and `sign`. The `Longitude` object already has a `.nakshatra` getter. So this may be as simple as:

```dart
int get nakshatra => longitude.nakshatra;
int get pada => longitude.pada;
```

Check if `Longitude.nakshatra` returns what we want (a nakshatra index 1-27) and that it works correctly for cusp longitudes.

**Files:** `cusp.dart`.

**Tests:** Add to existing test or new `cusp_test.dart` — verify cusp nakshatra for known longitudes.

## Step 4: D7 Saptamsha — Dedicated Method

**Goal:** Correct D7 calculation instead of falling through to parivritti.

**Depends on:** Nothing (independent).

**What to do:**

D7 (Saptamsha) rule: divide each sign into 7 equal parts (4°17'8.57" each). For odd signs, count from the sign itself. For even signs, count from the 7th sign from it.

Currently falls through to `_parivritti` which does simple cyclic division without the odd/even starting-sign rule.

1. Add `_saptamsha()` method to `Longitude`:
   ```dart
   int _saptamsha() {
     final signNum = (eclipticLongitude ~/ 30).toInt();
     final inSign = eclipticLongitude % 30;
     final division = (inSign / (30 / 7)).floor();
     final isOdd = signNum % 2 == 0; // 0-indexed, so 0=Aries=odd
     final startSign = isOdd ? signNum : (signNum + 6) % 12;
     return (startSign + division) % 12;
   }
   ```

2. Add `VargaType.saptamsha` case to the `_computeVarga` switch.

**Files:** `longitude.dart`.

**Tests:** Add to `longitude_test.dart` or `varga_test.dart` — test D7 for planets in odd and even signs, verify starting-sign rule.

**Reference:** Port from libaditya. Check the Python/C# implementation for the exact rule, especially edge cases at sign boundaries.

## Step 5: D30 Trimsamsha

**Goal:** Correct D30 calculation with unequal divisions.

**Depends on:** Nothing (independent).

**What to do:**

D30 (Trimsamsha) uses unequal divisions within each sign. There are multiple systems:

**Parashara Trimsamsha (standard):**
For odd signs:
- 0°-5°: Mars (Aries)
- 5°-10°: Saturn (Aquarius)
- 10°-18°: Jupiter (Sagittarius)
- 18°-25°: Mercury (Gemini)
- 25°-30°: Venus (Taurus)

For even signs, the order reverses.

**Greek/Western Trimsamsha** has different lords. Need to check which system(s) libaditya supported.

1. Add `_trimsamsha()` method to `Longitude` with the Parashara table.
2. Add `VargaType.trimsamsha` to the switch.
3. If multiple systems are needed, parameterize via `CalcConfig`.

**Files:** `longitude.dart`, possibly `arrow_options` if a new `VargaType` variant is needed.

**Tests:** Test planets at specific degrees in odd and even signs, verify lord assignment matches the Parashara table.

**Reference:** Port from libaditya. The unequal divisions make this the most error-prone varga to implement — thorough edge-case testing at division boundaries.

## Step 6: Nakshatra Ayanamsa

**Goal:** Apply the separate nakshatra ayanamsa correction in `Longitude`.

**Depends on:** Nothing, but needs clarity on what EphSnapshot provides.

**What to do:**

The `nakshatra` getter in `Longitude` has a TODO: "nakAyanamsa offset would be applied here when available from EphSnapshot."

The issue: signs use one ayanamsa (set in `SweConfig`, applied by Swiss Ephemeris before positions reach arrow_core). Nakshatras can use a different ayanamsa (`nakAyanamsa` in the config — default is dhruva/Galactic Center). The sign ayanamsa is already baked into `EphSnapshot` longitudes. The nakshatra ayanamsa needs to be applied as a delta on top.

1. Determine what `EphSnapshot` provides: are longitudes already sidereal (sign ayanamsa subtracted by SWE)? Or tropical? Check `arrow_swe`.

2. If sidereal: the nakshatra offset is `nakAyanamsa - signAyanamsa`, applied only for nakshatra/pada calculation.

3. If tropical: both sign and nakshatra offsets need application, but SWE should be doing the sign one.

4. The delta value needs to come from config or snapshot. Check if `CalcConfig` or `EphSnapshot` carries the necessary ayanamsa values.

5. Apply the correction in `Longitude.nakshatra` and `Longitude.pada`.

**Files:** `longitude.dart`, possibly `arrow_swe` if the snapshot needs to carry ayanamsa metadata.

**Tests:** Calculate nakshatra for a known position with dhruva ayanamsa vs. lahiri ayanamsa, verify the offset produces the correct nakshatra.

**Note:** This is the subtlest item. The dual-ayanamsa system (sign ayanamsa vs. nak ayanamsa) is a core design feature of Arjuna. Getting it wrong silently produces wrong nakshatras. Needs careful testing against libaditya reference values.

## Step 7: Retain Cusps in Varga

**Goal:** `Varga` stores its `Cusp` list as a field, not a local variable.

**Depends on:** Nothing (independent). Required by Step 1.

**What to do:**

Currently `Varga` constructs 12 `Cusp` objects during init but only uses them to populate `signs` (assigning each sign its cusp). The `Cusp` list itself is discarded. Store it:

```dart
late final List<Cusp> cusps;
```

Populate during construction. This is a one-line change plus the field declaration.

**Files:** `varga.dart`.

**Tests:** Verify `varga.cusps.length == 12` and cusps are in house order.

## Implementation Order

```
Step 0: Graha inheritance decision         ← must be first
   │
   ├── Step 7: Retain cusps in Varga       (independent, quick)
   ├── Step 3: Cusp.nakshatra              (independent, quick)
   ├── Step 4: D7 Saptamsha               (independent)
   ├── Step 5: D30 Trimsamsha             (independent)
   ├── Step 6: Nakshatra ayanamsa         (independent, subtle)
   │
   └── Step 1: Typed accessors on Chart    ← depends on Step 0 + Step 7
          │
          └── Step 2: Wire dignity to Karaka  ← depends on Step 1
```

Steps 3, 4, 5, 6, 7 are all independent of each other and of steps 1-2 (except step 7 which step 1 needs). They can be done in parallel or any order.

The REPL-critical path is: **0 → 7 → 1 → 2**. Everything else enriches the model but doesn't block the REPL from working.

## Estimated Scope

| Step | Lines Changed | New Tests | Complexity |
|------|--------------|-----------|------------|
| 0. Graha inheritance | ~150 refactor | Update existing | Medium — structural change, but behavior is identical |
| 1. Typed accessors | ~80 | ~40 | Low — delegation boilerplate |
| 2. Dignity wiring | ~40 | ~30 | Low — calling existing code |
| 3. Cusp nakshatra | ~5 | ~10 | Trivial |
| 4. D7 Saptamsha | ~20 | ~20 | Low |
| 5. D30 Trimsamsha | ~40 | ~30 | Medium — unequal divisions, port from libaditya |
| 6. Nak ayanamsa | ~30 | ~20 | Medium — needs investigation of what EphSnapshot provides |
| 7. Retain cusps | ~5 | ~5 | Trivial |
| **Total** | **~370** | **~155** | |
