# True-Sidereal Zodiac: the Midpoint Method

Engineering reference for Arrow's 13-constellation true-sidereal zodiac
(`arrow/calc/lib/src/zodiac/`). This is a clean-room summary written in our own
words; it records the **method and the factual boundary data** (star identities,
catalog positions, computed boundaries), none of which are copyrightable. For the
full rationale, prose derivation, and discussion, cite the source:

> Chimenti, A. (2026). *The Midpoint Method: An Ecliptic-Based Boundary System
> for Zodiacal Constellations.* Zenodo. https://doi.org/10.5281/zenodo.20747017
> (CC BY-NC-ND 4.0)

## What problem it solves

Astrology needs the ecliptic partitioned into named segments. Equal-segment
schemes (tropical, Lahiri/Fagan-Bradley sidereal) cut it into twelve uniform 30°
arcs that ignore the real angular extent of the constellations. The IAU 1930
boundaries follow the constellations but are drawn as polygons in *equatorial*
coordinates, so projected onto the ecliptic a boundary becomes latitude-dependent
— a body's constellation can change with its ecliptic latitude, which is useless
for a longitude-only partition.

The Midpoint Method produces boundaries that (a) follow the observed
constellations, (b) are single ecliptic-longitude values with no latitude
dependence, and (c) are reproducible from primary catalog data.

## Core rule

For two adjacent zodiacal constellations `C` (preceding) and `C′` (following),
with `λ_last(C)` the ecliptic longitude of the **last line star** of `C` and
`λ_first(C′)` the **first line star** of `C′`:

```
λ_boundary(C → C′) = ½ · ( λ_last(C) + λ_first(C′) )
```

At the Pisces→Aries wrap, add 360° to the smaller longitude before averaging and
reduce mod 360. This is the only boundary that straddles 0°.

Applied around the full circle to the **thirteen** constellations the ecliptic
crosses — the twelve traditional signs **plus Ophiuchus** (between Scorpius and
Sagittarius) — the thirteen midpoints partition the ecliptic completely.

### Reference frame

All star positions are J2000.0 mean ecliptic (ICRS), from the Hipparcos-2
catalog (van Leeuwen 2007, `I/311/hip2`), reduced from the catalog epoch
J1991.25 to J2000.0 with each star's proper motion, then rotated equatorial→
ecliptic by the mean obliquity at J2000. For dates other than J2000 the software
applies precession (Arrow/SWE use the Vondrák-Capitaine-Wallace 2011 model).

## Edge-star selection

"Line stars" are the stars forming a constellation's stick-figure, not every
star in its IAU region. For each constellation, its first and last line stars
along the ecliptic are the candidates. Three rules resolve the candidates:

1. **Tradition selection.** Line stars are drawn from two sky cultures (Stellarium
   "Modern/IAU" and "Indian Vedic"). When they disagree on an edge star, pick the
   one that makes the constellation *broader*: the lower-longitude candidate at the
   start, the higher-longitude candidate at the end. This never lets midpoint
   geometry alone discard an admissible edge star.

2. **Ecliptic-latitude filter (overlap regions only).** By default an edge is read
   straight from the figure's endpoints. Where two figures overlap in longitude —
   the signature of a figure standing *across* the ecliptic rather than *along* it —
   the outermost endpoints may be a raised hand or foot far off the band, so
   frontage is instead read from line stars within **±10° ecliptic latitude**.
   Overlap (a binary, objective condition) is the trigger, not latitude itself; once
   engaged for a constellation it applies at both its edges. The two overlap regions
   are **Capricornus/Aquarius** and **Scorpius/Ophiuchus**.

3. **Ordering constraint.** Constellations must stay in monotonic ecliptic order. An
   edge star is admitted only if its longitude exceeds the previous constellation's
   last star, preventing reordering in overlap regions.

## Zero point / ayanamsa

