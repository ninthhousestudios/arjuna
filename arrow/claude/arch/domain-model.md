
❯ for the dart rewrite, what do you think about using a rich domain model?                                                             
                                                                           
● Good question. There's a real tension here. Let me think through it against what's actually in the codebase.                         
                                                            
  What the Python rich model gets right:                                                                                               
  planet.dignity()                                          
  planet.nakshatra()                                                                                                                   
  planet.is_retrograde()                                    
  planet.varga_position(9)  # navamsha
  This is genuinely ergonomic. When you're exploring a chart interactively or writing analysis code, chart.sun.dignity() reads like
  astrology, not like programming.

  What it gets wrong:
  The Python Planet.__init__ calls swe.calc_ut() directly. It inherits from SWEFirstLast for heliacal functions. The object is the
  calculation — you can't have a Planet without running SWE. That's the coupling we've already decided to break with the pipeline.

  The C# model is the opposite problem:
  EphData is just double[13,6]. All intelligence lives in static methods like AstroTools.PlanetNakshatraLords(p, native, levels). It's
  decoupled but the call sites read like accounting, not astrology. You're always passing indices and data bags around.

  For Arrow, I'd suggest a hybrid — rich objects that don't own their data:

  The EphSnapshot stays dumb and immutable (the pipeline boundary). But arrow_core wraps it into rich objects that provide the
  ergonomic API without owning the SWE call:

  // arrow_core builds these FROM an EphSnapshot + CalcConfig
  // they don't call SWE — they just provide a nice lens over the snapshot

  class Graha {
    final PlanetPosition _pos;   // from snapshot
    final CalcConfig _config;    // for derived calc decisions
    final int id;

    double get longitude => _pos.longitude;
    bool get isRetrograde => _pos.speedLongitude < 0;
    int get sign => (longitude ~/ 30) + 1;
    Nakshatra get nakshatra => Nakshatra.of(longitude);
    int get vargaSign(int division) => _calcVarga(longitude, division, _config);
    // ...
  }

  class Chart {
    final EphSnapshot snapshot;
    final CalcConfig config;
    late final Map<int, Graha> grahas;
    late final List<Bhava> bhavas;

    Chart(this.snapshot, this.config) {
      grahas = snapshot.planets.map((id, pos) =>
        MapEntry(id, Graha(pos, config, id)));
      // ...
    }

    Graha get sun => grahas[1]!;
    Graha get moon => grahas[2]!;
    // ...
  }

  So the call site reads like: chart.sun.nakshatra, chart.moon.dignity — the same ergonomics as Python. But a Graha is just a view over
   snapshot data + config. It doesn't fetch anything. You can construct one from JSON, from a server response, from a test fixture.

  The risk with rich models:
  They tend to accumulate everything. Python's Planet inherits from CelestialObject, Longitude, PlanetBala, and SWEFirstLast — it's
  ~1500 lines. Methods get added because "well, it's about a planet." Eventually you can't reason about what depends on what.

  Mitigation: Keep the rich objects thin. Graha has properties and simple derived getters. Complex analysis (shadbala, dashas, yogas)
  stays as functions in arrow_calc that take a Chart, not methods on it. The rule would be:

  - On the object: things that are about this graha/bhava in isolation (sign, nakshatra, dignity, retrograde, speed, varga placement)
  - Functions taking the object: things that involve relationships between multiple grahas or the chart as a whole (aspects, yogas,
  dashas, shadbala, ashtakavarga)

  This keeps the rich objects from becoming god objects while still giving you chart.jupiter.dignity instead of
  calcDignity(snapshot.planets[5]!, config).

  What's your instinct — does that split feel right, or do you want to draw the line differently?

# Arrow Domain Model

## Core Principle

Rich objects that don't own their data. The EphSnapshot stays dumb and immutable (the pipeline boundary). arrow_core wraps it into rich objects that provide an ergonomic API without calling SWE.

## Celestial Body Hierarchy

Three-level distinction:

- **Karaka** — the 7 embodied planets: Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn
- **Graha** — karakas + Rahu and Ketu (the 9 used in most Vedic calculations)
- **Planet** — grahas + Uranus, Neptune, Pluto (the full set)

`Planet` is the base class. `Graha` and `Karaka` are narrowing subtypes — every Karaka is a Graha, every Graha is a Planet, but not vice versa.

```dart
class Planet {
  final PlanetPosition _pos;
  final CalcConfig _config;
  final int id;

  double get longitude => _pos.longitude;
  double get latitude => _pos.latitude;
  double get speed => _pos.speedLongitude;
  bool get isRetrograde => _pos.speedLongitude < 0;
  int get sign => (longitude ~/ 30).toInt() + 1;
  Nakshatra get nakshatra => Nakshatra.of(longitude);
  int vargaSign(int division) => calcVarga(longitude, division, _config);
}

class Graha extends Planet {
  // Rahu/Ketu + all karakas
  // Vedic-specific properties that apply to the 9
}

class Karaka extends Graha {
  // The 7 embodied planets only
  // Dignity, combustion, etc. — things that don't apply to nodes or outers
  Dignity get dignity => ...;
  bool get isCombust => ...;
}
```

Whether a Planet is accessed as a Karaka, Graha, or Planet depends on context. The Chart holds all of them; typed accessors narrow the view:

```dart
chart.sun          // -> Karaka
chart.rahu         // -> Graha
chart.uranus       // -> Planet
chart.karakas      // -> List<Karaka> (7)
chart.grahas       // -> List<Graha> (9)
chart.planets      // -> List<Planet> (all)
```

## Cusps

House cusps as longitude points. Not signs, not houses — just the cusp degree.

```dart
class Cusp {
  final int house;        // 1-12
  final double longitude;
  final CalcConfig _config;

  int get sign => (longitude ~/ 30).toInt() + 1;
  Nakshatra get nakshatra => Nakshatra.of(longitude);
  int vargaSign(int division) => calcVarga(longitude, division, _config);
}
```

## Chart

The top-level rich object. Constructed from EphSnapshot + CalcConfig. Does not call SWE.

```dart
class Chart {
  final EphSnapshot snapshot;
  final CalcConfig config;

  // typed accessors
  Karaka get sun => ...;
  Karaka get moon => ...;
  Karaka get mars => ...;
  Karaka get mercury => ...;
  Karaka get jupiter => ...;
  Karaka get venus => ...;
  Karaka get saturn => ...;

  Graha get rahu => ...;
  Graha get ketu => ...;

  Planet get uranus => ...;
  Planet get neptune => ...;
  Planet get pluto => ...;

  List<Karaka> get karakas => ...;   // 7
  List<Graha> get grahas => ...;     // 9
  List<Planet> get planets => ...;   // all

  List<Cusp> get cusps => ...;       // 12
  AscMcPoints get ascmc => ...;
}
```

## What goes ON objects vs. what takes objects

**On the object** — things about this body/cusp in isolation:
- sign, nakshatra, pada
- varga placement
- dignity (karakas only)
- retrograde, speed
- combustion (karakas only)

**Functions taking the object** — relationships and multi-body analysis:
- aspects between planets
- yogas
- dashas
- shadbala
- ashtakavarga
- chara karakas (ranking across all karakas)

This keeps rich objects from becoming god objects.
