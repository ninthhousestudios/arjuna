# Human Design — Implementation Plan

Port HD calculations from `libaditya/hd/` into Arrow as a new tradition alongside Vedic.

## What exists in Arrow

- `options/lib/src/tradition.dart` — `Tradition` enum (currently only `vedic`)
- `options/lib/src/calc_config.dart` — `CalcConfig` (freezed), planned but not yet present `HumanDesignConfig` field
- `swe/` — full Swiss Ephemeris facade, can compute positions for all required bodies including Chiron, Uranus, Neptune, Pluto
- No HD calculations of any kind

## What libaditya provides

- Conscious (natal) planetary positions — direct from birth chart
- Unconscious (design) positions via 88-degree Sun algorithm
- Hexagram wheel mapping: longitude → gate/line/color/tone/base
- Gate activation for both personality and design
- Bodygraph: gate lists, channel activation, center activation (partially — channel/center tables not fully present in libaditya)

## The 88-degree Sun algorithm (Design timestamp)

The key unique calculation in HD:

1. `soughtLon = (birthSunLon - 88) % 360`
2. Go back 95 days from birth
3. Find the next moment the Sun reaches `soughtLon` (solar ingress root-finding)
4. Compute all planets at that moment → design (unconscious) positions

This requires a **solar ingress finder** — a function that finds the Julian Day when the Sun crosses a specific ecliptic longitude.

## Hexagram wheel decomposition

### Constants

```
gateOne = 223.25°       # tropical ecliptic start of Gate 1
gateArc = 360 / 64      # = 5.625° per gate
lineArc = gateArc / 6   # = 0.9375° per line
colorArc = lineArc / 6  # = 0.15625° per color
toneArc = colorArc / 6  # = 0.026041...° per tone
baseArc = toneArc / 5   # = 0.005208...° per base
```

Total subdivisions: 64 x 6 x 6 x 6 x 5 = 69,120 bases in 360°.

### Algorithm

```
dist = (longitude - gateOne) % 360

basesTotal = floor(dist / baseArc)
(tonesTot, base)  = divmod(basesTotal, 5);  base  += 1   # 1–5
(colorsTot, tone) = divmod(tonesTot, 6);    tone  += 1   # 1–6
(linesTot, color) = divmod(colorsTot, 6);   color += 1   # 1–6
(gateIdx, line)   = divmod(linesTot, 6);    line  += 1   # 1–6

gate = wheel[gateIdx]    # 64-element lookup
```

### The wheel (gate order around the mandala)

```
[1, 43, 14, 34, 9, 5, 26, 11, 10, 58, 38, 54, 61, 60, 41, 19,
 13, 49, 30, 55, 37, 63, 22, 36, 25, 17, 21, 51, 42, 3, 27, 24,
 2, 23, 8, 20, 16, 35, 45, 12, 15, 52, 39, 53, 62, 56, 31, 33,
 7, 4, 29, 59, 40, 64, 47, 6, 46, 18, 48, 57, 32, 50, 28, 44]
```

### Planets used

Sun, Earth (= Sun + 180°), Moon, Rahu, Ketu (= Rahu + 180°), Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto. Chiron is included but noted as non-gate-activating.

## Channels and centers

libaditya does **not** include the 36 channel pairs or 9 center definitions — these must be sourced independently and hard-coded. Standard HD reference data:

- **36 channels**: each defined by a pair of gate numbers
- **9 centers**: Head, Ajna, Throat, G/Self, Heart/Ego, Sacral, Spleen, Solar Plexus, Root
- **Each center** has a specific set of gates assigned to it
- A **channel is defined** when both its gates appear in the combined (conscious + unconscious) gate list
- A **center is defined** when at least one of its channels is defined

Type and Authority derivation depend on which centers are defined — these are standard HD rules to implement as a lookup.

## Implementation

### Layer mapping

```
arrow_options:  Tradition.humanDesign, HumanDesignConfig
arrow_swe:      solarIngress() — new utility
arrow_core:     HdPosition, Bodygraph domain objects
arrow_calc:     HdCalc — channel/center/type/authority logic
```

### New in `arrow_options`

Add `humanDesign` to `Tradition` enum.

```dart
@freezed
class HumanDesignConfig with _$HumanDesignConfig {
  const factory HumanDesignConfig({
    @Default(223.25) double gateOne,
  }) = _HumanDesignConfig;
}
```

Add to `CalcConfig`:
```dart
@Default(null) HumanDesignConfig? humanDesign,
```

### New in `arrow_swe`: Solar ingress finder

