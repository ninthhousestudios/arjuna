---

## 6. The Three Core Types

These are the foundational types that everything else builds on:

### `packages/arrow_swe/lib/src/eph_snapshot.dart`

The **immutable bridge** between SWE and everything else:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'eph_snapshot.freezed.dart';
part 'eph_snapshot.g.dart';

/// The immutable, serializable snapshot of all raw SWE output.
/// This is THE bridge between arrow_swe and arrow_core/arrow_calc.
/// Non-SWE code never calls SWE directly — it only sees this.
@freezed
class EphSnapshot with _$EphSnapshot {
  const factory EphSnapshot({
    required DateTime jdUt,
    required double ayanamsaValue,
    required Map<BodyId, BodyPosition> bodiesEcliptic,
    required Map<BodyId, BodyPosition> bodiesEquatorial,
    required List<double> cusps,        // 12 house cusps
    required AscMcPoints ascmc,
    required SunTimes sunTimes,
  }) = _EphSnapshot;

  factory EphSnapshot.fromJson(Map<String, dynamic> json) =>
      _$EphSnapshotFromJson(json);
}

/// Raw position data for a single celestial body straight from SWE.
@freezed
class BodyPosition with _$BodyPosition {
  const factory BodyPosition({
    required double longitude,
    required double latitude,
    required double distance,
    required double speedLongitude,
    required double speedLatitude,
    required double speedDistance,
  }) = _BodyPosition;

  factory BodyPosition.fromJson(Map<String, dynamic> json) =>
      _$BodyPositionFromJson(json);
}

/// Ascendant, MC, and related special points from SWE.
@freezed
class AscMcPoints with _$AscMcPoints {
  const factory AscMcPoints({
    required double ascendant,
    required double mc,
    required double armc,
    required double vertex,
    required double equatorialAscendant,
    required double coAscendantKoch,
    required double coAscendantMunkasey,
    required double polarAscendant,
  }) = _AscMcPoints;

  factory AscMcPoints.fromJson(Map<String, dynamic> json) =>
      _$AscMcPointsFromJson(json);
}

/// Sunrise and sunset times for the date/location.
@freezed
class SunTimes with _$SunTimes {
  const factory SunTimes({
    required double sunrise,
    required double sunset,
  }) = _SunTimes;

  factory SunTimes.fromJson(Map<String, dynamic> json) =>
      _$SunTimesFromJson(json);
}

/// Identifies a celestial body in the snapshot.
enum BodyId {
  sun,
  moon,
  mars,
  mercury,
  jupiter,
  venus,
  saturn,
  rahu,       // Mean or true, depending on SweConfig
  ketu,
  uranus,
  neptune,
  pluto,
}
```

---

### `packages/arrow_core/lib/src/model/planet.dart`

The **rich domain object** hierarchy — wraps EphSnapshot, never calls SWE:

```dart
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';

/// Base class for all celestial bodies.
///
/// Rich object that wraps EphSnapshot + CalcConfig.
/// Provides ergonomic accessors WITHOUT calling SWE.
///
/// Hierarchy:
///   Planet (all bodies) → Graha (+ nodes = 9) → Karaka (7 embodied)
class Planet {
  final int id;
  final EphSnapshot snapshot;
  final CalcConfig config;

  const Planet({
    required this.id,
    required this.snapshot,
    required this.config,
  });

  /// Raw position data from the snapshot
  PlanetPosition get position => snapshot.planets[id]!;

  /// Sidereal longitude (0-360)
  double get longitude => position.longitude;

  /// Speed in longitude (degrees/day)
  double get speed => position.speedLongitude;

  /// Is this planet retrograde?
  bool get isRetrograde => speed < 0;

  /// Sign index (0-11): Aries = 0, Taurus = 1, ...
  int get signIndex => (longitude ~/ 30).toInt();

  /// Degree within the sign (0-30)
  double get signDegree => longitude % 30;

  /// Nakshatra index (0-26): Ashwini = 0, Bharani = 1, ...
  int get nakshatraIndex => (longitude * 27 / 360).toInt();

