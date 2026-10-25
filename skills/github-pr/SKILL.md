---
name: github-pr
description: "Open a pull request for the current branch: draft title, base and description, then push and create it only on the user's explicit approval. Use for `/github-pr` or when asked to open a PR."
disable-model-invocation: false
---

# GitHub PR

Draft a pull request for the current branch, iterate on it with the user, then open it. Anything the user passes as arguments overrides the defaults below.

## 1. Gather

- **Changes**: the diff and commits from the merge-base with the base branch, merge commits excluded.
- **Base**: if the head branch of one of the user's open PRs (`gh pr list --author @me`) is an ancestor of `HEAD`, the branch is stacked on it: propose that branch as `--base`. Otherwise, the repo's default branch.
- **The why**: from the conversation first, then the ticket, then the commits. When the branch name carries a ticket ID, fetch the relevant ticket through the issue tracker convention. When the sources disagree, the conversation wins.

Done when you can state the problem in the terms the conversation or the ticket use, not the terms the diff suggests.

## 2. Draft

**Title**: Conventional Commits, in English: `type(scope): summary`, with the dominant commit type and the dominant app or package as scope.

**Description**: in Spanish, under three fixed headings:

- `## TLDR for humans`: the problem or the goal behind the PR, said the way you'd say it out loud to a teammate, usually in one plain sentence. Problem and Solution carry the detail.
- `## Problem`: when the branch carries a ticket, open with the line the issue tracker uses to link a ticket from a PR. Then the motivation.
- `## Solution`: what a reviewer needs to follow the change, grouped however suits it. The diff carries the line-by-line.

Beyond those three, add what only you know and the reviewer needs. Tests come first: if the change writes or modifies tests, say what behaviour they cover (not file names) and what you ran green. Anything else, such as a deploy constraint or a follow-up without a ticket, goes wherever it fits best, as its own section or inside Solution. The `--base` already expresses a stack. Cite another PR only when the description cannot be understood without it.

Every part stays **proportional** to the size of the change.

## 3. Review

**Nothing reaches the remote or GitHub before the user approves.** No `git push`, no `gh pr create`, until the user's own message approves this draft. The commands you show are a proposal for the user to read, never a step to run. After showing the draft, stop and wait. As a subagent, stopping means returning the title, base and description as your final summary; nothing runs.

Show the title, the base, the description in a markdown block, and the commands approval will run: `git push -u origin <branch>` when the branch is not on the remote yet, then `gh pr create --assignee @me` with `--base` when stacked.

Any feedback → revise and show it again. Explicit approval (`approve`, `OK`, `dale`) runs the commands; an approval that carries a change ("approve, but drop X") applies the change and runs without showing the draft again. One approval covers both the push and the create.

## 4. Create

Run the commands and print the PR URL.
