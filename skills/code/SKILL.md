---
name: code
description: Implement a single issue end-to-end and stop with the working tree dirty — no commit, no push, no branch, no issue close. Reads the repo's issue tracker convention to fetch the issue, loads project context, applies the coding-standards bar, and embodies red-green-refactor where feasible. Use when the user runs `/code #N` (or passes an issue URL/path) and wants one issue built but left uncommitted for deliberate review.
disable-model-invocation: true
---

# Code

Build **one** issue end-to-end, then **stop and leave the working tree dirty**.
This is one deliberate step in a human-in-the-loop flow.

**Argument:** an issue reference — `/code #N`, a URL, or a path,
depending on the repo's tracker. Implement **only** that issue.

## 1. Fetch the issue

The issue tracker convention should already be in your context — run
`/setup-matt-pocock-skills` if not. Fetch the given issue **with its full body
and comments**, and pull in its parent PRD if it has one.

## 2. Load context

Before writing code, read the project's own bar and shape:

- `CONTEXT.md`, `docs/adr/`, `CLAUDE.md` / `AGENTS.md`.
- Explore the repo and fill context with the parts relevant to this issue —
  **especially the test files** that touch the area you'll change.

## 3. Apply the quality bar

Invoke **`/coding-standards`** for the bar on deep modules, testing, and clean
code. Don't restate standards here — that skill owns them.

## 4. Implement (TDD where feasible)

Derive the behaviors to build from the issue's **acceptance criteria**. Apply
red-green-refactor where it's feasible — one cycle at a time:

1. **RED** — write one failing test for the next behavior.
2. **GREEN** — implement just enough to pass it. Never refactor while RED.
3. **REPEAT** — next test responds to what the last cycle taught you. Don't
   write all the tests up front.
4. **REFACTOR** — once green, clean up against the coding-standards bar.

Embody this discipline directly. **Do not invoke the `tdd` skill** — its
interactive planning gate isn't wanted here. Where TDD doesn't fit, just build
it well; a later review pass is the safety net that adds tests.

## 5. Autonomy & escalation

Work autonomously — no plan-approval gate. Escalate to the user (**in prose, no
interactive prompts**) **only** for a blocking ambiguity that neither the issue,
its PRD, `CONTEXT.md`, nor the ADRs resolve. Don't guess blindly; don't ask
about everything either.

## 6. Feedback loop

Before stopping, run the repo's **real** typecheck and test commands and get them
green. Get them from where the repo documents them — `CLAUDE.md` / `AGENTS.md`,
project memory, a `docs/` runbook. Only if they aren't written down anywhere, fall
back to discovering them (`package.json` scripts, `Makefile`, README); don't assume
`npm`, and don't spelunk in a loop.

## 7. Stop — leave it dirty

When the issue is done:

- **Do NOT** commit, push, create a branch, or close the issue. Work on the
  current branch; branches are the user's concern.
- End with a short summary: what you built, key decisions, and the
  typecheck/test status.
