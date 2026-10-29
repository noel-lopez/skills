---
name: build-stack
description: "Turn a spec into a GitButler stack of PRs, one branch per ticket."
disable-model-invocation: true
---

# Build stack

Carry every ticket of a spec through `build` and `improve` subagents to atomic commits on its own branch of one GitButler stack, then open the stack as PRs assigned to the user. You are the **sole writer**: subagents implement, review and plan; you run every `but` write, one at a time, always naming file or hunk IDs. Invoking this skill is the user's explicit authorization for this run's `but` writes. The official `but` skill owns command syntax and IDs.

## 1. Preflight

`git status --porcelain --untracked-files=all` must list only **hook files**: files whose content contains `GITBUTLER_MANAGED_HOOK_V1`. Anything else stops the run.

Then run [`scripts/check-stale-stacks`](scripts/check-stale-stacks) from the repo root: any output stops the run, naming each stack it lists.

Then run `but setup`, then `but pull`.

## 2. Stack

Fetch the spec, its open tickets, and each one's blockers. A blocker is **satisfied** once it is closed or has its atomic commits. A ticket with an open blocker outside the spec, or in a blocker cycle, stops (step 5) before any branch exists.

Order the remaining tickets topologically, ties broken by tracker order. Name each branch by the repo's documented convention, or `<ticket-number>-<kebab-case title>` when there is none. Create the first with `but branch new <branch>` and each next one with `but branch new <branch> -A <previous-branch>`.

Done when `but status` shows a single stack holding every branch in that order.

## 3. Schedule

A ticket is **ready** when every blocker is satisfied. Launch the pipeline of every ready ticket at once, with no concurrency cap. A ticket is **in flight** from its launch until its atomic commits, and **claims** every path in the `Files:` lists it reports.

An escalated **overlap** makes the ticket **wait on** the in-flight ticket whose `Files:` list claims that path, as one more blocker. If its branch sits below the blocker's, `but move <branch> --above <blocker-branch>`. Once that blocker is satisfied, resume the same subagent with "Overlap resolved: build on top." and its pipeline continues.

Done when every ticket has its atomic commits or is stopped.

## 4. Ticket pipeline

**Matching** a `Files:` list: every listed path shows in `but diff`, and no other ticket in flight claims it. A failed match stops the ticket. [`scripts/cli-ids`](scripts/cli-ids) `<path>...` prints the IDs of matched paths.

### 4.1 Build

Launch a subagent with [`briefs/build.md`](briefs/build.md).

### 4.2 WIP commit

Match the `Files:` list, then `but commit -b <branch> -m "wip(#<ticket-number>)" <hunk-ids>`, and keep the change ID it prints.

Done when no listed path remains in `but diff`.

### 4.3 Improve

Launch a fresh subagent with the review message of [`briefs/improve.md`](briefs/improve.md). Match its `Files:` list, an empty list included, and `but amend -t <wip-change-id> <hunk-ids>` when there are changes.

Done when no listed path remains in `but diff`.

### 4.4 Prune comments

Resume the improve subagent with the prune message of [`briefs/improve.md`](briefs/improve.md). Match its `Files:` list, an empty list included, and `but amend -t <wip-change-id> <hunk-ids>` when there are changes.

Done when no listed path remains in `but diff`.

### 4.5 Commit plan

Resume the improve subagent with the plan message of [`briefs/improve.md`](briefs/improve.md).

Done when every change in `but diff <branch>` belongs to exactly one planned commit.

### 4.6 Replace the WIP

`but uncommit <wip-change-id>`, then one `but commit -b <branch> -m "<message>" <hunk-ids>` per planned commit, in plan order.

Done when `but status -fv` shows the branch carrying exactly the planned commits in order and no WIP, and none of the ticket's paths remain in `but diff`.

## 5. Stopping a ticket

A ticket stops when its subagent escalates a product question or fails, when a match fails, or when one of its `but` writes fails.

For each stopped ticket:

1. Stop its running subagent, if any, and stop every ticket that depends on it, transitively.
2. If it has a branch, commit its claimed paths still in `but diff` as `wip(#<ticket-number>)` on that branch, then `but move <branch> --unstack`.
3. Record the ticket, its branch, and the reason, an escalated question verbatim.

The rest of the spec keeps running.

## 6. Gate

`but unapply` every stopped ticket's branch, so the working tree is the top of the stack. Build the packages the stack touches, then run the repo's documented typecheck and test commands, scoped to the apps and packages it touches.

Done when every command is green. A red gate skips step 7.

## 7. Pull requests

Resume every stack ticket's improve subagent at once with the PR message of [`briefs/improve.md`](briefs/improve.md).

Then, bottom-up, for each branch:

1. Write its PR message as the title line, a blank line and the description to a file outside the repo, so it never lands in `but diff`.
2. `but pr new <branch> -F <file>`.
3. `gh pr edit <branch> --add-assignee @me`.

Done when `gh pr view <branch> --json assignees,baseRefName` shows every stack branch assigned to the user, with the branch below it as base.

## 8. Summary

Report:

- the stack bottom-up, the order to review it in, each branch with its PR link;
- a red gate's failing command and its errors, in place of the links;
- every stopped ticket with its unapplied branch and reason;
- everything `improve` flagged;
- every path left in `but diff` other than hook files.

## 9. Feedback

The repo stays in workspace mode. For each piece of feedback on a PR:

1. Resume that ticket's improve subagent with the message of [`briefs/feedback.md`](briefs/feedback.md).
2. Match its `Files:` list, then `but commit -b <branch> -m "<message>" <hunk-ids>`: always a new commit on top of the branch, leaving published commits untouched.
3. `but push <top-branch>`, without `--with-force` or `--skip-force-push-protection`.
4. Resume the same subagent with the PR message of [`briefs/improve.md`](briefs/improve.md), write its answer to a file outside the repo, and `gh pr edit <branch> --title "<title>" --body-file <file>`.

Done when `but status -fv` shows the new commit on its branch, the branches above restacked on it, nothing left unpushed, and the PR's description covering the fix.

## 10. Teardown

Offer the teardown whenever the review looks finished, and on the user's go-ahead `but unapply` every applied stack, then run `but teardown --checkout-to <top-branch>`, so no stack stays marked in the workspace, and `git branch -D gitbutler/workspace gitbutler/target`. Report the stack branches left behind.
