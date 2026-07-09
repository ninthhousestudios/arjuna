
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
