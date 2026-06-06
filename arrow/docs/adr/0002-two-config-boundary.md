# Separate SweConfig (ephemeris computation) from CalcConfig (derived interpretation)

Arrow splits configuration into two distinct objects with different cost profiles. `SweConfig` controls raw ephemeris computation (ayanamsa, house system, which bodies to calculate) — changing any field requires a new `SweFacade.calcAll()` call and a new `EphSnapshot`. `CalcConfig` controls derived interpretation (circle, traditions, varga options) — changing it is free, just construct a new `Chart` over the same snapshot.

Most astrology libraries (including libaditya, Arrow's Python reference implementation) mix computation and interpretation freely. This caused boundary violations during the initial port of Stars from libaditya, where Python functions that interleaved SWE calls with interpretation logic were translated into Dart without respecting the separation. The fix required disentangling the port after the fact.

Every feature ported from libaditya must be classified before implementation: does it need new raw data from SWE (Category A — requires SweFacade/EphSnapshot changes), or does it derive from existing positions (Category B — pure arrow_calc)? Naively porting a function that mixes both will violate the boundary.

## Consequences

- `ArrowOptions` bundles both: `ArrowOptions(sweConfig: ..., calcConfig: ...)`. Consumer code can swap `CalcConfig` freely without touching `SweConfig`.
- `EphSnapshot` is the boundary object between the two worlds. Everything downstream of the snapshot is a view, not a computation.
- Features that need new SWE data (rise/set times, eclipses, heliacal events, returns, alt/az) require extending the SWE pipeline, not just adding calc functions.
