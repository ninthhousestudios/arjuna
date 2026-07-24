# Arrow API Reference

Consumer-facing API surface for `arrow_options`, `arrow_swe`, `arrow_core`, `arrow_calc`. All four packages are `publish_to: none` — consumers use `path:` deps.

Generated from source on 2026-07-24 (post swisseph_rs migration). Refresh when API changes.

---

## Packages

| Package | Path | Depends on |
|---------|------|------------|
| `arrow_options` | `arrow/options/` | — |
| `arrow_swe` | `arrow/swe/` | `arrow_options`, `swisseph_rs: ^0.2.0` |
| `arrow_core` | `arrow/core/` | `arrow_options`, `arrow_swe` |
| `arrow_calc` | `arrow/calc/` | `arrow_options`, `arrow_swe`, `arrow_core` |

Workspace root: `arjuna/pubspec.yaml` (Dart pub workspace, Melos 7.5.0 for scripts). `arrow/pubspec.yaml` is a container package only.

---

## Barrel exports

### `arrow_options` — `options/lib/arrow_options.dart`
```dart
export 'src/arrow_options_data.dart';
export 'src/ayanamsa.dart';
export 'src/being.dart';
export 'src/being_type.dart';
export 'src/body.dart';
export 'src/calc_config.dart';
export 'src/circle.dart';
export 'src/constellation_id.dart';
export 'src/dasha_year_length.dart';
export 'src/dignity_type.dart';
export 'src/ephemeris_source.dart';
export 'src/hora.dart';
export 'src/house_system.dart';
export 'src/location.dart';
export 'src/presets.dart';
export 'src/rashi_aspect_mode.dart';
export 'src/reference_point.dart';
export 'src/star.dart';
export 'src/swe_config.dart';
export 'src/tradition.dart';
export 'src/varga_type.dart';
export 'src/vedic_config.dart';
export 'src/zodiac_system.dart';
```

### `arrow_swe` — `swe/lib/arrow_swe.dart`
```dart
export 'src/asc_mc_points.dart';
export 'src/body_position.dart';
export 'src/cardinal_points.dart';
export 'src/eph_snapshot.dart';
export 'src/ephemeris_flag.dart';
export 'src/julian_day.dart';
export 'src/pheno_data.dart';
export 'src/star_data.dart';
export 'src/star_position.dart';
export 'src/sun_times.dart';
export 'src/swe_facade.dart';
```

### `arrow_core` — `core/lib/arrow_core.dart`
```dart
export 'src/being_data.dart';
export 'src/being_uncertainty.dart';
export 'src/body_motion.dart';
export 'src/celestial_body.dart';
export 'src/chara_karaka.dart';
export 'src/chart.dart';
export 'src/cusp.dart';
export 'src/fixed_star.dart';
export 'src/dignity.dart';
export 'src/karaka.dart';
export 'src/longitude.dart';
export 'src/motion_state.dart';
export 'src/nakshatra.dart';
export 'src/nature.dart';
export 'src/nakshatra_data.dart';
export 'src/planet.dart';
export 'src/rashi.dart';
export 'src/sky_object.dart';
export 'src/time_uncertainty.dart';
export 'src/sign.dart';
export 'src/sign_data.dart';
export 'src/varga.dart';
export 'src/varga_deities.dart';
export 'src/varga_math.dart';
```

### `arrow_calc` — `calc/lib/arrow_calc.dart`
```dart
export 'src/being_uncertainty.dart';
export 'src/vedic/aspect.dart';
export 'src/vedic/baladi.dart';
export 'src/vedic/deeptadi.dart';
export 'src/vedic/jagradadi.dart';
export 'src/vedic/jaimini.dart';
export 'src/vedic/lajjitaadi.dart';
export 'src/vedic/nabhasa_yoga.dart';
export 'src/vedic/rashi_aspect.dart';
export 'src/vedic/shadbala.dart';
export 'src/vedic/shadbala_const.dart';
export 'src/vedic/vimshottari.dart';
export 'src/vedic/panchanga/karana.dart';
export 'src/vedic/panchanga/nakshatra.dart';
export 'src/vedic/panchanga/next.dart';
export 'src/vedic/panchanga/tithi.dart';
export 'src/vedic/panchanga/vara.dart';
export 'src/vedic/panchanga/vedanga_jyotisha.dart';
export 'src/vedic/panchanga/yoga.dart';

export 'src/zodiac/boundary_stars.dart';
export 'src/zodiac/build_ecliptic13.dart';
export 'src/zodiac/constellation.dart';
export 'src/zodiac/constellation_star_map.dart';
export 'src/zodiac/ecliptic13.dart';
```

