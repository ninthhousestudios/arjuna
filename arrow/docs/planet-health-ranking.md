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
**Status: proposal.** The code and `planet-health-results.md` still produce
the v2 ranking; the v3 figures below are simulated from the v2 results'
per-planet subtotals and factor breakdowns. The results file is regenerated
once v3 is implemented.

What changed from v2, and why:

| # | v2 | v3 | Why |
|---|----|----|-----|
| 1 | Rank by Strong subtotal; Aspect subtotal only breaks ties | Rank by **Strong + ½ × Aspect** | Strict precedence ignored aspects in >90% of rankings; Laura's rule is per-factor, which any weight below 1 satisfies |
| 2 | Aspect agitation fires alongside aspect starvation | Unchanged — flagged for Laura | Every agitating aspect also starves; whether that should cost twice is her call |

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
- **Aspect** → the Parashara aspect strength, then halved (next section).

### The sign is stronger than the aspect — per cause

Laura (round 1, Q4):

> *"The LA of the planet in a Sign is always stronger than the aspect. So if
> Saturn is exalted but also aspected by Mars, the exaltation of Saturn is
> stronger. Same goes for delighted within a Sign, starved within a Sign,
> etc. The only time this does not apply is with conjunctions."*

Her examples compare **one sign cause with one aspect cause**, state for
state: an exaltation against a Mars aspect; starved-in-sign against
starved-by-aspect. v3 encodes exactly that and no more.

Each planet's score still has two subtotals:

