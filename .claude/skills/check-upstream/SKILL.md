---
name: check-upstream
description: Audits the manifest's tracked copies of Matt Pocock's skills against his upstream repo in two separate passes — main (his released state) and the open PRs. For main, flags tracked skills that changed since the pin and traces the dependency closure within main for broken/missing referenced skills. For each open PR, surfaces what it would change and traces the closure within that PR's own tree (e.g. a PR that splits out a new sub-skill an existing one starts to depend on). Reasons over SKILL.md bodies; never touches a SHA (the bundled scripts/upstream.sh owns that). Advances the reviewed-up-to pin only on an explicit literal OK. Use when the user runs `/check-upstream`, asks to check upstream drift, sync against Matt's skills, or see what changed in the tracked skills. Pass `--merged-only` for a cheap main-only check that skips open PRs.
disable-model-invocation: false
---

# Check upstream

Audit the tracked skills against Matt's upstream in two independent passes, then
advance the pin **only** on an explicit OK. You reason over SKILL.md bodies; the
script owns all SHA mechanics — **never read, write, or pass a SHA.**

## 1. Gather the data

```bash
./scripts/upstream.sh fetch              # both audits
./scripts/upstream.sh fetch --merged-only   # cheap: AUDIT 1 (main) only
```

This stages `pendingSha` (the reviewed HEAD) in the manifest and dumps: the main
skill universe (name→path map), and the two audits below. Read it — don't re-fetch.

To recurse into a referenced skill the dump didn't include:

```bash
./scripts/upstream.sh body <path> [ref]   # ref defaults to main; pass a PR branch for PR bodies
```

## 2. Build the report — two separate audits

### Audit 1 — main (Matt's released state)

main is a closed graph: a released skill never references one that only exists in
a PR. So this entire audit resolves **within main**.

**[1a] Tracked skills that changed in main since the pin.** For each, read its
patch and classify: *improvement* / *behaviour change* / *breaking*, with a
recommendation (update or hold). Empty on a baseline run (empty pin).

**[1b] Dependency closure on main.** Start from the tracked skill bodies. Any
skill a body references enters the frontier; recurse with `body <path>` until the
set closes. Classify each edge **hard** (A invokes/depends on B → recommended
action) vs **soft** (A merely names B → note). Present as a tree. A referenced
skill that is missing from main is a real broken/incomplete dependency; one that
exists on main but isn't in the manifest is a *suggestion* to add — surface it,
the user decides.

### Audit 2 — open PRs (the horizon)

Skipped under `--merged-only`. Inform only — **never** touch the pin or manifest
for anything here. A PR-borne change re-reports when it merges, which is when to act.

For each open PR: which tracked skills it modifies, which new skills it introduces,
and the dependency closure **within that PR's own tree** (main + the PR). This is
where a PR that makes an existing skill depend on a brand-new sub-skill shows up
(e.g. `grill-with-docs` modified to run `/domain-modeling`, both inside the PR).

## 3. Wait for OK

Show the report, then **stop**. Only the literal `OK` (or `ok`) advances the pin.
`OK, but <change>` → adjust, re-show, wait. Anything else → adjust, re-show, wait.

## 4. Advance the pin

On OK:

```bash
./scripts/upstream.sh pin    # promotes pendingSha -> pin, clears pendingSha
```

The pin advances for AUDIT 1 (main) only. It does not re-fetch (the OK may have
taken a while; re-fetching would reopen the race). Queue agreed follow-ups
separately (e.g. with `to-issues`) — the pin means "reviewed up to here", not "synced".
