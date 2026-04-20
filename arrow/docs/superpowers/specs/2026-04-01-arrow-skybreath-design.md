# Arrow for Skybreath — Design Spec

Arrow scoped to what Skybreath needs: planet positions, sign/nakshatra/varga placement across tropical, sidereal, and Aditya coordinate systems, plus dignity and chara karakas. No analytical calculations (dashas, yogas, shadbala, etc.) — those are deferred to arrow_calc when a future app needs them.

The full Arrow vision remains in `claude/impl/one.md`. This spec covers only the Skybreath-scoped subset.

## Scope

### In

- **arrow_options** — enums, SweConfig, CalcConfig (modular structure, only VedicConfig populated)
- **arrow_swe** — swisseph.dart (`swisseph` package from pub.dev) bindings, EphSnapshot, SweFacade
- **arrow_core** — Longitude, Sign, Nakshatra, Varga/Rashi/Chart, domain model, dignity, chara karakas

### Out (deferred)

- **arrow_calc** — dashas, yogas, shadbala, ashtakavarga, Jaimini analysis, aspects, avasthas, tajika
- **Tradition configs** beyond VedicConfig (Hellenistic, Uranian, Persian, etc.)
- **Quiver integration** — Arrow stays on-device only; architecture remains Quiver-ready
- **FixedStar** body type — can be added when a consumer needs it
- **HTTP fallback** to KalaBrain for SWE calls

## Package Structure

```
arrow/
├── options/    # arrow_options
├── swe/        # arrow_swe
├── core/       # arrow_core
└── melos.yaml
```

Strict one-way dependency: `arrow_options <- arrow_swe <- arrow_core`

Directory names are short (`swe/` not `arrow_swe/`). Dart package names in pubspec.yaml are `arrow_options`, `arrow_swe`, `arrow_core`.

## Longitude — Core Abstraction

Ported from libaditya's `Longitude` class (`libaditya/objects/longitude.py`).

Longitude wraps raw position data and makes coordinate-system complexity invisible to callers. It carries both ecliptic and equatorial longitudes from SWE, and uses the right one depending on context. The raw longitudes arrive already in the correct frame (tropical or sidereal) per SweConfig — Longitude does not apply the sign ayanamsa. It does apply the nak ayanamsa for nakshatra computation.

```dart
class Longitude {
  final double eclipticLongitude;    // raw from SWE, already tropical/sidereal per SweConfig
  final double equatorialLongitude;  // raw from SWE, for equatorial nakshatras
  final int amsha;                   // 1 = rashi, 9 = navamsha, etc.
  final CalcConfig config;           // carries Circle, nakAyanamsa, nakEquatorial

  double get amshaLongitude;         // varga-transformed (from ecliptic)
  double get longitude => amshaLongitude;  // the contextually correct longitude

  int get sign;                      // 1-12, Circle-aware, derived from longitude
  int get signIndex;                 // 0-11
  int get nakshatra;                 // 1-27, applies nakAyanamsa (may use equatorial)
  int get pada;                      // 1-4
  String get deity;                  // varga deity
  double get inSignLongitude;        // degrees within the sign

  // Utility
  double degreesApart(double other);
  int signsApart(int otherSign);
  double virupasBetween(Longitude point);  // fractional strength (0-60) based on angular distance — used by dignity/shadbala
  bool isBetween(double long1, double long2);
}
```

Key behaviors:
- **`longitude` getter**: Returns `amshaLongitude`. When amsha=1, this equals `eclipticLongitude`. All derived getters (sign, inSignLongitude, etc.) use this value.
- **Sign ayanamsa**: Handled by SWE — the raw ecliptic longitude is already tropical or sidereal. Longitude does not apply any offset for signs.
- **Nak ayanamsa**: Applied by Longitude. Uses `nakAyanamsa` from CalcConfig, applies the offset to compute nakshatra. Independent from sign ayanamsa. Primary use case: tropical signs + dhruva nakshatras.
- **Equatorial nakshatras**: When `CalcConfig.nakEquatorial` is true, nakshatra computation uses `equatorialLongitude` instead of `eclipticLongitude`. Dhruva ayanamsa anchors the Galactic Center's equatorial longitude as mid-Mula (6°40' of Mula), then divides the equator into 27 × 13°20'.
- **Circle handling**: Aditya offsets sign index by +1 (mod 12). Zodiac uses standard 0-based.
- **Varga transformation**: `Longitude(eclLon, eqLon, 9, config)` gives the navamsha. Every Longitude knows both its ecliptic longitude and its amsha longitude.

