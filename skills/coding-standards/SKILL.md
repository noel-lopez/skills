---
name: coding-standards
description: The universal bar for good code — deep modules, design for testability, behavior-driven tests, mocking only at system boundaries, lean clean code. Use when writing, reviewing, refactoring, or judging the quality of any code, or when the user references coding standards, clean code, or deep modules. Reconciles this universal bar with the repo's own CONTEXT.md, docs/adr/, and CLAUDE.md/AGENTS.md.
disable-model-invocation: false
---

# Coding Standards

The universal bar for what good code is.

## Reconcile with the repo first

This bar is the universal floor. Layer the repo's own rules on top — on conflict,
the repo wins:

- `CONTEXT.md` — the project's domain language and shape.
- `docs/adr/` — recorded architectural decisions.
- `CLAUDE.md` / `AGENTS.md` — explicit instructions for this repo.

## Interface design

**Deep modules** — small interface, deep implementation: a few methods with
simple params hiding complex logic behind them. Avoid shallow modules (large
interface that just passes through to thin implementation). When designing, ask:
can I reduce the number of methods? Simplify the params? Hide more complexity
inside?

**Design for testability**:

1. **Accept dependencies, don't create them** — pass external dependencies in
   rather than constructing them internally.
2. **Return results, don't produce side effects** — a function that returns a
   value is easier to reason about and test than one that mutates state.
3. **Small surface area** — fewer methods = fewer tests; fewer params = simpler
   setup.

**Scrutinise optional parameters** — they are a major source of bugs by
omission. Prioritise correctness over backwards compatibility.

## Clean code

- Reduce nesting and complexity; flatten control flow where you can.
- Eliminate redundancy.
- Clear, intention-revealing names.
- Remove comments that describe obvious code.
- Avoid nested ternaries — prefer `if/else` or `switch`.
- Clarity over brevity.

**Don't over-simplify.** A simpler form isn't better if it buries clarity,
merges unrelated concerns into one unit, removes an abstraction that aided
organization, or makes the code harder to debug. Deep modules ≠ monolithic
functions.

## Testing

Tests verify **behavior through public interfaces, not implementation details**.
Code can change entirely; tests shouldn't break unless behavior changed.

- Test what callers care about, through the public API only.
- One logical assertion per test.
- Mock only at **system boundaries** (external APIs, time/randomness, FS/DB when
  no real instance is practical). **Never mock your own classes/modules or
  internal collaborators** — if something is hard to test without that, redesign
  the interface.

See [references/testing.md](references/testing.md) for GOOD/BAD examples, the
full red-flag list, boundary-mocking detail, and the TDD rationale.

## TDD (when feasible)

Vertical slices, one cycle at a time — `test1→impl1`, then `test2→impl2`, …
Never write all tests first, and never refactor while RED. TDD is complementary:
clean code and deep modules carry the weight.
