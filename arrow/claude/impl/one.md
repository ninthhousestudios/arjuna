# Arrow Implementation Plan

> **CRITICAL EARLY VALIDATION: sweph.dart isolate behavior.** The entire Quiver concurrency model assumes each Dart isolate gets its own C library state via FFI. If sweph.dart uses process-global state, concurrent calculations will interfere with each other and the server architecture must be redesigned. Phase 2A (sweph.dart spike) MUST include a test: two concurrent isolates each calling calcAll() with different inputs, verifying results match sequential calls. Document initialization cost and thread safety findings.

## Guiding Principle

Build thoroughly, intentionally, methodically from the ground up. Every layer, every step includes logging, error handling, and testing AS it is built — not bolted on afterward. Each piece is complete before the next begins.

## Conventions

- **Directory names**: short, no prefix. `arrow/swe/` not `arrow/packages/arrow_swe/`. Dart package name in pubspec.yaml is `arrow_swe`.
- **No `packages/` intermediary**. The `arrow/` directory IS the container.
- **Logging**: `package:logging` everywhere. Logger hierarchy: `Arrow.Swe`, `Arrow.Core`, `Arrow.Calc`.
- **Immutability**: `freezed` + `json_serializable` for all data classes. Enums serialize by name.
- **Testing**: every file gets tests. Not "later" — now.
- **Multi-tradition**: active from the start. CalcConfig is modular — core `CalcConfig` with `Set<Tradition>` + typed configs (`VedicConfig`, `CardsOfTruthConfig`, `HumanDesignConfig`). Cards of Truth and Human Design both need SWE, giving us real traditions to validate the design. See `arrow/claude/arch/universal-options.md`.

## Directory Structure

```
arrow/
├── options/              # arrow_options: enums, SweConfig, CalcConfig, ArrowOptions
├── swe/                  # arrow_swe: sweph.dart bindings, EphSnapshot, facade
├── core/                 # arrow_core: signs, nakshatras, vargas, dignities, domain model
├── calc/                 # arrow_calc: dashas, yogas, shadbala, ashtakavarga, jaimini
├── claude/               # architecture docs, this plan
└── melos.yaml
```

Dependency graph (strict one-way):
```
arrow_options  (no dependencies — enums + freezed config)
     ^
arrow_swe      (depends on: arrow_options, sweph)
     ^
arrow_core     (depends on: arrow_options, arrow_swe [for EphSnapshot type only])
     ^
arrow_calc     (depends on: arrow_options, arrow_core)
```

---

## Phase 1: Foundation

Everything in this phase can be built without sweph.dart. Pure types, pure Dart.

### 1A. Scaffold the monorepo

Create `melos.yaml`, `analysis_options.yaml` at the root. Create the four package directories with `pubspec.yaml` files and barrel exports. Verify `melos bootstrap` works. No code yet — just the skeleton.

```
arrow/
├── melos.yaml
├── analysis_options.yaml
├── options/
│   ├── pubspec.yaml          # name: arrow_options
│   ├── analysis_options.yaml
│   └── lib/
│       └── arrow_options.dart
├── swe/
│   ├── pubspec.yaml          # name: arrow_swe, depends on arrow_options + sweph
│   ├── analysis_options.yaml
│   └── lib/
│       └── arrow_swe.dart
├── core/
│   ├── pubspec.yaml          # name: arrow_core, depends on arrow_options + arrow_swe
│   ├── analysis_options.yaml
│   └── lib/
│       └── arrow_core.dart
└── calc/
    ├── pubspec.yaml          # name: arrow_calc, depends on arrow_options + arrow_core
    ├── analysis_options.yaml
    └── lib/
        └── arrow_calc.dart
```

Done when: `melos bootstrap` succeeds, `melos run analyze` passes on all four packages.

### 1B. arrow_options — All enums and config types

This is the largest type-definition step. Everything here is pure Dart + freezed. No SWE dependency.

**Shared enums** (SWE-level, tradition-agnostic):
```
options/lib/src/enums/
├── ayanamsa.dart              # Ayanamsa enum (~40 values + sweCode getter)
├── house_system.dart          # HouseSystem enum (22 systems + sweCode)
├── house_cusp_mode.dart       # HouseCuspMode (start, middle, end)
├── nakshatra_calc_mode.dart   # NakshatraCalcMode (ecliptic, equatorial, dhruvaEcliptic)
├── rise_mode.dart             # RiseMode (hindu, centerTrue, centerApparent, tipTrue, tipApparent)
├── body.dart                  # Body enum (sun, moon, ..., pluto — with sweId getter) + BodySets
└── tradition.dart             # Tradition enum (vedic, cardsOfTruth, humanDesign, ...)
```

