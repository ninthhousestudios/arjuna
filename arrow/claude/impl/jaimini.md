# Jaimini + Rashi Aspects — Implementation Plan

Port Jaimini calculations from `libaditya/calc/jaimini.py`, `jaimini_get.py` and rashi aspects from `libaditya/objects/signs.py` into Arrow.

## What exists in Arrow

- `core/lib/src/chara_karaka.dart` — chara karaka assignment (AK through DK, optional 8th). Complete, matches libaditya.
- `calc/lib/src/vedic/aspect.dart` — Parashara continuous-strength aspects. No rashi aspects.
- `core/lib/src/sign.dart` — `Sign` with `number`, `quality`, `planets`, `lord`

## What libaditya provides

- **Rashi aspects** — sign-to-sign aspects by modality
- **Padas** — arudha lagna, upapada, all 12 padas
- **Argala and Virodhina** — planetary intervention and obstruction
- **Bandhana yogas** — symmetric house-pair patterns
- **Three sign-strength rankings** — First, Second, Third Strength
- **JaiminiGet API** — factor/varga resolution for Jaimini readings

---

## Part 1: Rashi Aspects

### Rules

| Source modality | Aspects signs of | Exception |
|----------------|-----------------|-----------|
| Movable (1,4,7,10) | Fixed (2,5,8,11) | Not the adjacent fixed sign |
| Fixed (2,5,8,11) | Movable (1,4,7,10) | Not the adjacent movable sign |
| Dual (3,6,9,12) | Other Dual signs | None (all 3 other duals) |

Concrete table:

| Sign | Aspects |
|------|---------|
| 1 (Aries) | 5, 8, 11 |
| 2 (Taurus) | 4, 7, 10 |
| 3 (Gemini) | 6, 9, 12 |
| 4 (Cancer) | 2, 8, 11 |
| 5 (Leo) | 1, 7, 10 |
| 6 (Virgo) | 3, 9, 12 |
| 7 (Libra) | 2, 5, 11 |
| 8 (Scorpio) | 1, 4, 10 |
| 9 (Sagittarius) | 3, 6, 12 |
| 10 (Capricorn) | 2, 5, 8 |
| 11 (Aquarius) | 1, 4, 7 |
| 12 (Pisces) | 3, 6, 9 |

An empty sign does NOT cast a rashi aspect — there must be at least one graha present.

### Implementation

Add to `calc/lib/src/vedic/aspect.dart` (or a new `rashi_aspect.dart`):

```dart
class RashiAspect {
  const RashiAspect._();

  static const Map<int, List<int>> _table = { /* 12 entries above */ };

  static bool doesAspect(int fromSign, int toSign) => _table[fromSign]!.contains(toSign);
  static bool doesAspectWithOccupants(int fromSign, int toSign, bool fromHasGrahas) =>
      fromHasGrahas && doesAspect(fromSign, toSign);
  static int mutual(int sign1, int sign2, bool sign1HasGrahas, bool sign2HasGrahas);
  // Returns 0 (none), 1 (1→2 only), 2 (2→1 only), 3 (mutual)
}
```

---

## Part 2: Pada (Arudha) Calculation

### Algorithm — `pada(refSign, lord, lordSign)`

1. `signsApart = ((lordSign - refSign) % 12) + 1` (1–12, inclusive counting)
2. Special cases:
   - If `signsApart == 1` or `signsApart == 7`: pada = 10th from refSign
   - If `signsApart == 4` or `signsApart == 10`: pada = 4th from refSign
3. Otherwise: pada = `signsApart` signs forward from lordSign

Helper: `signsForward(sign, n) = ((sign + n - 2) % 12) + 1` (inclusive: forward(1) = self)

### Specific padas

- **Arudha Lagna (AL)**: `pada(lagnaSign, lagnaLord, lagnaLordSign)`
- **Upapada**: `pada(cusp12Sign, cusp12Lord, cusp12LordSign)` — note: libaditya uses cusp 10 (MC), not cusp 12, which is non-standard. Document both options.
- **All 12 padas**: iterate each sign 1–12 as refSign.

---

## Part 3: Argala and Virodhina

### Algorithm — `argala(targetSign, allSigns, ketuSign, firstStrengthRanking)`

**Step 1: Ketu direction modifier.** If Ketu is in targetSign, reverse all house offsets (multiply by -1).

**Step 2: Four argala/virodhina pairs** (house offsets from targetSign):

| Argala position | Virodhina position |
|----------------|-------------------|
| 2nd | 12th |
| 11th | 3rd |
| 4th | 10th |
| 9th | 5th |

**Step 3: For each pair:**
- Count grahas (Sun–Ketu, all 9) in each sign
- If argala count > virodhina count: argala stands (unobstructed)
- If argala count < virodhina count: compare signs by First Strength ranking — if argala sign ranks higher, argala stands; otherwise obstructed
- If equal: obstructed

**Step 4: Special 3rd-house malefic argala.** Count malefics vs benefics in 3rd from target. If malefics > benefics, those malefics form a separate argala.

### Result type

