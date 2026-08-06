---
name: walkthrough
description: "Build a throwaway HTML reading guide for a set of changes (dirty tree, local commits, or a PR): what it means for users and for the system, then an ordered walk through the code with links that open each file in the IDE. Orients the human; leaves every quality call to them."
disable-model-invocation: true
---

# Walkthrough

Turn a set of changes into a guide the human can *read*: impact first, then an
ordered walk through the code, with every stop linked to the real file in their
IDE. This is one deliberate step in a human-in-the-loop flow.

**Argument:** free text naming what to review, e.g. `/walkthrough PR 1234`,
`/walkthrough lo que tengo sin commitear`, `/walkthrough los últimos 3 commits`.
There is no default changeset: if the argument doesn't name one, ask.

**You orient, you don't judge.** State what changed, what it implies, and in
what order to read it. Risk density is orientation and belongs in the guide:
name what a stop touches (auth, money, data migration) and name what is
mechanical. Quality calls, bugs and improvements are the human's to make here,
with other skills and their own eyes. This guide is deliberately blind to them.

## 1. Resolve the changeset

Turn the argument into a concrete diff: `git diff HEAD` for a dirty tree, a
range for local commits, `gh pr diff` for a PR. Ambiguity about what counts as
"the change" is resolved by asking, never by picking.

## 2. Decide where the links point

Links open files **on disk right now**, so they only tell the truth when disk
matches the changeset.

For a **local** changeset (dirty tree, local commits) disk is the truth. Link to
the IDE and move on.

For a **PR**, compare local `HEAD` with the PR's `headRefOid`. On a mismatch,
**ask** which the human wants:

- **checkout** the PR branch, so the guide links into their IDE, or
- **GitHub links** pinned to the PR's SHA, leaving the tree untouched.

Ask regardless of whether the tree is dirty; the choice is theirs. If checkout
is chosen and git refuses, say so and fall back to GitHub links. After a
checkout, leave the branch in place and tell them which branch they're on.

## 3. Read past the diff

Read the full files the change touches, and the code around them that explains
it: callers, the shape it replaces, the convention it follows.

Read the stated intent too: a PR's description, and the spec or ticket when the
human named one. Both are claims *about* the change, and the guide describes the
change: where intent and code diverge, naming the divergence is orientation.

Delegate the surrounding-code exploration to subagents, one per zone of the
changeset, and keep the whole changeset in your own context. The narrative
decisions in step 4 need someone who has seen all of it at once.

## 4. Design the walk

**Stops are ideas, not files.** A stop can span three files; a file can appear
in two stops. Group mechanical churn into a single stop (one renaming across 32
files is one stop).

**Order by the change, never by the directory tree.** Pick execution flow or
dependency order depending on where the core of the change sits, and state in
one line why that order.

**Cap the walk at around 12 stops.** Past that, say so and propose narrowing the
changeset instead of composing it.

## 5. Compose the guide

Read [`references/html.md`](references/html.md) for the artifact: structure,
language, link mechanics, state, and the bar for the page itself.

## 6. Validate coverage

Before opening it, check that **every file in the changeset** appears either in
a stop or in the leftovers section, and that every link resolves to a file that
exists. A file silently missing from the guide is the one failure the human
can't catch themselves.

## 7. Hand it over

Open the file in the browser (`open <path>`), and report the path and the number
of stops. Everything else is in the guide: summarising it in the terminal is how
it goes unread.

## What this skill does NOT do

- **No review.** Issues, bugs, quality and suggested fixes belong to other
  skills the human runs separately. Staying blind to them is what keeps this
  guide a clean first read.
- **No writes to the repo.** The only change it may make is a checkout the human
  explicitly asked for in step 2.
