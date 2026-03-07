# Universal Options Architecture for Arrow

## The Problem

The current `CalcConfig` is a flat class of ~25 Vedic-specific fields. Every field is always present, always deserialized, always carried through the system. This works for one tradition but collapses when you add Hellenistic, modern Western, Uranian, Persian, Cards of Truth, and the dozens of variations within Vedic itself.

A flat class for all traditions would have 200+ fields, most irrelevant to any given chart. Worse, the fields interact in tradition-specific ways — a Hellenistic time lord has no relationship to a Vedic dasha year length, but both would live on the same object.

## Key Insight: Three Layers, Three Scopes

The 3-layer pipeline already solves the hardest part. **SWE doesn't care about traditions.** Planetary positions are planetary positions — tropical longitude, latitude, distance, speed. The ayanamsa correction, house system, and body selection are the only SWE-level choices, and they're already tradition-agnostic.

The tradition-specific complexity lives entirely in `CalcConfig` and `arrow_calc`. So the redesign is:

1. **SweConfig** — expand slightly (more bodies), stays flat, stays tradition-agnostic
2. **CalcConfig** — replace flat class with modular, tradition-scoped config
3. **arrow_calc** — pluggable tradition modules that consume their own config slice

## Layer 1: SweConfig (Minor Expansion)

SweConfig is already correct in structure. It just needs more bodies:

```dart
/// Which celestial bodies to calculate positions for.
/// SWE calculates only requested bodies — this controls cost.
enum Body {
  // Classical 7 + nodes (current)
  sun, moon, mars, mercury, jupiter, venus, saturn,
  rahuTrue, rahuMean, ketuTrue, ketuMean,

  // Outers (Western, Uranian)
  uranus, neptune, pluto,

  // Centaurs / minor bodies (modern Western, evolutionary)
  chiron, pholus, nessus, chariklo,

  // Main belt asteroids (asteroid astrology, some Hellenistic)
  ceres, pallas, juno, vesta, eris,

  // Hypothetical planets (Uranian / Hamburg School)
  cupido, hades, zeus, kronos, apollon, admetos, vulkanus, poseidon,

  // Lilith variants
  lilithMean,     // mean lunar apogee (Black Moon Lilith)
  lilithTrue,     // oscillating lunar apogee
  lilithInterp,   // interpolated (Delphine Jay)

  // Lots / Arabic parts are calculated points, not SWE bodies — handled in CalcConfig

  // Fixed stars are queried by name, not enumerated here
}

abstract class SweConfig {
  // Existing — unchanged
  Ayanamsa get signAyanamsa;
  Ayanamsa get nakAyanamsa;
  HouseSystem get houseSystem;
  HouseCuspMode get houseCuspMode;
  bool get trueNode;
  bool get topocentric;
  NakshatraCalcMode get nakCalcMode;
  RiseMode get riseMode;
  double? get userArc;
  double? get userEpoch;

  // New: which bodies to calculate
  Set<Body> get bodies;

  // New: fixed stars to calculate (by catalog name, e.g. 'Regulus', 'Aldebaran')
  Set<String> get fixedStars;
}
```

**EphSnapshot expansion:**

```dart
@freezed
class EphSnapshot with _$EphSnapshot {
  const factory EphSnapshot({
    required Map<Body, PlanetPosition> planets,   // was Map<int, ...>
    required List<double> houseCusps,
    required AscMcPoints ascmc,
    required double signAyanamsa,
    required double nakAyanamsa,
    required ArrowOptions options,

    // New
    @Default({}) Map<String, FixedStarPosition> fixedStars,
  }) = _EphSnapshot;
}
```

The `Map<int, PlanetPosition>` keyed by sweph integer ID becomes `Map<Body, PlanetPosition>`. The `Body` enum handles the mapping to sweph IDs internally. This is cleaner and tradition-agnostic.

### Default body sets

