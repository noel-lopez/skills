---
name: build-stack
description: "Take a spec from its link to atomic commits on one GitButler branch per ticket: subagents run build and improve, the orchestrator writes every commit."
disable-model-invocation: true
---

# Build stack

Carry a spec's ticket through `build` and `improve` subagents to atomic commits on its own GitButler branch. You are the **sole writer**: subagents implement, review and plan; you run every `but` write, always naming file or hunk IDs. Invoking this skill is the user's explicit authorization for this run's `but` writes. The official `but` skill owns command syntax and IDs.

## 1. Preflight

`git status --porcelain --untracked-files=all` must list only **hook files**: files whose content contains `GITBUTLER_MANAGED_HOOK_V1`. Anything else stops the run.

Then run `but setup`.

## 2. Ticket and branch

Fetch the spec and its tickets. This version runs exactly one ticket: if the spec has more, stop and report.

Create the ticket's branch with `but branch new <branch>`, named by the repo's documented convention, or `<ticket-number>-<kebab-case title>` when there is none.

## 3. Build

Launch a subagent with [`briefs/build.md`](briefs/build.md). An escalated question stops the run: report it.

## 4. WIP commit

Match `but diff` against the subagent's `Files:` list: every changed path but hook files listed, every listed path changed. Any unmatched path stops the run. Then `but commit -b <branch> -m "wip(#<ticket-number>)" <ids>` and keep the change ID it prints.

Done when no path from the `Files:` list remains in `but diff`.

## 5. Improve

Launch a fresh subagent with the review message of [`briefs/improve.md`](briefs/improve.md). Match its `Files:` list as in step 4, an empty list included, and `but amend -t <wip-change-id> <ids>` when there are changes.

Done when no path from the `Files:` list remains in `but diff`.

## 6. Commit plan

Resume the improve subagent with the plan message of [`briefs/improve.md`](briefs/improve.md).

Done when the plan places every path in `but diff <branch>` in exactly one commit.

## 7. Replace the WIP

`but uncommit <wip-change-id>`, then one `but commit -b <branch> -m "<message>" <ids>` per planned commit, in plan order.

Done when `but status -fv` shows the branch carrying exactly the planned commits in order, no WIP, and the uncommitted area holds only hook files.

## 8. Summary

Report the branch, its commits, and everything `improve` flagged.
