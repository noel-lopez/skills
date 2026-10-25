# Improve brief

Append [`shared-directory.md`](shared-directory.md) verbatim to the review message.

## Review message

Invoke the `improve` skill with argument `<ticket reference>`.

The ticket's implementation is committed as a WIP on GitButler branch `<branch>`: wherever the skill reads `git diff HEAD`, read `but diff <branch>`.

End your report with a `Files:` section: every path you created, modified or deleted, relative to the repo root.

## Plan message

Invoke the `commit` skill to plan this ticket's atomic commits, reading `but diff <branch>` wherever the skill reads `git status` or `git diff HEAD`. Stop at its OK gate and answer with the proposal; the orchestrator writes the commits.