```dart
/// Convenience body sets for common traditions
class BodySets {
  static const vedic7 = {
    Body.sun, Body.moon, Body.mars, Body.mercury,
    Body.jupiter, Body.venus, Body.saturn,
    Body.rahuTrue, Body.ketuTrue,
  };

  static const western10 = {
    ...vedic7,
    Body.uranus, Body.neptune, Body.pluto,
  };

  static const westernFull = {
    ...western10,
    Body.chiron, Body.lilithMean,
    Body.ceres, Body.pallas, Body.juno, Body.vesta,
  };

  static const uranian = {
    ...western10,
    Body.cupido, Body.hades, Body.zeus, Body.kronos,
    Body.apollon, Body.admetos, Body.vulkanus, Body.poseidon,
  };
}
```

## Layer 2: CalcConfig (Modular Redesign)

### The Core Idea: Tradition Modules

Replace the flat `CalcConfig` with a small shared core plus optional, typed tradition modules. Each tradition module is a freezed class with only its own options. A chart carries only the modules it needs.

```dart
/// Shared options that apply regardless of tradition
abstract class CalcCore {
  /// Which astrological traditions are active for this chart.
  /// Determines which analysis modules run.
  Set<Tradition> get traditions;
}

enum Tradition {
  vedic,
  hellenistic,
  modernWestern,
  uranian,
  persian,
  cardsOfTruth,
  chinese,
  // extensible
}
```

### Tradition Config Classes

Each tradition gets its own freezed config class. These are self-contained — they don't reference each other.