---

## Options layer

### `ArrowOptions` — `options/lib/src/arrow_options_data.dart:15`
Freezed top-level config bundling both halves of the config boundary.
`SweFacade.calcAll` takes the `sweConfig` half; `Chart` takes the `calcConfig` half.
```dart
const factory ArrowOptions({
  @Default(SweConfig())  SweConfig  sweConfig,
  @Default(CalcConfig()) CalcConfig calcConfig,
}) = _ArrowOptions;

void validate();   // throws ArgumentError: Dhruva nakAyanamsa needs nakEquatorial
```

### `SweConfig` — `options/lib/src/swe_config.dart:20`
Affects raw ephemeris positions. Changes require a new `EphSnapshot`.
```dart
const factory SweConfig({
  @Default({Body.sun, Body.moon, Body.mercury, Body.venus, Body.mars,
            Body.jupiter, Body.saturn, Body.rahu, Body.ketu})
  Set<Body> bodies,
  @Default(Ayanamsa.tropical)          Ayanamsa    signAyanamsa,
  @Default(HouseSystem.campanus)       HouseSystem houseSystem,
  @Default(true)  bool trueNode,
  @Default(false) bool topocentric,
  @Default(EphemerisSource.swissEph)   EphemerisSource      ephemerisSource,
  @Default(<ReferencePoint>{})         Set<ReferencePoint>  extraFrames,
  @Default(<Star>{})                   Set<Star>            stars,
  @Default(<String>{})                 Set<String>          customStarNames,
  @Default(Ayanamsa.dhruva)            Ayanamsa             nakAyanamsa,
}) = _SweConfig;
```
`nakAyanamsa` lives here (not on `CalcConfig`) because the nakshatra-frame
longitudes are computed by SWE and baked into the snapshot.
`extraFrames` requests barycentric/heliocentric positions; barycentric is
rejected under Moshier.

### `CalcConfig` — `options/lib/src/calc_config.dart:19`
Affects derived calculations only. Changes are free — reuse existing `EphSnapshot`.
```dart
const factory CalcConfig({
  @Default(Circle.aditya)              Circle       circle,
  @Default(true)                       bool         nakEquatorial,
  @Default({Tradition.vedic})          Set<Tradition> traditions,
  @Default(ZodiacSystem.tropical12)    ZodiacSystem zodiacSystem,
  @Default(VedicConfig())              VedicConfig  vedic,
}) = _CalcConfig;
```
`nakEquatorial` picks which pre-computed nak-frame map the domain objects read
(`bodiesNakEquLon` vs `bodiesNakEclLon`) — it does not re-run SWE.

### `Location` — `options/lib/src/location.dart:11`
Decimal degrees, altitude in meters.
```dart
const factory Location({
  required double latitude,
  required double longitude,
  @Default(0.0) double altitude,
}) = _Location;
```

### `ArrowPresets` — `options/lib/src/presets.dart:15`
| Preset | Sign ayanamsa | Nak ayanamsa | Houses | Circle | Bodies |
|--------|---------------|--------------|--------|--------|--------|
| `.aditya`          | tropical | dhruva (equatorial) | Campanus   | Aditya | default 9 |
| `.lahiriVedic`     | lahiri   | lahiri (ecliptic)   | whole-sign | Zodiac | default 9 |
| `.westernTropical` | tropical | dhruva (default)    | Placidus   | Zodiac | 10 (adds Uranus/Neptune/Pluto) |

`.westernTropical` sets `traditions: {}`.

---

## SWE layer

