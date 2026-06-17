# libaditya calculations not yet in Arrow

Inventory of calculation capabilities present in libaditya (Python) that Arrow (Dart) does not yet implement. Updated 2026-06-04 from a full side-by-side audit of both codebases.

Arrow now implements: planetary positions (13 bodies, 4 coordinate frames), house cusps (15 systems), angles (8 points), nakshatras/padas, 51 ayanamsas (47 SWE + 4 custom), 29 varga types, full compound dignity, combustion, retrograde/direction/speed classification, pheno data (phase/elongation/magnitude), synodic state, Parashara drishti (0–60 virupas), rashi aspects (3 modes), all 4 avasthas (Baladi/Jagradadi/Deeptadi/Lajjitaadi), full Shadbala (6 balas), Vimshottari dasha engine, Jaimini (chara karakas, padas, argala, bandhana yogas, 3-level sign strength), Nabhasa yogas (32), Panchamahapurusha (5), solar yogas (3), lunar yogas (4), panchanga (5 limbs + next-boundary finders), sunrise/sunset, 64 named fixed stars + custom, 13-constellation true-sidereal zodiac, nature classification, hora, being type, aditya being.

---

## Astronomical calculations

### Eclipse calculations
Solar and lunar eclipse finder (next/previous, local and global). Returns EphContext at eclipse maximum.

### Heliacal events
First/last rising and setting of planets. Mercury/Venus/Moon have evening-first and morning-last. Uses atmosphere and observer parameters.

### Moonrise / Moonset
`swe.rise_trans()` for Moon with Hindu rising bitflag.

### Planet rise / set / meridian transit
Generic `rise_trans()` for any body — rise, set, upper meridian transit, lower meridian transit.

### Sun ingress finder
`Sun.ingress(longitude)` — iterative solver for the next moment the Sun reaches a given ecliptic degree.

### Next new moon / full moon
Exact conjunction (0°) and opposition (180°) of Sun and Moon.

### Planetary ingress to arbitrary degree
Find the next moment any planet crosses a specific ecliptic longitude.

## Avasthas

### Shayanadi Avasthas (12 states)
Shayana, Upavesha, Netrapani, Prakasha, Gamana, Agamana, Sabha, Agama, Bhojana, Nrityalipsa, Kautuka, Nidra. Based on nakshatra index × planet multiplier + navamsha number + birth ghatis since sunrise, mod 12.

Arrow has the other 4 avastha systems.

## Jaimini extensions

### Jaimini Kemadruma
Checks from multiple reference points (lagna, AK in D1, pada, svamsha in D9) for malefics in 2nd/8th and Moon aspects.

### JaiminiGet (declarative topic queries)
`rashi.get(spec)` — computes sign influences (conjunctions + rashi aspects) for pre-defined topic specs (spirituality, home, dharma, spouse, etc.) across specified vargas.

## Chart types

### Solar return
Full chart for the exact moment the Sun returns to its natal degree in any year of life.

### Lunar return
Framework exists but not fully implemented in libaditya either.

### Tajika annual chart
Annual return / solar arc horary system. Partial in libaditya.

## Coordinate systems

### Draconic
Planets shifted by Rahu's longitude (sysflg = -8). A coordinate frame, not a separate calculation.

### Altitude / Azimuth (local horizon)
Per-body horizon coordinates. Arrow computes topocentric positions but not local alt/az.

## Non-Vedic systems

### Human Design
- Conscious (natal) and unconscious (88° Sun prior) planetary positions
- Gate, line, color, tone, base from hexagram wheel
- Bodygraph channel and center activation
- SVG bodygraph drawing

### Cards of Truth
- Birth card from birth date
- Birth/year/day spreads (52-card layout)
- Quadrations (Jack, Queen, King)

### Hellenistic profections
Stub in libaditya (not implemented). Not in Arrow.

### Sarvatobhadra Chakra
Base grid drawing (SVG). Transit overlay incomplete in libaditya.

## Not in either codebase

- **Ashtakavarga** — standard Vedic calculation, absent from both

---

## Summary

| Category | Calculation | libaditya | Arrow |
|---|---|---|---|
| Astronomical | Eclipse finder | full | — |
| Astronomical | Heliacal events | full | — |
| Astronomical | Moonrise/moonset | yes | — |
| Astronomical | Planet rise/set/transit | yes | — |
| Astronomical | Sun ingress | yes | — |
| Astronomical | New/full moon finder | yes | — |
| Astronomical | Planetary ingress | yes | — |
| Avastha | Shayanadi (12 states) | yes | — |
| Jaimini | Kemadruma | yes | — |
| Jaimini | JaiminiGet topics | yes | — |
| Chart types | Solar return | yes | — |
| Chart types | Lunar return | stub | — |
| Chart types | Tajika | partial | — |
| Coordinates | Draconic frame | yes | — |
| Coordinates | Alt/Az (horizon) | yes | — |
| Non-Vedic | Human Design | full | — |
| Non-Vedic | Cards of Truth | full | — |
| Non-Vedic | Hellenistic profections | stub | — |
| Non-Vedic | SBC | partial | — |
| Both missing | Ashtakavarga | — | — |
