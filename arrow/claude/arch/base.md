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

Two config interfaces, one concrete class:

### SweConfig
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

### CalcConfig
Options that affect derived/analytical calculations but do not require SWE recalculation.

- **Zodiac circle** (zodiac vs aditya) — shifts sign boundaries by 30°; pure math on longitude, no SWE needed. See `tropical-aditya-distinction.md`.
- Temporary friendship source (rashi-based vs varga-based)
- Ashtakavarga method (Parashara vs Varahamihira)
- Combustion method (contemporary vs Surya Siddhanta)
- Varga variants:
  - D10: 3 methods (contemporary, parivritti, reverse for even rashis)
  - D24: 3 methods (contemporary, parivritti, reverse for even rashis)
  - D30: 2 methods (element lords, rashi30)
- Rashi aspect mode (conventional, elemental, quadrantal)
- Jaimini karakas count (7 or 8)
- Chara karaka 8th planet (Lagna vs Rahu) — applicable when 8 karakas
- Aya dasha mirror rule (side vs front)
- Moon fatal degree source (Phaladeepika vs Saravali)
- Vara mode (local, Yamakoti, Ujjain)
- Year length for nakshatra dashas (nakshatra, savana, saura, sidereal, chandra nakshatra, lunar tithi)
- Year length for rashi dashas (same options)
- Nakshatra dasha source planet
- Tajika: Moon as VarshaPati, aspect mode for VarshaPati, candidacy count priority, equal house cusps for sahams
- D3 to use for Jaimini yogada table

### Composition

One concrete `ArrowOptions` class implements both interfaces. Functions declare which interface they need:

```dart
EphSnapshot calcAll(double jd, Location loc, SweConfig config);
int calcVargaSign(double longitude, int division, CalcConfig config);
```

The SWE/non-SWE boundary is enforced at the type level: `arrow_swe` only takes `SweConfig`, everything else takes `CalcConfig`. Changing a `CalcConfig` field never triggers SWE recalculation. Changing a `SweConfig` field invalidates the `EphSnapshot`.

## Universal Options Architecture

The options system described above covers Vedic astrology (Ernst's system specifically). For the full multi-tradition design — supporting Hellenistic, modern Western, Uranian, Persian, Cards of Truth, and more — see `universal-options.md`. Key changes:

- `SweConfig` gains a `bodies` set (asteroids, hypotheticals, Lilith variants) and `fixedStars`
- `CalcConfig` becomes modular: a small core + optional typed tradition configs (`VedicConfig`, `HellenisticConfig`, `ModernWesternConfig`, `UranianConfig`, `PersianConfig`, etc.)
- `ArrowOptions` composes `SweConfig` + `CalcConfig` instead of implementing both as interfaces
- Named presets (`ArrowPresets.ernst`, `.hellenistic`, `.modernWestern`) replace magic defaults
- `arrow_calc` gets per-tradition subdirectories that are tree-shakeable

The current `CalcConfig` fields map exactly to `VedicConfig`. No calculation logic changes — just reorganization.

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
- The full `ArrowOptions` that produced it — carries both SweConfig and CalcConfig, so a deserialized snapshot contains everything needed to reconstruct a `Chart`

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
