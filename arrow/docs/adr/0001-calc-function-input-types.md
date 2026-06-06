# Calc functions accept domain objects for multi-body calculations

Complex multi-body calculations in `arrow_calc` (lajjitaadi, shadbala, nabhasa yogas, vimshottari, jaimini argala, etc.) should accept `Chart` or `Varga` as input rather than decomposed primitives. Simple pure-math functions (tithi from two longitudes, baladi from sign + degree, single aspect checks) remain primitive-input.

The original design used primitives-only signatures everywhere for maximum testability. In practice this created a marshalling tax — callers assembling `Map<Body, double>`, `Map<Body, DignityType>`, `Map<int, List<Body>>` etc. from domain objects they already had. The testability benefit was marginal because `stubSnapshot()` already makes constructing a `Chart` trivial.

## Considered options

- **Primitives only (status quo)** — every calc function takes doubles, ints, enums, and maps. Maximum decoupling from the domain model. Rejected because: calc already depends on core (for `SignData`, `Dignity`, `Nature` static utilities), so no coupling is saved; the marshalling boilerplate obscures intent; and `stubSnapshot()` makes Chart-based tests just as easy.
- **Chart for everything** — even simple formulas take Chart. Rejected because pure-math functions like `calcTithi(sunLon, moonLon)` gain nothing from Chart and lose composability.
- **Chart for multi-body, primitives for pure-math (chosen)** — the heuristic: if a function iterates over multiple bodies or looks up inter-body relationships, it takes `Chart` or `Varga`. If it's a formula on 1-3 numbers, it stays primitive.