```dart
static double solarIngress({
  required double targetLon,
  required double searchFromJd,
  // Uses binary search over calcPlanet(jd, Body.sun).lon
  // Converge to sub-arcsecond precision
});
```

This is also useful for solar returns (another planned feature). Implement as a general `planetIngress(Body, targetLon, searchFromJd)` that works for any body.

Alternative: check if `sweph.dart` exposes `swe_solcross` or `swe_solcross_ut` — if so, use it directly.

### New in `arrow_core`

**`core/lib/src/hd/hd_position.dart`**:
```dart
class HdPosition {
  final int gate;    // 1–64
  final int line;    // 1–6
  final int color;   // 1–6
  final int tone;    // 1–6
  final int base;    // 1–5

  factory HdPosition.fromLongitude(double tropicalLon, {double gateOne = 223.25});
}
```

**`core/lib/src/hd/hd_constants.dart`**:
```dart
const hdWheel = [1, 43, 14, ...];  // 64 entries
const hdChannels = [(64, 47), (61, 24), ...];  // 36 pairs — source independently
const hdCenterGates = {
  HdCenter.head: [64, 61, 63],
  HdCenter.ajna: [47, 24, 4, 17, 43, 11],
  // ...
};
```

**`core/lib/src/hd/bodygraph.dart`**:
```dart
class Bodygraph {
  final Map<Body, HdPosition> conscious;
  final Map<Body, HdPosition> unconscious;
  List<int> get consciousGates => ...;
  List<int> get unconsciousGates => ...;
  List<int> get allGates => ...;
}
```

### New in `arrow_calc`

**`calc/lib/src/hd/hd_calc.dart`**:
```dart
class HdCalc {
  const HdCalc._();

  static double designJd({required double birthSunLon, required double birthJd});
  static Bodygraph bodygraph({
    required EphSnapshot conscious,
    required EphSnapshot unconscious,
    double gateOne = 223.25,
  });
  static List<(int, int)> definedChannels(List<int> allGates);
  static Set<HdCenter> definedCenters(List<(int, int)> definedChannels);
  static HdType type(Set<HdCenter> definedCenters);
  static HdAuthority authority(Set<HdCenter> definedCenters, HdType type);
}
```

### Enums

```dart
enum HdCenter { head, ajna, throat, gSelf, heartEgo, sacral, spleen, solarPlexus, root }
enum HdType { manifestor, generator, manifestingGenerator, projector, reflector }
enum HdAuthority { emotional, sacral, splenic, ego, self, none }  // simplified
```

## Testing

### Unit tests

- `HdPosition.fromLongitude` — known longitudes → expected gate/line/color/tone/base
- Wheel boundary: longitude exactly at gateOne → Gate 1, Line 1
- Wheel wrap: longitude just before gateOne → Gate 44 (last in wheel)
- Earth = Sun + 180° → verify complementary gates
- Channel detection: provide gate list with a known channel pair → detected
- Center activation: define a channel → its two centers are defined

### Integration tests

- Full pipeline: birth JD → design JD → both snapshots → bodygraph → channels → centers → type → authority
- Compare against known HD charts (publicly available)

### Golden tests

Generate from libaditya for known birth charts: gate lists for conscious and unconscious.

## Dependencies

- `arrow_options` — `Body`, `Tradition`, `HumanDesignConfig`
- `arrow_swe` — `EphSnapshot`, `SweFacade` (for ingress search)
- `arrow_core` — new HD domain objects
- No dependency on Vedic calc modules

## Sequence

1. `HumanDesignConfig` + `Tradition.humanDesign` in options
2. `HdPosition.fromLongitude` + wheel constant + unit tests (pure math, no SWE)
3. `hdChannels` and `hdCenterGates` constants (source from HD reference)
4. `solarIngress` / `planetIngress` utility in `arrow_swe` + tests
5. `designJd` computation (88° algorithm) + tests
6. `Bodygraph` domain object in core + tests
7. Channel detection + center activation + tests
8. Type and Authority derivation + tests
9. Integration test: full pipeline
10. Export from barrels

## Notes

- HD uses **tropical longitude only** — no ayanamsa. The `gateOne` constant (223.25°) is a fixed ecliptic offset, not zodiac-relative.
- Earth position is derived (Sun + 180°), not computed via SWE. Ketu is derived (Rahu + 180°).
- The `solarIngress` utility serves double duty — also needed for solar returns.
- Channel and center data must be independently sourced and verified. libaditya doesn't include these tables.
- The dream context (Moon 88° variant) is a secondary feature — implement after the standard personality/design pipeline works.
