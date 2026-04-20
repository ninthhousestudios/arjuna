# Shadbala — Implementation Plan

Port the six-fold strength system from `libaditya/objects/shadbala.py` into Arrow's calc layer.

## What exists in Arrow

- `core/lib/src/dignity.dart` — full dignity system (exaltation, debilitation, moolatrikona, own sign, natural/temporary/compound friendship, combustion)
- `calc/lib/src/vedic/aspect.dart` — Parashara drishti with continuous strength (0–60)
- `core/lib/src/varga.dart` — can compute any divisional chart
- Planet positions, sign placements, house cusps all available via `Varga`/`EphSnapshot`

## What libaditya provides

Four bala groups with sub-components:
- **Sthana Bala**: Ucca + Saptavargaja + Sama-Visama + Kendradi + Drekkana
- **Dig Bala**: directional strength from digbala cusp
- **Kala Bala**: Ayana + Cheshta
- **Drig Bala**: aspectual strength (benefics add, malefics subtract)

All scores in **virupas** (0–60 per component; 60 virupas = 1 rupa).

## Core primitive: `virupasBetween`

Used by Ucca, Dig, Ayana, and Cheshta bala. Measures angular proximity on a 0–60 scale.

```
virupasBetween(selfLon, pointLon):
  opposite = (pointLon + 180) % 360
  if selfLon == pointLon: return 60
  if selfLon == opposite: return 0
  # In the half-circle opposite→point (ascending): ratio * 60
  # In the half-circle point→opposite (descending): ratio * 60
```

## Sub-component details

### Sthana Bala

**Ucca Bala (0–60 virupas)** — `virupasBetween(planetLon, exaltationPoint)`.

Exaltation points (ecliptic degrees):

| Body | Exaltation | Debilitation (+180) |
|------|-----------|---------------------|
| Sun | 10 | 190 |
| Moon | 33 | 213 |
| Mars | 298 | 118 |
| Mercury | 165 | 345 |
| Jupiter | 95 | 275 |
| Venus | 357 | 177 |
| Saturn | 200 | 20 |

Moon and Mercury have range-based exaltation (not a single point):
- Moon: exalted in 30–33° (Taurus 0–3°), debilitated in 210–213°
- Mercury: exalted in 150–165° (Virgo 0–15°), debilitated in 330–345°

If in the exaltation range → 60. If in the debilitation range → 0. Otherwise proportional over `180 - rangeWidth` degrees.

**Saptavargaja Bala (max 315 virupas)** — sum dignity points across 7 vargas (D1, D2, D3, D7, D9, D12, D30).

Points by dignity: MT=45, OH=30, GF=20, F=15, N=10, E=4, GE=2. If dignity is EX or DB, substitute the compound friendship instead.

**Sama-Visama Bala (0, 15, or 30 virupas)** — gender match in D1 and D9 only. +15 per varga where planet gender matches sign gender (or planet is neuter and sign is masculine).

Planet genders: Sun=M, Moon=F, Mars=M, Mercury=N, Jupiter=M, Venus=F, Saturn=M.
Sign genders: odd signs (1,3,5,7,9,11) = M; even signs = F.

**Kendradi Bala (15, 30, or 60 virupas)** — by house type. Kendra (1,4,7,10) = 60, Panaphara (2,5,8,11) = 30, Apoklima (3,6,9,12) = 15.

**Drekkana Bala (0 or 15 virupas)** — by decanate and gender. 1st third (0–10° in sign) = M, 2nd (10–20°) = N, 3rd (20–30°) = F. Match → 15.

### Dig Bala (0–60 virupas)

`virupasBetween(planetLon, digbalaCuspLon)`.

| Body | Digbala house |
|------|--------------|
| Sun, Mars | 10 (MC) |
| Moon, Venus | 4 (IC) |
| Mercury, Jupiter | 1 (Asc) |
| Saturn | 7 (Desc) |

### Kala Bala

**Ayana Bala (0–60 virupas)** — solstice proximity. `virupasBetween(planetLon, solsticePoint)`.

| Bodies | 60-point longitude |
|--------|-------------------|
| Sun, Mars, Jupiter, Venus | 90° (Cancer/Uttarayana) |
| Moon, Saturn | 270° (Capricorn/Dakshinayana) |
| Mercury | whichever solstice is closer |

Uses **tropical** longitude (pre-ayanamsa).

**Cheshta Bala (0–60 virupas)** — motional strength. Formula:

```
T = (JD - 2451545.0) / 36525.0      # Julian centuries from J2000
sunMeanLon = polynomial(T)            # 3rd-degree polynomial
planetMeanLon = polynomial(T)         # per-planet polynomial

For inner planets (Mercury, Venus): apogee = planetMeanLon, mean = sunMeanLon
For outer planets (Mars, Jupiter, Saturn): apogee = sunMeanLon, mean = planetMeanLon

average = (eclipticLon + mean) / 2
reduce = abs(apogee - average)
if reduce > 180: reduce = 360 - reduce
cheshtaBala = reduce / 3              # max 60
```

Special cases:
- Sun: same as Ayana Bala (`virupasBetween(sunLon, 90)`)
- Moon: `virupasBetween(moonLon, (sunLon + 180) % 360)` — 60 at full moon, 0 at new moon

Mean longitude polynomials (degrees, argument T = Julian centuries from J2000):

