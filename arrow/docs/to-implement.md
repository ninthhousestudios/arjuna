# libaditya calculations not yet in Arrow

Inventory of calculation capabilities present in libaditya (Python) that Arrow (Dart) does not yet implement. Organized by category with notes on what libaditya provides.

---

## Vimshottari Dasha — period arithmetic

Arrow has the nakshatra lord table but no dasha engine.

libaditya provides:
- Full dasha tree to arbitrary depth (mahadasha → antardasha → pratyantardasha → ...)
- Current dasha lord(s) at any moment
- Next dasha lords
- Specific period lookup without computing the full tree
- Multiple year-length options: Saura (365.2422 days), Savana, Chandra, Nakshatra

## Shadbala

Nothing in Arrow. libaditya implements:

- **Sthana Bala** — Ucca Bala, Saptavargaja Bala, Sama-Visama Bala, Kendradi Bala, Drekkana Bala
- **Dig Bala** — directional strength from digbala cusp
- **Kala Bala** — Ayana Bala (solstice proximity), Cheshta Bala (motional strength)
- **Drig Bala** — aspectual strength (full for Mercury/Jupiter, 1/4 for others, subtracted for malefics)

## Yogas

Nothing in Arrow. libaditya implements:

- **Nabhasa Yogas (32):** Ashraya (3), Dala (2), Sankhya (7), Akriti (20) — all scored by `to_move` (planets that would need to move to complete)
- **Panchamahapurusha (5):** Ruchaka, Bhadra, Hamsa, Malavya, Sasa
- **Solar Yogas:** Vosi, Vesi, Ubhayachari
- **Lunar Yogas:** Sunapha, Anapha, Durudhara, Kemadruma

## Jaimini — padas, argala, sign strength

Arrow has chara karaka assignment. libaditya adds:

- Pada (arudha lagna) for any sign
- Upapada (arudha of 10th)
- All 12 padas
- Argala and Virodhina (planetary intervention and obstruction)
- Rashi argala to lagna and 7th
- Bandhana yogas (sign-pair combinations)
- Jaimini First/Second/Third Strength (sign ranking tiebreakers)
- Jaimini Kemadruma yoga (from multiple reference points)

## Rashi (sign-to-sign) aspects

Arrow has Parashara drishti (planet aspects). libaditya also has:

- Rashi aspects (Jaimini rules): movable aspects fixed, fixed aspects movable, dual aspects all except adjacent dual

## Shayanadi Avasthas

Arrow has Baladi, Jagradadi, Deeptadi, Lajjitaadi. libaditya additionally has:

- **Shayanadi (12 states):** Shayana, Upavesha, Netrapani, Prakasha, Gamana, Agamana, Sabha, Agama, Bhojana, Nrityalipsa, Kautuka, Nidra — based on nakshatra, navamsha, and birth ghatis since sunrise

## Solar/Lunar Returns

- Solar return chart for any year of life (exact Sun-return-to-natal-degree moment)
- Framework for lunar returns

## Panchanga — event finders

Arrow has all five limbs and next-boundary finders. libaditya additionally provides:

- Next new moon / next full moon (exact conjunction/opposition)
- Moon's next morning-last and evening-first visibility
- First/last visibility of Mercury, Venus

## Planetary ingress

- `planet.ingress(longitude)` — find the next moment a planet crosses a given ecliptic degree

## Fixed stars

- Fixed star positions from Swiss Ephemeris star files
- Star-to-sign boundary data

## Ashtakavarga

Not in either codebase, but worth noting as a standard Vedic calculation gap.

---

## Non-Vedic systems (in libaditya, not in Arrow)

### Human Design
- Conscious (natal) and unconscious (88-degree Sun prior) planetary positions
- Gate, line, color, tone, base from hexagram wheel
- Bodygraph channel and center activation
- SVG bodygraph drawing

### Cards of Truth
- Birth card from birth date
- Birth spread (52-card layout)
- Year spread at any age
- Quadrations (Jack, Queen, King)

### Hellenistic
- Annual profections — declared but not yet implemented in libaditya either

### Tajika
- Annual chart framework — partial in libaditya

### Sarvatobhadra Chakra (SBC)
- Base grid drawing (SVG); transit overlay incomplete in libaditya

---

## Summary table

| Calculation | libaditya | Arrow |
|---|---|---|
| Vimshottari dasha engine | full | lord table only |
| Shadbala | 4 balas | none |
| Yogas (Nabhasa, PMP, solar, lunar) | 32+ yogas | none |
| Jaimini (padas, argala, sign strength) | full | chara karakas only |
| Rashi aspects | yes | no |
| Shayanadi avasthas | yes | no (4 other systems done) |
| Solar/lunar returns | yes | no |
| Panchanga event finders (new/full moon, visibility) | yes | next-boundary only |
| Planetary ingress | yes | no |
| Fixed stars | yes | no |
| Human Design | yes | no |
| Cards of Truth | yes | no |
| Hellenistic profections | stub | no |
| Tajika annual chart | partial | no |
| SBC | partial | no |
