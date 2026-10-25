---
name: build-stack
description: "Take a spec from its link to a GitButler stack with one branch of atomic commits per ticket: subagents run build and improve in parallel along the blocker graph, the orchestrator writes every commit."
disable-model-invocation: true
---

# Build stack

Carry every ticket of a spec through `build` and `improve` subagents to atomic commits on its own branch of one GitButler stack. You are the **sole writer**: subagents implement, review and plan; you run every `but` write, one at a time, always naming file or hunk IDs. Invoking this skill is the user's explicit authorization for this run's `but` writes. The official `but` skill owns command syntax and IDs.

## 1. Preflight

`git status --porcelain --untracked-files=all` must list only **hook files**: files whose content contains `GITBUTLER_MANAGED_HOOK_V1`. Anything else stops the run.

Then run `but setup`.

## 2. Stack

Fetch the spec, its open tickets, and each one's blockers. A blocker is **satisfied** once it is closed or has its atomic commits. A ticket with an open blocker outside the spec, or in a blocker cycle, stops (step 5) before any branch exists.

Order the remaining tickets topologically, ties broken by tracker order. Name each branch by the repo's documented convention, or `<ticket-number>-<kebab-case title>` when there is none. Create the first with `but branch new <branch>` and each next one with `but branch new <branch> -A <previous-branch>`.

Done when `but status` shows a single stack holding every branch in that order.

## 3. Schedule

A ticket is **ready** when every blocker is satisfied. Launch the pipeline of every ready ticket at once, with no concurrency cap, each subagent in the background. A ticket is **in flight** from its launch until its atomic commits, and **claims** every path in the `Files:` lists it reports.

Done when every ticket has its atomic commits or is stopped.

## 4. Ticket pipeline

**Matching** a `Files:` list: every listed path shows in `but diff`, and no other ticket in flight claims it. A failed match stops the ticket.

### 4.1 Build

Launch a subagent with [`briefs/build.md`](briefs/build.md).

### 4.2 WIP commit

Match the `Files:` list, then `but commit -b <branch> -m "wip(#<ticket-number>)" <hunk-ids>`, and keep the change ID it prints.

Done when no listed path remains in `but diff`.

### 4.3 Improve

Launch a fresh subagent with the review message of [`briefs/improve.md`](briefs/improve.md). Match its `Files:` list, an empty list included, and `but amend -t <wip-change-id> <hunk-ids>` when there are changes.

Done when no listed path remains in `but diff`.

### 4.4 Commit plan

Resume the improve subagent with the plan message of [`briefs/improve.md`](briefs/improve.md).

Done when every change in `but diff <branch>` belongs to exactly one planned commit.

### 4.5 Replace the WIP

`but uncommit <wip-change-id>`, then one `but commit -b <branch> -m "<message>" <hunk-ids>` per planned commit, in plan order.

Done when `but status -fv` shows the branch carrying exactly the planned commits in order and no WIP, and none of the ticket's paths remain in `but diff`.

## 5. Stopping a ticket

A ticket stops when its subagent escalates a question or fails, when a match fails, or when one of its `but` writes fails.

For each stopped ticket:

1. Stop its running subagent, if any, and stop every ticket that depends on it, transitively.
2. If it has a branch, commit its claimed paths still in `but diff` as `wip(#<ticket-number>)` on that branch, then `but move <branch> --unstack`.
3. Record the ticket, its branch, and the reason, an escalated question verbatim.

The rest of the spec keeps running.

## 6. Summary

Report:

- the stack bottom-up, each branch with its commits;
- every stopped ticket with its branch and reason;
- everything `improve` flagged;
- every path left in `but diff` other than hook files.
