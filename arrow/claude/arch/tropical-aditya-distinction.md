# Tropical vs Aditya Distinction

## Overview

Both Aditya and tropical charts use **the same SWE calculation** — tropical flag in both cases. The raw ecliptic longitudes in `EphSnapshot` are identical. The difference is entirely in how you map a longitude to a sign number. No SWE recalculation is needed.

## Sign Formulas

**Zodiac (tropical):** Sign 1 (Aries) starts at 0° — the vernal equinox.
```
sign = floor(lon / 30) + 1
```

**Aditya:** The circle is shifted 30° earlier. Sign 1 (the first Aditya) starts at 330° tropical.
```
sign = floor((lon + 30) / 30) % 12 + 1
```

Example: a planet at 5° tropical is in Aries (sign 1) under Zodiac, but sign 2 under Aditya.
Example: a planet at 345° tropical is in Pisces (sign 12) under Zodiac, but sign 1 under Aditya.

The 12 Adityas are solar deities representing the 12 months of the solar year. The Aditya circle is Vedic tradition's way of dividing the solar year, starting 30° before the vernal equinox.

## Where it Lives in Arrow

This is pure derived math — no SWE recalculation. `Circle` belongs in `CalcConfig`.

```dart
enum Circle { zodiac, aditya }
```

Sign calculation:
```dart
int signOf(double longitude, CalcConfig config) {
  final offset = config.circle == Circle.aditya ? 30.0 : 0.0;
  return (((longitude + offset) % 360) ~/ 30) + 1;
}
```

## Independence of Circle and Ayanamsa

`Circle` and `signAyanamsa` are fully independent. Any `signAyanamsa` can be used with either circle. Examples:
- `signAyanamsa = tropical, circle = aditya` — the primary Vedic use case
- `signAyanamsa = tropical, circle = zodiac` — Western tropical
- `signAyanamsa = lahiri, circle = zodiac` — standard sidereal Vedic

## Signs and Nakshatras are Always Independent

Arrow always distinguishes sign ayanamsa from nakshatra ayanamsa. Each has its own setting in `SweConfig`:
- `signAyanamsa` — controls the zero point for the 12-sign circle
- `nakAyanamsa` — controls the zero point for the 27-nakshatra circle

The primary use case for Arrow: `signAyanamsa = tropical, nakAyanamsa = dhruva`.

**Dhruva** is the Galactic Center / middle of Mula ayanamsa, calculated with equatorial coordinates. It is implemented in libkala (`libkala/objects/nakshatras.py`). This gives nakshatras their most astronomically grounded reference point.

The `Circle` setting does not affect nakshatra calculation.

## Source

Ported from `libkala/objects/longitude.py`:
- `Circle` enum (ADITYA / ZODIAC) in `EphContext`
- `aditya_offset = 30` when `circle == Circle.ADITYA`, else `0`
- Used throughout varga calculations as a longitude baseline shift
