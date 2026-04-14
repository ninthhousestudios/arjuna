# Arrow API Reference

Consumer-facing API surface for `arrow_options`, `arrow_swe`, `arrow_core`, `arrow_calc`. All four packages are `publish_to: none` — consumers use `path:` deps.

Generated from source on 2026-04-13 (post Wave 4). Refresh when API changes.

---

## Packages

| Package | Path | Depends on |
|---------|------|------------|
| `arrow_options` | `arrow/options/` | — |
| `arrow_swe` | `arrow/swe/` | `arrow_options`, `swisseph: ^0.4.4` |
| `arrow_core` | `arrow/core/` | `arrow_options`, `arrow_swe` |
| `arrow_calc` | `arrow/calc/` | `arrow_options`, `arrow_swe`, `arrow_core` |

Workspace root: `arrow/pubspec.yaml` (Melos 7.5.0).

---

## Barrel exports

### `arrow_options` — `options/lib/arrow_options.dart`
```dart
export 'src/arrow_options_data.dart';
export 'src/ayanamsa.dart';
export 'src/body.dart';
export 'src/calc_config.dart';
export 'src/circle.dart';
export 'src/dignity_type.dart';
export 'src/house_system.dart';
export 'src/location.dart';
export 'src/presets.dart';
export 'src/swe_config.dart';
export 'src/tradition.dart';
export 'src/varga_type.dart';
export 'src/vedic_config.dart';
```

### `arrow_swe` — `swe/lib/arrow_swe.dart`
```dart
export 'src/asc_mc_points.dart';
export 'src/body_position.dart';
export 'src/eph_snapshot.dart';
export 'src/pheno_data.dart';
export 'src/sun_times.dart';
export 'src/swe_facade.dart';
```

### `arrow_core` — `core/lib/arrow_core.dart`
```dart
export 'src/body_motion.dart';
export 'src/celestial_body.dart';
export 'src/chara_karaka.dart';
export 'src/chart.dart';
export 'src/cusp.dart';
export 'src/dignity.dart';
export 'src/graha.dart';
export 'src/karaka.dart';
export 'src/longitude.dart';
export 'src/nakshatra.dart';
export 'src/nature.dart';
export 'src/nakshatra_data.dart';
export 'src/planet.dart';
export 'src/rashi.dart';
export 'src/sign.dart';
export 'src/sign_data.dart';
export 'src/varga.dart';
export 'src/varga_deities.dart';
```

### `arrow_calc` — `calc/lib/arrow_calc.dart`
```dart
export 'src/vedic/aspect.dart';
export 'src/vedic/baladi.dart';
export 'src/vedic/deeptadi.dart';
export 'src/vedic/jagradadi.dart';
export 'src/vedic/lajjitaadi.dart';
export 'src/vedic/motion.dart';
export 'src/vedic/synodic.dart';
```

---

## Options layer

### `ArrowOptions` — `options/lib/src/arrow_options_data.dart:11`
Freezed top-level config. Pass to `SweFacade.calcAll`.
```dart
const factory ArrowOptions({
  @Default(SweConfig())  SweConfig  sweConfig,
  @Default(CalcConfig()) CalcConfig calcConfig,
}) = _ArrowOptions;
```

### `SweConfig` — `options/lib/src/swe_config.dart:14`
Affects raw ephemeris positions. Changes require new `EphSnapshot`.
```dart
const factory SweConfig({
  @Default({Body.sun, Body.moon, Body.mercury, Body.venus, Body.mars,
            Body.jupiter, Body.saturn, Body.rahu, Body.ketu})
  Set<Body> bodies,
  @Default(Ayanamsa.tropical)    Ayanamsa    signAyanamsa,
  @Default(HouseSystem.campanus) HouseSystem houseSystem,
  @Default(true)  bool trueNode,
  @Default(false) bool topocentric,
}) = _SweConfig;
```

### `CalcConfig` — `options/lib/src/calc_config.dart:16`
Affects derived calculations only. Changes are free — reuse existing `EphSnapshot`.
```dart
const factory CalcConfig({
  @Default(Circle.aditya)     Circle    circle,
  @Default(Ayanamsa.dhruva)   Ayanamsa  nakAyanamsa,
  @Default(true)              bool      nakEquatorial,
  @Default({Tradition.vedic}) Set<Tradition> traditions,
  @Default(VedicConfig())     VedicConfig vedic,
}) = _CalcConfig;
```

