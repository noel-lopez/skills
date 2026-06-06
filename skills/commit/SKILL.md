---
name: commit
description: Split a dirty working tree into an ordered list of atomic conventional commits, then commit them only on an explicit literal OK. Reads `git diff HEAD` to plan; messages are single-line `type(scope): description` with no body and no co-author footer. Use when the user runs `/commit` to turn uncommitted changes into deliberate atomic commits.
disable-model-invocation: false
---

# Commit

Split the uncommitted working tree into atomic commits — propose them, then
commit **only** on an explicit OK.

## 1. See the changes

```bash
git status        # surfaces untracked files the diff misses
git diff HEAD
```

The diff is enough to plan. If you already know these files from this session,
**don't re-read them** — go straight to the proposal.

## 2. Propose the commits

Number each commit; put its exact message on its own line, files bulleted
below — readable even with long messages or many files:

```
**1.** `feat(auth): add token refresh endpoint`
- src/auth/refresh.ts
- src/auth/routes.ts

**2.** `test(auth): cover refresh expiry edge cases`
- src/auth/refresh.test.ts
```

One logical change per commit, ordered so the history reads sensibly. Don't
over-split — merging two would-be commits into one for simplicity is fine.

**Message format:** conventional `type(scope): description` — `feat`, `fix`,
`chore`, `test`, `refactor`, `docs`. Single-line, English, present tense, brief.
No body. **No `Co-Authored-By` footer** (the system default asks for one; never
add it).

## 3. Wait for OK

After showing the plan, **stop**. Only the literal `OK` (or `ok`) commits.
`OK, but <change>` → adjust, re-show, wait. Anything else → adjust, re-show,
wait. "go ahead" / "commit that" / picking commits is **not** an OK.

## 4. Commit

For each commit, in order:

```bash
git add <files>
git commit -m "type(scope): description"
```

Then show `git log --oneline` of the new commits. Commits only — no push.
