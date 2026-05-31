# Handoff — Arrow Refactor

## Branch: `drona`

## Last commit: `06f2c60` — Complete review fixes

All three review-driven fixes from the GLM-5.1 wave-A review are implemented:

1. **Dhruva + nakEquatorial constraint**: `ArrowOptions.validate()` throws `ArgumentError` if dhruva ayanamsa is used with `nakEquatorial=false`. `Chart` constructor has a matching debug assert. Dhruva is equatorial-only — ecliptic nakshatras are meaningless.

2. **Sidereal nakshatra integration test**: 6 tests in `swe/test/nakshatra_sidereal_integration_test.dart` verify the full calcAll→Chart pipeline with Lahiri sidereal config. Tests cover: nak/sign longitude identity when ayanamsas match, tropical-sidereal difference equals ayanamsa value, 0° sidereal → Ashvini (nakshatra 1), cusp nak longitude computation.

3. **Cusp nak correctness**: `EphSnapshot` gains `cuspsNakLon` (defaulted `List<double>`). `calcAll` recomputes `housesEx` in the nak frame when `nakAyanamsa != signAyanamsa` (standard SWE ayanamsas). `Cusp` accepts optional `nakLongitude`, passed through by `Varga._initMaps`. Dhruva cusps fall back to ecliptic longitude (cusps are ecliptic divisions — equatorial projection is not meaningful).

## Completed waves

- **Wave A** (all parts): SWE boundary sealed
- **Wave C**: Body hierarchy flattened
- **Wave D**: Varga math extracted from Longitude
- **Wave B.1**: CalcConfig stripped from EphSnapshot
- **Wave B.2**: StarPosition introduced, 6 star maps collapsed to 2
- **Nak-frame fix** (`04cc717`): Double-subtraction bug fixed, sidereal positions computed natively
- **Review fixes** (`06f2c60`): Dhruva validation, sidereal nak integration test, cusp nak longitudes

## Test counts

All 839 tests pass (options 55, swe 73, core 317, calc 394).

## Notes

- Generated files (.freezed.dart, .g.dart) are gitignored — run `dart run build_runner build` in options/ and swe/ after touching freezed classes
- `ArrowOptions` still exists in `options/` — it's the user-facing config bundle, just no longer on the snapshot
- SWE global state ordering in `calcAll` is critical: all sign-frame work must complete before nak-frame phase switches `setSidMode`
- Cusp nak longitudes are ecliptic-only (no equatorial variant) since house cusps are ecliptic divisions