- **Strong** — every non-aspect cause: dignity, sign placement, sign lord,
  conjunction, and the shame conditions (shame is conjunction-triggered, so
  it lives here — Laura's "except conjunctions").
- **Aspect** — every aspect cause, each prorated by aspect strength.

**Score = Strong + ½ × Aspect.** Planets rank by score.

Why one half: a full-strength (60/60) aspect then carries exactly half the
weight of the same avastha arising from the sign. An enemy aspect starves at
most −22.5 against −45 for starvation in the sign; a friendly aspect
delights at most +7.5 against +15. No single aspect can match its sign
counterpart — it takes two full-strength aspects to equal one sign cause —
yet aspects that pile up now count, which Laura also asked for (round 1, Q6:
*"aspects cause a lot of problems"*). Laura's own example holds with room to
spare: a full Mars aspect on Saturn costs at most 37.5 (starved + agitated,
halved), below exaltation's +45.

#### What v2 did instead, and why it was dropped

v2 ranked **lexicographically**: Strong first, Aspect only among planets with
identical Strong subtotals. That is the limiting case of an aspect weight of
zero, and it reads Laura's rule as "the sign beats *all aspects combined*" —
which she didn't say. In practice it meant aspects barely counted: across the
16 test charts, the Aspect subtotal decided only **30 of 336** planet-pair
orderings (9%), even though the median planet carries 14v of aspect score
against 30v of Strong. The visible symptom was Josh's Saturn — the most
aspect-afflicted planet in his chart, ranked healthiest.

### Grading shame

Unchanged from v2. Shame requires *both* a conjunction with Sun, Mars, or
Saturn *and* one of — conjunct Rahu/Ketu, or in the 5th whole sign from the
lagna. These two weigh **equally** (both full strength); the 5th house is
taken by whole sign, not by cusp. The degree-exact 5th-cusp condition is
still detected and kept in the code but contributes zero to this ranking.

Each malefic that triggers the shame scores −60 in its own right (a planet
shamed by two malefics is twice as shamed), plus the condition factor. A
planet shamed by both Mars and Saturn while conjunct Rahu carries
−60 − 60 − 60 = −180 of shame, all in the Strong tier.

### One cause, one score

Unchanged from v2. Where two rules detect the *same* state from the same
fact — Saturn conjunct a planet it is also the natural enemy of fires two
starvation rules; a friendly Jupiter conjunction delights twice — the state
is counted once.

### Open: a malefic enemy's aspect starves *and* agitates

The rules follow Ernst's teaching:

- **Starved** — aspected by an enemy (among other triggers).
- **Agitated** — conjunct the Sun, **or** aspected by an enemy that is a
  malefic.

The second agitation trigger is a strict subset of the starvation trigger:
every aspect that agitates also starves. So a malefic enemy's aspect costs
starved + agitated = −75 (before halving), while a benefic enemy's costs −45
— a 67% surcharge for being malefic. These are two *different* states from
one fact, so "one cause, one score" doesn't currently collapse them.

That may be exactly right — a malefic enemy should hurt more than a benefic
one. But it has two side effects worth Laura's eye:

- **It concentrates on Saturn.** Saturn's natural enemies are the Sun, the
  Moon, and Mars — all malefic, the Moon when waning — so Saturn takes the
  surcharge from every enemy that aspects it. This feeds the open question
  below about the ranking restating planetary nature.
- **It lets one aspect beat a healthy sign.** Per state, the half weight
  keeps every aspect below its sign counterpart. But summed, one
  full-strength malefic-enemy aspect (−37.5) outweighs a planet's own-sign
  "healthy" (+30), though not its exaltation (+45).

The options:

| | Malefic-enemy aspect costs | Effect |
|---|---|---|
| (a) Both states count (current) | −75 × ½ = −37.5 | Malefic enemies clearly worse than benefic ones |
| (b) Only the worse state (starved) counts | −45 × ½ = −22.5 | Same cost as a benefic enemy |
| (c) Both count, agitation reduced when paired with starvation | between | Keeps the distinction, softer |

v3 keeps (a) until Laura answers.

------------------------------------------------------------------------

## What v3 does to the 16 test charts

(Simulated from the v2 results; see Status above.)

**The healthiest planet is always genuinely healthy.** Under v2, 3 of 16
charts had a healthiest planet with a negative total. Under v3 every chart's
top planet scores positive (+6.4 to +60.8).

**Most charts barely move.** Four charts are unchanged (Charlie Sheen, Elon
Musk, JK Rowling, RFK Jr.); most others shift two to four planets by a place
or two. Only Josh, R.D. Laing, and Vladimir Lenin reorder heavily. The
healthiest planet changes in only two charts (Josh, R.D. Laing); the
least healthy in two (Thomas Merton, Tori Amos).

**Josh's Saturn**, the case that prompted v3:

| Planet | Strong | Aspect | v2 rank | v3 score (a) | v3 rank (a) | v3 score (b) | v3 rank (b) |
|--------|-------:|-------:|--------:|------:|-----:|------:|-----:|
| Saturn  |   45.0 | −126.0 | 1 |  −18.0 | 6 |   11.7 | 3 |
| Moon    |   30.0 |    0.0 | 2 |   30.0 | 1 |   30.0 | 1 |
| Mars    |   15.0 |   −1.2 | 3 |   14.4 | 2 |   14.4 | 2 |
| Jupiter |    0.0 |    0.3 | 4 |    0.1 | 3 |    0.1 | 4 |
| Mercury |  −15.0 |    0.0 | 5 |  −15.0 | 4 |  −15.0 | 5 |
| Sun     |  −15.0 |   −2.1 | 6 |  −16.1 | 5 |  −15.7 | 6 |
| Venus   | −105.0 |   −2.3 | 7 | −106.2 | 7 | −104.6 | 7 |

Saturn is moolatrikona (proud, +45) and aspected by the Sun, the (waning)
Moon, and Mars — all enemies, all malefic — so under (a) it carries six
aspect afflictions. The double-count question alone moves it from 6th to 3rd.
Where Saturn *should* land is the clearest single test of Laura's answer.

**The benefic/malefic pattern persists.** Jupiter and the Moon still top most
charts, Venus and Saturn still sink. v3 doesn't cause this and doesn't fix
it; option (b) would soften the Saturn side of it.

------------------------------------------------------------------------

## Deferred to round 2: Rahu and Ketu

Laura: *"Nodes give the results (LA) of their ruler & any conjunct planets,
so they can be doing a lot. That would be a good idea for a separate
report."*

So the nodes don't get their own Lajjitaadi — they **inherit** the health of
their sign lord and of any planet they conjoin. That is a distinct
calculation and a distinct report, tracked separately and built after this
round is confirmed.

------------------------------------------------------------------------

## Open questions for Laura

1. **Malefic-enemy aspects.** Should one aspect from a malefic enemy count as
   both starved and agitated (a), only the worse of the two (b), or
   something in between (c)?

2. **Benefic/malefic restatement.** Is it right that Jupiter and the Moon
   dominate the healthy end and Venus and Saturn the sick end across charts,
   or is that the model measuring planetary nature rather than condition?

3. **The healthy-state weights.** The down-shift (+45/+30/+15) is our reading
   of "afflictions should have more value." Is one rung enough, too much, or
   should the gap be larger?
