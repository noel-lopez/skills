---
name: improve
description: Review one issue's uncommitted implementation locally, pre-commit, in a fresh session for zero implementer bias. Reads the issue spec and `git diff HEAD`, applies the coding-standards bar, actively fixes bugs/edge-cases/quality in place and writes tests to break the code, then flags spec-coverage gaps and scope creep for the human instead of silently filling them. Leaves the tree green and never commits, pushes, branches, or touches GitHub. Use when the user runs `/improve #N` (or an issue URL/path) on uncommitted changes that implement an issue, regardless of how they were produced.
disable-model-invocation: true
---

# Improve

Review the uncommitted changes in the working tree against an issue —
**locally, before any commit**. This is one deliberate step in a
human-in-the-loop flow.

**Argument:** an issue reference — `/improve #N`, a URL, or a path, depending
on the repo's tracker. Review **only** that issue's work.

## 1. Fetch the issue (the spec)

The issue tracker convention should already be in your context — run
`/setup-matt-pocock-skills` if not. Fetch the given issue **with its full body
and comments**. If it's a PRD with sub-issues, treat the body as the overall
intent and each sub-issue as a sub-requirement. The issue is the spec you
review against.

## 2. Load the diff and context

- **`git diff HEAD`** — the uncommitted changes in the working tree. **This is
  what you review.** When the diff references logic outside it, read the full
  files for real context — don't review a hunk in isolation.
- `CONTEXT.md`, `docs/adr/`, `CLAUDE.md` / `AGENTS.md` — the repo's own bar and
  shape.

**Anti-bias:** review the diff on its own merits against the spec. There's no
author's report or commit message to lean on — and you shouldn't seek one. Judge
the code, not its author's intent.

## 3. Apply the quality bar

Invoke **`/coding-standards`** for the bar on deep modules, testing, and clean
code. Don't restate standards here — that skill owns them.

## 4. Establish a baseline — run typecheck and test first

Before you change anything, run the repo's **real** typecheck and test commands
to see the starting state. Get them from where the repo documents them —
`CLAUDE.md` / `AGENTS.md`, project memory, a `docs/` runbook. Only if they
aren't written down anywhere, fall back to discovering them (`package.json`
scripts, `Makefile`, README); don't assume `npm`, and don't spelunk in a loop.

A tree that arrived already red is a finding to **flag** — not a failure to
silently absorb or attribute to yourself.

## 5. Review actively — fix in place

You are not just commenting; you **improve the code**.

- **Try to break it.** For anything dodgy — fragile logic, unchecked
  assumptions, tricky conditions, implicit coercions, missing guards — write a
  test that exercises it. If you can break it, **fix it**.
- **If the issue is a bug report**, write a test that reproduces the original
  bug and confirm the diff actually fixes it.
- **Stress edge cases** and add tests: empty/zero/negative inputs, missing
  optional fields, null/undefined, repeated or concurrent calls, off-by-one in
  loops and slices, regressions in adjacent code. The suite is a safety net —
  especially for paths the existing tests don't already cover.
- **Improve quality** against the coding-standards bar: reduce nesting,
  eliminate redundancy, sharpen names, consolidate logic. Don't over-simplify.
- **Preserve behavior.** Change only *how* the code works, never *what* it does.

Fixes and new tests go into the **working tree, uncommitted** — like everything
else here.

Reviewing thoroughly and concluding the code is already clean, well-tested, and
sound — **changing nothing** — is a valid outcome. Don't invent refactors to look
busy; only touch what genuinely needs it.

## 6. Verify the diff against the spec — flag, don't fill

Walk the issue's stated outcomes and check the diff for:

- **Coverage** — does it do everything the issue asked? Note any stated outcome
  you can't find in the code.
- **Scope** — does it do anything the issue did *not* ask for? Unrequested
  refactors, drive-by changes, scope creep. For a PRD, code for an *open*
  sub-issue is a scope violation.
- **Interpretation** — is an ambiguous requirement read sensibly? If you'd serve
  the stated goal better another way, say so.

**This is the autonomy frontier.** You do the *technical-judgment* work — clean,
harden, test — and fix it in place. You leave the *product/scope* calls to the
human: **never silently fill a coverage gap or absorb scope creep by writing
code yourself.** Flag those in the report so the human decides.

## 7. Leave the tree green

Re-run the **same** typecheck and test commands from step 4 and leave them
green. If you genuinely can't get there, say so clearly in the report — never
hide a red tree.

## 8. Report — in the terminal, in prose

End with a report covering: **what you changed and why** (fixes, hardening,
refactors); **what you flagged but did NOT touch** (spec-coverage gaps, scope
creep, judgment calls left to the human); **tests you added** and what they
protect against; and the **typecheck/test status** (green, or exactly what's
still failing).

## What this skill does NOT do

- **No commit, no push, no branch.** Leave everything uncommitted — committing is
  a separate, deliberate step. It's branch-agnostic; it works on `git diff HEAD`.
- **No GitHub / PR machinery.** This is local, pre-commit; there is no PR.