### `Location` — `options/lib/src/location.dart:8`
Decimal degrees, altitude in meters.
```dart
const factory Location({
  required double latitude,
  required double longitude,
  @Default(0.0) double altitude,
}) = _Location;
```

### `ArrowPresets` — `options/lib/src/presets.dart:12`
| Preset | Ayanamsa | Houses | Circle | Bodies |
|--------|----------|--------|--------|--------|
| `.ernst`           | tropical | Campanus  | Aditya | default 9 |
| `.lahiriVedic`     | lahiri   | whole-sign | Zodiac | default 9 |
| `.westernTropical` | tropical | Placidus  | Zodiac | 10 (adds Uranus/Neptune/Pluto) |

---

## SWE layer

### `SweFacade` — `swe/lib/src/swe_facade.dart:18`
Synchronous. Construct with a `SwissEph` the caller configured (ephe path if needed). Moshier default needs no `.se1` files.
```dart
class SweFacade {
  SweFacade(SwissEph swe);
  EphSnapshot calcAll(double jdUt, Location location, ArrowOptions options);
}
```

### `EphSnapshot` — `swe/lib/src/eph_snapshot.dart:13`
Freezed + JSON. Immutable bridge between SWE and non-SWE code.
```dart
const factory EphSnapshot({
  required double jdUt,
  required Location location,
  required ArrowOptions options,
  required Map<Body, BodyPosition> bodiesEcliptic,
  required Map<Body, BodyPosition> bodiesEquatorial,
  required Map<Body, PhenoData>    phenoData,    // sparse; no Rahu/Ketu
  required List<double>            cusps,        // 12 entries
  required AscMcPoints             ascmc,
  required SunTimes                sunTimes,
  required double                  ayanamsaValue,
}) = _EphSnapshot;
```

`AscMcPoints` — has `.ascendant` and `.mc` (degrees).
`BodyPosition` — ecliptic/equatorial position + `speedLongitude`.
`PhenoData` — `phaseAngle`, `elongation`, `illumination`, `magnitude`, etc.

---

## Core layer

### `Chart` — `core/lib/src/chart.dart:18`
Wraps `EphSnapshot + CalcConfig`. Eagerly builds D1 (rashi). Divisional charts cached on demand.
```dart
class Chart {
  final EphSnapshot snapshot;
  final CalcConfig  config;
  late final Rashi  rashi;

  Chart(this.snapshot, this.config);
  Varga varga(VargaType type);   // cached
}
```

Body access goes through `chart.rashi` (Rashi extends Varga). No `chart.sun`/etc. shortcut. Angles: `snapshot.ascmc.ascendant/mc`. Cusps: `snapshot.cusps`.

### `Planet` — `core/lib/src/planet.dart:6`
Base for all bodies including outers.
```dart
class Planet extends CelestialBody {
  Planet(Body body, EphSnapshot snapshot, CalcConfig config, VargaType vargaType);
  bool      get isRetrograde;   // position.speedLongitude < 0
  PhenoData? get pheno;         // null for Rahu/Ketu
  // inherited: body, position, longitude (Longitude), sign, nakshatra, ...
}
```

### `Graha` — extends `Planet` — 9 bodies (7 + Rahu + Ketu).
### `Karaka` — `core/lib/src/karaka.dart:7` — extends `Graha` — 7 embodied; carries dignity.
```dart
class Karaka extends Graha {
  double get inSignLongitude;  // 0-30°
}
```

### `Longitude` — `core/lib/src/longitude.dart:34`
Takes both ecliptic + equatorial raw longitudes; applies Circle + nak ayanamsa via `CalcConfig`.
```dart
Longitude(double eclipticLongitude, double equatorialLongitude,
          VargaType vargaType, CalcConfig config);

double get longitude;        // varga-adjusted ecliptic
int    get sign;             // 1-12 (Circle-aware; Aditya shifts +1)
int    get signIndex;        // 0-11
int    get nakshatra;        // 1-27 (equatorial or ecliptic per config)
int    get pada;             // 1-4
double get inSignLongitude;  // 0-30°
double degreesApart(double other);
int    signsApart(int otherSign);
bool   isBetween(double long1, double long2);
```

### `Dignity` — `core/lib/src/dignity.dart`
`DignityType` enum: `exalted, ownSign, moolatrikona, greatFriend, friend, neutral, enemy, greatEnemy, debilitated`. Also `isCombust`.

---

## Calc layer

### `Motion` — `calc/lib/src/vedic/motion.dart`
```dart
enum Direction  { direct, stationary, retrograde }
enum SpeedClass { fast, mean, slow, stationary }

static Direction  direction      (Body body, double speed);   // abs ≤ threshold → stationary
static SpeedClass classifySpeed  (Body body, double speed);   // bands: 0.8× / 1.2× meanDailyMotion
```

