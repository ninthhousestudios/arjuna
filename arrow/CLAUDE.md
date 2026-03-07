# Arrow

Arrow is the working name for a Dart rewrite of the astrology calculation engine. It will be a standalone Dart package (or set of packages) shared across all KalaAI apps (Celestial and future apps).

## Source Material

Arrow is ported from two existing codebases:
- **C# Astro**: `soft/kala/kalang/Astro/` — the original Kala calculation engine
- **Python libkala**: `soft/libkala/libkala/` — the Python calculation library

The product-level architecture doc is at `claude/arch/architecture.md` (in the ka root).

## Architecture

3-layer pipeline. Each layer only depends on the output of the previous one.

```
ArrowOptions (SweConfig + CalcConfig)
    |
    v
arrow_swe   — sweph.dart (dart:ffi to Swiss Ephemeris), ~15 functions
    |            OR: HTTP fallback to KalaBrain
    v
EphSnapshot — immutable, serializable (the bridge between SWE and non-SWE)
    |
    v
arrow_core  — pure Dart derivation: signs, nakshatras, vargas, dignities, karakas
    |            builds rich domain objects (Chart, Planet, Cusp) from EphSnapshot
    v
arrow_calc  — pure Dart analysis: dashas, yogas, shadbala, ashtakavarga, jaimini
```

Non-SWE code never calls SWE directly. It only sees the EphSnapshot.

## SWE Bindings

Use https://github.com/vm75/sweph.dart.git (the `sweph` package).

## Options

Two config interfaces implemented by one concrete `ArrowOptions` class (freezed):
- **SweConfig** — changes raw positions, triggers SWE recalculation
- **CalcConfig** — affects derived/analytical calculations only

Functions declare which interface they need in their signature, enforcing the SWE/non-SWE boundary at the type level.

## Domain Model

Rich objects that don't own their data. They wrap EphSnapshot + CalcConfig and provide ergonomic accessors (`chart.sun.nakshatra`) without calling SWE.

### Body Hierarchy

- **Karaka** — the 7 embodied planets (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn)
- **Graha** — karakas + Rahu and Ketu (9)
- **Planet** — grahas + Uranus, Neptune, Pluto (all)

`Planet` is the base class. `Graha` extends `Planet`. `Karaka` extends `Graha`. Dignity and combustion live on Karaka only.

### Cusps

`Cusp` — house cusp as a longitude point, with derived getters (sign, nakshatra, varga).

### What goes where

- **On the object**: things about this body/cusp in isolation (sign, nakshatra, dignity, retrograde, varga placement)
- **Functions taking the object**: relationships and multi-body analysis (aspects, yogas, dashas, shadbala, ashtakavarga)

## Design Docs

Detailed architecture and type sketches live in `claude/arch/`:
- `base-arch.md` — full architecture, options inventory, config interfaces
- `domain-model.md` — domain model rationale and class sketches
- `types-sketch.dart` — all enums, interfaces, ArrowOptions, EphSnapshot, function signatures
- `varga-constants.dart` — VargaDeity enum, vargaDeities lookup map, VargaResult; idiomatic Dart for domain constants
- `tropical-aditya-distinction.md` — Circle enum, sign formula, ayanamsa independence
- `universal-options.md` — Multi-tradition options architecture (Vedic, Hellenistic, Western, Uranian, Persian, Cards of Truth)

---

## Conversation Log

### 1. Starting point and scope

Reviewed the product architecture doc (`claude/arch/architecture.md`) which describes the overall Celestial ecosystem and the on-device vs server calculation split. Established that Arrow is the whole engine with two parts: SWE (Swiss Ephemeris via FFI) and non-SWE (pure Dart derived calculations). Most non-SWE code will be ported from C# Astro and Python libkala.

### 2. Surveyed the reference codebases

