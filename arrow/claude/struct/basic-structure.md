Ah right — **Arrow**, the 3-layer calculation engine! Based on the architecture in the CLAUDE.md, this maps perfectly to a clean package structure.

---

## 📁 Suggested Arrow Project Structure

Given the **3-layer pipeline** (`arrow_swe` → `arrow_core` → `arrow_calc`), I'd recommend a **Dart monorepo** with separate packages:

```
arrow/
├── packages/
│   ├── arrow_swe/            # Layer 1: Swiss Ephemeris bindings
│   │   ├── lib/
│   │   │   ├── arrow_swe.dart        # Barrel export
│   │   │   └── src/
│   │   │       ├── swe_facade.dart    # ~15 SWE functions via sweph.dart
│   │   │       ├── swe_fallback.dart  # HTTP fallback to KalaBrain
│   │   │       └── eph_snapshot.dart  # The immutable bridge object
│   │   ├── test/
│   │   └── pubspec.yaml
│   │
│   ├── arrow_core/           # Layer 2: Pure Dart derivation
│   │   ├── lib/
│   │   │   ├── arrow_core.dart       # Barrel export
│   │   │   └── src/
│   │   │       ├── model/            # Rich domain objects
│   │   │       │   ├── chart.dart
│   │   │       │   ├── planet.dart   # Planet → Graha → Karaka
│   │   │       │   └── cusp.dart
│   │   │       ├── signs/            # Sign placements
│   │   │       ├── nakshatras/       # Nakshatra/pada
│   │   │       ├── vargas/           # Divisional charts
│   │   │       ├── dignities/        # Dignity, friendship
│   │   │       └── karakas/          # Chara karakas, combustion
│   │   ├── test/
│   │   └── pubspec.yaml              # Depends on arrow_swe (for EphSnapshot)
│   │
│   ├── arrow_calc/           # Layer 3: Pure Dart analysis
│   │   ├── lib/
│   │   │   ├── arrow_calc.dart       # Barrel export
│   │   │   └── src/
│   │   │       ├── dashas/           # Dasha systems
│   │   │       ├── yogas/            # Yoga detection
│   │   │       ├── shadbala/         # Strength calculations
│   │   │       ├── ashtakavarga/     # Ashtakavarga
│   │   │       └── jaimini/          # Jaimini techniques
│   │   ├── test/
│   │   └── pubspec.yaml              # Depends on arrow_core
│   │
│   └── arrow_options/        # Shared config (optional separate pkg)
│       ├── lib/
│       │   └── src/
│       │       ├── arrow_options.dart # Concrete freezed class
│       │       ├── swe_config.dart    # SweConfig interface
│       │       └── calc_config.dart   # CalcConfig interface
│       └── pubspec.yaml
│
├── claude/
│   └── arch/                 # Design docs (already exist)
│       ├── base-arch.md
│       └── domain-model.md
│
├── CLAUDE.md                 # Project memory
├── melos.yaml                # Monorepo management (or pubspec with path deps)
└── README.md
```

---

## 🔑 Key Decisions

| Decision | Recommendation |
|---|---|
| **Monorepo tool** | [Melos](https://melos.invertase.dev/) — handles multi-package Dart repos well |
| **Dependency flow** | `arrow_swe` ← `arrow_core` ← `arrow_calc` (strict one-way) |
| **EphSnapshot lives in** | `arrow_swe` — it's the output/contract of that layer |
| **Options package** | Could be separate or bundled in `arrow_swe` — separate keeps it clean since both `arrow_swe` and `arrow_core` need it |
| **Enums** | Shared enums (Graha IDs, signs, nakshatras) go in `arrow_options` or a small `arrow_types` package |
| **Code generation** | `freezed` + `json_serializable` for `ArrowOptions` and `EphSnapshot` |

---

## 🔄 Dependency Graph

```
arrow_options (enums, configs)
     ↑
arrow_swe (SWE bindings → produces EphSnapshot)
     ↑
arrow_core (rich domain model, derivations)
     ↑
arrow_calc (analysis: dashas, yogas, shadbala)
```

---

## 💡 Why This Structure?

1. **Enforces the architecture** — the 3-layer boundary isn't just a convention, it's a **package boundary**. `arrow_core` literally cannot import SWE.
2. **Testable in isolation** — `arrow_core` and `arrow_calc` are pure Dart, no FFI needed to test
3. **Shareable** — Celestial, the Astrologer App, the Dating App all just depend on what they need
4. **Serialization boundary is clear** — `EphSnapshot` is the contract between SWE and everything else

Want me to scaffold out any of these packages, or dive deeper into any specific layer?
