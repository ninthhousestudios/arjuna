# Arrow

Dart astrological calculation library. Multi-tradition, multi-system.

## Package structure

```
options/  →  swe/  →  core/  →  calc/
```

Dependency flows strictly left-to-right. `tool/` is internal fixture generation.

| Package | Role | What goes here |
|---------|------|----------------|
| `arrow_options` | Enums, freezed configs, value types | Pure types with no computation. No SWE, no domain logic. |
| `arrow_swe` | Swiss Ephemeris facade | `SweFacade.calcAll()` → `EphSnapshot`. Raw positions only. |
| `arrow_core` | Rich domain model | `Chart`, `Planet`, `Karaka`, `Longitude`, static data tables, per-body calculations |
| `arrow_calc` | Multi-body calculations | Avasthas, aspects, yogas, dashas, shadbala, panchanga. Functions take primitives, not domain objects. |

## The two-config boundary

This is the most important architectural concept:

**`SweConfig`** controls raw ephemeris computation (ayanamsa, house system, which bodies to calculate). Changing ANY SweConfig field requires a new `SweFacade.calcAll()` call → new `EphSnapshot`. Expensive.

**`CalcConfig`** controls derived interpretation (circle, traditions, varga options). Changing CalcConfig is free — just construct `Chart(sameSnapshot, newConfig)`. No SWE recalculation.

```
SweConfig change  →  must recompute EphSnapshot  →  new Chart
CalcConfig change →  reuse same EphSnapshot      →  new Chart
```

`ArrowOptions` bundles both: `ArrowOptions(sweConfig: ..., calcConfig: ...)`.

## Circle: zodiac vs aditya

`CalcConfig.circle` determines where sign 1 starts:

- **`Circle.zodiac`** — sign 1 at 0° ecliptic (standard). `signIndex = floor(lon / 30)`
- **`Circle.aditya`** — sign 1 at 330° ecliptic (shifted 30° earlier). `signIndex = (floor(lon / 30) + 1) % 12`

Both use the **same SWE positions**. The difference is purely a sign-mapping offset applied in `Longitude.signIndex`. When using the Aditya circle, a "rashi" IS an Aditya — the 12 Adityas are 12 solar deities representing the 12 30° segments of the ecliptic, starting at 330° tropical.

