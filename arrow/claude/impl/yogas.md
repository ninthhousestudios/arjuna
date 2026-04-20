# Yogas — Implementation Plan

Port yoga detection from `libaditya/calc/rashi.py` into Arrow's calc layer.

## What exists in Arrow

- `Varga` with `signs: Map<int, Sign>`, planet placements, dignity per planet
- `Sign` with `quality` (cardinal/fixed/mutable), `planets`, sign number
- `Nature.ofMoon(sunLon, moonLon)` for phase-dependent benefic/malefic
- No yoga detection of any kind

## What libaditya provides

- 32 Nabhasa yogas (Ashraya, Dala, Sankhya, Akriti subtypes)
- 5 Panchamahapurusha yogas
- 3 Solar yogas (Vosi, Vesi, Ubhayachari)
- 4 Lunar yogas (Sunapha, Anapha, Durudhara, Kemadruma)

All use a `to_move` proximity score (0 = fully formed, higher = further from formation).

## Core concept: `toMove` scoring

`toMove` counts how many of the 7 karakas (Sun–Saturn) would need to relocate for the yoga to be perfect. Zero means the yoga is fully present.

Two variants:
- **`tm(houses)`** — simple: `7 - sum(karakasInHouses)`. How many karakas are outside the required houses.
- **`tmDist(houses)`** — distribution-aware: `max(outside, emptyRequiredHouses)`. Used for spread-out patterns where both concentration *and* coverage matter.

## Yoga categories

### Nabhasa — Ashraya (3 yogas)

All 7 karakas in signs of one modality:
- Rajju: all in cardinal (1,4,7,10)
- Musala: all in fixed (2,5,8,11)
- Nala: all in mutable (3,6,9,12)
- `toMove = 7 - countInMatchingModality`

### Nabhasa — Dala (2 yogas)

Benefic/malefic distribution in kendras (houses 1,4,7,10):
- Mala: all benefics in kendras. `toMove = totalBenefics - beneficsInKendras`
- Sarpa: all malefics in kendras. `toMove = totalMalefics - maleficsInKendras`

Moon nature is **phase-dependent** here (same as in Lajjitaadi).

### Nabhasa — Sankhya (7 yogas)

Number of occupied houses:
- Veena (7), Dama (6), Pasa (5), Kedara (4), Sula (3), Yuga (2), Gola (1)
- `toMove = abs(actualOccupied - required)`
- Exactly one always has `toMove = 0`

### Nabhasa — Akriti (20 yogas)

Planetary distribution patterns. Key groups:

| Pattern | Yogas | Houses | Scoring |
|---------|-------|--------|---------|
| Trine | Sringataka, Hala (x3) | (1,5,9), (2,6,10), (3,7,11), (4,8,12) | `tm` |
| Angle pairs | Gada (x4) | pairs of successive angles | `tm` |
| Two-angle | Sakata, Vihaga | (1,7), (4,10) | `tm` |
| Four-angle | Kamala, Vapi (x2) | (1,4,7,10), (2,5,8,11), (3,6,9,12) | `tm` |
| Vajra/Yava | 2 | benefics/malefics in correct angles | `7 - correctCount` |
| Four-consecutive | Yupa, Sara, Shakti, Danda | runs of 4 from each angle | `tm` |
| Seven-consecutive | Nauka, Kuta, Chatra, Chapa | runs of 7 from each angle | `tmDist` |
| Ardha Chandra (x8) | 8 variants | runs of 7 from non-angle houses | `tmDist` |
| Alternate-6 | Chakra, Samudra | (1,3,5,7,9,11), (2,4,6,8,10,12) | `tmDist` |

### Panchamahapurusha (5 yogas)

Mars (Ruchaka), Mercury (Bhadra), Jupiter (Hamsa), Venus (Malavya), Saturn (Sasa).

Conditions (both must hold):
1. Planet is in a kendra house (1, 4, 7, 10 from lagna)
2. Planet's dignity is own sign, moolatrikona, or exalted

All 5 always returned with `present: true/false`.

### Solar yogas (3)

Eligible planets: Mars, Mercury, Jupiter, Venus, Saturn (no Sun, Moon, nodes).

- Vosi: eligible planet in 12th house from Sun
- Vesi: eligible planet in 2nd house from Sun
- Ubhayachari: planets in both 2nd and 12th from Sun