### `SweFacade` — `swe/lib/src/swe_facade.dart:30`
Synchronous. swisseph_rs is handle-based rather than globally stateful: config
lives in an `EphemerisConfig` at handle construction, and the facade keeps a
lazily-populated `Map<(EphemerisSource, SiderealMode?), Ephemeris>` cache. There
is no `setEphePath` / `setSidMode` global to re-apply.
```dart
class SweFacade {
  final String? ephePath;
  final String? jplFile;

  SweFacade.create({String? ephePath, String? jplFile});
  void dispose();                       // closes every cached handle

  EphSnapshot calcAll(
    double jdUt,
    Location location,
    SweConfig sweConfig, {
    bool includeStarData = false,       // magnitude + rise/set for fixed stars
  });

  double getAyanamsa  (double jdEt, Ayanamsa ayanamsa);   // ET; throws on Dhruva
  double getAyanamsaUt(double jdUt, Ayanamsa ayanamsa);   // UT; Dhruva supported

  double calcSiderealLongitude(double jdUt, int sweId, Ayanamsa ayanamsa);
  double calcDhruvaLongitude  (double jdUt, int sweId);   // GC mid-Mula equatorial

  double housePosition(
    double jdUt,
    Location location,
    SweConfig sweConfig, {
    required double longitude,          // in sweConfig.signAyanamsa's frame
    double latitude = 0.0,
    HouseSystem? houseSystem,           // defaults to sweConfig.houseSystem
  });                                   // continuous 1.0–13.0

  CardinalPoints calcCardinalPoints(
    int year, {
    EphemerisSource source = EphemerisSource.swissEph,
  });
}
```
Omit `ephePath` to fall back to Moshier (the default handle source is chosen by
whether `ephePath` is set). `ephePath` is required for
`EphemerisSource.swissEph` precision and for fixstar lookups; `jplFile` is
required for `EphemerisSource.jplEph`.

Ayanamsa notes: tropical returns `0.0`. `Ayanamsa.dhruva` is hand-rolled from a
fixed-star lookup in universal time — `getAyanamsaUt` returns its equatorial
offset, `getAyanamsa` throws. Custom codes 97 and 99–101 throw from both.
`housePosition` throws for any non-standard sign ayanamsa including Dhruva
(equatorial-only, so no ecliptic house position).

For swisseph functions Arrow deliberately does not wrap (eclipse and
occultation search), see [direct-swisseph-usage.md](direct-swisseph-usage.md).

### `EphSnapshot` — `swe/lib/src/eph_snapshot.dart:18`
Freezed + JSON. Immutable bridge between SWE and non-SWE code. Carries
`SweConfig`, not `ArrowOptions` — the calc half of the config is applied later
by `Chart`.
```dart
const factory EphSnapshot({
  required double    jdUt,
  required Location  location,
  required SweConfig sweConfig,
  required Map<Body, BodyPosition> bodiesEcliptic,
  required Map<Body, BodyPosition> bodiesEquatorial,
  required Map<Body, PhenoData>    phenoData,     // sparse; no Rahu/Ketu
  required List<double>            cusps,         // 12 entries
  required AscMcPoints             ascmc,
  required SunTimes                sunTimes,
  required double                  ayanamsaValue,

  // Nakshatra-frame longitudes (SWE-computed under sweConfig.nakAyanamsa)
  @Default({}) Map<Body, double>   bodiesNakEclLon,
  @Default({}) Map<Body, double>   bodiesNakEquLon,
  @Default({}) Map<Star, double>   starsNakEclLon,
  @Default({}) Map<Star, double>   starsNakEquLon,
  @Default({}) Map<String, double> customStarsNakEclLon,
  @Default({}) Map<String, double> customStarsNakEquLon,
  @Default([]) List<double>        cuspsNakLon,

  // Extra reference frames — null unless requested via SweConfig.extraFrames
  Map<Body, BodyPosition>? bodiesEclipticBarycentric,
  Map<Body, BodyPosition>? bodiesEclipticHeliocentric,

  // Fixed stars — populated from SweConfig.stars / customStarNames
  @Default({}) Map<Star, StarPosition>   stars,
  @Default({}) Map<String, StarPosition> customStars,
}) = _EphSnapshot;
```

### Snapshot value types
```dart
class AscMcPoints {   // all degrees
  double ascendant, mc, armc, vertex,
         equatorialAscendant, coAscendantKoch, coAscendantMunkasey,
         polarAscendant;
}

class BodyPosition {
  double longitude, latitude, distance,
         speedLongitude, speedLatitude, speedDistance;
}

class PhenoData {     // from swe_pheno_ut; sparse — no lunar nodes
  double phaseAngle, phase, elongation, apparentDiameter, apparentMagnitude;
}

class StarPosition { BodyPosition ecliptic, equatorial; StarData? starData; }

class StarData {      // rise/set require includeStarData: true
  double? apparentMagnitude, riseJd, setJd;
  bool circumpolar;   // default false
}

class SunTimes  { double? sunrise, sunset; }        // JD UT; null if circumpolar
class CardinalPoints {
  double ascendingEquinox, northernSolstice,
         descendingEquinox, southernSolstice;       // JD UT
}
```