The scheme's 0° (start of Aries) is the Pisces→Aries boundary: the midpoint
between Alrescha (α Psc) and Mesarthim (γ Ari). At J2000 that is **31.2816°** of
tropical ecliptic longitude — i.e. an ayanamsa of 31.2816°. In Swiss Ephemeris
terms this is `swe_set_sid_mode(SE_SIDM_USER, 2451545.0, 31.2816)` under Vondrák
2011.

## Edge stars (facts, J2000 Hipparcos-2)

First = lowest-longitude line star, Last = highest. `Trad.` = sky culture the star
is drawn from. These are the selections after applying the three rules above.

| Constellation | Edge  | Star            | HIP    | Ecl. Long (°) | Ecl. Lat (°) | Trad.     |
|---------------|-------|-----------------|--------|---------------|--------------|-----------|
| Aries         | first | Mesarthim       | 8832   | 33.1846       | 7.1624       | IAU/Vedic |
| Aries         | last  | Botein          | 14838  | 50.8530       | 1.8240       | Vedic     |
| Taurus        | first | Omicron Tauri   | 15900  | 51.1636       | −9.3342      | IAU/Vedic |
| Taurus        | last  | Tianguan (ζ Tau)| 26451  | 84.7846       | −2.1956      | IAU/Vedic |
| Gemini        | first | 1 Geminorum     | 28734  | 90.9463       | −0.1726      | IAU/Vedic |
| Gemini        | last  | Kappa Geminorum | 37740  | 113.6658      | 3.0786       | IAU/Vedic |
| Cancer        | first | Chi Cancri      | 40843  | 120.9730      | 7.4654       | Vedic     |
| Cancer        | last  | Acubens         | 44066  | 133.6416      | −5.0804      | IAU/Vedic |
| Leo           | first | Al Minliar (κ Leo)| 46146| 135.2961      | 10.4262      | IAU       |
| Leo           | last  | Denebola        | 57632  | 171.6175      | 12.2669      | IAU/Vedic |
| Virgo         | first | Nu Virginis     | 57380  | 174.1592      | 4.5863       | IAU/Vedic |
| Virgo         | last  | Rijl al Awwa (μ Vir)| 71957| 220.1312    | 9.6721       | IAU/Vedic |
| Libra         | first | Zubenelgenubi   | 72622  | 225.0827      | 0.3331       | IAU/Vedic |
| Libra         | last  | 48 Librae       | 78207  | 240.3994      | 6.0855       | Vedic     |
| Scorpius      | first | Dschubba        | 78401  | 242.5712      | −1.9861      | IAU/Vedic |
| Scorpius      | last  | Paikauhale (τ Sco)| 81266| 251.4569      | −6.1204      | IAU/Vedic |
| Ophiuchus     | first | Sabik           | 84012  | 257.9696      | 7.1978       | IAU       |
| Ophiuchus     | last  | 45 Ophiuchi     | 85423  | 262.8807      | −6.6292      | IAU       |
| Sagittarius   | first | Alnasl (Nash, γ Sgr)| 88635| 271.2614    | −6.9912      | IAU/Vedic |
| Sagittarius   | last  | 62 Sagittarii   | 98688  | 297.0658      | −7.1062      | Vedic     |
| Capricornus   | first | Algedi (α² Cap) | 100064 | 303.8586      | 6.9302       | IAU/Vedic |
| Capricornus   | last  | Deneb Algedi    | 107556 | 323.5426      | −2.6017      | IAU/Vedic |
| Aquarius      | first | Iota Aquarii    | 109139 | 328.7199      | −2.0810      | IAU/Vedic |
| Aquarius      | last  | Phi Aquarii     | 114724 | 347.1386      | −1.0524      | IAU       |
| Pisces        | first | Gamma Piscium   | 114971 | 351.4532      | 7.2571       | IAU/Vedic |
| Pisces        | last  | Alrescha (α Psc)| 9487   | 29.3787       | −9.0609      | IAU/Vedic |

