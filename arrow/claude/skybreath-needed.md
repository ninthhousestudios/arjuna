# Arrow_calc Requirements for SkyBreath

Finalized 2026-04-09. SkyBreath is Arrow's first consumer app — all domain
computation belongs in Arrow for reusability.

## Computation Units (8)

| # | Unit | Description |
|---|------|-------------|
| 1 | **Lajjitaadi avasthas** | Relational, 7 states per Ernst Wilhelm (includes svastha/healthy for own-sign) |
| 2 | **Baladi avasthas** | Age by degree |
| 3 | **Jagradadi avasthas** | Alertness by sign type |
| 4 | **Deeptadi avasthas** | Mood from dignity |
| 5 | **Retrograde cycle phases** | Station-aware, full cycle tracking |
| 6 | **Combustion** | Angular distance from Sun + phase |
| 7 | **Speed classification** | Relative to mean daily motion |
| 8 | **Synodic state** | Phase angle, illumination, elongation, apparent diameter, magnitude via `swe_pheno_ut()` |

## Layered Computation Model

```
arrow_swe (raw positions)
  → arrow_core (sign/nak/dignity)
    → arrow_calc (avasthas + breath + synodic)
```

Zodiac switching re-runs steps 2-3 only. Layered calls chosen over monolithic
to match Arrow's existing architecture and keep each computation testable in
isolation.

## Scope Decisions

- **Gandanta** — removed. Not used in SkyBreath's feature set.
- **Synodic state** — all 13 bodies. Cheap to compute, dramatic for inferior
  planets, useful data even for outers. Also serves Tier 2 paywall
  (Astrologer's Almanac).

## Prerequisites (arrow_core / arrow_swe additions)

- **Benefic/malefic nature** — `Nature.of(Body)` in arrow_core. Needed by
  units 1 (Lajjitaadi) and 4 (Deeptadi).
- **Parashara aspects (drishti)** — `Aspect.doesAspect()` in arrow_core.
  Needed by unit 1 (Lajjitaadi).
- **PhenoData on EphSnapshot** — `swe_pheno_ut()` results added to
  EphSnapshot in arrow_swe. Needed by unit 8 (Synodic state).

## Port Status

| Unit | Source | Notes |
|------|--------|-------|
| 1–4 | `libaditya/calc/avasthas.py` | Direct port |
| 5 | New work | libaditya only has `speed < 0` bool — no station detection |
| 6 | `libaditya/calc/avasthas.py` (Deeptadi Vikala) | Combustion orbs exist in Arrow already (`Dignity.isCombust`) |
| 7 | New work | libaditya has no mean speed constants or classification |
| 8 | New work | `swe_pheno_ut()` not used in libaditya |

## Exclusions

- **Shayanadi avasthas** — requires sunrise computation (SWE rise_trans +
  location), out of SkyBreath scope.
- **Gandanta/sandhi** — not used in SkyBreath's feature set.
- **Parashara aspect strength** (partial aspects) — only full aspects for now.
- **Graha yuddha** (planetary war) — not in libaditya, not needed for SkyBreath.

## Rejected Alternatives

- Avastha logic in the app — not reusable, mixes domain with UI
- Avastha logic in separate thin package — adds indirection, Arrow is the right home
- Monolithic single-call API — makes Arrow rigid, harder to test
- Reactive computation graph — over-complex for the actual dependency chain
- Synodic state for inferior planets only — data is cheap for all, useful at Tier 2
