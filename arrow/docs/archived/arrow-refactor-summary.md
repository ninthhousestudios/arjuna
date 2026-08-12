# Arrow Refactor — Summary

Branch `drona`. Companion to `docs/arrow-refactor.md` (diagnosis) and
`docs/arrow-refactor-plan.md` (implementation plan).

## Wave A — Fix config contracts and seal the SWE boundary

Corrected the SweConfig/CalcConfig split, fixed a silent nakshatra bug,
and moved all SWE wire-format knowledge out of the options layer.

| Step | Commit | Description | Files |
|------|--------|-------------|-------|
| A1 | `931ce1b` | Move `nakAyanamsa` from CalcConfig to SweConfig | 4 |
| A2 | `a009d22` | Wire nakAyanamsa through `Longitude.nakshatra`/`pada` — fixes ~24° silent error | 7 |
| A3 | `fa0c627` | Move `includeStarData` from SweConfig to `SweFacade.calcAll` parameter | 5 |
| A4.1 | `04c7dc9` | Move `Body.sweId` to swe/ as `sweIdFor()` | 4 |
| A4.2 | `4f5d120` | Move `Star.sweName` to swe/ as `sweNameFor()` | 4 |
| A4.3 | `7d8ec85` | Stop re-exporting `SwissEph` and `dhruva` from barrel | 5 |

**Review together:** All 6 commits form one logical change (SWE boundary
hygiene). A1+A2 are tightly coupled (A2 depends on A1's field move).
A4.1–A4.3 build on each other sequentially.

## Wave B — Reshape EphSnapshot

Stripped unnecessary config from the snapshot and unified the star data model.

| Step | Commit | Description | Files |
|------|--------|-------------|-------|
| B.1 | `00f006d` | Replace `EphSnapshot.options: ArrowOptions` with `.sweConfig: SweConfig` | 11 |
| B.2 | `fa3fcd1` | Introduce `StarPosition`, collapse 6 star maps to 2 | 10 |
| B.3 | — | JSON converter optimization (deferred) | — |

**Review together:** B.1 and B.2 are independent but both reshape
EphSnapshot. B.1 is the broader change (11 files, mostly test updates).
B.2 introduces the new `StarPosition` type and is self-contained.

## Wave C — Flatten body hierarchy

Removed vestigial class layers that added no behavior.

| Step | Commit | Description | Files |
|------|--------|-------------|-------|
| C | `bf6f828` | Delete `Graha` class, delete `Sun` class, `Karaka extends Planet` directly | 8 |

**Review as one commit.** Mechanical hierarchy simplification. Net -65 lines.

## Wave D — Extract varga math from Longitude

Pure mechanical extraction — no behavior changes.

| Step | Commit | Description | Files |
|------|--------|-------------|-------|
| D | `be0361f` | Extract 16 varga methods to `varga_math.dart` as pure top-level functions | 4 |

**Review as one commit.** Longitude drops from 691 to 150 lines. New
`varga_math_test.dart` covers edge cases. Net +143 lines (new test file).

## Totals

| Wave | Commits | Files changed | Insertions | Deletions |
|------|---------|---------------|------------|-----------|
| A | 6 | 29 | 340 | 376 |
| B | 2 | 21 | 224 | 310 |
| C | 1 | 8 | 16 | 81 |
| D | 1 | 4 | 706 | 563 |
| **All** | **10** | **62** | **1286** | **1330** |

All 830 tests pass after the final commit (options 52, swe 67, core 317, calc 394).