**Vedic-specific enums** (used by VedicConfig):
```
options/lib/src/enums/vedic/
├── circle.dart                # Circle (zodiac, aditya)
├── temp_friendship.dart       # TempFriendshipSource (rashi, varga)
├── ashtakavarga_method.dart   # AshtakavargaMethod (parashara, varahamihira)
├── combustion_method.dart     # CombustionMethod (contemporary, suryaSiddhanta)
├── d10_method.dart            # D10Method (contemporary, parivritti, revForEvenRashis)
├── d24_method.dart            # D24Method (contemporary, parivritti, revForEvenRashis)
├── d30_method.dart            # D30Method (elementLords, rashi30)
├── rashi_aspect_mode.dart     # RashiAspectMode (conventional, elemental, quadrantal)
├── chara_karaka_8th.dart      # CharaKaraka8th (lagna, rahu)
├── adarasha_rashi.dart        # AdarashaRashi (side, front)
├── moon_fatal_degree.dart     # MoonFatalDegreeSource (phaladeepika, saravali)
├── vara_mode.dart             # VaraMode (local, yamaKoti, ujjain)
├── year_length.dart           # YearLength (nakshatra, savana, saura, sidereal, chandraNakshatra, lunarTithi)
└── dasha_source_body.dart     # DashaSourceBody (moon, ...others if any)
```

**Cards of Truth enums** (used by CardsOfTruthConfig):
```
options/lib/src/enums/cards/
├── card_deck.dart             # CardDeck (standard52, extended53)
└── spread_type.dart           # SpreadType (yearly, weekly, lifetime)
```

**Config types** (freezed):
```
options/lib/src/
├── swe_config.dart            # SweConfig (freezed, all SWE-affecting fields + bodies + fixedStars)
├── calc_config.dart           # CalcConfig (freezed, core: Set<Tradition> + optional typed configs)
├── vedic_config.dart          # VedicConfig (freezed, all Vedic-specific fields)
├── cards_config.dart          # CardsOfTruthConfig (freezed, Cards-specific fields)
├── arrow_options.dart         # ArrowOptions (freezed, composes SweConfig + CalcConfig)
├── location.dart              # Location (freezed: latitude, longitude, altitude)
└── presets.dart               # ArrowPresets (static const instances: ernst, cardsOfTruth, ...)
```

