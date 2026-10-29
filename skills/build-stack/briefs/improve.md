# Improve brief

Append [`shared-directory.md`](shared-directory.md) verbatim to the review message.

## Review message

Invoke the `improve` skill with argument `<ticket reference>`.

The ticket's implementation is committed as a WIP on GitButler branch `<branch>`: wherever the skill reads `git diff HEAD`, read `but diff <branch>`.

End your report with a `Files:` section: every path you created, modified or deleted, relative to the repo root.

## Plan message

Invoke the `commit` skill to plan this ticket's atomic commits, reading `but diff <branch>` wherever the skill reads `git status` or `git diff HEAD`. Run only its planning steps and answer with the plan: the orchestrator creates the commits with `but`, so leave the branches and the working tree as they are.

## PR message

Invoke the `github-pr` skill: the changes are `but diff <branch>` and this branch's commits in `but status -fv`. Add a `## Decisiones fuera de la spec` section, present even when empty: every decision in the final code that the ticket and its spec left open. Stop at its approval gate and answer with the title and the description; the orchestrator opens the PR.
