# Arrow Base Architecture

## Overview

Arrow is a Dart rewrite of the astrology calculation engine. It has two parts:
- **SWE** (Swiss Ephemeris via dart:ffi, using the `sweph` package from https://github.com/vm75/sweph.dart.git)
- **Non-SWE** (pure Dart derived calculations, ported from C# Astro and Python libkala)

## 3-Layer Pipeline

```
ArrowOptions (SweConfig + CalcConfig)
    |
    v
+-------------+
|  arrow_swe  |  <- sweph.dart (dart:ffi), ephemeris files
|             |  <- OR: HTTP fallback to KalaBrain
+------+------+
       | EphSnapshot (immutable, serializable)
       v
+-------------+
| arrow_core  |  <- pure Dart derivation
|             |  <- signs, nakshatras, vargas, dignities, karakas
+------+------+
       | Chart (rich model, all positions resolved)
       v
+-------------+
| arrow_calc  |  <- pure Dart analysis
|             |  <- dashas, yogas, shadbala, ashtakavarga, jaimini
+-------------+
```

Each layer only depends on the output of the previous one. Non-SWE code never calls SWE directly — it only sees the EphSnapshot.

## SWE Surface Area

~15 functions total:
- calcPlanet(jd, planet_id, flags) -> (lon, lat, dist, speedLon, speedLat, speedDist)
- calcHouses(jd, lat, lon, hsys) -> (cusps[], ascmc[])
- getAyanamsa(jd, sidmode) -> double
- riseSet(jd, planet, location, flags) -> double
- heliacalUt(jd, location, planet, eventType) -> double
- solarEclipse / lunarEclipse (global and local variants)

Primary public API is a batch `calcAll` that returns an `EphSnapshot`. Edge features (eclipses, heliacal) are separate functions.

## Options Architecture

Two config types composed into one `ArrowOptions` class (all freezed):

### SweConfig (freezed)
Options that change raw planetary/house positions — changing any of these requires SWE recalculation.

- Zodiac mode for signs (tropical, Lahiri, Raman, ~40 ayanamsas)
- Zodiac mode for nakshatras (can differ from signs)
- House system (22 systems: Campanus, Placidus, Koch, etc.)
- House cusp mode (start / middle / end)
- True node vs mean node
- Topocentric vs geocentric
- Nakshatra calculation mode (ecliptic, equatorial, dhruva ecliptic)
- Rise mode (Hindu, center true/apparent, tip true/apparent)
- Custom ayanamsa (user arc + user epoch)
- `Set<Body> bodies` — which celestial bodies to calculate (see `BodySets` in `universal-options.md`)
- `Set<String> fixedStars` — fixed stars to calculate by catalog name

### CalcConfig (freezed, modular)
Modular config for derived/analytical calculations. Does not require SWE recalculation.

Core fields:
- `Set<Tradition> traditions` — which traditions are active
- Optional typed tradition configs: `VedicConfig?`, `CardsOfTruthConfig?`, `HumanDesignConfig?` (and future configs)

Vedic-specific options (in `VedicConfig`) include: circle, friendship method, ashtakavarga method, combustion method, varga variants (D10/D24/D30), rashi aspect mode, jaimini karakas, dasha year lengths, tajika options, etc. See `universal-options.md` for the full inventory.

### Composition

`ArrowOptions` composes `SweConfig` + `CalcConfig` as fields (not interfaces):

```dart
@freezed
class ArrowOptions with _$ArrowOptions {
  const factory ArrowOptions({
    required SweConfig sweConfig,
    required CalcConfig calcConfig,
  }) = _ArrowOptions;
}
```

Functions declare which config they need:

```dart
EphSnapshot calcAll(double jd, Location loc, SweConfig config);
List<DashaPeriod> calcVimshottari(EphSnapshot snap, VedicConfig config);
```

The SWE/non-SWE boundary is enforced at the type level: `arrow_swe` only takes `SweConfig`, tradition-specific functions take their own config type. Changing a `CalcConfig` field never triggers SWE recalculation. Changing a `SweConfig` field invalidates the `EphSnapshot`.

## Universal Options Architecture (Active)

CalcConfig is modular from the start. Cards of Truth and Human Design both need SWE (Cards uses equatorial sunrise + planet placements; Human Design uses precise planetary positions for gate/line placement), giving us multiple real traditions to validate the design alongside Vedic. See `universal-options.md` for full details. Key structure:

- `SweConfig` gains a `bodies` set (asteroids, hypotheticals, Lilith variants) and `fixedStars`
- `CalcConfig` is modular: a small core (`Set<Tradition>`) + optional typed tradition configs (`VedicConfig`, `CardsOfTruthConfig`, `HumanDesignConfig`, and future configs like `HellenisticConfig`, `ModernWesternConfig`, etc.)
- `ArrowOptions` composes `SweConfig` + `CalcConfig` instead of implementing both as interfaces
- Named presets (`ArrowPresets.aditya`, `.cardsOfTruth`, `.humanDesign`) replace magic defaults
- `arrow_calc` gets per-tradition subdirectories that are tree-shakeable
- Functions take exactly the config they need: `calcVimshottari(snap, VedicConfig)`, `calcBirthCard(snap, CardsOfTruthConfig)`

## Chart Options Patterns

### CalcConfig changes: free
Changing any `CalcConfig` field never invalidates the `EphSnapshot`. Use `copyWith` (freezed) and construct a new Chart with the same snapshot:

```dart
final chart2 = Chart(chart1.snapshot, chart1.config.copyWith(circle: Circle.zodiac));
```

### SweConfig changes: require new EphSnapshot
Changing ayanamsa, house system, etc. requires a new SWE call. The explicit API:

```dart
final newOptions = options.copyWith(signAyanamsa: Ayanamsa.lahiri);
final newSnapshot = swe.calcAll(jd, location, newOptions);
final chart2 = Chart(newSnapshot, newOptions);
```

### Sidereal approximation (no SWE)
For a quick sidereal sign placement without re-running SWE, subtract the ayanamsa value stored in the `EphSnapshot` from the tropical longitude. Accurate enough for sign placement in most cases; use full SWE recalc when precision matters.

## EphSnapshot

Immutable, serializable data object. Contains:
- Planet positions (lon, lat, dist, speed per planet)
- House cusps (12 values)
- Ascmc points
- Resolved ayanamsa values (sign and nakshatra)
- The `SweConfig` that produced it (not full ArrowOptions — CalcConfig is not SWE's concern). Final design will come from the sweph.dart spike (Phase 2A/2B), not these sketches.

This is the bridge between SWE and non-SWE. It can come from:
1. Local SWE calculation (sweph.dart)
2. KalaBrain server response
3. Supabase cache
4. Serialized JSON

Non-SWE code is identical regardless of source.

## JSON Serialization

Every data class uses **`freezed` + `json_serializable`**. This generates `toJson`, `fromJson`, `copyWith`, `==`, and `hashCode` from a single source of truth.

**What gets serialized:**
- `EphSnapshot` — KalaBrain responses, Supabase cache, test fixtures
- `ArrowOptions` — user settings, embedded in EphSnapshot
- `Location` — part of a chart request
- Calculation results (`DashaPeriod`, `ShadBala`, etc.) in `arrow_calc`

**What does NOT get serialized:**
- `Chart`, `Planet`, `Graha`, `Karaka`, `Cusp` — these are rich views over data. To persist a Chart: serialize `snapshot` + `options` (both already inside `EphSnapshot`), reconstruct with `Chart(snapshot, options)`.

**Enum JSON:** enums serialize by **name** (`'lahiri'`, `'campanus'`, `'aditya'`), never by integer. The `sweCode` integer on `Ayanamsa` is a sweph implementation detail, not a serialization identity. This is the `json_serializable` default — no extra annotation needed.