## Body Model

### Universal layer

```dart
/// Universal base. Holds raw position data from EphSnapshot.
class CelestialBody {
  final Body body;
  final EphSnapshot snapshot;
  final CalcConfig config;

  BodyPosition get position => snapshot.bodiesEcliptic[body]!;
  BodyPosition get equatorialPosition => snapshot.bodiesEquatorial[body]!;
  double get rawLongitude => position.longitude;
  double get rawEquatorialLongitude => equatorialPosition.longitude;

  Longitude get longitude => Longitude(rawLongitude, rawEquatorialLongitude, 1, config);
  Longitude varga(int amsha) => Longitude(rawLongitude, rawEquatorialLongitude, amsha, config);

  int get sign => longitude.sign;
  int get nakshatra => longitude.nakshatra;
  int get pada => longitude.pada;
}

/// Moving body. Adds speed/retrograde semantics.
class Planet extends CelestialBody {
  bool get isRetrograde => position.speedLongitude < 0;
}
```

### Vedic layer (composition over CelestialBody)

```dart
/// The 9 Vedic bodies (7 classical + Rahu + Ketu).
/// Wraps a Planet — composition, not inheritance from CelestialBody.
/// Delegates all position/longitude access to the inner Planet.
class Graha {
  final Planet planet;

  Graha(this.planet);

  // Delegation
  Body get body => planet.body;
  Longitude get longitude => planet.longitude;
  Longitude varga(int amsha) => planet.varga(amsha);
  int get sign => planet.sign;
  int get nakshatra => planet.nakshatra;
  int get pada => planet.pada;
  bool get isRetrograde => planet.isRetrograde;
  // Note: graha.longitude.inSignLongitude is how chara karaka sorting
  // accesses the in-sign degree. All Longitude accessors are available
  // through the delegated longitude getter.
}

/// The 7 embodied planets (Sun through Saturn).
/// Adds dignity and combustion — only meaningful for these 7.
class Karaka extends Graha {
  Karaka(super.planet);

  Dignity get dignity => /* lookup from tables */;
  bool get isCombust => /* proximity to Sun check */;
}
```

Design rationale: the data is universal (a longitude is a longitude) but the meaning is tradition-specific. CelestialBody/Planet are universal. Graha/Karaka are Vedic wrappers — composition, not inheritance from CelestialBody. A Karaka is always also a Graha. Future tradition wrappers (WesternPlanet, Asteroid, etc.) can be added without changing the universal base.

### Longitude construction and CalcConfig changes

Varga constructs Longitude objects lazily via getters. A new `Chart(snapshot, newConfig)` produces new Varga/Longitude objects with the new config — there is no caching across Chart instances. "CalcConfig changes are free" means: same EphSnapshot, new Chart, all Longitudes reflect the new config automatically.

## Varga, Chart, Sign & Nakshatra

Chart is a collection of vargas. Each varga is a complete view of the sky through a divisional lens — its own planets, signs, and cusps. The base class is Varga; Rashi extends it for D1 and adds nakshatras.

### Varga

```dart
class Varga {
  final int amsha;                  // 1 = rashi, 9 = navamsha, etc.
  final EphSnapshot snapshot;
  final CalcConfig config;

  // Bodies — one instance per body within this Varga
  List<Planet> get planets;         // all moving bodies
  List<Graha> get grahas;           // the 9
  List<Karaka> get karakas;         // the 7

  // Named accessors
  Karaka get sun;
  Karaka get moon;
  Karaka get mars;
  Karaka get mercury;
  Karaka get jupiter;
  Karaka get venus;
  Karaka get saturn;
  Graha get rahu;
  Graha get ketu;
  Planet get uranus;
  Planet get neptune;
  Planet get pluto;

  // Signs — 12, each with reference data + occupants
  Map<int, Sign> get signs;         // 1-12
  Sign signOf(Planet planet);       // convenience

  // Cusps
  List<Cusp> get cusps;             // 12 house cusps
}
```

`karakas` is a semantically distinct collection, not a filtered view. It's the group that Jaimini sorting operates on. `grahas` includes nodes. `planets` is everything.

### Rashi

```dart
class Rashi extends Varga {
  Rashi(EphSnapshot snapshot, CalcConfig config) : super(1, snapshot, config);

  // Nakshatras — only on Rashi, not other vargas
  Map<int, Nakshatra> get nakshatras;    // 1-27
  Nakshatra nakshatraOf(Planet planet);  // convenience
}
```

