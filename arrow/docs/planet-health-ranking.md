# Ranking planets by Lajjitaadi health — v3

A point system for ordering the seven embodied planets from healthiest to
least healthy, so the beings they activate can be ranked the same way. This
is the **third draft**. It keeps everything Laura confirmed in round 2 and
replaces one piece of v2 — how aspects combine with sign/conjunction causes —
which turned out to read her precedence rule far more literally than she
stated it.

Earlier drafts are preserved in `archived/`:
`planet-health-ranking-v1.md` / `planet-health-results-v1.md` and
`planet-health-ranking-v2.md`.

Implementation: `arrow/calc/lib/src/vedic/planet_health.dart`.
Results over the test corpus: `planet-health-results.md`.
**Status: implemented.** Both v3 open questions are resolved (below).

What changed from v2, and why:

| # | v2 | v3 | Why |
|---|----|----|-----|
| 1 | Rank by Strong subtotal; Aspect subtotal only breaks ties | Rank by **Strong + Aspect** — aspects prorated by strength, no further discount | Strict precedence ignored aspects in >90% of rankings; aspect strength already grades an aspect against a sign cause |
| 2 | Aspect agitation fires alongside aspect starvation | Unchanged — **confirmed** | A malefic enemy's aspect should cost more than a benefic enemy's |
| 3 | Tied totals share a rank | Ties break by **dignity**, then a fixed planet order | Laura's rule; every planet gets a distinct rank |

------------------------------------------------------------------------

## The problem

Laura's affliction/health ordering, worst to best:

| Affliction | Health |
|------------|--------|
| Shamed     | Proud  |
| Starved    | Secure (arrow calls this "healthy") |
| Agitated   | Delighted |
| Thirsty    | |

A pure ordering can't rank a chart. Two planets can both be shamed; 79% of
all planets in the corpus are starved and 93% delighted, so those states
separate almost nothing; and a planet is rarely in one state — it
accumulates several at once, from several causes. So we need a score.

## The point system

