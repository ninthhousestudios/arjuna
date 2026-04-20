# Cards of Truth — Implementation Plan

Port the Cards of Truth system from `libaditya/cards/` into Arrow as a tradition alongside Vedic and Human Design.

## What exists in Arrow

- `options/lib/src/tradition.dart` — `Tradition` enum (currently only `vedic`)
- `options/lib/src/calc_config.dart` — `CalcConfig`, planned but not yet present `CardsOfTruthConfig` field
- `swe/` — Swiss Ephemeris facade (needed only for equatorial sunrise in birth card derivation)

## What libaditya provides

- Birth card derivation from birth date + location
- Three quadrations (Jack, Queen, King) — card permutation algorithm
- Birth spread (14 positions from Queen quadration)
- Year spread (age-based quadration)
- Day spread (day-based quadration)
- Card/Deck data model

## Card encoding

52 cards as two-character strings (rank + suit):
```
AH 2H 3H ... KH  (hearts, index 0–12)
AC 2C 3C ... KC  (clubs, index 13–25)
AD 2D 3D ... KD  (diamonds, index 26–38)
AS 2S 3S ... KS  (spades, index 39–51)
```

Index 0–51 is the universal card identity.

## Birth card algorithm

1. Compute equatorial sunrise for the birth longitude on the birth date (use Swiss Ephemeris sunrise function at latitude 0, same longitude as birth).
2. If birth time < sunrise: step back one calendar day (if day becomes 0, go to last day of previous month; February always has 29 days for CoT).
3. Look up `firstCardOfMonth[month]` → starting index into `birthCardOrder`.
4. Birth card = `birthCardOrder[startIndex + (day - 1)]`.

`birthCardOrder` is the 52 cards in reverse natural order (KS, QS, JS, ... AH).

First card of each month:

| Month | Starting card |
|-------|--------------|
| Jan | KS |
| Feb | JS |
| Mar | 9S |
| Apr | 7S |
| May | 5S |
| Jun | 3S |
| Jul | AS |
| Aug | QD |
| Sep | TD |
| Oct | 8D |
| Nov | 3D |
| Dec | 4D |

Note: libaditya has a bug here (`match match:` instead of `match month:`) — fix in the Dart port.

## Quadration algorithm

`quadrate(deck)` transforms a 52-integer list into the next quadration:

**Phase 1 — deal by threes into 4 piles:**
While > 4 cards remain: pop 3 from front, prepend to piles 1–4 respectively. Then pop the remaining 4 singles to each pile. Recombine: pile4 + pile3 + pile2 + pile1.

**Phase 2 — redeal one at a time into 4 piles:**
Pop one card at a time from front, cycling through piles 1–4. Recombine: pile4 + pile3 + pile2 + pile1.

The three named quadrations:
- **Jack** = `[0, 1, 2, ..., 51]` (identity)
- **Queen** = `quadrate(Jack)`
- **King** = `quadrate(Queen)`

`quadrateN(deck, n)` applies `quadrate` n times iteratively.

## Spread algorithm

`birthSpread(birthCard, quadration)`:

1. Find index `bc` of the birth card within `quadration`.
2. Take 14 consecutive elements: `quadration[(bc + i) % 52]` for i in 0..13.
3. Position 0 = Base (the birth card). Positions 1–13 = planetary cards.

Planet ordering (configurable):
- **Vedic**: Base, Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu, Ecliptic, Uranus, Neptune, Pluto
- **Solar system**: Base, Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Rahu, Ketu, Ecliptic, Uranus, Neptune, Pluto

## Year and day spreads

- **Year spread** at age N: `birthSpread(birthCard, quadrateN(jackQuad, N + 1))`
  - Age 0 → Queen quad, age 1 → King quad, age 2+ → further iterations
- **Day spread** at day D: `birthSpread(birthCard, quadrateN(queenQuad, D))`

## Implementation

### Layer mapping

```
arrow_options:  CardsOfTruthConfig
arrow_core:     (none — CoT doesn't need the astrological domain model)
arrow_calc:     CotCalc, Quadration, CotCard, CotSpread
```

CoT is self-contained in `arrow_calc` — it doesn't use `arrow_core`'s Chart/Varga/Planet model at all. The only external dependency is `arrow_swe` for the sunrise calculation in birth card derivation.

### New in `arrow_options`

```dart
@freezed
class CardsOfTruthConfig with _$CardsOfTruthConfig {
  const factory CardsOfTruthConfig({
    @Default(CotPlanetOrder.vedic) CotPlanetOrder planetOrder,
  }) = _CardsOfTruthConfig;
}

enum CotPlanetOrder { vedic, solarSystem }
```

Add to `CalcConfig`:
```dart
@Default(null) CardsOfTruthConfig? cardsOfTruth,
```

### New in `arrow_calc`