### Julian day helpers — `swe/lib/src/julian_day.dart`
```dart
double   julianDay(DateTime dt);       // UTC → JD UT (Meeus)
DateTime fromJulianDay(double jd);     // JD UT → UTC DateTime
```

---

## Core layer

### `Chart` — `core/lib/src/chart.dart:27`
Wraps `EphSnapshot + CalcConfig`. Eagerly builds D1 (rashi) and fixed stars.
Divisional charts cached on demand.
```dart
class Chart {
  final EphSnapshot snapshot;
  final CalcConfig  config;
  late final Rashi  rashi;
  late final Map<Star, FixedStar>   fixedStars;
  late final Map<String, FixedStar> customFixedStars;

  Chart(this.snapshot, this.config);   // asserts Dhruva ⇒ nakEquatorial
  Varga varga(VargaType type);         // cached

  // Typed accessors, delegating to rashi
  Karaka get sun, moon, mars, mercury, jupiter, venus, saturn;
  Planet get rahu, ketu;
  List<Karaka> get karakas;            // 7 embodied
  List<Planet> get grahas;             // 9
  List<Planet> get planets;            // everything requested

  List<Cusp> get cusps;
  Cusp cusp(int house);                // 1-based
  double get ascendant, mc;

  Map<Body, SynodicState> get synodicStates;   // sparse — nodes omitted
}
```

### `Varga` / `Rashi` — `core/lib/src/varga.dart:17`, `rashi.dart:14`
`Varga` is a divisional chart view: same typed planet accessors as `Chart`,
plus `planet(Body)`, `cusps`, and per-sign grouping. `Rashi` extends it with
`Map<int, Nakshatra> nakshatras` (1-27) and `nakshatraOf(Planet)`.

```dart
class Sign      { int number; Body lord; Element element; Quality quality;
                  Gender gender; String name;
                  List<Planet> planets; List<Cusp> cusps; }
class Nakshatra { int number; Body lord; String deity, name;
                  List<Planet> planets; }
class Cusp      { int house; Longitude longitude;
                  int sign, nakshatra, pada; }
```

### Object hierarchy — `SkyObject` → `CelestialBody` → `Planet` → `Karaka`
```dart
abstract class SkyObject {                  // core/lib/src/sky_object.dart:16
  BodyPosition get position, equatorialPosition;
  CalcConfig   get config;
  VargaType    get vargaType;
  double       get rawLongitude, rawEquatorialLongitude, nakLongitude;

  Longitude get longitude;                  // in this object's vargaType
  Longitude varga(VargaType type);          // same body, other varga
  int  get sign, nakshatra, pada;
  Hora get hora;
  BeingType get beingType;
  Being get trimsamsaBeing, horaBeing;
}

class CelestialBody extends SkyObject {     // celestial_body.dart:15
  final Body body; final EphSnapshot snapshot;
  CelestialBody(Body body, EphSnapshot snapshot, CalcConfig config,
                VargaType vargaType);
  BodyPosition? get barycentricPosition, heliocentricPosition;   // extraFrames
  Longitude?    get barycentricRashiLongitude, heliocentricRashiLongitude;
}

class Planet extends CelestialBody {        // planet.dart:11
  bool          get isRetrograde;    // position.speedLongitude < 0
  Direction     get direction;
  SpeedClass    get speedClass;
  PhenoData?    get pheno;           // null for Rahu/Ketu
  SynodicState? get synodicState;    // null when pheno is null
}

class Karaka extends Planet {               // karaka.dart:12
  Karaka(Body body, EphSnapshot snapshot, CalcConfig config,
         VargaType vargaType, {double? sunLongitude});
  double      get inSignLongitude;   // 0-30°
  DignityType get dignity;
  bool        get isCombust;         // false when sunLongitude was not supplied
}

class FixedStar extends SkyObject {         // fixed_star.dart:14
  final Star? star; final String name;
  final int? junctionOf;             // nakshatra number if a yogatara
  final StarData? starData;
  double? get magnitude;             // StarData, else Star.traditionalMag
}
```