### Chart

```dart
class Chart {
  final EphSnapshot snapshot;
  final CalcConfig config;

  Rashi get rashi;                  // D1, the default
  Varga varga(int amsha);           // varga(9) = navamsha, etc.
}
```

Access patterns:
- `chart.rashi.sun` — Sun in the natal chart
- `chart.rashi.signs[5].planets` — planets in sign 5
- `chart.rashi.signOf(chart.rashi.mars)` — which Sign Mars is in
- `chart.rashi.nakshatras[14]` — Chitra nakshatra
- `chart.rashi.nakshatraOf(chart.rashi.moon)` — Moon's nakshatra
- `chart.varga(9).sun` — Sun in navamsha
- `chart.varga(9).signs[5].planets` — planets in sign 5 in navamsha

Each Varga constructs its own Planet/Sign/Cusp instances. Within a single Varga, there is only one instance of each Planet — `varga.signs[5].planets[0]` and `varga.sun` are the same object. Across vargas, they are different objects (different Longitude, different sign placement).

### Sign

```dart
class Sign {
  final int number;                 // 1-12

  // Reference data (static per sign number)
  Body get lord;
  Element get element;
  Quality get quality;
  Gender get gender;

  // Occupants (chart-scoped, populated by parent Varga)
  List<Planet> get planets;
  List<Cusp> get cusps;
}
```

### Nakshatra

```dart
class Nakshatra {
  final int number;                 // 1-27

  // Reference data
  Body get lord;                    // vimshottari lord
  String get deity;
  // shakti, symbol, gana, etc.

  // Occupants (chart-scoped, populated by parent Rashi)
  List<Planet> get planets;
}
```

Sign and Nakshatra are chart-scoped view objects — they combine static reference data with dynamic occupants for a specific chart. They hold references to the same Planet objects that the parent Varga owns.

## Cusp

```dart
class Cusp {
  final int house;                  // 1-12
  final Longitude longitude;
  // sign, nakshatra, varga — all via Longitude, same as any body
}
```

## EphSnapshot & SweFacade

```dart
class SweFacade {
  // Stateless. Takes full ArrowOptions so the snapshot embeds everything
  // needed for Chart reconstruction. No init/dispose lifecycle.
  // Quiver-ready: wrappable in an isolate.
  EphSnapshot calcAll(double jd, Location location, ArrowOptions options);
}

@freezed
class EphSnapshot {
  double jdUt;
  Location location;
  ArrowOptions options;              // full config for reconstruction

  Map<Body, BodyPosition> bodiesEcliptic;
  Map<Body, BodyPosition> bodiesEquatorial;  // not used by Skybreath scope, but stored per greedy snapshot principle

  List<double> cusps;                // 12 house cusps
  AscMcPoints ascmc;                 // asc, mc, armc, vertex, etc.
  SunTimes sunTimes;                 // sunrise, sunset
  double ayanamsaValue;              // for sidereal approximation
}
```

Note: the `@freezed` annotations above are pseudocode sketches showing the data shape, not compilable Dart. The real implementation will use freezed's `const factory` constructor syntax.

EphSnapshot is greedy by design — grab everything SWE can give you in one call, store it all, never go back. The cost is trivial memory; the benefit is a clean SWE boundary. In a server context (future Quiver), minimizing SWE round-trips matters more than saving a few doubles.

**Why `ArrowOptions` and not just `SweConfig`?** `base.md` originally said EphSnapshot stores only `SweConfig`. This spec stores the full `ArrowOptions` so that a deserialized snapshot is a complete unit — anyone with an EphSnapshot can reconstruct a Chart without needing to know what CalcConfig was in play. The embedded CalcConfig is a default/suggestion, not a constraint: you can always construct `Chart(snapshot, differentCalcConfig)` to override it.

## arrow_options — Enums & Configs

### Enums

- **Body** — Sun through Pluto, Rahu, Ketu. Expandable for asteroids/hypotheticals.
- **Ayanamsa** — Lahiri, Raman, Krishnamurti, dhruva, tropical (none), etc. Each has a `sweCode` getter mapping to swisseph.dart constants.
- **HouseSystem** — Placidus, Koch, Whole Sign, Equal, etc. Each has a `sweCode` getter.
- **Circle** — aditya, zodiac.
- **Tradition** — vedic (only one populated for now).
- **Dignity enums** — exaltation, moolatrikona, own, friend, neutral, enemy, debilitation.
- **Varga enums** — D1 through D60, plus method variants (D10Method, D24Method, D30Method).