| Body | a0 | a1 | a2 | a3 |
|------|----|----|----|----|
| Sun | 280.466449 | 36000.7698231 | 0.00030368 | 0.000000021 |
| Mars | 355.433275 | 19141.6964746 | 0.00031097 | 0.000000015 |
| Mercury | 252.250906 | 149474.0722491 | 0.00030397 | -0.000000018 |
| Jupiter | 34.351484 | 3036.3027889 | 0.00022374 | 0.000000025 |
| Venus | 181.979801 | 58519.2130302 | 0.00031060 | 0.000000015 |
| Saturn | 50.07741 | 1223.5110141 | 0.00051952 | -0.000000003 |

### Drig Bala (can be negative)

Sum of aspect contributions from all other karakas:

```
For each aspecting karaka (Sun–Saturn, excluding self):
  strength = Aspect.strength(aspector, from_lon, to_lon)
  if aspector is Mercury or Jupiter:       total += strength      (full benefic)
  elif aspector is Venus or waxing Moon:   total += strength / 4  (partial benefic)
  else (Sun, Mars, Saturn, waning Moon):   total -= strength / 4  (malefic subtraction)
```

Arrow's `Aspect.strength()` already implements continuous Parashara aspect strength — reuse directly.

## Implementation

### New files

```
calc/lib/src/vedic/shadbala.dart         — ShadbalaCalc class + Shadbala result
calc/lib/src/vedic/shadbala_const.dart   — exaltation points, digbala cusps, genders, mean lon polynomials
```

### Result type

```dart
class Shadbala {
  // Sthana sub-components
  final double uccaBala;
  final double saptavargajaBala;
  final double samaVisamaBala;
  final double kendradiBala;
  final double drekkanaBala;
  double get sthanaBala => uccaBala + saptavargajaBala + samaVisamaBala + kendradiBala + drekkanaBala;

  // Other balas
  final double digBala;
  final double ayanaBala;
  final double cheshtaBala;
  final double drigBala;

  double get totalVirupas => sthanaBala + digBala + ayanaBala + cheshtaBala + drigBala;
  double get totalRupas => totalVirupas / 60.0;
}
```

### API

```dart
class ShadbalaCalc {
  const ShadbalaCalc._();

  static double virupasBetween(double selfLon, double pointLon);
  static double uccaBala(Body body, double eclipticLon);
  static double saptavargajaBala(Body body, List<(int sign, DignityType dignity)> sevenVargas);
  static double samaVisamaBala(Body body, int rashiSign, int navamshaSign);
  static double kendradiBala(int houseFromLagna);
  static double drekkanaBala(Body body, double inSignLon);
  static double digBala(Body body, double planetLon, double cuspLon);
  static double ayanaBala(Body body, double tropicalLon);
  static double cheshtaBala(Body body, double eclipticLon, double julianDay, double sunEclipticLon);
  static double drigBala(Body body, double bodyLon, Map<Body, double> allKarakaLons, bool moonIsWaxing);

  static Map<Body, Shadbala> calculateAll({
    required Varga rashi,
    required List<Varga> saptavargas,
    required double julianDay,
    required Map<Body, double> tropicalLongitudes,
  });
}
```

Individual bala functions take primitives. `calculateAll` is the convenience method that extracts everything from `Varga` objects.

### Constants file

```dart
// Exaltation points (ecliptic degrees), with range info for Moon/Mercury
// Digbala house assignments
// Planet genders
// Mean longitude polynomial coefficients
// Saptavargaja dignity point table
```

### What needs to be added elsewhere

1. **`EphSnapshot` must expose Julian Day** — verify this exists; if not, add it to `arrow_swe`.
2. **Tropical longitudes** — `EphSnapshot` stores tropical positions by default (sidereal is post-ayanamsa). Confirm which field is which.
3. **Saptavarga helper** — a utility that returns D1,D2,D3,D7,D9,D12,D30 `Varga` objects. Could live in core or be computed by the caller.

## Testing

### Unit tests — `calc/test/vedic/shadbala_test.dart`

- `virupasBetween` — test at same point (60), opposite (0), quarter points (30), eighth points (15)
- Each sub-bala with known inputs and hand-calculated results
- Moon/Mercury range-based ucca bala edge cases
- Drig bala with a mix of benefic and malefic aspectors (verify can go negative)

### Golden tests

- Generate fixtures from libaditya for 3–5 charts
- Compare each sub-component within 0.01 virupas tolerance

## Dependencies

- `arrow_options` — `Body` enum
- `arrow_core` — `Varga`, `Dignity`, `DignityType`, sign data
- `arrow_calc` — `Aspect.strength()` (for Drig Bala)
- `arrow_swe` — `EphSnapshot` (for Julian Day, tropical longitudes)

## Sequence

1. Implement `virupasBetween` + tests (foundation for 4 sub-balas)
2. Constants file (exaltation points, digbala cusps, genders, polynomials)
3. Sthana Bala sub-components (ucca, drekkana, kendradi, sama-visama) + tests
4. Saptavargaja Bala (requires computing 7 vargas) + tests
5. Dig Bala + tests
6. Kala Bala (ayana, cheshta) + tests — needs Julian Day and tropical longitudes
7. Drig Bala + tests — needs Aspect.strength()
8. `calculateAll` integration + golden tests
9. Export from barrel

## Notes

- Naisargika Bala (innate strength) is not in libaditya's implementation. It's a fixed constant per planet — can be added later as a trivial lookup.
- All scores are virupas. No conversion to rupas in the calculation layer. Display layer can divide by 60.
- Cheshta Bala uses mean longitude polynomials — these are approximate. For production, consider using Swiss Ephemeris mean positions if available, but the polynomials are standard practice and match libaditya.