### `Longitude` — `core/lib/src/longitude.dart:16`
Takes the raw ecliptic longitude plus an optional pre-computed nak-frame
longitude; the nak frame is chosen by the caller (`CelestialBody` reads
`nakEquatorial` off `CalcConfig`).
```dart
Longitude(double eclipticLongitude, VargaType vargaType, CalcConfig config,
          {double? nakLongitude});

int    get amsha;            // vargaType.amsha
double get longitude;        // varga-adjusted (== amshaLongitude)
VargaDeity? get deity;       // null for rashi
int    get sign;             // 1-12 (Circle-aware; Aditya shifts +1)
int    get signIndex;        // 0-11
int    get nakshatra;        // 1-27 (from nakLongitude ?? eclipticLongitude)
int    get pada;             // 1-4
double get inSignLongitude;  // 0-30°
double degreesApart(double other);
int    signsApart(int otherSign);
bool   isBetween(double long1, double long2);
```

### `Dignity` — `core/lib/src/dignity.dart:12`
Tables (`exaltation`, `debilitation`, `moolatrikona`, `ownSigns`,
`combustionOrbs`) plus `Dignity.calculate(body, sign, inSignDeg, lordSign)`,
`Dignity.isCombust(...)`, `compoundFriendship(...)`, and the `isExalted` /
`isDebilitated` / `isMoolatrikona` / `isOwnSign` / `isNaturalFriend` /
`isNaturalEnemy` / `isTemporaryFriend` predicates.

`DignityType` (in options): `exalted, moolatrikona, ownSign, greatFriend,
friend, neutral, enemy, greatEnemy, debilitated`. Also `FriendshipType` and
`FriendshipLevel`.

### Motion & synodic state — `core/lib/src/motion_state.dart`
Per-body derived state. Reachable as getters on `Planet`; free functions
available for raw inputs.
```dart
enum Direction  { direct, stationary, retrograde }
enum SpeedClass { fast, mean, slow, stationary }

Direction  directionOf   (Body body, double speed);   // abs ≤ threshold → stationary
SpeedClass classifySpeed (Body body, double speed);   // bands: 0.8× / 1.2× meanDailyMotion

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
  final bool? isWaxing;      // null for Sun and outer planets
  factory SynodicState.from({
    required Body body,
    required double bodyLongitude,
    required double sunLongitude,
    required PhenoData pheno,
  });
}

// On Planet:
Direction     get direction;
SpeedClass    get speedClass;
SynodicState? get synodicState;   // null for Rahu/Ketu

// On Chart:
Map<Body, SynodicState> get synodicStates;   // sparse — nodes omitted
```

### `CharaKaraka` — `core/lib/src/chara_karaka.dart`
`CharaKarakaRole` enum + `CharaKaraka.assign(...)` → `Map<CharaKarakaRole, Karaka>`.

---

## Calc layer

Calc functions take primitives or a `Varga`, never a `Chart`.

### Avasthas
```dart
// Baladi — age by degree (even signs reverse)
enum BaladiState { bala, kumara, yuva, vriddha, mrita }
static BaladiState Baladi.of(int sign, double inSignDegree);

// Jagradadi — alertness from dignity
enum JagradadiState { jagrat, swapna, sushupti }
static JagradadiState Jagradadi.of(DignityType dignity);

// Deeptadi — mood cascade from dignity/aspect/combustion
enum DeeptadiState { /* 9 states */ }
static DeeptadiState Deeptadi.of(Body body, Varga varga);
```

### `Lajjitaadi` — `calc/lib/src/vedic/lajjitaadi.dart:163`
Relational, bidirectional giving/receiving. Takes the whole `Varga` and derives
the longitudes, dignities, and cusps it needs.
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

