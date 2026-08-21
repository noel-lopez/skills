---
name: prune-comments
description: Prune the comments in freshly implemented code — every comment earns its place under one test, or it goes. Survivors compress to one line.
disable-model-invocation: true
---

# Prune Comments

Give every comment in the code that was just implemented a verdict, and prune the
ones that haven't earned their place.

**Scope:** the recent change. If you already hold it from this session, work from
what you have; otherwise read `git diff HEAD`. An argument overrides the scope —
a path, a glob, a directory of older code.

## 1. Reconcile with the repo

The bar below is the floor. Layer the repo's own comment rules on top —
`CLAUDE.md` / `AGENTS.md` — and on conflict the repo wins.

## 2. Baseline

Run the repo's typecheck and lint before touching anything. Take the commands
from where the repo documents them (`CLAUDE.md` / `AGENTS.md`, project memory, a
`docs/` runbook), discovering them only when they're written nowhere. A tree that
arrives red is a finding to report.

## 3. The test

**Every comment in scope gets a verdict.** One question decides it:

> Would a competent reader of this code, without this comment, lose information?

Lost information means the comment carries a **why** the code cannot express and
that is worth knowing: a workaround, a constraint from outside the file, a
decision whose discarded alternative looks better than it is. Whatever the code
already says is information the reader already has.

Three verdicts:

- **Keep** — the reader would lose something, and the comment is already tight.
- **Reduce** — a why sits buried in prose that restates the code. Compress it to
  the why alone.
- **Delete** — the reader loses nothing.

A survivor is **one line**; more than one needs a reason you can state.

When deleting leaves the code unclear, **fix the code** — a sharper name, an
extracted function — so there is nothing left to explain.

### Patterns that fail the test on sight

- **Narrated preamble** — a block of prose above a method, class, or type telling
  in words what the unit does.
- **Inline changelog** — "now uses X instead of Y", "added to support Z". Git
  holds this.
- **Step narration** — `// 1. validate`, `// 2. save`, over code that already
  reads in that order.
- **Restatement** — the line's own logic, said again in words.
- **Obvious docblock** — JSDoc/TSDoc repeating the signature.

### Public API docblocks

A docblock on a library's exported API is judged by what it gives the consumer —
autocomplete, generated docs — rather than by inferability. Keep the ones that
serve the consumer, pruned to what the consumer needs.

### TODO and FIXME

A `TODO` the implementation wrote about its own work: delete it, and report it —
it often marks work left half-done that belongs in a ticket. A `TODO` older than
the scope stays as it is.

### Functional comments are out of scope

These are code wearing a comment's syntax, and they receive no verdict:
`@ts-expect-error`, `eslint-disable*`, `biome-ignore`, `prettier-ignore`,
`/// <reference>`, `// @vite-ignore`, shebangs, license headers, codegen markers.

Every file with comment syntax is in scope — TypeScript, YAML, SQL, Dockerfile,
CSS. A config option's why earns its place through the same test as any other
comment.

## 4. Verify

Re-run the baseline commands. Pruning prose leaves behavior identical, so red
means a functional comment left with it — restore that comment.

## 5. Report

In prose, in the terminal:

- What you **deleted** and **reduced**, grouped by pattern where several shared
  one.
- What you **kept**, and the why each survivor carries. This is how the human
  audits that the sweep was real.
- **Code you changed** to absorb a deleted comment, listed apart — that's a code
  change, not a comment change.
- `TODO`s you removed.
- Typecheck and lint status, plus anything that arrived red at baseline.
