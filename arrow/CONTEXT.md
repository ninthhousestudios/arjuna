# Arrow

Dart astrological calculation library. Multi-tradition, multi-system. Computes planetary positions via Swiss Ephemeris and derives interpretive calculations from those positions.

## Language

### Positional concepts

**Sign**:
One of 12 thirty-degree segments of the ecliptic. Circle-agnostic, tradition-agnostic. Represented as int 1-12 in code.
_Avoid_: Rashi (when meaning a sign)

**Circle**:
Where sign 1 begins on the ecliptic. `zodiac` starts at 0°; `aditya` starts at 330°. Both use the same raw positions — the difference is purely a sign-mapping offset. Independent of ayanamsa.

**Ayanamsa**:
Precession correction subtracted from ecliptic longitude. Sign and nakshatra use independent ayanamsas (`signAyanamsa` and `nakAyanamsa`). `tropical` applies no correction; `lahiri` is the Indian standard; `dhruva` is equatorial-only (Ernst Wilhelm's system).

**Nakshatra**:
One of 27 lunar mansions, each spanning 13°20'. Determined by its own ayanamsa and reference frame, independent of sign calculation.

**Pada**:
One of 4 quarters within a nakshatra (3°20' each).

**Longitude**:
The core coordinate object. Constructed from ecliptic longitude + VargaType + CalcConfig. Eagerly computes varga-transformed position, sign (circle-aware), nakshatra, and pada.

### Divisional charts

**Varga**:
A system of dividing the ecliptic into sub-charts. Each varga has a specific division method and interpretive purpose (e.g., navamsha for marriage, dashamsha for career).
_Avoid_: Divisional chart (informal gloss, not canonical)

**Amsha**:
The division number of a varga (e.g., 9 for navamsha, 12 for dwadashamsha). A numeric property of a varga, not a synonym for it.

**Rashi**:
The D1 varga — the base chart. In code, `Rashi extends Varga` and adds nakshatra grouping. Not a synonym for "sign."
_Avoid_: Using "rashi" to mean a sign

### Celestial bodies

**Planet**:
Any celestial body with motion in the domain model. The class name is intentionally Western-neutral for multi-tradition support. In a Vedic context, a Planet models the concept of a *graha* ("seizer" — a living celestial influence), but the class serves all traditions.
_Avoid_: Graha (as a class name; acceptable in Vedic discussion to mean the concept)

**Karaka**:
One of the 7 embodied planets (Sun through Saturn). Structurally distinguished from Planet by having dignity and combustion. "Karaka" means "significator" — these are the bodies capable of signifying life domains.
_Avoid_: Confusing with Chara Karaka (the Jaimini role assignment)

**Chara Karaka**:
A Jaimini system where the 7 karakas are ranked by in-sign longitude and assigned roles (Atmakaraka through Darakaraka). A calculation that produces role assignments, not a body classification. Always qualified as "chara karaka" — bare "karaka" means the class.

**Graha**:
The 9-body Vedic set (7 karakas + Rahu + Ketu). In code, `Body.grahas`. Not a class name — the class is `Planet`. Rahu and Ketu are mathematical points (lunar nodes), not physical planets, but are full grahas in Vedic reckoning.

### The Aditya system

Reference: `~/adityas/docs/aditya-system.md`. This system is from Ernst Wilhelm's teaching derived from the Srimad Bhagavatam. It is NOT in standard Jyotish literature or LLM training data — always consult the reference doc.

**Aditya**:
One of 12 solar deities, each associated with a sign when using `Circle.aditya`. Each Aditya embodies a specific kind of love. An Aditya is an *attribute* of a sign in the Aditya circle, not a replacement for the sign concept.

**Being**:
A named entity from the Srimad Bhagavatam that a planet activates based on its position within an Aditya. There are 84 beings total (12 Adityas × 7 types). The being type is determined by Trimsamsa (5-5-8-7-5° division). A planet activates exactly one being. Arrow currently implements 60 (the 5 Trimsamsa-determined types); Aditya and Naga beings are derivable from sign + hora but not yet implemented.

**Being type**:
One of 7 classes of beings: Aditya (solar love), Rishi (bridging wisdom), Naga (unconscious lunar force), Gandharva (solar fire, inspiration), Rakshasa (solar air, tough growth), Yaksha (lunar earth, material retraining), Apsara (lunar water, emotional alchemy).

**Hora**:
Which half of a sign (Sun or Moon, 15° each). In the Aditya system, determines which side of the mountain — active Aditya expression (Sun) or releasing unconscious blocks (Moon).

### Configurations

**EphSnapshot**:
The frozen output of a single `SweFacade.calcAll()` call — all raw positions, speeds, and house cusps for one moment and location. The boundary object between ephemeris computation and everything downstream.

**SweConfig**:
Controls ephemeris computation (ayanamsa, house system, bodies, ephemeris source). Changing any field requires a new SWE call and a new EphSnapshot. Expensive.

**CalcConfig**:
Controls derived interpretation (circle, traditions, varga options). Changing it is free — reuse the same EphSnapshot. Cheap.

**Tradition**:
A self-contained interpretive framework that determines which calculations are available and how they're configured. Different traditions share the same EphSnapshot but interpret it through different systems. Currently: Vedic. Planned: Hellenistic, Human Design, Cards of Truth, Modern Western, Uranian, Persian. The Aditya system is within the Vedic tradition, not a separate tradition.

### Strength and state

**Avastha**:
"State" or "condition" of a planet. Five systems: Baladi (age by degree), Deeptadi (mood by dignity/combustion), Jagradadi (alertness by dignity), Lajjitaadi (relational-psychological, multi-factor), Shayanadi (12 states, unimplemented).

**Shadbala**:
"Six-fold strength" — the specific six-component strength calculation: Sthana (positional), Dig (directional), Ayana (solstitial), Cheshta (motional), Drig (aspectual) balas. Measured in virupas. Not a generic term for "strength."

**Dignity**:
How comfortably a planet functions in a given sign. Nine levels from exalted to debilitated, determined by the planet-sign relationship (own sign, friend's sign, enemy's sign, etc.).

### Timing

**Dasha**:
A planetary period system — a method of dividing a person's life into periods ruled by specific planets or signs. Two sub-categories: **nakshatra dashas** (keyed to Moon's nakshatra — Vimshottari, Yogini) and **sign dashas** (keyed to sign positions — Chara).
_Avoid_: "Rashi dasha" (use "sign dasha" per our convention that rashi = D1 varga)

**Panchanga**:
"Five limbs" of the Vedic almanac: tithi (lunar day), vara (weekday), karana (half-tithi), yoga (nityayoga), nakshatra (Moon's mansion). Always refers to this specific five-element set.

## Relationships

- A **Chart** is constructed from one **EphSnapshot** + one **CalcConfig**
- A **Chart** contains multiple **Vargas** (divisional views), lazily constructed
- A **Varga** contains **Karakas** (for the 7 embodied planets) and **Planets** (for Rahu, Ketu, outers)
- Each **Karaka** has a **Dignity** and may be combust
- Each **Planet** (and Karaka) has a **Longitude** per varga, which determines its **Sign**, **Nakshatra**, **Pada**, **Hora**, and **Being**
- **Avasthas** and **Shadbala** are computed by `arrow_calc` from a **Chart**, not stored on domain objects
- A **Dasha** is computed from a **Chart**'s Moon position and birth time
- An **Aditya** is an attribute of a **Sign** when using `Circle.aditya`

## Example dialogue

> **Dev:** "What sign is Mars in?"
> **Domain expert:** "Mars is in sign 4. In the Aditya circle, that's Varuna's sign — Mars activates the Rakshasa Chitrasvana there."
>
> **Dev:** "What's the difference between a Karaka and a Planet?"
> **Domain expert:** "All Karakas are Planets, but not all Planets are Karakas. Karakas are the 7 embodied planets — they carry dignity and combustion. Rahu and Ketu are Planets but not Karakas."
>
> **Dev:** "I need the rashi dasha periods."
> **Domain expert:** "We call those sign dashas. 'Rashi' in our language means the D1 chart, not a sign."

## Flagged ambiguities

- **Rashi**: used in spoken Vedic astrology to mean both "a sign" and "the D1 chart." Resolved: Rashi = D1 varga class. Sign = the 30° segment.
- **Karaka**: used in two senses — the class (7 embodied planets) and Jaimini chara karaka roles. Resolved: bare "karaka" = the class; Jaimini concept always qualified as "chara karaka."
- **Graha vs Planet**: "graha" is the Vedic domain concept; `Planet` is the class name, chosen for multi-tradition neutrality. `Body.grahas` is the 9-body Vedic grouping.
- **Aditya**: can mean the sign itself (in spoken language) or the solar deity being. Resolved: signs are signs; the Aditya is an attribute of the sign in `Circle.aditya`.
- **Rashi dasha**: spoken term conflicts with our Rashi = D1 convention. Resolved: use "sign dasha."
