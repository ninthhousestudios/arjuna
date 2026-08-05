# Ranking planets by Lajjitaadi health

A proposed point system for ordering the seven embodied planets from
healthiest to least healthy, so that the beings they activate can be ranked
the same way. Written for Laura's review — the weights and the open
questions at the end are hers to settle.

Implementation: `arrow/calc/lib/src/vedic/planet_health.dart`.
Results for the 16 test charts: `planet-health-results.md`.

---

## The problem

Laura's affliction/health ordering, worst to best:

| Affliction | Health |
|------------|--------|
| Shamed     | Proud |
| Starved    | Secure (arrow calls this "healthy") |
| Agitated   | Delighted |
| Thirsty    | |

A pure ordering isn't enough to rank a chart. Two planets can both be
shamed. Almost every chart has at least one starved planet — in our 16
test charts, 79% of all planets are starved and 93% are delighted, so
those two states alone separate almost nothing. And a planet is rarely in
one state: it accumulates several at once, from several causes.

So we need a score, not a category.

## The point system

Every avastha is worth a signed number of **virupas** (1/60 of a rupa —
the same unit Parashara's aspect strengths already use, where 60 is a full
aspect). The afflictions are negative, the healthy states positive:

| Avastha | Virupas |
|---------|--------:|
| Shamed | −60 |
| Starved | −45 |
| Agitated | −30 |
| Thirsty | −15 |
| Delighted | +30 |
| Secure / healthy | +45 |
| Proud | +60 |

Shamed and proud carry a full rupa; each step in from there drops 15.

### Scaling by how the avastha was caused

A planet can be starved by a conjunction or starved by a distant aspect,
and those shouldn't count the same. So each cause is scaled by its
strength on the 0–60 scale:

- **Conjunction, sign placement, sign lord, dignity** → full strength (60),
  so full points.
- **Aspect** → the Parashara aspect strength. An enemy aspecting with 30
  points of strength starves at 30/60 × −45 = **−22.5**.

### Grading shame by its cause

Shame is the one avastha with a compound trigger. It requires *both* a
conjunction with Sun, Mars, or Saturn *and* one of three conditions:
conjunct Rahu/Ketu, in the 5th sign from the lagna, or conjunct the 5th
cusp. Laura noted that shame by Rahu/Ketu is worse than shame by being in
the 5th house, so the three conditions are graded:

| Shame condition | Strength | Virupas |
|-----------------|---------:|--------:|
| Conjunct Rahu/Ketu | 60 | −60 |
| Conjunct the 5th cusp | 45 | −45 |
| In the 5th sign | 30 | −30 |

These are **guesses** and the most likely thing to need changing.

Each malefic that triggers the shame also scores −60 in its own right, so
a planet shamed by both Mars and Saturn while conjunct Rahu carries
−60 − 60 − 60 = −180 of shame. That is how two shamed planets get
distinguished: by how many malefics and how severe the condition.

### Summing

Add every scored cause. Most virupas = healthiest; fewest = least healthy.
Ties share a rank.

### One cause, one score

The classical rules overlap. Saturn conjunct a planet it is also the
natural enemy of fires two starvation rules — "conjunction with a natural
enemy starves" and "Saturn's conjunction always starves" — for a single
physical fact. A friendly Jupiter conjunction likewise delights twice.
Identical causes are counted once.

---

## What the model deliberately does *not* do

It does not let any avastha trump another. A planet can be proud and
shamed at the same time and the score just adds them. Josh flagged this as
an open question; we scored the corpus first to see whether it matters in
practice. It does, in one visible case — see below.

---

## What the 16 test charts show

Full output in `planet-health-results.md`.

**Shame already sorts itself to the bottom.** Eleven planets across four
charts are shamed. Every one of them lands in the bottom half of its
chart (ranks 4–7 of 7); none reaches the top three. So the additive model
reproduces "shame is the worst" without needing a hard rule.

**Proud usually wins, but not always.** Of the twelve proud planets, eight
rank first in their chart. The exception worth Laura's attention is Josh's
Saturn: it is proud (exalted) and still ranks **6th of 7** at −43.6,
because the starvation and agitation it accumulates outweigh the +60.
That is exactly the case Josh asked about, and it is a real chart, not a
hypothetical.

**The ranking is partly a restatement of natural benefic/malefic status.**
Across the 16 charts, the healthiest planet is Jupiter or the Moon in 10
of 16, and the least healthy is Saturn in 6 of 16 and Venus or Mercury in
another 7. This falls out of the rules themselves — Jupiter's conjunction
always delights, Saturn's always starves, Jupiter aspects the most widely,
and Venus and Mercury have the most natural enemies. This may be correct
(a malefic really is less healthy) or it may mean the model is measuring
planetary nature more than chart-specific condition. **This is the biggest
open question.**

---

## Questions for Laura

1. **Are the seven virupa values right?** The −60/−45/−30/−15 and
   +60/+45/+30 ladder is even spacing over Laura's ordering, nothing more.
   Should the gaps be uneven — e.g. is shamed much worse than starved,
   rather than a third worse?

2. **Shame conditions.** Are 60/45/30 for Rahu-Ketu / 5th cusp / 5th sign
   the right grading? Should conjunction with the 5th cusp outrank
   residence in the 5th sign at all?

3. **Should shame be additive per malefic?** Right now shame by Mars *and*
   Saturn scores twice. Is a planet shamed by two malefics twice as
   shamed, or is shame a condition you're either in or not?

4. **Should proud or shamed override the sum?** Josh's exalted-but-starved
   Saturn ranking 6th is the test case. Two alternatives if the additive
   answer is wrong:
   - Sort shamed planets to the bottom and proud ones to the top first,
     then use the point total only to break ties within those groups.
   - Keep the sum but cap how much the other avasthas can offset a
     proud or shamed planet.

5. **Should the healthy states be worth as much as the afflicted ones?**
   Delighted appears on 93% of planets and starved on 79%. Because both
   are so common and both accumulate from every aspect in the chart, the
   totals are driven largely by how many planets aspect a given planet.
   Should afflictions weigh more heavily than the healthy states — say,
   afflictions at full value and healthy states at half — so that the
   score tracks damage rather than traffic?

6. **Should aspect-caused avasthas count at all**, or only conjunctions,
   sign placement, and dignity? Dropping aspects would remove most of the
   accumulation and leave a much sparser, blunter score.

7. **Do Rahu and Ketu need their own health scores?** They activate no
   beings of their own, so they are currently scored only as causes of
   shame in other planets, never as subjects.