Worked cases from the source, for reference:
- **Aries/Taurus** (tradition selection): traditions disagree on Aries' last star
  (Bharani 48.20° IAU vs Botein 50.85° Vedic); the broader extent picks Botein.
  With Omicron Tauri (51.1636°): boundary = ½(50.8530 + 51.1636) = **51.0083°**.
- **Scorpius/Ophiuchus** (latitude filter): Larawag (ε Sco) at lat −11.74° is
  excluded (>±10°), leaving Paikauhale (251.4569°) and Sabik (257.9696°):
  boundary = **254.7132°**.
- **Capricornus/Aquarius** (ordering): Sadalsuud (β Aqr, 323.3951°) would fall
  *before* Capricornus' last star Deneb Algedi (323.5426°), inverting order, so it
  is rejected; Iota Aquarii (328.7199°) is used: boundary = **326.1312°**.

## Boundaries (facts, J2000)

Absolute = tropical-referenced ecliptic longitude. Zodiacal = relative to this
scheme's Aries start. Length = extent of the sign.

| Sign        | Absolute (°) | Zodiacal (°) | Length (°) |
|-------------|--------------|--------------|------------|
| Aries       | 31.2816      | 0.0000       | 19.7267    |
| Taurus      | 51.0083      | 19.7267      | 36.8572    |
| Gemini      | 87.8655      | 56.5838      | 29.4539    |
| Cancer      | 117.3194     | 86.0378      | 17.1495    |
| Leo         | 134.4689     | 103.1872     | 38.4195    |
| Virgo       | 172.8884     | 141.6068     | 49.7185    |
| Libra       | 222.6069     | 191.3253     | 18.8784    |
| Scorpius    | 241.4853     | 210.2037     | 13.2279    |
| Ophiuchus   | 254.7132     | 223.4316     | 12.3578    |
| Sagittarius | 267.0711     | 235.7895     | 33.3912    |
| Capricornus | 300.4622     | 269.1806     | 25.6690    |
| Aquarius    | 326.1312     | 294.8496     | 23.1646    |
| Pisces      | 349.2959     | 318.0143     | 41.9857    |

Lengths sum to 360° at full precision (displayed values round to 359.9999°).
Practical interpretation treats ±3° around each boundary as a transition zone;
that buffer is interpretive, not encoded in the values.

## How Arrow implements it

- `constellation_star_map.dart` — the 13 first/last edge stars above (the
  three selection rules are pre-resolved into this static table).
- `ecliptic13.dart` — `_computeBoundaries` applies the midpoint formula with
  wrap-safe modular arithmetic, then rotates so `boundaries[i]` is the *start* of
  constellation `i` (the Pisces→Aries midpoint becomes Aries' start). `Ecliptic13`
  bins planets/stars by longitude; fixed stars with |ecliptic lat| > 10° are
  skipped at placement.
- `boundary_stars.dart` — the set of `Star`s to request in `SweConfig.stars`.
- Boundaries are computed at runtime from the star longitudes in the `EphSnapshot`,
  so they follow whatever frame the snapshot is in (tropical J2000 reproduces the
  absolute column above to ~0.01°, the residual being SWE's Vondrák precession vs
  the source's astropy reduction).

### Catalog dependency

Every boundary star must exist in the Swiss Ephemeris fixed-star catalog
(`sefstars.txt`) on the active ephe path, or `swe_fixstar` lookup fails. The two
edge stars that are easy to get wrong (both feed only the Sagittarius→Capricornus
boundary) are:

- Sagittarius last: **62 Sagittarii**, HIP 98688, SWE name `,cSgr`
- Capricornus first: **Algedi** (α² Cap), HIP 100064, SWE name `,alf02Cap`

`,cSgr` is not in the stock Swiss Ephemeris distribution and must be added to
`sefstars.txt` (generate the entry with swisseph-rs's `make-swe-stars`).