```dart
// ── Vedic ──────────────────────────────────────────────

@freezed
class VedicConfig with _$VedicConfig {
  const factory VedicConfig({
    // circle
    @Default(Circle.aditya) Circle circle,

    // dignity & friendship
    @Default(true) bool tempFriendshipFromRashi,
    @Default(AshtakavargaMethod.parashara) AshtakavargaMethod ashtakavargaMethod,
    @Default(CombustionMethod.suryaSiddhanta) CombustionMethod combustionMethod,

    // vargas
    @Default(D10Method.revForEvenRashis) D10Method d10Method,
    @Default(D24Method.revForEvenRashis) D24Method d24Method,
    @Default(D30Method.rashi30) D30Method d30Method,

    // jaimini
    @Default(8) int jaiminiKarakaCount,
    @Default(CharaKaraka8th.lagna) CharaKaraka8th charaKaraka8th,
    @Default(RashiAspectMode.conventional) RashiAspectMode rashiAspectMode,
    @Default(AdarashaRashi.side) AdarashaRashi adarashaRashi,

    // misc
    @Default(MoonFatalDegreeSource.phaladeepika) MoonFatalDegreeSource moonFatalDegreeSource,
    @Default(VaraMode.yamaKoti) VaraMode varaMode,

    // dasha
    @Default(YearLength.saura) YearLength nakshatraDashaYear,
    @Default(YearLength.saura) YearLength rashiDashaYear,
    @Default(DashaSourceBody.moon) DashaSourceBody nakshatraDashaSource,

    // tajika / varshaphala
    @Default(true) bool moonAsVarshaPati,
    @Default(false) bool simpleAspectsForVarshaPati,
    @Default(false) bool varshaPatiCandidacyCountPriority,
    @Default(false) bool equalHouseCuspsForSahams,
  }) = _VedicConfig;

  factory VedicConfig.fromJson(Map<String, dynamic> json) =>
      _$VedicConfigFromJson(json);
}

// ── Hellenistic ────────────────────────────────────────

@freezed
class HellenisticConfig with _$HellenisticConfig {
  const factory HellenisticConfig({
    // sect
    @Default(true) bool useSect,     // diurnal/nocturnal distinction

    // lots (Arabic Parts)
    @Default(LotFormula.traditional) LotFormula lotOfFortune,
    @Default(true) bool reverseLotFormulaByNight,

    // bounds/terms
    @Default(BoundsSystem.egyptian) BoundsSystem boundsSystem,

    // aspects
    @Default(true) bool useSignBasedAspects,     // whole-sign aspects
    @Default(true) bool useDegreeBasedAspects,   // Ptolemaic degree aspects
    @Default(OrbStyle.moiety) OrbStyle orbStyle,  // moiety vs fixed orbs

    // time lords
    @Default(true) bool calcZodiacalReleasing,
    @Default(true) bool calcAnnualProfections,
    @Default(false) bool calcDecennials,
    @Default(false) bool calc129YearSystem,

    // dignities
    @Default(TriplicitySystem.dorotheus) TriplicitySystem triplicitySystem,

    // fixed stars
    @Default(true) bool useRoyalStars,
    @Default(1.0) double fixedStarOrb,
  }) = _HellenisticConfig;

  factory HellenisticConfig.fromJson(Map<String, dynamic> json) =>
      _$HellenisticConfigFromJson(json);
}

enum BoundsSystem { egyptian, ptolemaic, chaldean }
enum TriplicitySystem { dorotheus, ptolemy, morin }
enum LotFormula { traditional, ptolemaic }
enum OrbStyle { moiety, fixedOrb }

// ── Modern Western ─────────────────────────────────────

@freezed
class ModernWesternConfig with _$ModernWesternConfig {
  const factory ModernWesternConfig({
    // aspects
    @Default(AspectSet.major) AspectSet aspectSet,
    @Default({}) Map<WesternAspect, double> orbOverrides,  // per-aspect orbs

    // midpoints
    @Default(false) bool calcMidpoints,
    @Default(MidpointDial.d360) MidpointDial midpointDial,

    // patterns
    @Default(true) bool calcAspectPatterns,   // grand trine, t-square, yod, etc.

    // progressions
    @Default(ProgressionType.secondary) ProgressionType defaultProgression,
    @Default(SolarArcMethod.naibod) SolarArcMethod solarArcMethod,

    // returns
    @Default(true) bool calcSolarReturn,
    @Default(true) bool calcLunarReturn,

    // retrograde shadow
    @Default(false) bool showRetrogradeShadow,
  }) = _ModernWesternConfig;

  factory ModernWesternConfig.fromJson(Map<String, dynamic> json) =>
      _$ModernWesternConfigFromJson(json);
}

enum AspectSet { major, majorMinor, all }
enum WesternAspect {
  conjunction, opposition, trine, square, sextile,           // major
  semisextile, quincunx, semisquare, sesquiquadrate,         // minor
  quintile, biquintile, septile, novile,                     // harmonic
}
enum MidpointDial { d360, d90, d45 }
enum ProgressionType { secondary, tertiary, minor, solarArc }
enum SolarArcMethod { naibod, trueArc }

// ── Uranian / Hamburg School ───────────────────────────

@freezed
class UranianConfig with _$UranianConfig {
  const factory UranianConfig({
    @Default(MidpointDial.d90) MidpointDial primaryDial,
    @Default(true) bool calcPlanetaryPictures,
    @Default(true) bool useTransNeptunians,   // Cupido, Hades, Zeus, etc.
    @Default(0.5) double midpointOrb,
    @Default(true) bool calcSensitivePoints,
    @Default(true) bool showMidpointTrees,
  }) = _UranianConfig;

  factory UranianConfig.fromJson(Map<String, dynamic> json) =>
      _$UranianConfigFromJson(json);
}

// ── Persian / Medieval ─────────────────────────────────

@freezed
class PersianConfig with _$PersianConfig {
  const factory PersianConfig({
    // lots — Persian tradition uses many more lots than Hellenistic
    @Default(true) bool calcAllLots,
    @Default({}) Set<PersianLot> activeLots,

    // firdaria
    @Default(true) bool calcFirdaria,
    @Default(FirdariaSystem.alBiruni) FirdariaSystem firdariaSystem,

    // profections
    @Default(true) bool calcProfections,

    // halb (planetary hour lord based periods)
    @Default(false) bool calcHalb,

    // al-mubtazz (almuten)
    @Default(AlmutenMethod.ibnEzra) AlmutenMethod almutenMethod,
  }) = _PersianConfig;

  factory PersianConfig.fromJson(Map<String, dynamic> json) =>
      _$PersianConfigFromJson(json);
}

enum FirdariaSystem { alBiruni, bonatti, schoener }
enum AlmutenMethod { ibnEzra, bonatti, lilly }
enum PersianLot { fortune, spirit, eros, necessity, courage, victory, nemesis /* ... */ }

// ── Cards of Truth ─────────────────────────────────────

@freezed
class CardsOfTruthConfig with _$CardsOfTruthConfig {
  const factory CardsOfTruthConfig({
    @Default(CardDeck.standard52) CardDeck deck,
    @Default(true) bool showPlanetaryRulers,
    @Default(true) bool showKarmicCards,
    @Default(SpreadType.yearly) SpreadType defaultSpread,
  }) = _CardsOfTruthConfig;

  factory CardsOfTruthConfig.fromJson(Map<String, dynamic> json) =>
      _$CardsOfTruthConfigFromJson(json);
}

enum CardDeck { standard52, extended53 }
enum SpreadType { yearly, weekly, lifetime }
```