Read through the key files in both source codebases to understand the existing patterns:
- **Python libkala**: `EphContext` (flat dataclass with all options), `Planet` (rich object that calls SWE in its constructor, inherits from multiple mixins including `SWEFirstLast` and `SWERashi`), `SWERashi` (eclipse functions), `swe_functions.py` (heliacal phenomena)
- **C# Astro**: `EphData` (dumb data container — `double[13,6]` for planets, `double[13]` for houses), `PlanetData`, `CalculationOptions` (implements RSwissEph IOptions), `AstroTools` (static calculation methods), the full Options hierarchy (`FormatOptions -> BasicOptions -> AstroOptions`)

### 3. Proposed the 3-layer pipeline

Identified that the SWE surface area is only ~15 functions. Proposed three architecture options for the SWE part (minimal facade, batch-oriented, hybrid) and three patterns for how non-SWE interacts with SWE (data object, rich domain model, pipeline/layered transformation). Recommended the pipeline with a hybrid SWE layer — batch `calcAll` for the common case, specific functions for eclipses/heliacal. The key abstraction is `EphSnapshot`: immutable, serializable, the single bridge between SWE and non-SWE. Wrote `base-arch.md`.

### 4. SWE bindings decision

Decided to use https://github.com/vm75/sweph.dart.git for Swiss Ephemeris bindings.

### 5. Options management

Catalogued every option from both codebases. Identified three categories:
- **SWE-affecting**: ayanamsa (signs and nakshatras independently), house system (22 options), house cusp mode, true/mean node, topocentric, nakshatra calc mode, rise mode, custom ayanamsa
- **Derived-calculation**: temp friendship, ashtakavarga method, combustion method, varga variants (D10: 3, D24: 3, D30: 2), rashi aspect mode, jaimini karakas (7 or 8), chara karaka 8th, aya dasha mirror, moon fatal degree source, vara mode, year lengths for nakshatra and rashi dashas, dasha source planet, tajika options, D3 for Jaimini yogada table

Proposed 4 approaches for managing options:
1. Layered immutable config objects (nested freezed classes)
2. Single flat freezed class with extension methods
3. Typed interfaces over a single freezed class
4. Registry / key-value with typed access

Chose **Option 3** but collapsed to 2 interfaces: `SweConfig`, `CalcConfig`. One concrete `ArrowOptions` implements both. Functions declare which interface they need. DisplayConfig was considered but removed — Arrow is a calculation engine, not a display layer.

Corrections applied: D24 has 3 methods (contemporary, parivritti, reverse for even rashis — Astro had 2, libkala added parivritti). Added 7/8 jaimini karakas to calc options. Added D3 for Jaimini yogada table to calc options.

Wrote `types-sketch.dart` with all enums, interfaces, the concrete class with defaults, EphSnapshot, and example function signatures.

### 6. Rich domain model discussion

Evaluated the tradeoff between the Python approach (rich objects that own their SWE calls — ergonomic but coupled) and the C# approach (dumb data bags with static methods — decoupled but reads like accounting). Proposed the hybrid: rich objects that don't own their data. EphSnapshot stays dumb. arrow_core wraps it into `Chart`, `Planet`, `Cusp` objects that provide `chart.sun.nakshatra` style access without calling SWE. Drew the line: on-object for isolated properties, standalone functions for multi-body relationships.

### 7. Body hierarchy and naming