static Map<Body, LajjitaadiResult> Lajjitaadi.compute(Varga varga);
// Karakas with no factors in any state are omitted from the map.
```

### `Aspect` — `calc/lib/src/vedic/aspect.dart:14`
Degree-based Parashara port. `Aspect.strength(from, fromLon, toLon)` (0-60),
`isConjunction(fromLon, toLon)`, `doesAspect(from, fromLon, toLon)`.
Mars/Jupiter/Saturn special overrides.

### `RashiAspect` — `calc/lib/src/vedic/rashi_aspect.dart:15`
Sign-based (Jaimini) aspects, table selected by `RashiAspectMode`.
`doesAspect(...)`, `doesAspectWithOccupants(...)`, `mutual(...)`.

### `Shadbala` — `calc/lib/src/vedic/shadbala.dart:37`
`Shadbala` holds the nine sub-balas in virupas with `sthanaBala`,
`totalVirupas`, `totalRupas` getters. `ShadbalaCalc` provides the static
computation per sub-bala (`uccaBala`, `saptavargajaBala`, `samaVisamaBala`,
`kendradiBala`, `drekkanaBala`, `digBala`, `ayanaBala`, `cheshtaBala`,
`drigBala`) plus the `virupasBetween` primitive. Constants in
`shadbala_const.dart`.

### `Vimshottari` — `calc/lib/src/vedic/vimshottari.dart:49`
`DashaPeriod` + static `currentDasha({...})`, `specificPeriod({...})`,
`fullTree({...})`, `periodDuration(lordIndices, yrlen)`. Year length comes from
`DashaYearLength` in options.

### `Jaimini` — `calc/lib/src/vedic/jaimini.dart:25`
Arudha padas (`pada`, `arudhaLagna`, `upapada`, `allPadas`), `argala` →
`ArgalaResult`, and sign-strength ordering (`firstStrength`, `secondStrength`).

### `NabhasaYogaCalc` — `calc/lib/src/vedic/nabhasa_yoga.dart:76`
`ashrayaYogas`, `dalaYogas`, `sankhyaYogas`, `akritiYogas` → `NabhasaYoga`;
also `MahapurushaYoga` and `SolarLunarYoga` result types.

### Panchanga — `calc/lib/src/vedic/panchanga/`
Free functions over longitudes, each returning a small value class:
```dart
Tithi     calcTithi    (double sunLongitude, double moonLongitude);
Karana    calcKarana   (double sunLongitude, double moonLongitude, Tithi tithi);
Nakshatra calcNakshatra(double siderealLongitude);
Yoga      calcYoga     (double sunSiderealLongitude, double moonSiderealLongitude);
Vara      calcVara     (double jdUt);
double    vedangaJyotishaEcliptic(double tropicalLongitude);
```
`next.dart` holds the "when does this limb change" search helpers.

### Zodiac (13-sign) — `calc/lib/src/zodiac/`
`Ecliptic13` + `buildEcliptic13(EphSnapshot snap)` derive constellation
boundaries from boundary-star positions in the snapshot.

---

## Full consumer flow

```dart
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_calc/arrow_calc.dart';

final facade  = SweFacade.create(ephePath: '/path/to/ephe'); // omit for Moshier-only
final options = ArrowPresets.lahiriVedic;                    // or custom ArrowOptions(...)
final loc     = Location(latitude: 28.6, longitude: 77.2);
final jdUt    = julianDay(DateTime.utc(1990, 3, 17, 12, 30));

final snap    = facade.calcAll(jdUt, loc, options.sweConfig); // sync
final chart   = Chart(snap, options.calcConfig);

// D1 access
final sun = chart.sun;                  // Karaka (== chart.rashi.sun)
sun.sign;                               // 1-12
sun.nakshatra;                          // 1-27
sun.isRetrograde;                       // bool
sun.pheno;                              // PhenoData?
sun.dignity;                            // DignityType

// Angles & cusps
chart.ascendant;
chart.cusp(1).sign;

// Divisional
chart.varga(VargaType.navamsha).sun.sign;

// Motion / synodic (on Planet)
final dir = chart.mercury.direction;                  // Direction
final syn = chart.venus.synodicState;                 // SynodicState?
final all = chart.synodicStates;                      // Map<Body, SynodicState>

// Calc layer
final avasthas = Lajjitaadi.compute(chart.rashi);     // Map<Body, LajjitaadiResult>

facade.dispose();                                     // closes SWE handles
```

---

## Platform notes

- No async init — `calcAll` is synchronous.
- Native FFI via `swisseph_rs` (Rust binding to Swiss Ephemeris). Handles are
  explicit objects; call `SweFacade.dispose()` when done.
- Moshier is the fallback when no `ephePath` is given — no `.se1` files needed
  unless precision, date range, or fixstar lookups require them.
- All snapshot data classes use `freezed` + `json_serializable` — snapshots are
  serializable for cache/persist. Core/calc classes are plain Dart.
- `CalcConfig` changes (circle/tradition/nak frame) are free:
  `Chart(sameSnap, newCalcConfig)`. `SweConfig` changes require new `calcAll`.
