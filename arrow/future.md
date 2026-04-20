# Arrow — Future Blueprints

Designs saved here for later extraction when the need arises. Not implemented now.

## Multi-Tradition Architecture

Multi-tradition is active from the start. Cards of Truth and Human Design both need SWE, giving us real traditions to validate the modular design alongside Vedic. Full design in `claude/arch/universal-options.md`.

Key points:
- CalcConfig is modular: core `Set<Tradition>` + optional typed tradition configs (VedicConfig, CardsOfTruthConfig, HumanDesignConfig)
- ArrowPresets for named defaults (ernst, lahiriVedic, hellenistic, modernWestern, etc.)
- arrow_calc gets per-tradition subdirectories (vedic/, hellenistic/, western/, etc.)
- Each tradition module is tree-shakeable

Future traditions (Hellenistic, Western, Uranian, Persian) follow the same pattern when needed.

## EphSnapshot Variants

Multiple prototypes exist for EphSnapshot key types:
- `universal-options.md`: `Map<Body, PlanetPosition>` keyed by Body enum
- `core-types.dart`: `Map<Body, BodyPosition>` with different type names

These are design sketches, not code. The real EphSnapshot will be determined by exploring the sweph.dart API — designed to capture everything SWE can produce so arrow_swe is complete from the start.
