# Enforcement ledger — arjuna

The append-only record of arjuna's architectural constraints: what is governed,
why, at what severity, and how each rule binds. `.sutra/rules.toml` (at the
workspace root) is the machine-readable source of truth; this ledger is the
human-readable rationale and the maintenance history that `vidhi-sutra-tend`
diffs against.

**Append-only.** Rows are added or their status amended with a dated note; rows
are never silently deleted. A retired constraint is marked retired with a
rationale, not removed.

arjuna is a Dart/melos monorepo. `arrow/` and `quiver/` were once separate sutra
workspaces; their `rules.toml` files were folded into the root and paths
re-prefixed (`arrow/…`, `quiver/…`). The repo was *adopted* into sutra with
rules but no ledger; this ledger was backfilled at the 2026-08-15 tend.

## Buckets

- **(a) graph-enforced** — expressible as a sutra constraint and actively bound
  (forbidden_dep, confined_external, no_cycles, forbidden_pattern). The guard
  denies or warns at edit time.
- **(b) deferred** — a constraint whose trigger structure does not exist yet.
- **(c) prose invariant** — a rule stated in CLAUDE.md / design docs that the
  graph cannot express; enforcement is human review only.
- **(d) convention** — FCA-tracked pattern preference, lifecycle-managed.

## (a) Graph-enforced constraints

Constraints are keyed by `name` (the `.sutra/accepted.toml` key). Severity is
blocking unless noted.

### Dart house baseline

| name | kind | scope | provenance | status |
|------|------|-------|------------|--------|
| no-ignore-comments | forbidden_pattern (`// ignore:` / `// ignore_for_file:`) | dart, workspace-wide | house analysis_options.yaml baseline | live — 44 unwaived + 314 waived pre-existing matches, grandfathered by the guard's introduced-only semantics; new `// ignore` comments denied at edit time |

### Arrow package boundaries

Dependency flows strictly left-to-right: **options → swe → core → calc**; each
package may only import from packages to its left.

| name | from → to | provenance |
|------|-----------|------------|
| options-must-not-import-swe | arrow/options → arrow/swe | arrow arch: left-to-right layering |
| options-must-not-import-core | arrow/options → arrow/core | arrow arch: left-to-right layering |
| options-must-not-import-calc | arrow/options → arrow/calc | arrow arch: left-to-right layering |
| swe-must-not-import-core | arrow/swe → arrow/core | arrow arch: left-to-right layering |
| swe-must-not-import-calc | arrow/swe → arrow/calc | arrow arch: left-to-right layering |
| core-must-not-import-calc | arrow/core → arrow/calc | arrow arch: left-to-right layering |

### Arrow calc subsystem isolation

`vedic/` and `zodiac/` are independent subsystems within calc; neither depends
on the other.

| name | from → to |
|------|-----------|
| vedic-must-not-import-zodiac | arrow/calc/.../vedic → .../zodiac |
| zodiac-must-not-import-vedic | arrow/calc/.../zodiac → .../vedic |

### Arrow FFI encapsulation

| name | kind | rule | provenance |
|------|------|------|------------|
| swisseph-only-in-arrow-swe | confined_external (`swisseph_rs`, `swisseph`) | allowed only in `arrow/swe/**` + `arrow/tool/**` | arrow arch: only arrow_swe imports swisseph; everything else (arrow/rdf included) goes through SweFacade |

### Quiver package layering

`quiver/core/` is the shared foundation; `server/` and `embedded/` are
independent deployment modes that depend on core but never on each other.

| name | from → to | provenance |
|------|-----------|------------|
| core-no-server-dep | quiver/core → quiver/server | quiver/CLAUDE.md: embedded/ and server/ do not depend on each other |
| core-no-embedded-dep | quiver/core → quiver/embedded | quiver/CLAUDE.md |
| embedded-no-server-dep | quiver/embedded → quiver/server | quiver/CLAUDE.md |
| server-no-embedded-dep | quiver/server → quiver/embedded | quiver/CLAUDE.md |

### Cycle prevention

Each calculator/element/unit should remain independently testable.

| name | scope |
|------|-------|
| no-cycles-vedic-calcs | arrow/calc/lib/src/vedic/ |
| no-cycles-panchanga | arrow/calc/lib/src/vedic/panchanga/ |
| no-cycles-zodiac | arrow/calc/lib/src/zodiac/ |
| no-cycles-options | arrow/options/lib/src/ |
| services-no-cycles | quiver/server/lib/src/services/ |
| no-cycles-arrow-rdf | arrow/rdf/lib/src/ — *added checkpoint:vidya/astrology-research/6* |

### Arrow/rdf serialization sink *(added checkpoint:vidya/astrology-research/6)*

`arrow/rdf/` is the RDF/N-Quads serializer; the compute layers must never depend
back on the emitter, keeping serialization at the edge.

| name | from → to |
|------|-----------|
| options-must-not-import-rdf | arrow/options → arrow/rdf |
| swe-must-not-import-rdf | arrow/swe → arrow/rdf |
| core-must-not-import-rdf | arrow/core → arrow/rdf |
| calc-must-not-import-rdf | arrow/calc → arrow/rdf |

## (b) Deferred constraints

None currently parked.

## (c) Prose invariants (human-review only)

| invariant | source | enforcement |
|-----------|--------|-------------|
| SweFacade is the only path to the Swiss Ephemeris binding | arrow arch / CLAUDE.md | partially graph-enforced by `swisseph-only-in-arrow-swe`; the facade-usage discipline (call the facade, not re-export the binding) is review |

## (d) Conventions

Deliberately unconfigured. The legacy arrow/quiver `[conventions]` suppress lists
(20 + 34 hashes) are no longer read by sutra (sutra/234 replaced convention
violations with an on-the-fly deviation report; the only reader of
`config.suppress` is `FcaEngine::check`, which has no production caller). Don't
re-add a suppress list without first confirming something consumes it.

## Maintenance history

- **2026-08-15 — checkpoint:vidya/astrology-research/6** (first tend; backfilled
  this ledger). arjuna was adopted into sutra with rules folded in from the
  former arrow + quiver workspaces but no ledger — this pass backfills it from
  `.sutra/rules.toml` provenance, run under the vidya ARP-R2 corpus review that
  needed the arrow serializer tended. Health check: full parse (3669 symbols,
  304 files), **0 import cycles workspace-wide**, all layering / FFI-confinement
  rules bind, zero `dead_constraint`; the only violations are `no-ignore-comments`
  (44 unwaived + 314 waived), all pre-existing Dart-house baseline, grandfathered
  by the guard. Emergent structure: the **arrow_rdf serializer package**
  (`arrow/rdf/lib/src/`) was entirely ungoverned — it imports options/swe/core
  via the `arrow_swe` facade (not swisseph directly, so `swisseph-only-in-arrow-swe`
  holds) and is the RDF emission sink. Added **5 constraints**: `no-cycles-arrow-rdf`
  and four `*-must-not-import-rdf` sink rules; all bind clean (0 cycles, no
  compute→rdf edges today), so blocking. No drift found. Next tend: when the
  serializer grows the aditya being-layer / additional Views
  (vidya/astrology-research/26), or the next arrow track lands.
