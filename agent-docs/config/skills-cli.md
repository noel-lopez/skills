# Skills CLI

How to install, update, and remove externally-authored skills (e.g. `mattpocock/skills`) in this setup, using the [skills.sh](https://skills.sh) CLI.

Read this **before running the command**, not after. Every rule below exists because getting it wrong leaves the install in a state that looks fine and isn't.

## Invocation

The RTK hook rewrites `npx` into `npm` and breaks the command, so always go through `rtk proxy`, and pin the version:

```bash
cd ~ && rtk proxy npx -y skills@<version> <subcommand> …
```

- **Run from `~`.** Inside a repo the CLI detects a project and installs project-local, littering the repo with `.agents/`, `skills-lock.json`, and symlinks under `.claude/skills/`.
- **`-g`** installs to `~/.agents/skills`, the canonical store.
- **Omit `--agent`.** Left out, the CLI writes to the universal store and symlinks `~/.claude/skills/<name> -> ../../.agents/skills/<name>`, which is the layout this setup wants. Passing `--agent claude-code` copies the files straight into `~/.claude/skills` instead, and the copy then drifts from the store.
- **`-y`** skips the prompts.

## Reading the output

Read it whole, top to bottom. The `Installed N` block comes **first**, and a `Failed to install N` block follows it listing the agents that rejected the install. `PromptScript: does not support global skill installation` is one of those, and it is expected: PromptScript is a different agent and has no bearing on Claude Code.

So a successful run ends on a failure message. Judging the run by its last lines reports a working install as a total failure, and the natural repair (retrying with `--agent claude-code`) is exactly what breaks the symlink layout.

## The three operations

```bash
# install
rtk proxy npx -y skills@<version> add mattpocock/skills -g --skill <names…> -y

# update (omit the names to update every global skill)
rtk proxy npx -y skills@<version> update -g -y <names…>

# remove
rtk proxy npx -y skills@<version> remove -g -y <name>
```

`update` reports skills that were deleted upstream (`appear to have been deleted upstream`) but leaves them installed in non-interactive mode. Finish the job with `remove`.

## After installing or updating Matt's skills

Run `./scripts/patch-matt-skills.sh`. It reapplies the only local delta — flipping `disable-model-invocation` to `false` on the skills invoked conversationally — reading the list from `upstream/matt-skills.json`. It is idempotent.

`update` overwrites that flag, so the patch is owed after every update, not just after a fresh install.