### The Unified CalcConfig

```dart
@freezed
class CalcConfig with _$CalcConfig {
  const factory CalcConfig({
    /// Active traditions — determines which modules are consulted
    @Default({Tradition.vedic}) Set<Tradition> traditions,

    /// Tradition-specific configs. Only create the ones you need.
    /// null means "use defaults if tradition is active, skip if not"
    VedicConfig? vedic,
    HellenisticConfig? hellenistic,
    ModernWesternConfig? modernWestern,
    UranianConfig? uranian,
    PersianConfig? persian,
    CardsOfTruthConfig? cardsOfTruth,
  }) = _CalcConfig;

  factory CalcConfig.fromJson(Map<String, dynamic> json) =>
      _$CalcConfigFromJson(json);
}
```

### How Functions Consume It

Functions declare exactly what they need:

```dart
// Vedic dasha calculator only needs VedicConfig
List<DashaPeriod> calcVimshottari(EphSnapshot snap, VedicConfig config);

// Hellenistic time lords only need HellenisticConfig
List<TimeLordPeriod> calcZodiacalReleasing(EphSnapshot snap, HellenisticConfig config);

// Uranian midpoints need UranianConfig
List<Midpoint> calcMidpoints(EphSnapshot snap, UranianConfig config);

// Cross-tradition: an analysis runner checks which traditions are active
FullAnalysis analyze(EphSnapshot snap, CalcConfig config) {
  final results = <AnalysisResult>[];

  if (config.traditions.contains(Tradition.vedic)) {
    final vc = config.vedic ?? const VedicConfig();
    results.add(analyzeVedic(snap, vc));
  }
  if (config.traditions.contains(Tradition.hellenistic)) {
    final hc = config.hellenistic ?? const HellenisticConfig();
    results.add(analyzeHellenistic(snap, hc));
  }
  // ...
  return FullAnalysis(results);
}
```

### Presets

Named presets replace magic defaults:

```dart
class ArrowPresets {
  /// Ernst Wilhelm's system (current defaults)
  static const ernst = ArrowOptions(
    sweConfig: SweConfig(
      signAyanamsa: Ayanamsa.tropical,
      nakAyanamsa: Ayanamsa.dhruva,
      houseSystem: HouseSystem.campanus,
      bodies: BodySets.vedic7,
    ),
    calcConfig: CalcConfig(
      traditions: {Tradition.vedic},
      vedic: VedicConfig(circle: Circle.aditya),
    ),
  );

  /// Traditional Lahiri Vedic
  static const lahiriVedic = ArrowOptions(
    sweConfig: SweConfig(
      signAyanamsa: Ayanamsa.lahiri,
      nakAyanamsa: Ayanamsa.lahiri,
      houseSystem: HouseSystem.equal,
      bodies: BodySets.vedic7,
    ),
    calcConfig: CalcConfig(
      traditions: {Tradition.vedic},
      vedic: VedicConfig(circle: Circle.zodiac),
    ),
  );

  /// Hellenistic (whole sign, tropical)
  static const hellenistic = ArrowOptions(
    sweConfig: SweConfig(
      signAyanamsa: Ayanamsa.tropical,
      houseSystem: HouseSystem.equal,     // whole sign
      bodies: BodySets.vedic7,            // traditional 7
    ),
    calcConfig: CalcConfig(
      traditions: {Tradition.hellenistic},
      hellenistic: HellenisticConfig(),
    ),
  );

  /// Modern Western (Placidus, tropical, full planets)
  static const modernWestern = ArrowOptions(
    sweConfig: SweConfig(
      signAyanamsa: Ayanamsa.tropical,
      houseSystem: HouseSystem.placidus,
      bodies: BodySets.westernFull,
    ),
    calcConfig: CalcConfig(
      traditions: {Tradition.modernWestern},
      modernWestern: ModernWesternConfig(),
    ),
  );

  /// Uranian / Hamburg School
  static const uranianHamburg = ArrowOptions(
    sweConfig: SweConfig(
      signAyanamsa: Ayanamsa.tropical,
      houseSystem: HouseSystem.equal,
      bodies: BodySets.uranian,
    ),
    calcConfig: CalcConfig(
      traditions: {Tradition.uranian},
      uranian: UranianConfig(),
    ),
  );

  /// Multi-tradition: Vedic + Hellenistic overlay
  static const vedicHellenistic = ArrowOptions(
    sweConfig: SweConfig(
      signAyanamsa: Ayanamsa.tropical,
      nakAyanamsa: Ayanamsa.dhruva,
      houseSystem: HouseSystem.campanus,
      bodies: BodySets.vedic7,
    ),
    calcConfig: CalcConfig(
      traditions: {Tradition.vedic, Tradition.hellenistic},
      vedic: VedicConfig(circle: Circle.aditya),
      hellenistic: HellenisticConfig(),
    ),
  );
}
```

## Layer 3: arrow_calc (Pluggable Modules)

Each tradition gets its own package or subdirectory within `arrow_calc`:

```
arrow_calc/
  lib/
    vedic/
      dashas/          # vimshottari, yogini, ashtottari, rashi dashas...
      shadbala.dart
      ashtakavarga.dart
      yogas.dart
      jaimini.dart
      muhurtha.dart
      compatibility.dart
      avasthas.dart
    hellenistic/
      time_lords/      # zodiacal releasing, profections, decennials
      lots.dart        # lot of fortune, spirit, etc.
      sect.dart
      bounds.dart
      dignities.dart   # triplicity, terms, face
    western/
      aspects.dart     # orb-based, aspect patterns
      midpoints.dart
      progressions.dart
      returns.dart
    uranian/
      midpoints.dart   # 90° dial, planetary pictures
      sensitive_points.dart
    persian/
      firdaria.dart
      lots.dart
      almuten.dart
    cards/
      birth_card.dart
      spreads.dart
```

Each module:
- Takes `EphSnapshot` + its own tradition config
- Returns typed result objects
- Has zero dependencies on other tradition modules
- Can be tree-shaken — if the app never imports `arrow_calc/uranian`, that code never ships

## The ArrowOptions Composition

```dart
@freezed
class ArrowOptions with _$ArrowOptions {
  const factory ArrowOptions({
    required SweConfig sweConfig,
    required CalcConfig calcConfig,
  }) = _ArrowOptions;

  factory ArrowOptions.fromJson(Map<String, dynamic> json) =>
      _$ArrowOptionsFromJson(json);
}
```

This is a clean break from the current design where `ArrowOptions` implements both `SweConfig` and `CalcConfig` interfaces directly. Now it composes them. The `SweConfig` and `CalcConfig` are themselves freezed classes (not abstract interfaces).

