---
name: resolve-conflicts
description: "Resolve conflict markers left by a rebase, merge or cherry-pick, and orchestrate a stacked rebase."
disable-model-invocation: true
---

# Resolve conflicts

Resolve every conflict by **intent** — what each side was trying to do — and hunt the **silent breaks** git never marks. Propose, then act only on an explicit OK.

## The gate

Two moments hand control back to the user:

1. A proposed resolution, before any file is edited.
2. Every command that moves git state — `add`, `--continue`, `commit`, `push`.

At each, show the proposal and **stop**. `OK` / `ok` / `dale` / `vale` proceeds. `OK, but <change>` → adjust, re-show, wait. Anything else → adjust, re-show, wait.

Reading is free: inspect the repository as deeply as the resolution needs, no gate.

## 1. Find the door

```bash
git status
```

- **Nothing in progress** → step 2.
- **Conflict already on disk** → step 3. The map step 2 draws would no longer change a decision.

## 2. Recon and plan

Predict the conflicts without touching the index or the working tree:

```bash
git merge-tree --write-tree --name-only <upstream> <branch>
```

For every file it reports, name the upstream commits that touch it — `git log --oneline <merge-base>..<upstream> -- <file>` — so the user sees what is landing before running anything.

**More than one branch in play → read [`STACKED-BRANCHES.md`](STACKED-BRANCHES.md) now.** A stack rebased branch by branch reconflicts itself, and the cut point has to be chosen before the first command.

Present the map, then propose the first command.

## 3. Resolve, file by file

For each conflicted file:

- Read the three stages — `git show :1:<path>` (common ancestor), `:2:` (ours), `:3:` (theirs). Under `zdiff3`/`diff3`, the middle marker section is the ancestor.
- **In a rebase, `ours` is the new base and `theirs` is the commit being replayed** — your own work is `theirs`.
- Read the commit behind the other side with `git log -p`, so the resolution answers what each side was for.
- Read what git auto-merged in the same file. Those hunks hold the evidence for the resolution, and they are where a **silent break** hides.

Two shapes: an **adjacency conflict** — each side added a neighbour, a field, a method, an import — usually keeps both sides; a **semantic conflict**, where both sides changed the same behaviour, is decided by the intent behind each.

Propose in this shape:

```
`path/to/file.ts` — adjacency | semantic

- **ours** (`<sha>` <subject>): <what it did>
- **theirs** (`<sha>` <subject>): <what it did>

<the resolved block>

Evidence: <what in the code already proves this>
```

**The evidence carries the proposal.** A resolution the user can approve without opening the file is one that cites what already proves it: the auto-merged `build()` that references both fields, the test upstream added for that very case. Where none exists, say so and name the command that will produce it.

## 4. Verify the stop, then continue

Every conflicted file resolved means: no marker survives, the code type-checks, and the specs covering the touched files pass — with whatever commands the project defines for those.

Then propose staging and continuing. `--continue` runs under `GIT_EDITOR=true`, so it takes the existing message instead of waiting on an editor.

Back to step 3 for the next stop.

## 5. Verify the branch

The last commit applying is not the end — it is where **silent breaks** surface: hunks that auto-merged clean and no longer compile, because upstream deleted a field, renamed a type or wrapped a return value.

Done when **everything the replayed commits touch** type-checks and passes its tests — every app, package and workspace they reach, not only the one in front of you. `git log --name-only <upstream>..<branch>` is that list.

Where the fix lands:

- The break belongs to the commit being applied right now → fix it before `--continue`, so it ships inside that commit.
- The rebase already finished → one adaptation commit at the tip.
- It spans several commits, and each of them compiling on its own is worth a second pass → offer `git commit --fixup=<sha>` per commit plus `git rebase -i --autosquash`.

## 6. Close

Propose the push. `--force-with-lease` protects a rebased branch by comparing the remote against your remote-tracking ref, so push with that ref as you last saw it: a `fetch` first makes the lease expect whatever someone else pushed, and the force succeeds over their work.

Push a stack's branches back-to-back. Between the two pushes, the upper PR compares a rebased branch against a base that has not moved yet.

Where a branch has a PR, confirm its base ref still points where it did — `gh pr list --head <branch>`.
