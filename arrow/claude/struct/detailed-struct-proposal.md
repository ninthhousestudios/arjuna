Let me scaffold out the full Arrow monorepo structure for you. Here's everything:

---

## 📁 Complete Arrow Monorepo

```
arrow/
├── README.md
├── melos.yaml                          # Monorepo management
│
├── packages/
│   │
│   ├── arrow_options/                  # Shared config (no SWE dependency)
│   │   ├── lib/
│   │   │   ├── arrow_options.dart      # Barrel export
│   │   │   └── src/
│   │   │       ├── config/
│   │   │       │   ├── swe_config.dart         # SWE-affecting options interface
│   │   │       │   ├── calc_config.dart        # Derived calc options interface
│   │   │       │   └── arrow_options.dart      # Concrete class implementing both
│   │   │       └── enums/
│   │   │           ├── ayanamsa.dart
│   │   │           ├── house_system.dart
│   │   │           ├── node_type.dart          # True/Mean
│   │   │           ├── cusp_mode.dart
│   │   │           ├── nakshatra_calc_mode.dart
│   │   │           ├── rise_mode.dart
│   │   │           ├── temp_friendship.dart
│   │   │           ├── ashtakavarga_method.dart
│   │   │           ├── combustion_method.dart
│   │   │           ├── varga_variant.dart      # D10, D24, D30 variants
│   │   │           ├── rashi_aspect_mode.dart
│   │   │           ├── karaka_count.dart       # 7 or 8
│   │   │           └── vara_mode.dart
│   │   ├── test/
│   │   │   └── arrow_options_test.dart
│   │   ├── pubspec.yaml
│   │   └── analysis_options.yaml
│   │
│   ├── arrow_swe/                      # Layer 1: Swiss Ephemeris
│   │   ├── lib/
│   │   │   ├── arrow_swe.dart          # Barrel export
│   │   │   └── src/
│   │   │       ├── facade/
│   │   │       │   ├── swe_facade.dart         # Main SWE interface
│   │   │       │   ├── swe_local.dart          # dart:ffi via sweph.dart
│   │   │       │   └── swe_remote.dart         # HTTP fallback to KalaBrain
│   │   │       ├── snapshot/
│   │   │       │   ├── eph_snapshot.dart        # Immutable bridge object
│   │   │       │   ├── graha_record.dart        # Per-body SWE output
│   │   │       │   └── cusp_record.dart         # Per-cusp SWE output
│   │   │       └── functions/
│   │   │           ├── calc_all.dart            # Batch: positions + cusps + ayanamsa
│   │   │           ├── calc_positions.dart      # Graha longitudes, speeds, retro
│   │   │           ├── calc_cusps.dart          # House cusps + ascmc
│   │   │           ├── calc_ayanamsa.dart       # Ayanamsa value
│   │   │           ├── calc_sunrise.dart        # Sunrise/sunset
│   │   │           ├── calc_eclipse.dart        # Eclipse functions
│   │   │           └── calc_heliacal.dart       # Heliacal phenomena
│   │   ├── test/
│   │   │   ├── swe_facade_test.dart
│   │   │   ├── eph_snapshot_test.dart
│   │   │   └── functions/
│   │   │       ├── calc_all_test.dart
│   │   │       ├── calc_positions_test.dart
│   │   │       └── calc_cusps_test.dart
│   │   ├── pubspec.yaml
│   │   └── analysis_options.yaml
│   │
│   ├── arrow_core/                     # Layer 2: Pure Dart derivation
│   │   ├── lib/
│   │   │   ├── arrow_core.dart         # Barrel export
│   │   │   └── src/
│   │   │       ├── model/
│   │   │       │   ├── chart.dart              # Rich Chart object (wraps EphSnapshot)
│   │   │       │   ├── planet.dart             # Base: all bodies
│   │   │       │   ├── graha.dart              # Extends Planet: + nodes (9)
│   │   │       │   ├── karaka.dart             # Extends Graha: embodied (7)
│   │   │       │   └── cusp.dart               # House cusp as longitude point
│   │   │       ├── placement/
│   │   │       │   ├── sign.dart               # Rashi placement
│   │   │       │   ├── nakshatra.dart          # Nakshatra + pada
│   │   │       │   └── varga.dart              # Varga chart placements
│   │   │       ├── dignity/
│   │   │       │   ├── dignity.dart            # Own/exalt/debil/mool
│   │   │       │   ├── friendship.dart         # Natural + temporal
│   │   │       │   └── combustion.dart         # Combustion status
│   │   │       ├── varga/
│   │   │       │   ├── varga_chart.dart        # Varga chart builder
│   │   │       │   ├── d1.dart                 # Rashi
│   │   │       │   ├── d2.dart                 # Hora
│   │   │       │   ├── d3.dart                 # Drekkana
│   │   │       │   ├── d4.dart                 # Chaturthamsa
│   │   │       │   ├── d7.dart                 # Saptamsa
│   │   │       │   ├── d9.dart                 # Navamsa
│   │   │       │   ├── d10.dart                # Dasamsa (3 variants)
│   │   │       │   ├── d12.dart                # Dwadasamsa
│   │   │       │   ├── d16.dart                # Shodasamsa
│   │   │       │   ├── d20.dart                # Vimsamsa
│   │   │       │   ├── d24.dart                # Chaturvimsamsa (3 variants)
│   │   │       │   ├── d27.dart                # Bhamsa
│   │   │       │   ├── d30.dart                # Trimsamsa (2 variants)
│   │   │       │   ├── d40.dart                # Khavedamsa
│   │   │       │   ├── d45.dart                # Akshavedamsa
│   │   │       │   └── d60.dart                # Shashtiamsa
│   │   │       └── karakas/
│   │   │           └── chara_karaka.dart       # Chara karaka assignment
│   │   ├── test/
│   │   │   ├── model/
│   │   │   │   ├── chart_test.dart
│   │   │   │   ├── planet_test.dart
│   │   │   │   └── cusp_test.dart
│   │   │   ├── placement/
│   │   │   │   ├── sign_test.dart
│   │   │   │   └── nakshatra_test.dart
│   │   │   ├── dignity/
│   │   │   │   └── dignity_test.dart
│   │   │   └── varga/
│   │   │       └── varga_chart_test.dart
│   │   ├── pubspec.yaml
│   │   └── analysis_options.yaml
│   │
│   └── arrow_calc/                     # Layer 3: Pure Dart analysis
│       ├── lib/
│       │   ├── arrow_calc.dart         # Barrel export
│       │   └── src/
│       │       ├── dasha/
│       │       │   ├── vimshottari.dart         # Vimshottari dasha
│       │       │   ├── yogini.dart              # Yogini dasha
│       │       │   ├── ashtottari.dart          # Ashtottari dasha
│       │       │   ├── chara.dart               # Chara (Jaimini) dasha
│       │       │   └── narayana.dart            # Narayana dasha
│       │       ├── yoga/
│       │       │   ├── yoga.dart                # Yoga base / registry
│       │       │   ├── raja_yoga.dart
│       │       │   ├── dhana_yoga.dart
│       │       │   ├── pancha_mahapurusha.dart
│       │       │   └── nabhasa_yoga.dart
│       │       ├── shadbala/
│       │       │   ├── shadbala.dart            # Main shadbala calculator
│       │       │   ├── sthana_bala.dart         # Positional strength
│       │       │   ├── dig_bala.dart            # Directional strength
│       │       │   ├── kala_bala.dart           # Temporal strength
│       │       │   ├── chesta_bala.dart         # Motional strength
│       │       │   ├── naisargika_bala.dart     # Natural strength
│       │       │   └── drik_bala.dart           # Aspectual strength
│       │       ├── ashtakavarga/
│       │       │   ├── ashtakavarga.dart        # Main calculator
│       │       │   ├── bhinnashtaka.dart        # Individual contributions
│       │       │   └── sarvashtaka.dart         # Aggregate
│       │       ├── jaimini/
│       │       │   ├── jaimini.dart             # Jaimini analysis entry
│       │       │   ├── karakamsa.dart
│       │       │   ├── arudha.dart              # Arudha padas
│       │       │   └── yogada.dart
│       │       ├── aspect/
│       │       │   ├── rashi_aspect.dart        # Sign-based aspects
│       │       │   └── graha_aspect.dart        # Planetary aspects
│       │       ├── avastha/
│       │       │   ├── baladi.dart              # Baladi avasthas
│       │       │   ├── jagradadi.dart           # Jagradadi avasthas
│       │       │   └── deeptadi.dart            # Deeptadi avasthas
│       │       └── tajika/
│       │           ├── tajika.dart              # Tajika (annual) analysis
│       │           └── sahams.dart              # Sahams / lots
│       ├── test/
│       │   ├── dasha/
│       │   │   ├── vimshottari_test.dart
│       │   │   └── chara_test.dart
│       │   ├── yoga/
│       │   │   └── raja_yoga_test.dart
│       │   ├── shadbala/
│       │   │   └── shadbala_test.dart
│       │   ├── ashtakavarga/
│       │   │   └── ashtakavarga_test.dart
│       │   └── jaimini/
│       │       └── arudha_test.dart
│       ├── pubspec.yaml
│       └── analysis_options.yaml
│
└── claude/
    └── arch/
        ├── architecture.md
        ├── base-arch.md
        └── domain-model.md
```