Renamed `Bhava` to `Cusp` (we're working with cusp points as longitudes, not houses). Renamed `Graha` to `Planet` as the base class and established the threefold distinction:
- **Karaka** (7 embodied) extends **Graha** (+ nodes = 9) extends **Planet** (+ outers = all)

Chart provides typed accessors: `chart.sun` returns Karaka, `chart.rahu` returns Graha, `chart.uranus` returns Planet. List accessors: `chart.karakas` (7), `chart.grahas` (9), `chart.planets` (all).

Wrote `domain-model.md`.

### 9. Tropical vs Aditya distinction (Circle enum)

Both Aditya and tropical charts use identical SWE longitudes. The distinction is purely in sign calculation: where does sign 1 start? Zodiac starts at 0° (vernal equinox); Aditya starts at 330° (30° earlier). This is pure derived math → `Circle` enum lives in `CalcConfig`, not `SweConfig`. `Circle` and `signAyanamsa` are fully independent — any ayanamsa can be used with either circle. See `claude/arch/tropical-aditya-distinction.md`.

Default: `Circle.aditya`.

Signs and nakshatras always have independent ayanamsas (`signAyanamsa` and `nakAyanamsa` in `SweConfig`). Primary use case: `signAyanamsa = tropical`, `nakAyanamsa = dhruva`. Dhruva is the Galactic Center / middle of Mula ayanamsa with equatorial coordinates, implemented in libkala. Default `nakAyanamsa` is `dhruva`.

### 10. Chart options patterns

- **CalcConfig changes are free**: same EphSnapshot, new Chart via `config.copyWith(...)`. Example: `Chart(chart.snapshot, chart.config.copyWith(circle: Circle.zodiac))`.
- **SweConfig changes require new EphSnapshot**: explicit `swe.calcAll(jd, loc, newOptions)` then new Chart.
- **Sidereal approximation**: for sign placement without SWE recalc, subtract the ayanamsa value stored in EphSnapshot from the tropical longitude. Good enough for most cases.

### 11. JSON serialization strategy

All data classes use `freezed` + `json_serializable`. Enums serialize by name, not integer (`'lahiri'` not `1`). `EphSnapshot.options` stores the full `ArrowOptions` (not just `SweConfig`), so a deserialized snapshot contains everything needed to reconstruct a `Chart`. Rich domain objects (`Chart`, `Planet`, etc.) are NOT serialized — they're views over `EphSnapshot` + `ArrowOptions`.

### 12. Memory and cross-directory access

Discussed that auto-memory is scoped to the project directory. Added an Arrow section to the parent `ka/CLAUDE.md` so the architecture is discoverable from anywhere in the monorepo.

### 13. Universal options architecture (multi-tradition)

The original CalcConfig is a flat class of ~25 Vedic-specific fields (specifically Ernst's system). Redesigned to support every astrological tradition — Vedic, Hellenistic, modern Western, Uranian/Hamburg, Persian/Medieval, Cards of Truth, and future additions.

Key design decisions:
- **SweConfig is already tradition-agnostic** — positions are positions. Expanded with `Set<Body> bodies` (asteroids, hypotheticals, Lilith variants, centaurs) and `Set<String> fixedStars`. Added `BodySets` convenience constants (vedic7, western10, westernFull, uranian).
- **CalcConfig becomes modular** — a small core (`Set<Tradition> traditions`) plus optional typed tradition configs: `VedicConfig`, `HellenisticConfig`, `ModernWesternConfig`, `UranianConfig`, `PersianConfig`, `CardsOfTruthConfig`. Each is a standalone freezed class. Null means "use defaults if active."
- **ArrowOptions composes** `SweConfig` + `CalcConfig` instead of implementing both as interfaces.
- **Named presets** replace magic defaults: `ArrowPresets.ernst`, `.lahiriVedic`, `.hellenistic`, `.modernWestern`, `.uranianHamburg`, `.vedicHellenistic` (multi-tradition).
- **Functions take exactly what they need**: `calcVimshottari(snap, VedicConfig)`, `calcZodiacalReleasing(snap, HellenisticConfig)`. Cross-tradition analysis runner checks `config.traditions`.
- **arrow_calc gets per-tradition subdirectories**: `vedic/`, `hellenistic/`, `western/`, `uranian/`, `persian/`, `cards/` — tree-shakeable.
- **Migration is zero-disruption**: current CalcConfig fields map exactly to VedicConfig. No calculation logic changes.

Current VedicConfig fields are identical to the existing flat CalcConfig. All Vedic enums (D10Method, CharaKaraka8th, etc.) unchanged.

Open questions: aspect systems (tradition-scoped vs shared engine), dignity systems (likely tradition-scoped), Cards of Truth (may not need SWE at all).

Wrote `claude/arch/universal-options.md`. Updated `base-arch.md` with cross-reference.
