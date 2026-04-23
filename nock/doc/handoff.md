# Handoff

## Just completed

Nock REPL Phases 5, 6 (2 commits, 2df92d2..eea8f24 on `drona`). All 6 phases of `nock/doc/repl-impl.md` are now complete.

- **Phase 5 (Evaluator)** — `nock/lib/src/repl/evaluator.dart`. ReplSession holds variables + Vayu + active NockConfig. Evaluator walks AST, dispatches `chart()`, `config()`, `now()` functions, resolves property chains and method calls through NockValue types. Date parsing via `DateTime.parse`, builds `Location` + `ArrowOptions` for Vayu. Session-level config: `config()` both returns a value and updates the session default. 45 tests with real Vayu/Moshier.
- **Phase 6 (REPL loop + entry point)** — `nock/lib/src/commands/repl.dart`, updated `bin/nock.dart`. Bare `nock` enters REPL; `nock repl` also works as explicit subcommand. Vayu created on entry, disposed on exit. 10 pipeline integration tests.

119 total tests passing across all phases (13 format + 22 lexer/parser + 29 types + 45 evaluator + 10 pipeline).

### Key decisions

- **Session config**: `config()` mutates session state — subsequent `chart()` calls use the updated config unless an explicit config argument is passed. This makes the common case (set config once, calculate multiple charts) ergonomic.
- **Reserved names**: `chart`, `config`, `help`, `vars`, `quit`, `now` cannot be used as variable names.
- **Date handling**: `DateTime.parse` handles all formats (YYYY-MM-DD, YYYY-MM-DD HH:MM, ISO 8601 with T). Converts to UTC for Vayu.

## Pick up next

The REPL v1 is feature-complete per the plan. Possible follow-ups:

1. **Migrate chart.dart CLI command** to use shared formatters (deferred from Phase 2).
2. **Line editing / history** — look at `dart:io` readline or a Dart package for arrow keys, history recall.
3. **Tab completion** — complete property names, function names, variable names.
4. **synastry() / transits()** — gated on those calculations existing in Arrow.
5. **.dashas()** — gated on arrow_calc integration in Vayu.

## Context

- Chitta session summary: search `session-2026-04-23-nock-repl-phases-2-3-4`
- Implementation plan: `nock/doc/repl-impl.md`
- REPL DSL spec: `nock/doc/repl.md`