Every avastha is worth a signed number of **virupas** (1/60 of a rupa — the
unit Parashara's aspect strengths already use, where 60 is a full aspect).
The four afflictions keep the full −60/−45/−30/−15 ladder; the three healthy
states are shifted one rung *down* it, so that — per Laura (round 1, Q5) — an
affliction always outweighs the matching health:

| Avastha   | Virupas |
|-----------|--------:|
| Shamed    | −60 |
| Starved   | −45 |
| Agitated  | −30 |
| Thirsty   | −15 |
| Proud     | +45 |
| Healthy   | +30 |
| Delighted | +15 |

### Scaling by how the avastha was caused

A planet can be starved by a conjunction or by a distant aspect, and those
shouldn't count the same. Each cause is scaled by its strength on the 0–60
scale:

- **Conjunction, sign placement, sign lord, dignity** → full strength (60).
- **Aspect** → the Parashara aspect strength, and nothing else.

**Score = Σ (avastha virupas × strength / 60)**, summed over every cause.
Planets rank by score; ties break as in [Breaking ties](#breaking-ties).

So a full-strength (60/60) aspect that starves costs −45 — exactly the same
as starvation by sign or by conjunction. A half-strength (30/60) aspect that
starves costs −22.5; a quarter-strength one −11.25. The aspect's own
strength is the only thing that separates it from a sign cause.

Each planet's score is still reported as two subtotals, for reading a total
back to its causes — neither is a ranking key:

- **Strong** — every non-aspect cause: dignity, sign placement, sign lord,
  conjunction, and the shame conditions.
- **Aspect** — every aspect cause, each prorated by aspect strength.

#### What was dropped, and why

**v2 — strict precedence.** v2 ranked **lexicographically**: Strong first,
Aspect only among planets with identical Strong subtotals. That read Laura's
rule (round 1, Q4: *"The LA of the planet in a Sign is always stronger than
the aspect"*) as "the sign beats *all aspects combined*". In practice aspects
barely counted: across the 16 test charts, the Aspect subtotal decided only
**30 of 336** planet-pair orderings (9%), even though the median planet
carries 14v of aspect score against 30v of Strong. The visible symptom was
Josh's Saturn — the most aspect-afflicted planet in his chart, ranked
healthiest.

**v3 draft — half weight.** The v3 proposal kept a per-cause precedence by
halving every aspect, so no single aspect could match its sign counterpart.
Decided against: the Parashara strength already grades an aspect, and a full
aspect is as strong as the sign. Aspects now count at full prorated weight.

Consequence worth knowing: a single full-strength aspect can now outweigh a
sign dignity. A full Mars aspect on an exalted Saturn costs −75 (starved
+ agitated) against exaltation's +45.

### Breaking ties

When two planets have the same total, the planet in **better dignity**
ranks higher — exalted, moolatrikona, own sign, great friend, friend,
neutral, enemy, great enemy, debilitated, best to worst.

If they are also in the same dignity, this planet order decides:

1. Jupiter
2. Venus
3. Mercury
4. Moon
5. Sun
6. Mars
7. Saturn

So every planet gets its own rank, 1 through 7; ranks are never shared.
Example: in Stephen Colbert's chart Mars and Jupiter both score −90.0 in
the same dignity, and rank 6. Jupiter, 7. Mars.

### Grading shame

Unchanged from v2. Shame requires *both* a conjunction with Sun, Mars, or
Saturn *and* one of — conjunct Rahu/Ketu, or in the 5th whole sign from the
lagna. These two weigh **equally** (both full strength); the 5th house is
taken by whole sign, not by cusp. The degree-exact 5th-cusp condition is
still detected and kept in the code but contributes zero to this ranking.

Each malefic that triggers the shame scores −60 in its own right (a planet
shamed by two malefics is twice as shamed), plus the condition factor. A
planet shamed by both Mars and Saturn while conjunct Rahu carries
−60 − 60 − 60 = −180 of shame.

### One cause, one score

Unchanged from v2. Where two rules detect the *same* state from the same
fact — Saturn conjunct a planet it is also the natural enemy of fires two
starvation rules; a friendly Jupiter conjunction delights twice — the state
is counted once.

### A malefic enemy's aspect starves *and* agitates

The rules follow Ernst's teaching:

- **Starved** — aspected by an enemy (among other triggers).
- **Agitated** — conjunct the Sun, **or** aspected by an enemy that is a
  malefic.

Every aspect that agitates also starves. These are two *different* states
from one fact, and **both count**: a full-strength malefic enemy's aspect
costs starved + agitated = −75, a benefic enemy's −45. A malefic enemy hurts
more than a benefic one.

This concentrates on Saturn: its natural enemies are the Sun, the Moon, and
Mars — all malefic, the Moon when waning — so Saturn takes both states from
every enemy that aspects it.

------------------------------------------------------------------------

## What v3 does to the 16 test charts

Compared against the v2 results (full tables in `planet-health-results.md`).

**The healthiest planet is always genuinely healthy.** Under v2, 3 of 16
charts (Ernst Wilhelm, Josh, Vladimir Lenin) had a healthiest planet with a
negative total. Under v3 every chart's top planet scores positive (+8.8 to
+61.5).

**Aspects now reorder charts.** Only JK Rowling and RFK Jr. are unchanged.
The healthiest planet changes in five charts (Björk, Ernst Wilhelm, Josh,
R.D. Laing, Vladimir Lenin); the least healthy in five (Elon Musk, Jim
Carrey, R.D. Laing, Thomas Merton, Tori Amos). R.D. Laing reorders every
planet.

**Josh's Saturn**, the case that prompted v3:

| Planet | Strong | Aspect | v2 rank | v3 score | v3 rank |
|--------|-------:|-------:|--------:|---------:|--------:|
| Moon    |   30.0 |    0.0 | 2 |   30.0 | 1 |
| Mars    |   15.0 |   −1.2 | 3 |   13.8 | 2 |
| Jupiter |    0.0 |    0.3 | 4 |    0.3 | 3 |
| Mercury |  −15.0 |    0.0 | 5 |  −15.0 | 4 |
| Sun     |  −15.0 |   −2.1 | 6 |  −17.1 | 5 |
| Saturn  |   45.0 | −126.0 | 1 |  −81.0 | 6 |
| Venus   | −105.0 |   −2.3 | 7 | −107.3 | 7 |

Saturn is moolatrikona (proud, +45) and aspected by the Sun, the (waning)
Moon, and Mars — all enemies, all malefic — so it carries six aspect
afflictions and falls from 1st to 6th.

**The benefic/malefic pattern persists.** The Moon, Mars, and Jupiter top
13 of 16 charts; Saturn and Venus are least healthy in 10. v3 doesn't cause
this, and counting both aspect states sharpens the Saturn side of it.

------------------------------------------------------------------------

## Deferred to round 2: Rahu and Ketu

Laura: *"Nodes give the results (LA) of their ruler & any conjunct planets,
so they can be doing a lot. That would be a good idea for a separate
report."*

So the nodes don't get their own Lajjitaadi — they **inherit** the health of
their sign lord and of any planet they conjoin. That is a distinct
calculation and a distinct report, tracked separately and built after this
round is confirmed.
