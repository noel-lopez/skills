## Agent skills

### Issue tracker

Issues and specs live as GitHub issues, managed via the `gh` CLI. See `agent-docs/config/issue-tracker.md`.

### Triage labels

Five canonical triage roles, each mapped 1:1 to its default label string. See `agent-docs/config/triage-labels.md`.

### Domain docs

Single-context: `agent-docs/GLOSSARY.md` + `agent-docs/adr/`. See `agent-docs/config/domain.md`.

### Branches

Commits go straight to `main`, unless a flow builds its own branches (`build-stack`, `build-ticket`) or the user asks for a branch.

### Skills CLI

Read `agent-docs/config/skills-cli.md` before installing, updating, or removing an externally-authored skill — its invocation rules and its guide to reading the CLI output both have traps that only show up after the fact.
