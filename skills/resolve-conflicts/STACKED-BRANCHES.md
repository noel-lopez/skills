# Stacked branches

A **stack** is a chain of branches, each based on the one below instead of on the trunk. Rebasing the chain onto a moved trunk is one decision per branch, and that decision is the **cut point**.

## Order

Bottom-up. The lowest branch rebases onto the new trunk and gets verified before the branch above it moves: an upper branch replanted on an unverified base repeats every fix.

## The cut point

The lowest branch takes the ordinary form:

```bash
git rebase <new-base> <lowest-branch>
```

Every branch above it needs all three arguments, because its cut point and its destination are different commits:

```bash
git rebase --onto <rebased-branch-below> <old-head-of-that-branch> <upper-branch>
```

- **newbase** (`--onto`) — where the replayed commits land.
- **upstream** — the commits replayed are `upstream..branch`, so this is the branch below **as it was before its own rebase**.
- **branch** — checked out for you, and `HEAD` returns to it when the rebase ends. No `checkout` first.

Naming that old head is the whole trick. While the lower branch is still unpushed, `origin/<lower-branch>` names it; otherwise record the sha before rebasing it.

## Why the two-argument form reconflicts

`git rebase <rebased-branch-below> <upper-branch>` sets upstream = newbase, so the replay set becomes `<rebased-below>..<upper>` — which still holds the lower branch's **old** commits, since rebasing it gave them new shas. Git drops commits already upstream by patch-id, and resolving a conflict changed those patches, so they no longer match: they get replayed, and every conflict already resolved comes back.