Functions still declare what they need:

```dart
// SWE layer
EphSnapshot calcAll(double jd, Location loc, SweConfig config);

// Tradition-specific analysis
List<DashaPeriod> calcVimshottari(EphSnapshot snap, VedicConfig config);

// Full analysis
FullAnalysis analyze(EphSnapshot snap, CalcConfig config);
```

## SWE Invalidation (Unchanged Logic)

```dart
extension SweInvalidation on ArrowOptions {
  bool sweChanged(ArrowOptions other) => sweConfig != other.sweConfig;
}
```

Since `SweConfig` is a freezed class, `!=` checks structural equality. Any SweConfig field change invalidates the snapshot. CalcConfig changes remain free.

## Migration Path

The current `types-sketch.dart` maps exactly to the `VedicConfig` fields. No calculation logic changes — just reorganization:

1. Extract current `CalcConfig` fields into `VedicConfig`
2. Wrap in new `CalcConfig(traditions: {Tradition.vedic}, vedic: VedicConfig(...))`
3. Change `ArrowOptions` from implementing interfaces to composing `SweConfig` + `CalcConfig`
4. Update function signatures from `CalcConfig config` to `VedicConfig config` where tradition-specific

Vedic calculations don't change at all. The new structure just makes room for everything else.

## What This Enables

- **Single chart, multiple traditions**: A Hellenistic astrologer who also uses Vedic techniques gets both analyses from one EphSnapshot. No duplicate SWE calls.
- **Clean defaults**: `ArrowPresets.ernst` gives you exactly what Kala does today. `ArrowPresets.hellenistic` gives a clean Hellenistic setup. Users start from a preset and customize.
- **Tree-shaking**: A Vedic-only app never ships Uranian midpoint code. A Western-only app never ships dasha code.
- **Type safety**: A Vedic function can't accidentally read a Hellenistic option. Each function takes exactly the config it needs.
- **Future traditions**: Adding Chinese astrology means adding `ChineseConfig`, a `chinese/` directory in arrow_calc, and a `Tradition.chinese` enum value. Nothing else changes.
- **Professional desktop (Quiver)**: The desktop pro app can enable all traditions simultaneously, running heavy multi-tradition analysis locally with full CPU.

## Open Questions

1. **Aspect systems**: Vedic uses graha drishti (fixed aspect rules per planet). Hellenistic uses whole-sign + degree aspects with moiety. Western uses orb-based aspects with configurable orbs. These are fundamentally different systems. Should `aspects` be tradition-scoped (each tradition has its own aspect engine) or a shared engine with tradition-specific rules? Leaning toward tradition-scoped — the logic is too different.

2. **Dignity systems**: Vedic dignities (own sign, moolatrikona, exaltation, debilitation + friendship) vs Hellenistic (domicile, exaltation, triplicity, bounds, face) vs Western (essential + accidental). Similar question. Likely tradition-scoped since the dignity tables themselves differ.

3. **Body semantics**: In Vedic, Rahu/Ketu are first-class grahas. In Hellenistic, the nodes are sensitive points, not planets. In Western, Chiron is a centaur with planetary significance. The `Body` enum is shared (SWE positions are positions), but the *meaning* is tradition-specific. This is handled at the analysis layer, not the data layer.

4. **Cards of Truth**: This system DOES need SWE — the birth card is based on the time of sunrise at the equator corresponding to the native's longitude line, and the system also uses planet placements. It flows through the standard Arrow pipeline like every other tradition. `CardsOfTruthConfig` controls its specific options; arrow_calc/cards/ consumes EphSnapshot like everything else.

5. **Human Design**: Also fundamentally SWE-based. Uses precise planetary positions (especially gate/line placement derived from longitudes). Will be added as another tradition module following the same pattern.

All traditions are fundamentally based on birth time, place, and planetary/stellar positions at that time. The Arrow pipeline (SWE -> EphSnapshot -> derivation -> analysis) serves all of them. No tradition is "outside" the pipeline.