```dart
class ArgalaResult {
  final List<Body> argala;
  final List<Body> thirdMaleficArgala;
  final List<Body> obstructed;
}
```

---

## Part 4: Bandhana Yogas

Five symmetric pairs from lagna: offsets 2/12, 3/11, 4/10, 5/9, 6/8.

For each pair: if both sides have the same non-zero graha count, it's a bandhana yoga. Return the two planet lists.

---

## Part 5: Sign Strength Rankings

### First Strength — 8-level comparator sorting all 12 signs

| Level | Criterion | Winner |
|-------|-----------|--------|
| 0 | Karaka count (Sun–Saturn only) | More karakas |
| 1 | Sorted dignity scores of occupants | Lexicographically higher |
| 2 | Sign modality | Dual > Fixed > Movable |
| 3 | Karaka count in the lord's sign | More karakas |
| 4 | Sorted dignity scores in lord's sign | Lexicographically higher |
| 5 | Lord's sign modality | Dual > Fixed > Movable |
| 6 | Distance from sign to its lord | Greater distance |
| 7 | Tiebreaker: `knRao=true` → lord's in-sign longitude (higher wins); `knRao=false` → sign number (higher wins) |

### Second Strength

For each sign: which of Jupiter, Mercury, or the sign's lord conjoins or rashi-aspects it. Returns `Map<int, List<Body>>`.

### Third Strength

For each sign: `distance = signsApart(sign, lordSign)`, then:
- `distance % 3 == 1` → Kendra (strength 2)
- `distance % 3 == 2` → Panapara (strength 1)
- `distance % 3 == 0` → Apoklima (strength 0)

---

## Implementation

### New files

```
calc/lib/src/vedic/rashi_aspect.dart     — RashiAspect class + const table
calc/lib/src/vedic/jaimini.dart          — Jaimini class: pada, argala, bandhana, strengths
```

### API

```dart
class Jaimini {
  const Jaimini._();

  // Helpers
  static int signsForward(int sign, int n);
  static int signsApart(int from, int to);

  // Padas
  static int pada(int refSign, Body lord, int lordSign);
  static int arudhaLagna(int lagnaSign, Body lagnaLord, int lagnaLordSign);
  static int upapada(int cusp12Sign, Body lord, int lordSign);
  static Map<int, int> allPadas(Map<int, Body> signLords, Map<Body, int> lordSigns);

  // Argala
  static ArgalaResult argala({
    required int targetSign,
    required Map<int, List<Body>> grahasPerSign,
    required int ketuSign,
    required List<int> firstStrengthRanking,
  });

  // Bandhana
  static List<(List<Body>, List<Body>)> bandhanaYogas({
    required int lagnaSign,
    required Map<int, List<Body>> grahasPerSign,
  });

  // Strengths
  static List<int> firstStrength({
    required Map<int, List<Body>> karakasPerSign,
    required Map<Body, DignityType> dignities,
    required Map<int, Body> signLords,
    required Map<Body, int> lordSigns,
    required Map<Body, double> inSignLongitudes,
    bool knRao = false,
  });
  static Map<int, List<Body>> secondStrength({
    required int jupiterSign,
    required int mercurySign,
    required Map<int, Body> signLords,
    required Map<Body, int> lordSigns,
  });
  static Map<int, (int, String)> thirdStrength({
    required Map<int, Body> signLords,
    required Map<Body, int> lordSigns,
  });
}
```

## Testing

### Unit tests

- Rashi aspect table: verify each sign's 3 targets
- Empty sign does not cast rashi aspect
- Pada special cases: lord in 1st (signsApart=1 → pada at 10th), lord in 4th (→ pada at 4th)
- Argala with Ketu reversal
- First Strength comparator at each tiebreaker level
- Third Strength classification by modular arithmetic

### Golden tests

Generate from libaditya for known charts: all 12 padas, argala for lagna, full First Strength ranking.

## Dependencies

- `arrow_options` — `Body`, `DignityType`, `Quality`
- `arrow_core` — `Varga`, `Sign`, `CharaKaraka` (existing)
- No dependency on `arrow_swe`

## Sequence

1. Rashi aspect table + `RashiAspect` class + tests
2. `signsForward` / `signsApart` helpers + tests
3. `pada` algorithm + arudha lagna + upapada + tests
4. Third Strength (simplest of the three) + tests
5. Second Strength + tests (needs rashi aspects)
6. First Strength comparator (most complex — test each level) + tests
7. Argala (needs First Strength) + tests
8. Bandhana yogas + tests
9. Golden tests for all
10. Export from barrel

## Notes

- The `JaiminiGet` API (factor/varga resolution) is deferred — it's a UI convenience layer that depends on everything else being in place first.
- libaditya's upapada uses cusp 10 (MC), which is non-standard. Traditional texts use cusp 12. Support both via a parameter.
- `how_many_karakas()` counts Sun–Saturn (7 bodies). `how_many_grahas()` counts Sun–Ketu (9 bodies). Argala uses grahas; First Strength uses karakas.
- The dignity comparison at First Strength levels 1 and 4 sorts each sign's occupants by dignity score descending, then compares lexicographically. Need a numeric score per DignityType for this.