### Lunar yogas (4)

Same eligible set. Reference = Moon's house.

- Anapha: eligible planet in 12th from Moon
- Sunapha: eligible planet in 2nd from Moon
- Durudhara: planets in both positions
- Kemadruma: neither Anapha nor Sunapha — Moon is isolated

## Implementation

### New file: `calc/lib/src/vedic/yoga.dart`

### Result types

```dart
sealed class YogaResult {
  String get name;
  String get translation;
  int get toMove;
  bool get isPresent => toMove == 0;
}

class NabhasaYoga extends YogaResult {
  final String category;  // "Ashraya", "Dala", "Sankhya", "Akriti"
  final List<int> houses;
}

class MahapurushaYoga extends YogaResult {
  final Body planet;
  final bool present;
  final int house;
  final DignityType? dignity;
}

class SolarLunarYoga extends YogaResult {
  final List<Body> planets;
  final bool present;
}
```

### Primary input: house-karaka map

Most yoga checks need one data structure: **for each house (1–12), which karakas occupy it**. Build from a `Varga`:

```dart
Map<int, List<Body>> karakasPerHouse(Varga rashi, int lagnaSign) {
  // for each karaka, compute house = ((karakaSign - lagnaSign + 12) % 12) + 1
}
```

Helper: `int houseFrom(int lagnaSign, int signNum) => ((signNum - lagnaSign + 12) % 12) + 1`

### API

```dart
class Yoga {
  const Yoga._();

  static List<NabhasaYoga> ashrayaYogas({required Map<int, int> karakaCountPerHouse, required Map<int, Quality> signQualities});
  static List<NabhasaYoga> dalaYogas({required Map<int, List<Body>> karakasPerHouse, required bool moonIsBenefic});
  static List<NabhasaYoga> sankhyaYogas({required int occupiedHouseCount});
  static List<NabhasaYoga> akritiYogas({required Map<int, int> karakaCountPerHouse, required Map<int, List<Body>> karakasPerHouse, required bool moonIsBenefic});
  static List<NabhasaYoga> nabhasaYogas({...});  // combined, sorted by toMove

  static List<MahapurushaYoga> panchamahapurushaYogas({required Map<Body, int> karakaHouses, required Map<Body, DignityType> karakaDignities});
  static List<SolarLunarYoga> solarYogas({required Map<int, List<Body>> karakasPerHouse, required int sunHouse});
  static List<SolarLunarYoga> lunarYogas({required Map<int, List<Body>> karakasPerHouse, required int moonHouse});
}
```

## Testing

### Unit tests — `calc/test/vedic/yoga_test.dart`

- Each Sankhya yoga with exactly N occupied houses → `toMove = 0` for that yoga
- Panchamahapurusha with a planet in kendra + exalted → `present = true`
- Kemadruma: Moon isolated → `present = true`; planet in 2nd from Moon → `present = false`
- Vajra/Yava: benefics and malefics in correct positions

### Golden tests

Generate fixtures from libaditya for known charts. Compare full yoga lists.

## Dependencies

- `arrow_options` — `Body`, `DignityType`, `Quality`
- `arrow_core` — `Varga`, `Sign`, `Planet` (for extracting inputs)
- No dependency on `arrow_swe`

## Sequence

1. Define result types (`NabhasaYoga`, `MahapurushaYoga`, `SolarLunarYoga`)
2. Implement helper: `houseFrom(lagnaSign, signNum)`
3. Sankhya yogas (simplest — just count occupied houses) + tests
4. Ashraya yogas + tests
5. Dala yogas + tests
6. Akriti yogas (largest group — implement in subgroups) + tests
7. Panchamahapurusha yogas + tests
8. Solar yogas + tests
9. Lunar yogas + tests
10. Combined `nabhasaYogas` with `toMove` sorting + golden tests
11. Export from barrel

## Notes

- libaditya returns all yogas (present and absent) with their `toMove` score. This is a feature — it shows which yogas are "nearest" to forming. Preserve this behavior.
- The Akriti group produces ~33 entries (not 20) because some patterns have multiple starting positions. This matches libaditya's output.
- Only the 7 classical karakas (Sun–Saturn) are used. Rahu/Ketu are excluded from all yoga checks.