**Source for enum values**: cross-reference `soft/back/kala/kalang/Astro/` (C#) and `soft/back/libkala/` (Python) to get the complete list for each enum. The `sweCode` / `sweId` getters on Ayanamsa, HouseSystem, and Body must map to the integer constants that sweph.dart uses.

**Tests**: every enum round-trips through JSON (serialize by name, deserialize back). Every config type tests `copyWith`, `==`, `toJson`/`fromJson`. ArrowPresets all construct without error.

Done when: `dart test` passes in `options/`, all enums have values, all configs have defaults, all presets are defined.

### 1C. Location and shared types

`Location` is used by both arrow_swe and downstream code. It lives in arrow_options.

```dart
@freezed
class Location with _$Location {
  const factory Location({
    required double latitude,
    required double longitude,
    @Default(0.0) double altitude,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
}
```

---

## Phase 2: SWE Exploration and Implementation

### 2A. sweph.dart spike (throwaway)

Before designing EphSnapshot from the API, explore sweph.dart. Write throwaway code in `swe/spike/` (gitignored or deleted after). Answer every question from the original plan:

- Initialization: `Sweph()` constructor, `swe_set_ephe_path`, global state?
- Full function surface: list every function we might call
- Input/output shapes: what flags, what return types, what array shapes
- Error conditions: invalid dates, missing bodies, bad flags
- Cleanup: `swe_close`, resource management
- Ephemeris files: which ones, how loaded, bundled vs downloaded
- True/mean node toggle: which flag, which function
- Topocentric vs geocentric: which flag
- Ayanamsa: global state or per-call? How to get the value for a given JD?
- Body calculation flags: `SEFLG_SPEED`, `SEFLG_SIDEREAL`, etc.
- Hypothetical planets (Uranian): supported? Which IDs?
- Fixed star API: `swe_fixstar_ut` signature and output

Compare outputs to known values from KalaNG and libkala for a reference chart.

**Output**: a written inventory doc at `swe/claude/sweph-inventory.md` documenting every function, its signature, its flags, and its behavior. This becomes the reference for Step 2B.

### 2B. Design EphSnapshot from the inventory

Now that we know exactly what sweph.dart returns, design EphSnapshot to capture it completely. The existing sketches in `claude/arch/` and `claude/struct/` are starting points, but the final design comes from the real API.

EphSnapshot must contain everything SWE returns so downstream code never needs SWE. It stores the `SweConfig` that produced it (not full ArrowOptions — CalcConfig is not SWE's concern).

```
swe/lib/src/
├── snapshot/
│   ├── eph_snapshot.dart      # The main freezed class
│   ├── body_position.dart     # Per-body position data (lon, lat, dist, speeds)
│   ├── asc_mc_points.dart     # Ascendant, MC, ARMC, Vertex, etc.
│   └── sun_times.dart         # Sunrise, sunset for the date/location
```

Tests: EphSnapshot round-trips through JSON. All fields are present and typed.

### 2C. Implement the SWE facade

The public API of arrow_swe. Three tiers:

```
swe/lib/src/
├── facade/
│   └── swe_facade.dart        # The public calculation interface
├── functions/
│   ├── calc_bodies.dart       # Calculate all requested body positions
│   ├── calc_houses.dart       # House cusps + ascmc points
│   ├── calc_ayanamsa.dart     # Ayanamsa value for given JD
│   ├── calc_sun_times.dart    # Sunrise/sunset
│   ├── calc_eclipse.dart      # Solar/lunar eclipse (deferred — stub)
│   └── calc_heliacal.dart     # Heliacal phenomena (deferred — stub)
├── util/
│   ├── julian_day.dart        # DateTime <-> Julian Day conversion
│   └── body_mapping.dart      # Body enum -> sweph integer ID mapping
```

The facade:
```dart
class SweFacade {
  /// The primary API. One call, complete snapshot.
  Future<EphSnapshot> calcAll(double jd, Location loc, SweConfig config);

  /// Edge features — separate because they're expensive and rarely needed.
  Future<double> sunrise(double jd, Location loc, SweConfig config);
  Future<double> sunset(double jd, Location loc, SweConfig config);
  // eclipse, heliacal: stubs for now
}
```

**Isolate safety**: sweph.dart uses dart:ffi to a C library with global state. Each `SweFacade` instance should document whether it's safe to use across isolates or needs one-per-isolate. Test this explicitly.

**Tests**: calculate a reference chart (known date + location) and compare every output field to values from KalaNG and/or libkala. This is the most critical test suite in Arrow — if SWE output is wrong, everything downstream is wrong.

**Fletch connection**: once this step is complete, the Fletch ArrowAdapter can be built. Arrow becomes a comparison target alongside KalaNG and libkala.

Done when: `SweFacade.calcAll()` produces an EphSnapshot that matches KalaNG output for at least 3 reference charts across all body positions, house cusps, ascmc points, and ayanamsa values.

---

## Phase 3: Core Derivation

Everything here is pure Dart. No SWE calls. All functions take EphSnapshot and/or CalcConfig.

### 3A. Sign and Nakshatra placement

The most fundamental derivation. Given a longitude + config, determine sign and nakshatra.

```
core/lib/src/
├── placement/
│   ├── sign.dart              # signOf(longitude, CalcConfig) -> int (1-12)
│   │                          #   handles Circle.aditya vs Circle.zodiac
│   │                          #   handles sidereal approximation (subtract ayanamsa)
│   ├── nakshatra.dart         # nakshatraOf(longitude, CalcConfig) -> NakshatraResult
│   │                          #   nakshatra index (1-27), pada (1-4), degree within
│   └── sign_names.dart        # Sign enum or const list (Aries..Pisces + Aditya names)
```

**Circle logic**: `Circle.aditya` adds 30 degrees before dividing. `Circle.zodiac` starts at 0. See `tropical-aditya-distinction.md`.

**Ayanamsa application for signs**: when `signAyanamsa` is not tropical, subtract the ayanamsa value from EphSnapshot before computing the sign. The ayanamsa value is already in the snapshot.

**Ayanamsa application for nakshatras**: uses `nakAyanamsa` value from EphSnapshot, independent of sign ayanamsa.

Tests: known longitudes -> known signs for both circles. Known longitudes -> known nakshatras and padas. Edge cases at sign/nakshatra boundaries.

### 3B. Varga calculations

Divisional chart placement. Each varga maps a longitude to a sign in that division.

```
core/lib/src/
├── varga/
│   ├── varga.dart             # vargaSign(longitude, division, CalcConfig) dispatcher
│   ├── parivritti.dart        # Generic parivritti formula (works for most divisions)
│   ├── hora.dart              # D2 (special rules)
│   ├── drekkana.dart          # D3
│   ├── chaturthamsha.dart     # D4
│   ├── saptamsha.dart         # D7
│   ├── navamsha.dart          # D9
│   ├── dashamsha.dart         # D10 (3 methods via CalcConfig)
│   ├── dwadashamsha.dart      # D12
│   ├── shodashamsha.dart      # D16
│   ├── vimsamsha.dart         # D20
│   ├── chaturvimsamsha.dart   # D24 (3 methods via CalcConfig)
│   ├── bhamsha.dart           # D27
│   ├── trimsamsha.dart        # D30 (2 methods via CalcConfig)
│   ├── khavedamsha.dart       # D40
│   ├── akshavedamsha.dart     # D45
│   ├── shashtyamsha.dart      # D60
│   ├── varga_deities.dart     # VargaDeity enum + lookup tables (from varga-constants.dart sketch)
│   └── varga_result.dart      # VargaResult (longitude + deity)
```

Source: `soft/back/libkala/libkala/objects/longitude.py` (varga methods) and `soft/back/kala/kalang/Astro/AstroTools.cs`.

Tests: for each varga, test a set of known longitudes against known outputs from KalaNG/libkala. Test variant methods (D10x3, D24x3, D30x2) separately.

### 3C. Rich domain model

Build the Chart, Planet/Graha/Karaka, and Cusp classes. These wrap EphSnapshot + CalcConfig and provide ergonomic accessors. They do NOT call SWE.

```
core/lib/src/
├── model/
│   ├── planet.dart            # Planet base class (all bodies)
│   ├── graha.dart             # Graha extends Planet (+ Rahu/Ketu = 9)
│   ├── karaka.dart            # Karaka extends Graha (7 embodied)
│   ├── cusp.dart              # Cusp (house cusp as longitude point)
│   └── chart.dart             # Chart (entry point: chart.sun.nakshatra, etc.)
```

Every property on these objects calls the functions from 3A/3B. The model is thin — it's a lens over the snapshot, not a calculation engine.

```dart
class Planet {
  final Body body;
  final EphSnapshot _snapshot;
  final CalcConfig _config;

  BodyPosition get position => _snapshot.bodies[body]!;
  double get longitude => position.longitude;
  bool get isRetrograde => position.speedLongitude < 0;
  int get sign => signOf(longitude, _config);
  NakshatraResult get nakshatra => nakshatraOf(longitude, _config);
  VargaResult varga(int division) => vargaSign(longitude, division, _config);
}
```

Tests: construct a Chart from a known EphSnapshot, verify every accessor returns the expected value.

### 3D. Dignity and friendship

Karaka-only properties. Own sign, exaltation, debilitation, moolatrikona. Natural and temporary friendship.

```
core/lib/src/
├── dignity/
│   ├── dignity.dart           # Dignity enum + dignityOf(karaka) -> Dignity
│   ├── tables.dart            # Ownership, exaltation, debilitation tables
│   ├── friendship.dart        # Natural friendship table + temporary friendship calc
│   └── combustion.dart        # Combustion check (uses CombustionMethod from CalcConfig)
```

Source: `soft/back/libkala/libkala/objects/dignity.py` and `soft/back/kala/kalang/Astro/`.

Tests: for each of the 7 karakas in known positions, verify dignity, friendship status, and combustion against KalaNG.

### 3E. Chara karakas

Ranking the 7 (or 8) karakas by longitude within their sign to assign Jaimini karaka roles (Atmakaraka, Amatyakaraka, etc.).

```
core/lib/src/
├── karakas/
│   └── chara_karaka.dart      # assignCharaKarakas(chart) -> Map<CharaKarakaRole, Body>
```

Uses `jaiminiKarakaCount` and `charaKaraka8th` from CalcConfig.

Tests: known chart -> known karaka assignments for both 7 and 8 karaka modes.

---

## Phase 4: Analysis (arrow_calc)

All functions take Chart (or EphSnapshot + CalcConfig) and return typed result objects. Pure Dart.

### 4A. Dashas

Start with Vimshottari — it's the most common and has known reference values.

```
calc/lib/src/
├── dasha/
│   ├── dasha_period.dart      # DashaPeriod (freezed: lord, start, end, level, sub-periods)
│   ├── vimshottari.dart       # calcVimshottari(chart) -> List<DashaPeriod>
│   ├── yogini.dart            # later
│   ├── ashtottari.dart        # later
│   ├── chara.dart             # later
│   └── narayana.dart          # later
```

Source: `soft/back/libkala/libkala/objects/dashas/` and `soft/back/kala/kalang/Astro/Dashas/`.

Uses `nakshatraDashaYear`, `nakshatraDashaSource` from CalcConfig.

Tests: known chart -> known Vimshottari mahadasha sequence and dates, compared to KalaNG.

### 4B. Aspects

```
calc/lib/src/
├── aspect/
│   ├── graha_aspect.dart      # Planetary aspects (graha drishti — fixed rules per planet)
│   └── rashi_aspect.dart      # Sign-based aspects (uses RashiAspectMode from CalcConfig)
```

### 4C. Ashtakavarga

```
calc/lib/src/
├── ashtakavarga/
│   ├── bhinnashtaka.dart      # Individual planet contributions
│   └── sarvashtaka.dart       # Aggregate totals
```

Uses `ashtakavargaMethod` from CalcConfig.

### 4D. Shadbala

Six-component strength calculation. Each component is its own file.

```
calc/lib/src/
├── shadbala/
│   ├── shadbala.dart          # Main: calcShadbala(chart) -> Map<Body, ShadBalaResult>
│   ├── shadbala_result.dart   # ShadBalaResult (freezed: all 6 components + total)
│   ├── sthana_bala.dart       # Positional strength
│   ├── dig_bala.dart          # Directional strength
│   ├── kala_bala.dart         # Temporal strength
│   ├── chesta_bala.dart       # Motional strength
│   ├── naisargika_bala.dart   # Natural strength
│   └── drik_bala.dart         # Aspectual strength
```

### 4E. Yogas

```
calc/lib/src/
├── yoga/
│   ├── yoga.dart              # Yoga result type, registry
│   ├── raja_yoga.dart
│   ├── dhana_yoga.dart
│   ├── pancha_mahapurusha.dart
│   └── nabhasa_yoga.dart
```

### 4F. Jaimini

```
calc/lib/src/
├── jaimini/
│   ├── arudha.dart            # Arudha padas
│   ├── karakamsa.dart         # Karakamsa analysis
│   └── yogada.dart            # Yogada (uses D3 from CalcConfig)
```

### 4G. Avasthas and Tajika

```
calc/lib/src/
├── avastha/
│   ├── baladi.dart
│   ├── jagradadi.dart
│   └── deeptadi.dart
├── tajika/
│   ├── tajika.dart
│   └── sahams.dart
```

---

## Phase Ordering and Parallelism

```
Phase  Step   What                          Depends on        Who
─────  ────   ────                          ──────────        ───
  1     1A    Scaffold monorepo             nothing           either
  1     1B    arrow_options (all enums)     1A                Sonnet (large, mechanical)
  1     1C    Location type                 1A                either (tiny, do with 1B)

  2     2A    sweph.dart spike              1A                Josh (exploratory, needs judgment)
  2     2B    EphSnapshot design            2A                Josh (design from spike findings)
  2     2C    SWE facade implementation     1B + 2B           either

  3     3A    Sign + nakshatra placement    1B                Sonnet (can start during Phase 2)
  3     3B    Varga calculations            3A                Sonnet
  3     3C    Rich domain model             3A                either
  3     3D    Dignity + friendship          3C                Sonnet
  3     3E    Chara karakas                 3D                Sonnet

  4     4A    Vimshottari dasha             3C                either
  4     4B    Aspects                       3C                either
  4     4C    Ashtakavarga                  3C + 4B           either
  4     4D    Shadbala                      3C + 4B           either
  4     4E    Yogas                         3C + 4B           either
  4     4F    Jaimini                       3E + 4B           either
  4     4G    Avasthas + Tajika             3C                either
```

### What can run in parallel

- **1B** (enums) and **2A** (sweph spike) are fully independent. Start both immediately after 1A.
- **3A** (sign/nakshatra) needs only arrow_options, not arrow_swe. It can start as soon as 1B is done, even while Phase 2 is still in progress.
- **3B** (vargas) can follow 3A immediately.
- **3D**, **3E** can proceed while 2C is still being finished — they don't need SWE.
- Phase 4 steps (4A-4G) are mostly independent of each other once 3C exists.

### The critical path

```
1A -> 2A -> 2B -> 2C -> [integration testing with real EphSnapshot]
1A -> 1B -> 3A -> 3B -> 3C -> 4A
```

The longest pole is the SWE path (2A-2C) because it requires exploration and judgment. The pure-Dart path (1B -> 3A -> 3C) can race ahead and be ready to consume EphSnapshot the moment it exists.

---

## Fletch Integration Points

Fletch validates Arrow against KalaNG and libkala. Key integration moments:

1. **After 2C** (SWE facade complete): build the Fletch ArrowAdapter. Arrow becomes a comparison target. Run SWE-level comparisons (positions, cusps, ayanamsa) against KalaNG.

2. **After 3A-3B** (sign/nakshatra/varga): extend the ArrowAdapter to include derived placements. Compare sign, nakshatra, and varga outputs.

3. **After 3D** (dignity): add dignity to the comparison schema. This is where tradition-specific divergence is most likely.

4. **After 4A** (Vimshottari): add dasha comparison. Dates must match exactly.

5. **After 4D** (Shadbala): add shadbala comparison. This is the deepest numerical comparison — six components per planet.

Fletch steps 1-5 (core contracts, diff engine, execution, schema, KalaNG adapter) can proceed in parallel with all Arrow work. The ArrowAdapter gates on Arrow producing output, but everything else is independent.

---

## Sonnet Guidance

Steps marked "Sonnet" are well-defined, mechanical, and have clear source material. For each:

1. **Read the source material first.** Every enum, every calculation has a reference in KalaNG (C#) and/or libkala (Python). Don't invent — port.
2. **Match the source exactly.** If KalaNG has 22 house systems, Arrow has 22 house systems. Same names, same codes, same order isn't required but same completeness is.
3. **Write tests alongside code.** Not after. The test file is created in the same step as the implementation file.
4. **Log at appropriate levels.** `fine` for per-calculation details, `info` for facade-level operations, `warning` for fallbacks or approximations, `severe` for errors.
5. **Ask when uncertain.** If the C# and Python sources disagree, or if a design decision isn't covered here, surface it rather than guessing.

### What Sonnet should NOT do

- Design EphSnapshot (that comes from the sweph.dart spike — Step 2A/2B)
- Make architectural decisions about SWE isolation, global state, or threading
- Add traditions beyond Vedic, Cards of Truth, and Human Design (build those three first)
- Add features not in the plan (no "while I'm here" improvements)
- Create abstract base classes or generic frameworks for things that have one implementation

---

## Reference Charts

Maintain a set of reference charts with known-good values from KalaNG. These are the ground truth for all tests.

```
arrow/test_data/
├── reference_charts.json      # Birth data + expected outputs
└── README.md                  # What each chart tests and why it was chosen
```

Minimum set:
1. **Ernst's reference chart** — the primary test case, matches Kala desktop exactly
2. **Equator chart** — tests edge cases in house calculation
3. **High latitude chart** — tests house system behavior near poles
4. **Boundary chart** — planet near sign/nakshatra boundary (tests rounding)
5. **Retrograde chart** — multiple retrograde planets (tests speed/direction)

KalaNG values come from `KalaEngine.Api` (already running, `POST /api/chart`). Extract and store as JSON fixtures.

---

## Done Criteria

Arrow Phase 1-3 is complete when:
- `ArrowPresets.aditya` produces a Chart that matches KalaNG for all reference charts
- `chart.sun.sign`, `chart.sun.nakshatra`, `chart.sun.dignity` all return correct values
- All 16 vargas produce correct placements for all bodies
- Chara karakas match KalaNG assignments
- Fletch ArrowAdapter passes SWE-level comparison against KalaNG

Arrow Phase 4 is complete when:
- Vimshottari mahadasha dates match KalaNG
- Shadbala components match KalaNG (within tolerance)
- Ashtakavarga totals match KalaNG
- Aspect detection matches KalaNG
