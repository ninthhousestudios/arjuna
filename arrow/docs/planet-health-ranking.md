# Ranking planets by Lajjitaadi health — v2

A point system for ordering the seven embodied planets from healthiest to
least healthy, so the beings they activate can be ranked the same way. This
is the **second draft**, revised after Laura's answers to the v1 questions
(`laura-update.md`). The first draft and its results are preserved in
`planet-health-ranking-v1.md` and `planet-health-results-v1.md`.

Implementation: `arrow/calc/lib/src/vedic/planet_health.dart`. Results for the
16 test charts: `planet-health-results.md`.

What changed from v1, and why:

| # | v1 question | Laura's answer | v2 change |
|---|-------------|----------------|-----------|
| 1 | Are the virupa values right? | Yes — but (Q5) afflictions should weigh more | Healthy states shifted down one rung |
| 2 | Grade shame by node vs 5th cusp vs 5th sign? | Cusps aren't used; nodes and 5th sign weigh equally | Nodes = 5th sign = full; cusp = 0 (retained) |
| 3 | Shame additive per malefic? | Yes — twice as shamed | Unchanged (still additive) |
| 4 | Should proud/shamed override the sum? | Sign LA is always stronger than aspect LA (except conjunctions) | **New precedence sort** |
| 5 | Healthy worth as much as afflicted? | No — afflictions have more value | Healthy states shifted down |
| 6 | Should aspects count at all? | Yes — aspects cause a lot of problems | Unchanged (aspects still count) |
| 7 | Do Rahu/Ketu need their own scores? | They give the LA of their ruler + conjunct planets — a separate report | Deferred to round 2 |

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
states are shifted one rung *down* it, so that — per Laura's Q5 — an
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

(The v1 draft had proud/healthy/delighted at +60/+45/+30. Laura's "healthy
planets just act like they're supposed to; afflictions are what screw up our
lives" is read here as the down-shift, not a literal halving.)

### Scaling by how the avastha was caused

A planet can be starved by a conjunction or by a distant aspect, and those
shouldn't count the same. Each cause is scaled by its strength on the 0–60
scale:

- **Conjunction, sign placement, sign lord, dignity** → full strength (60).
- **Aspect** → the Parashara aspect strength. An enemy aspecting with 30
  points of strength starves at 30/60 × −45 = **−22.5**.

### Precedence: the sign is always stronger than the aspect

This is the heart of v2, and it comes straight from Laura's Q4:

> *"The LA of the planet in a Sign is always stronger than the aspect. So if
> Saturn is exalted but also aspected by Mars, the exaltation of Saturn is
> stronger. Same goes for delighted within a Sign, starved within a Sign,
> etc. The only time this does not apply is with conjunctions."*

So each planet's score is split into two subtotals:

- **Strong** — the sum of every non-aspect cause: dignity, sign placement,
  sign lord, conjunction, and the shame conditions (shame is conjunction-
  triggered, so it lives here — Laura's "except conjunctions").
- **Aspect** — the sum of every aspect cause, each prorated by aspect
  strength.

**Planets rank by the Strong subtotal first. The Aspect subtotal only orders
planets whose Strong subtotals are equal.** However many aspects pile onto a
planet, they can never rank it below a planet with a worse sign/conjunction
picture — they only break ties. This is what v1 lacked: there, aspects were
summed straight into one total and could bury a dignified planet.

### Grading shame

Shame is the one avastha with a compound trigger: it requires *both* a
conjunction with Sun, Mars, or Saturn *and* one of — conjunct Rahu/Ketu, or
in the 5th whole sign from the lagna. Per Laura, these two weigh **equally**
(both full strength), and shame is a whole-sign phenomenon like a yoga, so
the 5th house is taken by whole sign, not by cusp. The degree-exact 5th-cusp
condition is still detected and kept in the code (arrow may use it elsewhere)
but contributes zero to this ranking.

Each malefic that triggers the shame scores −60 in its own right (Q3: a
planet shamed by two malefics is twice as shamed), plus the condition factor.
A planet shamed by both Mars and Saturn while conjunct Rahu carries
−60 − 60 − 60 = −180 of shame, all in the Strong tier.

### One cause, one score

The classical rules overlap. Saturn conjunct a planet it is also the natural
enemy of fires two starvation rules for a single physical fact; a friendly
Jupiter conjunction delights twice. Identical causes are counted once.

------------------------------------------------------------------------

## What the 16 test charts show

Full output in `planet-health-results.md`, now with Strong / Aspect / Total
columns per planet.

**Precedence does its job.** In all 16 charts the healthiest planet has a
positive Strong subtotal (+15 to +60) — the top of every chart is now set by
dignity, sign, or a benefic conjunction, never by aspect traffic alone.

**Shame still sinks.** Because shame is a Strong-tier cause and heavily
negative, every shamed planet lands near the bottom, without any special
override rule.

**The rule is aggressive at the top — this is the open question.** In 3 of 16
charts the healthiest planet has a *negative* total, because its aspect pile
outweighs its dignity even though the ranking ignores that. Two are mild
(Ernst's Jupiter −13.9, Vladimir's Mercury −17.3). One is extreme and is
Josh's chart:

> **Josh's Saturn ranks 1st of 7 at a total of −81.0v.** Its Strong subtotal
> is +45 (moolatrikona — proud), the highest in the chart. Its Aspect
> subtotal is −126: it is starved *and* agitated by Sun, Moon, and Mars — six
> aspect afflictions, because each enemy aspect fires both states. Strict
> precedence confines all of that to the tie-break tier, so Saturn is the
> "healthiest" planet in the chart despite being the most aspect-afflicted.

This is exactly Laura's rule taken literally: the exaltation is stronger than
the aspects, full stop. The question for her is whether it should be *that*
literal — **is a dignified planet's health truly unbounded above any amount
of aspect affliction, or should a large enough aspect pile be able to pull a
strong score down past some point?** If she says the strict form is right,
we keep it. If not, the fix is a bounded version where aspects can offset the
Strong subtotal up to a cap. We're leaving it strict so the extreme case is
visible for her to react to rather than pre-empting her with a guess.

**The ranking still partly restates benefic/malefic nature.** The healthiest
planet is Jupiter or the Moon in 9 of 16 charts; the least healthy is Venus
in 6 and Saturn in 4. This falls out of the rules — Jupiter's conjunction
delights, Saturn's starves, Venus has the most natural enemies. It may be
correct, or it may mean the model measures planetary nature more than
chart-specific condition. This remains an open question, softened but not
resolved by precedence.

------------------------------------------------------------------------

## Deferred to round 2: Rahu and Ketu

Laura (Q7): *"Nodes give the results (LA) of their ruler & any conjunct
planets, so they can be doing a lot. That would be a good idea for a separate
report."*

So the nodes don't get their own Lajjitaadi — they **inherit** the health of
their sign lord and of any planet they conjoin. That is a distinct
calculation and a distinct report, tracked separately and built after this
round is confirmed.

------------------------------------------------------------------------

## Open questions for Laura

1. **The strict-precedence extreme.** Josh's exalted-but-triple-afflicted
   Saturn is the healthiest planet in his chart (total −81). Is dignity
   really unbounded over aspect affliction, or should aspects be able to pull
   a strong score down once they're large enough?

2. **Benefic/malefic restatement.** Is it right that Jupiter and the Moon
   dominate the healthy end and Venus and Saturn the sick end across charts,
   or is that the model measuring planetary nature rather than condition?

3. **The healthy-state weights.** The down-shift (+45/+30/+15) is our reading
   of "afflictions should have more value." Is one rung enough, too much, or
   should the gap be larger?