Circle and ayanamsa are fully independent. `signAyanamsa=tropical + circle=aditya` is the primary Vedic use case (Ernst Wilhelm's system). `signAyanamsa=lahiri + circle=zodiac` is standard sidereal Vedic.

The `adityaOffset` (30 when aditya, 0 when zodiac) propagates through all varga calculations in `varga_math.dart`. Any calculation that works with `sign` (1-12) and `inSignLongitude` (0-30°) is automatically circle-agnostic — the Circle is already resolved by the time those values exist.

## Domain model hierarchy

```
SkyObject (abstract)
  ├── CelestialBody       body + snapshot + config
  │     └── Planet        + isRetrograde, direction, speedClass, synodicState
  │           └── Karaka  + dignity, isCombust (7 embodied planets only)
  └── FixedStar           star from snapshot, no dignity/avastha
```

All domain objects are views over `EphSnapshot` data + `CalcConfig`. They don't call SWE. They don't own their data.

### What goes ON objects vs. in calc functions

**On the object** — per-body facts computable in isolation:
- Positional: sign, nakshatra, pada, inSignLongitude, hora, beingType, adityaBeing
- Motion: isRetrograde, direction, speedClass, synodicState
- Dignity: dignity, isCombust (Karaka only)

**Static functions in `arrow_calc`** — anything requiring multiple bodies or chart-wide context:
- Aspects, yogas, dashas, shadbala, ashtakavarga, avasthas, panchanga

Calc functions take **primitive inputs** (doubles, enums, `Map<Body, double>` etc.), NOT domain objects. This keeps the calc layer testable without constructing a full Chart.

## Options package conventions

`arrow_options` is **types only**. No computation logic. No data tables. Pattern:

- Simple enums: `DignityType`, `Hora`, `BeingType`, `Circle`, `Body`, etc.
- Freezed config classes: `CalcConfig`, `SweConfig`, `VedicConfig`, `ArrowOptions`, `Location`
- Value classes: `Being` (name + type + signNumber)

If a type needs calculation or a data lookup, the type definition goes in `options` and the logic goes in `core` (see `DignityType` in options → `Dignity` class in core, `Being` in options → `BeingData` in core).

## Core data tables and calculations

Static data + computation lives in `core` as classes with private constructors and static methods/constants. Pattern:

| Class | Data | Calculation |
|-------|------|-------------|
| `SignData` | lords, elements, qualities, genders, names (1-12) | `SignData.lord(sign)` etc. |
| `Dignity` | exaltation, debilitation, moolatrikona, ownSigns, friendshipTable, combustionOrbs | `Dignity.calculate(body, sign, deg, lordSign)`, `Dignity.isCombust(...)` |
| `BeingData` | 60-entry map: (sign, BeingType) → Being | `BeingData.forSign(sign, type)` |
| `NakshatraData` | lords, deities, names (1-27) | `NakshatraData.lord(nak)` etc. |

## Longitude

`Longitude` is the core coordinate object. Constructed with ecliptic longitude + `VargaType` + `CalcConfig`. Eagerly computes varga-transformed longitude and deity on construction.

- `sign` (1-12) — circle-aware via `signIndex`
- `inSignLongitude` (0-30°) — `longitude % 30`
- `nakshatra` (1-27), `pada` (1-4) — computed from nakshatra-specific longitude (which may be equatorial, per config)

Sign and nakshatra use **independent** ayanamsas and reference frames. `signAyanamsa` (from SweConfig) controls signs. `nakAyanamsa` (SweConfig — the nak-frame longitudes are SWE-computed into the snapshot) + `nakEquatorial` (CalcConfig — picks which pre-computed map to read) control nakshatras. The Dhruva ayanamsa is equatorial-only.

## Chart and Varga

`Chart` is the top-level entry point: `Chart(snapshot, config)`. It lazily builds a `Varga` cache.

`Varga` is a divisional chart view. It constructs `Karaka` (for the 7 embodied planets) and `Planet` (for Rahu, Ketu, outers) from the snapshot. `Rashi` extends `Varga` for D1, adding nakshatra grouping.

`Chart` provides typed accessors: `chart.sun` (Karaka), `chart.rahu` (Planet), `chart.karakas` (List<Karaka>, 7), `chart.grahas` (List<Planet>, 9), `chart.planets` (all).

## Body groupings

`Body` enum has 13 values: sun through ketu + 4 outers + chiron.

- `Body.karakas` — 7 embodied planets (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn). These get `Karaka` instances with dignity and combustion.
- `Body.grahas` — 9 Vedic grahas (karakas + Rahu, Ketu). These are the standard set for most Vedic calculations.

Rahu/Ketu: Ketu is never directly calculated by SWE — computed as Rahu + 180°, latitude negated.

## SWE handles

`SweFacade.calcAll()` is synchronous. Since the swisseph_rs migration there is no SWE global state to sequence around: config (ephe path, JPL file, sidereal mode, topocentric) lives in an `EphemerisConfig` attached to an `Ephemeris` handle, plus per-call overrides on `calcUtWithConfig`. `SweFacade` keeps a `Map<(EphemerisSource, SiderealMode?), Ephemeris>` cache because `housesEx2`/`getAyanamsaUt` read handle-level config with no per-call override. Call `dispose()` to close the handles.

## Testing

Tests live in per-package `test/` directories. `core/test/helpers/stub_snapshot.dart` provides `stubSnapshot()` — a minimal `EphSnapshot` with hardcoded longitudes for unit testing without SWE.

Tests access `src/` files directly for internal details. Golden file tests compare Arrow output against JSON fixtures generated by libaditya (the Python reference implementation).

Integration tests (SWE-dependent) exist in `swe/test/` and `calc/test/integration/`.

## Presets

`ArrowPresets` provides named configurations:
- `aditya` — tropical + Campanus + Aditya circle + Dhruva nak (Ernst Wilhelm's system)
- `lahiriVedic` — Lahiri sidereal + whole-sign + zodiac circle
- `westernTropical` — tropical + Placidus + zodiac circle + 10 bodies

## Key files

| File | What |
|------|------|
| `options/lib/src/calc_config.dart` | CalcConfig (circle, traditions, zodiac system) |
| `options/lib/src/swe_config.dart` | SweConfig (ayanamsa, house system, bodies) |
| `options/lib/src/circle.dart` | Circle enum (zodiac vs aditya) |
| `options/lib/src/body.dart` | Body enum + karakas/grahas groupings |
| `options/lib/src/ayanamsa.dart` | 50+ ayanamsa codes including Dhruva |
| `options/lib/src/varga_type.dart` | 29 divisional chart types |
| `swe/lib/src/swe_facade.dart` | SweFacade.calcAll — the full SWE pipeline |
| `swe/lib/src/eph_snapshot.dart` | EphSnapshot — the SWE/domain boundary |
| `core/lib/src/longitude.dart` | Longitude — varga + circle + nak computation |
| `core/lib/src/sky_object.dart` | SkyObject base class |
| `core/lib/src/chart.dart` | Chart entry point |
| `core/lib/src/dignity.dart` | Dignity tables + calculation |
| `core/lib/src/varga_math.dart` | 16 pure varga math functions |
| `calc/lib/src/vedic/lajjitaadi.dart` | Lajjitaadi (most complex avastha) |
| `calc/lib/src/vedic/vimshottari.dart` | Vimshottari dasha engine |

## Architecture docs

Design documents and planning artifacts live in `claude/arch/`:
- `domain-model.md` — rich-objects-that-don't-own-data design rationale
- `universal-options.md` — multi-tradition CalcConfig modular design
- `tropical-aditya-distinction.md` — Circle enum and the 30° offset

Implementation plans in `claude/impl/`. Feature gap inventory in `docs/to-implement.md`.

## Agent skills

### Issue tracker

Yojana (`arjuna/arrow`). See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary (needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context. See `docs/agents/domain.md`.