### Configs

```dart
@freezed class SweConfig {
  Set<Body> bodies;
  Ayanamsa signAyanamsa;            // default: tropical (none)
  HouseSystem houseSystem;
  bool trueNode;                    // true node vs mean node
  bool topocentric;
  // Additional SWE fields (houseCuspMode, nakCalcMode, riseMode,
  // custom ayanamsa params) exist in the full Arrow design but are
  // omitted from Skybreath scope. They will be added to SweConfig
  // when needed — no structural change required.
}

@freezed class VedicConfig {
  // dignity, friendship, varga method options
  // chara karaka options (7 or 8)
}

@freezed class CalcConfig {
  Circle circle;                    // default: aditya. Universal — every tradition needs this.
  Ayanamsa nakAyanamsa;             // default: dhruva. Independent from sign ayanamsa.
  bool nakEquatorial;               // default: true for dhruva. Use equatorial longitude for nakshatras.
  Set<Tradition> traditions;
  VedicConfig? vedic;               // null = use defaults if vedic active
}

@freezed class ArrowOptions {
  SweConfig sweConfig;
  CalcConfig calcConfig;
}
```

### Presets

- `ArrowPresets.ernst` — tropical signs + Aditya circle + dhruva nakshatras
- `ArrowPresets.lahiriVedic` — Lahiri sidereal, Zodiac circle
- `ArrowPresets.westernTropical` — tropical, Zodiac circle

Presets are convenience constructors, not magic.

## arrow_core — Implementation Scope

### Longitude (ported from libaditya)
- Varga transformation (all 16 vargas, method variants for D10, D24, D30)
- Sign calculation (Circle-aware, derived from `longitude` getter)
- Nakshatra calculation (applies nakAyanamsa from CalcConfig; ecliptic or equatorial per `nakEquatorial`)
- Pada
- Varga deity lookup
- Utility: degrees apart, signs apart, in-sign longitude, virupas between

### Domain model
- CelestialBody, Planet, Graha, Karaka, Cusp
- Varga (base), Rashi (extends Varga, amsha=1, adds nakshatras)
- Chart (collection of Vargas)
- Sign (chart-scoped: reference data + planet/cusp occupants)
- Nakshatra (chart-scoped: reference data + planet occupants, Rashi only)
- All position access through Longitude objects

### Dignity (Karaka only)
- Exaltation / debilitation (with exact degrees)
- Moolatrikona
- Own sign
- Natural, temporal, compound friendship
- Ported from libaditya

### Chara karakas
- Sort 7 karakas by in-sign longitude to assign Jaimini roles (Atmakaraka, Amatyakaraka, etc.)
- 7 or 8 karaka option (configurable in VedicConfig)

## Quiver-Readiness

Arrow is on-device only for Skybreath. These design choices ensure Quiver can wrap it later without refactoring:

- **SweFacade is stateless** — no held state between calls, trivially wrappable in an isolate
- **No singletons** — everything injectable/constructable
- **EphSnapshot + ArrowOptions is a complete unit** — serialize these two over gRPC and the other side can reconstruct a Chart
- **EphSnapshot is greedy** — one SWE call per chart, no follow-up queries

## Source Material

All calculations ported from:

kala anything is deprecated and no longer exists
-------------------------------------------------
- **KalaNG** — `soft/back/kala/kalang/Astro/` (C#)
- **libkala** — `soft/back/libkala/` (Python)
-------------------------------------------------------

- **libaditya** — `nhs/soft/libaditya/libaditya/` (Python, especially `objects/longitude.py`)

Port, don't invent. If sources disagree, surface the discrepancy.

## Relationship to Existing Docs

- `claude/impl/one.md` — the full Arrow implementation plan (all 4 layers). Remains as the complete vision.
- `claude/arch/base.md` — base architecture. Still accurate, with body model update (CelestialBody base, Graha/Karaka as wrappers).
- `claude/arch/universal-options.md` — multi-tradition design. Structure is correct; only VedicConfig gets populated for now.
- `claude/arch/domain-model.md` — body hierarchy. Superseded by this spec's body model (CelestialBody base + composition pattern for Graha/Karaka).
- `claude/arch/tropical-aditya-distinction.md` — Circle logic. Still accurate; now lives inside Longitude.
