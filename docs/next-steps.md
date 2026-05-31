# Next Steps

Prioritized by leverage. Items higher on the list unlock or inform items below.

## 1. Nock REPL - done

Interactive CLI for Arrow. The fastest feedback loop for verifying calculations, testing presets, and exploring the domain model without writing test code.

- Skeleton exists (`nock/bin/nock.dart`, stub commands) but isn't a working REPL.
- Design doc exists: check `nock/claude/` for the REPL design.
- Uses Vayu (embedded Arrow) — no server required.

## 2. Drishti + Aion integration

Wire Drishti MCP server into Aion so the AI agent can do real astrology. This is the highest-leverage test of the MCP surface — real queries will immediately expose which tools and options are missing.

- Drishti currently has one tool (`calculate_chart`).
- Next tools driven by what Aion actually asks for. Likely candidates: `get_panchanga`, `get_dasha`, `get_varga`, `get_aspects`.
- Don't pre-build tools speculatively; let usage drive priority.

## 3. Fletch comparison engine

Wire up `fletch_core`, `fletch_astro`, and `fletch_ui` to run side-by-side comparisons of libaditya vs Arrow output. This validates Arrow's correctness against the reference implementation.

- `fletch_core`, `fletch_astro`, and `fletch_ui` exist as peer packages (in `../fletch/` relative to arjuna).
- Key value: surfaces discrepancies in planetary positions, dignities, dashas, and derived calculations between the two engines.
- Arrow's rule is "port from libaditya, don't invent" — Fletch is how we verify that.

## 4. Expand Drishti tool surface

Driven by item 2 (Aion integration). As Aion hits limits of `calculate_chart`, add tools that expose Arrow's deeper capabilities:

- `get_panchanga` — tithi, nakshatra, vara, karana, yoga for a date.
- `get_dasha` — Vimshottari dasha periods for a chart.
- `get_varga` — divisional chart positions (D-9, D-10, etc.).
- `get_aspects` — planetary and rashi aspects with orbs.
- `get_shadbala` — six-fold strength scores.

## 5. Arrow calc gaps

Lower priority unless Nock or Aion workflows expose the need:

- **Ashtakavarga** — no implementation yet. Important for transit analysis.
- **More yogas** — only Nabhasa yogas exist. Raja, Dhana, Pancha Mahapurusha are missing.
- **Tajika / Sahams** — annual chart techniques. Specialized, can wait.

## 6. Bowyer (admin)

Deferred until there's a running Quiver server worth monitoring. Pure scaffold today (`bowyer/core` is an empty barrel export). Becomes relevant when Quiver is deployed and needs observability.