  /// Pada within the nakshatra (1-4)
  int get pada => ((longitude % (360 / 27)) / (360 / 108)).toInt() + 1;

  @override
  String toString() => 'Planet($id @ ${longitude.toStringAsFixed(2)}°)';
}

/// A Graha — the 9 Vedic grahas (7 karakas + Rahu + Ketu)
class Graha extends Planet {
  const Graha({
    required super.id,
    required super.snapshot,
    required super.config,
  });
}

/// A Karaka — the 7 embodied planets with dignity and combustion.
/// Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn.
class Karaka extends Graha {
  const Karaka({
    required super.id,
    required super.snapshot,
    required super.config,
  });

  // Dignity, combustion, friendships etc. will live here
  // These are Karaka-only concepts
}
/// The 9 Vedic grahas — karakas + Rahu/Ketu.
class Graha extends Planet {
  Graha(super.id, super.snapshot, super.config);
}

/// The 7 embodied planets — dignity and combustion live here.
class Karaka extends Graha {
  Karaka(super.id, super.snapshot, super.config);

  // TODO: dignity, combustion, friendship — only meaningful for embodied planets
}
```

---

### `packages/arrow_core/lib/src/model/chart.dart`

The **Chart** — the entry point to the domain model:

```dart
import 'package:arrow_swe/arrow_swe.dart';
import 'package:arrow_options/arrow_options.dart';
import 'planet.dart';
import 'cusp.dart';

/// The main domain object. Wraps EphSnapshot + CalcConfig
/// and provides typed access to all bodies and cusps.
class Chart {
  final EphSnapshot snapshot;
  final CalcConfig config;

  Chart(this.snapshot, this.config);

  // ── Karakas (7 embodied planets) ──────────────────────

  Karaka get sun      => Karaka(BodyId.sun, snapshot, config);
  Karaka get moon     => Karaka(BodyId.moon, snapshot, config);
  Karaka get mars     => Karaka(BodyId.mars, snapshot, config);
  Karaka get mercury  => Karaka(BodyId.mercury, snapshot, config);
  Karaka get jupiter  => Karaka(BodyId.jupiter, snapshot, config);
  Karaka get venus    => Karaka(BodyId.venus, snapshot, config);
  Karaka get saturn   => Karaka(BodyId.saturn, snapshot, config);

  List<Karaka> get karakas => [sun, moon, mars, mercury, jupiter, venus, saturn];

  // ── Grahas (karakas + nodes) ──────────────────────────

  Graha get rahu => Graha(BodyId.rahu, snapshot, config);
  Graha get ketu => Graha(BodyId.ketu, snapshot, config);

  List<Graha> get grahas => [...karakas, rahu, ketu];

  // ── All planets (grahas + outers) ─────────────────────

  Planet get uranus  => Planet(BodyId.uranus, snapshot, config);
  Planet get neptune => Planet(BodyId.neptune, snapshot, config);
  Planet get pluto   => Planet(BodyId.pluto, snapshot, config);

  List<Planet> get planets => [...grahas, uranus, neptune, pluto];

  // ── Cusps ─────────────────────────────────────────────

  List<Cusp> get cusps => List.generate(
    12,
    (i) => Cusp(i + 1, snapshot.cusps[i], snapshot, config),
  );

  Cusp cusp(int house) => cusps[house - 1];

  // ── Special points ────────────────────────────────────

  double get ascendant => snapshot.ascmc.ascendant;
  double get mc => snapshot.ascmc.mc;

  @override
  String toString() => 'Chart(${snapshot.jdUt})';
}
```

---

## Summary

```
EphSnapshot  → The immutable data bridge (freezed, serializable)
Planet       → Rich domain object hierarchy (Planet → Graha → Karaka)
Chart        → The entry point — chart.sun.nakshatra, chart.cusps, etc.
```

These three types are the **spine of Arrow**. Everything in `arrow_core` builds getters on these objects, and everything in `arrow_calc` takes them as inputs. Want me to scaffold out the `Cusp` class or the options/enums next?