### `Synodic` — `calc/lib/src/vedic/synodic.dart`
```dart
enum ElongationCategory {
  conjunction,      // <5°
  nearConjunction,  // 5-20°
  earlyElongation,  // 20-60°
  quadrature,       // 60-120°
  gibbous,          // 120-150°
  opposition;       // ≥150°
  static ElongationCategory of(double elongation);
}

class SynodicState {
  final PhenoData pheno;
  final ElongationCategory category;
  final bool isWaxing;
  factory SynodicState.from(PhenoData pheno);
}

static SynodicState? calcSynodic(Planet planet);  // null for Rahu/Ketu
```

### Avasthas
```dart
// Baladi — age by degree (even signs reverse)
enum BaladiState { bala, kumara, yuva, vriddha, mrita }
static BaladiState Baladi.of(int sign, double inSignDeg);

// Jagradadi — alertness from dignity
enum JagradadiState { jagrat, swapna, sushupti }
static JagradadiState Jagradadi.of(DignityType dignity);

// Deeptadi — mood cascade from dignity/aspect/combustion
enum DeeptadiState { /* 9 states */ }
static DeeptadiState Deeptadi.of(/* Karaka + context */);
```

### `Lajjitaadi` — `calc/lib/src/vedic/lajjitaadi.dart:167`
Relational, bidirectional giving/receiving.
```dart
enum LajjitaadiState { delighted, starved, agitated, thirsty, shamed, healthy, proud }

class LajjitaadiFactor {
  final String  source;     // 'conjunction' | 'aspect' | 'sign' | 'dignity' | 'condition'
  final Body?   planet;
  final Body?   lord;
  final double? strength;   // 0-60
  final String? dignity;    // 'EX' | 'MT'
  final String? detail;
  final Body?   to;
}

class LajjitaadiResult {
  final Map<LajjitaadiState, List<LajjitaadiFactor>> avasthas;    // raw
  final Map<LajjitaadiState, List<LajjitaadiFactor>> receiving;   // from others
  final Map<LajjitaadiState, List<LajjitaadiFactor>> giving;      // to others
}

static Map<Body, LajjitaadiResult> Lajjitaadi.compute({
  required Map<Body, double>       grahaLongitudes,
  required Map<Body, DignityType>  karakaDignities,
  required Map<Body, int>          karakaSigns,
  required int                     lagnaSign,
  required int                     fifthCuspSign,
});
```

### `Aspect` — `calc/lib/src/vedic/aspect.dart`
Degree-based Parashara port. `strength()` (0-60), `isConjunction()`, `doesAspect()`. Mars/Jupiter/Saturn special overrides.

---

## Full consumer flow

```dart
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_calc/arrow_calc.dart';
import 'package:swisseph/swisseph.dart';

final swe     = SwissEph();                              // caller configures ephe path if desired
final facade  = SweFacade(swe);
final options = ArrowPresets.lahiriVedic;                // or custom ArrowOptions(...)
final loc     = Location(latitude: 28.6, longitude: 77.2);
final jdUt    = /* DateTime → Julian Day UT */;

final snap    = facade.calcAll(jdUt, loc, options);      // sync
final chart   = Chart(snap, options.calcConfig);

// D1 access
final sun = chart.rashi.sun;            // Karaka
sun.longitude.sign;                     // 1-12
sun.longitude.nakshatra;                // 1-27
sun.isRetrograde;                       // bool
sun.pheno;                              // PhenoData?

// Angles & cusps
snap.ascmc.ascendant;
snap.cusps[0];

// Divisional
chart.varga(VargaType.navamsha).sun.longitude.sign;

// Calc layer
final dir   = Motion.direction(Body.mercury, sun.position.speedLongitude);
final syn   = Synodic.calcSynodic(chart.rashi.venus);     // SynodicState?
```

---

## Platform notes

- No async init — `calcAll` is synchronous.
- Native FFI via `swisseph` (pub.dev). Flutter consumers bundle the plugin's native library automatically per platform.
- Moshier ephemeris is the SWE default — no `.se1` files needed unless precision or date range requires them.
- All data classes use `freezed` + `json_serializable` — snapshots are serializable for cache/persist.
- `CalcConfig` changes (ayanamsa/circle/tradition) are free: `Chart(sameSnap, newCalcConfig)`. `SweConfig` changes require new `calcAll`.
