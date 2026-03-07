# Arrow — Future Blueprints

Designs saved here for later extraction when the need arises. Not implemented now.

## Multi-Tradition Architecture

When a second tradition is needed beyond Vedic, extract VedicConfig from CalcConfig and introduce the modular tradition system. Full design in `claude/arch/universal-options.md`.

Key points:
- CalcConfig becomes: core `Set<Tradition>` + optional typed tradition configs
- ArrowPresets for named defaults (ernst, lahiriVedic, hellenistic, modernWestern, etc.)
- arrow_calc gets per-tradition subdirectories (vedic/, hellenistic/, western/, etc.)
- Each tradition module is tree-shakeable
- Migration: current CalcConfig fields map exactly to VedicConfig, zero disruption

## EphSnapshot Variants

Multiple prototypes exist for EphSnapshot key types:
- `types-sketch.dart`: `Map<int, PlanetPosition>` keyed by sweph integer IDs
- `universal-options.md`: `Map<Body, PlanetPosition>` keyed by Body enum
- `core-types.dart`: `Map<BodyId, BodyPosition>` with different enum/type names

These are design sketches, not code. The real EphSnapshot will be determined by exploring the sweph.dart API — designed to capture everything SWE can produce so arrow_swe is complete from the start.
