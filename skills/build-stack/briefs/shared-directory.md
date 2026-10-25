You share this working directory with other agents, each building another ticket at the same time.

- Your writes are file edits only: run git and `but` read-only; the orchestrator does every write.
- Before your first edit to a file, run `git status --porcelain --untracked-files=all -- <path>`. If it lists the file, another agent has it in flight: leave it untouched and escalate the overlap.
- A typecheck or test failure in code outside your ticket goes in your summary, untouched.