**`calc/lib/src/cot/cot_constants.dart`** — all lookup tables:
```dart
const cotCards = ['AH', '2H', ..., 'KS'];  // 52 strings
const cotBirthCardOrder = [51, 50, 49, ..., 0];  // reversed indices
const cotFirstCardOfMonth = [51, 49, 47, ...];  // 12 ints, index into birthCardOrder
const cotPlanetOrderVedic = ['Base', 'Sun', 'Moon', 'Mars', ...];
const cotPlanetOrderSolarSystem = ['Base', 'Sun', 'Moon', 'Mercury', ...];
```

**`calc/lib/src/cot/cot_card.dart`**:
```dart
class CotCard {
  final int index;      // 0–51
  final String code;    // e.g. "7H"
  String get rank => ...;    // "7"
  String get suit => ...;    // "H"
  String get name => ...;    // "Seven of Hearts"
  String get symbol => ...;  // "7♥"
}
```

**`calc/lib/src/cot/quadration.dart`**:
```dart
class Quadration {
  const Quadration._();

  static List<int> quadrate(List<int> deck);
  static List<int> quadrateN(List<int> deck, int n);

  static final jackQuad = List.generate(52, (i) => i);
  static final queenQuad = quadrate(jackQuad);
  static final kingQuad = quadrate(queenQuad);
}
```

**`calc/lib/src/cot/cot_spread.dart`**:
```dart
class CotSpread {
  final CotCard birthCard;
  final List<CotCard> positions;  // 14 cards, position[0] = base
  final List<String> planetLabels;
}
```

**`calc/lib/src/cot/cot_calc.dart`**:
```dart
class CotCalc {
  const CotCalc._();

  static CotCard birthCard({
    required int year, required int month, required int day,
    required double birthJd, required double equatorialSunriseJd,
  });

  static CotSpread birthSpread({
    required CotCard birthCard,
    List<int>? quadration,  // defaults to Queen
    CotPlanetOrder planetOrder = CotPlanetOrder.vedic,
  });

  static CotSpread yearSpread({
    required CotCard birthCard,
    required int age,
    CotPlanetOrder planetOrder = CotPlanetOrder.vedic,
  });

  static CotSpread daySpread({
    required CotCard birthCard,
    required int daysSinceBirth,
    CotPlanetOrder planetOrder = CotPlanetOrder.vedic,
  });
}
```

### SWE dependency: equatorial sunrise

The birth card derivation needs sunrise at the equator for the birth longitude. Arrow's SWE facade may already expose sunrise calculation via Swiss Ephemeris functions. If not, add:

```dart
static double equatorialSunrise({required double longitude, required double jd});
```

This is a thin wrapper around `swe_rise_trans` with latitude=0.

## Testing

### Unit tests

- **Quadration**: verify Jack → Queen → King produces known permutations. Verify `quadrateN(jack, 1) == queen` and `quadrateN(jack, 2) == king`.
- **Birth card**: known birth dates → expected birth cards (test pre-sunrise and post-sunrise cases)
- **Birth spread**: known birth card in Queen quad → expected 14-card sequence
- **Year spread**: verify age 0 uses Queen, age 1 uses King
- **February edge case**: day=29 works correctly in CoT leap-year logic

### Golden tests

Generate from libaditya for known birth dates: birth card, birth spread, year spreads at ages 0, 1, 10.

## Dependencies

- `arrow_options` — `CardsOfTruthConfig`, `CotPlanetOrder`
- `arrow_swe` — equatorial sunrise only (one function)
- No dependency on `arrow_core`

## Sequence

1. Constants file (cards, birth card order, month table)
2. `CotCard` data class + tests
3. `Quadration.quadrate` algorithm + tests (verify Jack → Queen → King)
4. `Quadration.quadrateN` + tests
5. Birth spread from a given birth card + quadration + tests
6. Year spread + day spread + tests
7. Birth card derivation (needs SWE sunrise) + tests
8. `CardsOfTruthConfig` + `CotPlanetOrder` in options
9. Golden tests against libaditya
10. Export from barrel

## Notes

- CoT is entirely self-contained — no interaction with Vedic calculations, no shared domain model. It lives in `calc/lib/src/cot/` as an independent subdirectory.
- The quadration algorithm is deterministic and stateless — it's pure list permutation. Pre-compute and cache Queen and King quads as `static final`.
- libaditya's `cards_constants.py` has a bug: `match match:` instead of `match month:` in `days_in_the_month`. The Dart port should implement this as a simple switch on month with February = 29.
- The display layout (the 4-row visual spread) is a presentation concern, not a calculation concern. Defer to the UI layer.
- `quadrateN` for large N (e.g., age 80 for year spread) iterates 81 times. Each iteration is O(52). This is trivially fast — no optimization needed.
