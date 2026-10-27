---
name: resolve-conflicts
description: "Resolve conflict markers left by a rebase, merge or cherry-pick, and orchestrate a stacked rebase."
disable-model-invocation: true
---

# Resolve conflicts

Resolve every conflict by **intent** — what each side was trying to do — and hunt the **silent breaks** git never marks. Every decision waits for an explicit OK; the mechanics between decisions run on their own.

## The gate

Control returns to the user at the **decisions**, never at the mechanics:

1. A proposed resolution — a marked conflict or a **silent break** — before any file is edited.
2. The push.
3. A stop the plan did not predict: a verification that fails without a clear cause, a rebase halting for another reason.

At each, show the proposal and **stop**. `OK` / `ok` / `dale` / `vale` proceeds. Anything else → adjust, re-show, wait.

An OK carries every mechanical step up to the next decision: edit, verify, `add`, `--continue`, the next branch's rebase, a fixup and its autosquash. These run without asking — each is local and recoverable through `git rebase --abort` or the reflog.

Reading is free: inspect the repository as deeply as the resolution needs, no gate.

## 1. Find the door

```bash
git status
```

- **Nothing in progress** → step 2.
- **Conflict already on disk** → step 3. The map step 2 draws would no longer change a decision. In a rebase, record the old head first — `cat "$(git rev-parse --git-path rebase-merge/orig-head)"` — since the push leases against it.

## 2. Recon and plan

Predict the conflicts without touching the index or the working tree:

```bash
git merge-tree --write-tree --name-only <upstream> <branch>
```

For every file it reports, name the upstream commits that touch it — `git log --oneline <merge-base>..<upstream> -- <file>` — so the user sees what is landing before running anything.

**More than one branch in play → read [`STACKED-BRANCHES.md`](STACKED-BRANCHES.md) now.** A stack rebased branch by branch reconflicts itself, and the cut point has to be chosen before the first command.

Record the head sha of every branch about to move — the push leases against it. Then present the map and start the first rebase.

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

Then stage and continue. `--continue` runs under `GIT_EDITOR=true`, so it takes the existing message instead of waiting on an editor.

Back to step 3 for the next stop.

## 5. Verify the branch

The last commit applying is not the end — it is where **silent breaks** surface: hunks that auto-merged clean and no longer compile, because upstream deleted a field, renamed a type or wrapped a return value.

Done when **everything the replayed commits touch** type-checks and passes its tests — every app, package and workspace they reach, not only the one in front of you. `git log --name-only <upstream>..<branch>` is that list.

A silent break is a resolution: propose its fix in the step 3 shape, naming where the fix lands:

- The break belongs to the commit being applied right now → fix it before `--continue`, so it ships inside that commit.
- The rebase already finished → one adaptation commit at the tip.
- It spans several commits, and each of them compiling on its own is worth a second pass → `git commit --fixup=<sha>` per commit, then `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <upstream>`.

## 6. Close

Propose one atomic push for every rebased branch, each leased against the old head recorded before its rebase:

```bash
git push --atomic origin \
  --force-with-lease=<branch-1>:<old-sha-1> \
  --force-with-lease=<branch-2>:<old-sha-2> \
  <branch-1> <branch-2>
```

- `--atomic` moves every branch or none, so no upper PR ever compares against a base that has not moved yet.
- An explicit sha makes the lease independent of the remote-tracking ref, so a background `fetch` cannot void it.
- Someone else's push to any of the branches fails the whole push, and nothing is overwritten.

Where a branch has a PR, confirm its base ref still points where it did — `gh pr list --head <branch>`.