---

## 📦 Dependency Graph

```
arrow_options  (no dependencies — just enums + freezed config)
     ↑
arrow_swe      (depends on: arrow_options, sweph)
     ↑
arrow_core     (depends on: arrow_options, arrow_swe [for EphSnapshot type only])
     ↑
arrow_calc     (depends on: arrow_options, arrow_core)
```

---

## 🔧 melos.yaml (root)

```yaml
name: arrow
packages:
  - packages/**

scripts:
  analyze:
    run: melos exec -- dart analyze .
  test:
    run: melos exec -- dart test
  generate:
    run: melos exec -- dart run build_runner build --delete-conflicting-outputs
    select-package:
      depends-on: build_runner
```

---

## Key Design Decisions

| Decision | Rationale |
|---|---|
| **`arrow_options` as separate package** | Both SWE and non-SWE layers need config, avoids circular deps |
| **`EphSnapshot` lives in `arrow_swe`** | It's the output of the SWE layer, the bridge to everything downstream |
| **Melos for monorepo** | Standard Dart monorepo tooling, handles inter-package deps cleanly |
| **Each varga gets its own file** | Variants (D10×3, D24×3, D30×2) need space, keeps things scannable |
| **Shadbala split into 6 component files** | Each bala is its own algorithm, cleaner than one mega file |

---

Want me to generate the actual `pubspec.yaml` files for each package and start writing any of the core types?
