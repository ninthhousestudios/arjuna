# Codex Full Code Review

**Reviewer:** Codex
**Date:** 2026-05-04
**Scope:** Whole `arrow` workspace: `options`, `swe`, `core`, `calc`, and `tool`.

## Summary

The workspace is in good shape overall. The package split is mostly coherent, the SWE boundary is centralized in `arrow_swe`, and the test suite is broad enough to catch many domain regressions: all package test suites passed locally. The biggest remaining risks are not broad instability; they are API contract gaps where configurable snapshots meet convenience getters, and one likely behavioral bug in dignity calculation outside the rashi chart.

## Findings

### 1. Varga dignity mixes varga body sign with rashi lord sign

**Severity:** High

`Varga` creates `Karaka` objects for every divisional chart, not just D1 (`core/lib/src/varga.dart:37-45`). `Karaka.dignity` then uses the karaka's current `sign` and `inSignLongitude`, which are varga-aware, but computes the sign lord's position as a D1/rashi `Longitude` regardless of `vargaType` (`core/lib/src/karaka.dart:15-29`).

That means `chart.varga(VargaType.navamsha).sun.dignity` combines:

- Sun's navamsha sign
- Sun's navamsha in-sign degree
- the navamsha sign lord's rashi position for temporary friendship

This is an inconsistent coordinate frame. If dignity is intended to be rashi-only, the API should not expose it transparently on every `Karaka` in every `Varga`. If dignity is intended to work in divisional charts, the lord longitude should be computed with the same `vargaType`:

```dart
final lordLon = Longitude(lordPos.longitude, vargaType, config);
```

There is currently no direct test for dignity on a non-rashi varga; existing coverage only checks that rashi dignity is computable.

### 2. Configurable body sets make named accessors unsafe

**Severity:** Medium

`SweConfig.bodies` is configurable and presets can omit bodies. For example `ArrowPresets.westernTropical` excludes Rahu and Ketu and includes outer planets (`options/lib/src/presets.dart:39-58`). But `Chart` and `Varga` expose non-null named accessors such as `sun`, `rahu`, and `ketu` that force-unwrap map entries (`core/lib/src/chart.dart:59-68`, `core/lib/src/varga.dart:82-91`).
note: Rahu and Ketu should be in westernTropical, though they are usually called "north
node" and "south node" in western.
Any consumer using a reduced body set can get runtime `_TypeError`/null-check failures from normal-looking API calls:

```dart
final chart = Chart(snapshotFromWesternPreset, ArrowPresets.westernTropical.calcConfig);
chart.rahu; // throws because Rahu was never requested
```

The implementation should either validate required bodies at `Chart`/`Varga` construction, make optional access explicit (`Planet? maybePlanet(Body body)` / nullable named accessors), or document that named accessors are only valid when the body was included in `SweConfig.bodies`.

### 3. `fromJulianDay` clamps millisecond rollover instead of carrying

**Severity:** Medium

`fromJulianDay` rounds fractional seconds to milliseconds and then clamps the result to `999` (`swe/lib/src/julian_day.dart:40-48`). When floating-point rounding produces exactly `1000`, the function returns `...:ss.999` instead of carrying to the next second, minute, hour, or day.

This is small in absolute magnitude, but it breaks the function's stated "accurate to the millisecond" contract near second boundaries. A safer implementation is to convert the day fraction to a rounded integer millisecond count and construct the result by adding a `Duration` to midnight UTC, letting `DateTime` handle all rollovers.

### 4. Package metadata is relying on workspace leakage

**Severity:** Medium

`dart analyze` reports dependency hygiene issues:

- `core/test/fixed_star_test.dart` imports `package:swisseph/swisseph.dart`, but `core/pubspec.yaml` does not declare `swisseph`.
- `swe/test/ecliptic13_integration_test.dart` imports `package:arrow_calc/arrow_calc.dart`, but `swe/pubspec.yaml` does not declare `arrow_calc`.
- `swe/test/nakshatra_sidereal_integration_test.dart` imports `package:arrow_core/arrow_core.dart`, but `swe/pubspec.yaml` does not declare `arrow_core`.

The tests pass in this workspace because the workspace package graph exposes sibling packages, but individual package analysis correctly flags that these packages are not self-describing. Add the missing `dev_dependencies` or move cross-package integration tests to a workspace-level test package.

### 5. Integration test tags are not declared

**Severity:** Low

Several tests use `@Tags(['integration'])`, but there is no `dart_test.yaml` anywhere in the workspace. `dart test` warns repeatedly:

```text
Warning: A tag was used that wasn't specified in dart_test.yaml.
  integration was used in the suite itself
```

Add a root/package `dart_test.yaml` declaring `integration`, or remove the tags if they are not used for filtering. This is not a runtime bug, but it adds noise to CI and can hide more meaningful test output.

### 6. JPL ephemeris is exposed as a normal option without a serializable path

**Severity:** Low

`EphemerisSource.jplEph` is a public `SweConfig` value (`options/lib/src/ephemeris_source.dart:9-11`), while the required `jplFile` lives only on the `SweFacade` constructor (`swe/lib/src/swe_facade.dart:26-45`). A serialized `SweConfig` can therefore request JPL without carrying enough information to reproduce the calculation.

This is currently documented in comments and will fail at calculation time if the facade lacks a JPL file, but the API would be clearer if `jplEph` were either fail-fast validated in `calcAll` or paired with a first-class config field.

## Strengths

- The `SweConfig` / `CalcConfig` boundary is mostly well maintained: raw ephemeris choices are in `options`/`swe`, and derived chart behavior is in `core`/`calc`.
- `SweFacade.calcAll` now precomputes nakshatra-frame longitudes directly instead of doing late subtraction in `core`, which avoids the sidereal double-subtraction class of bugs.
- Test coverage is broad for varga math, avasthas, panchanga, Vimshottari, Jaimini, Shadbala, fixed stars, reference frames, and JSON round-trips.
- The `arrow_swe` barrel no longer re-exports `SwissEph`, which keeps the external boundary cleaner.

## Verification

Commands run:

```text
dart analyze   # core, options, swe, calc
dart test      # core, options, swe, calc
```

Results:

- `options`: analyze clean, tests passed (`55` tests).
- `calc`: analyze clean, tests passed (`394` tests).
- `core`: tests passed (`317` tests); analyzer reported one missing dependency warning for `swisseph` in tests.
- `swe`: tests passed (`73` tests); analyzer reported one dangling library-doc comment and two missing dependency warnings in tests.

The Dart executable is the Flutter-bundled wrapper, so the commands required permission to access the local Flutter SDK cache outside the sandbox.

## Suggested Priority

1. Fix or explicitly restrict `Karaka.dignity` for non-rashi vargas, then add a regression test.
2. Decide the body-set API contract and make missing bodies explicit instead of force-unwrapped.
3. Clean up package `dev_dependencies` and declare the `integration` test tag.
4. Fix the Julian Day rollover edge case.
5. Make the JPL configuration path fail-fast or serializable.
