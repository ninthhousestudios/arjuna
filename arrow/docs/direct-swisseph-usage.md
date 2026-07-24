# Using swisseph_rs directly alongside Arrow

Arrow deliberately does not wrap every Swiss Ephemeris function. This document
records the supported pattern for the ones it leaves out.

## What Arrow wraps, and why

The boundary is **config ownership**, not vocabulary purity.

`SweFacade` wraps functions whose correct invocation depends on Arrow-owned
configuration mapping — `SweConfig` → sidereal mode (including Dhruva), house
system codes, body IDs. Getting those wrong silently produces a wrong answer
rather than an error, so Arrow owns them:

| Method | Why it's wrapped |
|---|---|
| `calcAll` | The whole `SweConfig` → flags/modes/frames mapping |
| `getAyanamsa` / `getAyanamsaUt` | Ayanamsa → `SiderealMode`, plus Arrow's own Dhruva |
| `housePosition` | Needs ARMC + obliquity in a frame consistent with `signAyanamsa` |
| `calcSiderealLongitude`, `calcDhruvaLongitude`, `calcCardinalPoints` | Body IDs and ayanamsa frames |

## What Arrow does not wrap

Eclipse and occultation search:

- `solEclipseWhenGlob`, `solEclipseWhenLoc`, `solEclipseWhere`, `solEclipseHow`
- `lunEclipseWhen`, `lunEclipseWhenLoc`, `lunEclipseHow`
- `lunOccultWhenGlob`, `lunOccultWhenLoc`, `lunOccultWhere`

Their parameters — time window, location, ephemeris path/source — are all
app-owned, and their results are ayanamsa-independent. Wrapping them would
re-own an already well-typed result surface (`SolarEclipseGlobal` and friends)
purely for vocabulary, and every future event-search need would have to
round-trip through Arrow. Event search is a different axis from snapshot
calculation.

The same reasoning applies to other search-shaped functions Arrow does not
surface (`riseTrans` beyond sunrise/sunset, `solcross`/`mooncross` beyond the
cardinal points, `heliacal*`).

## The supported pattern

Declare `swisseph_rs` as a direct dependency and build your own `Ephemeris`
from the *same* ephemeris configuration Arrow uses. `SweFacade.ephePath` and
`.jplFile` are public for exactly this purpose.

```dart
import 'package:swisseph_rs/swisseph_rs.dart' as swe;

final facade = SweFacade.create(ephePath: ephePath);

final eclipseEph = swe.Ephemeris(
  swe.EphemerisConfig(
    // Arrow's own default-source rule: Swiss when an ephe path is present,
    // Moshier otherwise.
    ephemerisSource: facade.ephePath != null
        ? swe.EphemerisSource.swiss
        : swe.EphemerisSource.moshier,
    ephePath: facade.ephePath,
    jplFilename: facade.jplFile,
  ),
);

final next = eclipseEph.solEclipseWhenGlob(swe.JdUt1(jdUt), flags);
// ...
eclipseEph.close();
```

## Rules

**Declaring `swisseph_rs` as a direct dependency is correct.** It is not a
layering violation — it is the pub-correct way to depend on a transitive
package whose API you call.

**A second handle is safe.** swisseph-rs is stateless: configuration lives in
`EphemerisConfig` at construction time, and there is no process-global
`setEphePath` / `setSidMode` to drift. A second handle cannot corrupt Arrow's.
This is the hazard that made the old dual-door setup against the C
`swisseph.dart` binding fragile; it does not exist here.

**`ephePath`, `jplFilename`, and the ephemeris source must match Arrow's.** If
they diverge, eclipse times and chart positions come off different Delta-T
values and different ephemeris data — divergent results across features in the
same app.

**Do not `close()` anything owned by `SweFacade`.** The facade owns its handle
lifecycle via `dispose()`. Close only handles you constructed yourself.

**Across isolates, share rather than reopen.** Use `Ephemeris.share()` and
`Ephemeris.fromShareToken(token)` instead of opening an ad-hoc handle per
isolate.
