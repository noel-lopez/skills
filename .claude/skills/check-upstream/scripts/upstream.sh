#!/usr/bin/env bash
# upstream.sh — deterministic data-gathering for the check-upstream skill.
#
# Claude reasons; this script does the mechanics. The hard invariant: Claude
# never reads, writes, or passes a SHA. SHAs are 40-char literals handled here
# only. `fetch` captures main's HEAD into `pendingSha`; `pin` promotes it. The
# human OK happens between the two (HITL), so `pin` never re-fetches.
#
# `fetch` dumps TWO independent audits. AUDIT 1 is main (Matt's released state):
# its dependency closure resolves entirely within main — a released skill never
# references one that only exists in a PR. AUDIT 2 is the open PRs: each PR's
# closure resolves within that PR's own tree (main + the PR's changes).
#
# Subcommands:
#   fetch [--merged-only]   gather drift + dependency + horizon data; stage pendingSha
#   body <path> [ref]       dump one SKILL.md body (ref defaults to main) — for recursion
#   pin                     promote pendingSha -> pin, drop pendingSha (after the human OK)
set -euo pipefail

UPSTREAM_REPO="mattpocock/skills"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(git -C "$script_dir" rev-parse --show-toplevel)"
manifest="$root/upstream/matt-skills.json"

die() { echo "error: $*" >&2; exit 1; }

require() {
  command -v gh >/dev/null 2>&1 || die "gh CLI not found"
  command -v jq >/dev/null 2>&1 || die "jq not found"
  gh auth status >/dev/null 2>&1 || die "gh not authenticated — run: gh auth login"
  [ -f "$manifest" ] || die "manifest not found at $manifest"
}

# raw body of a file at a given ref (default: main)
raw_body() {
  local path="$1" ref="${2:-main}"
  gh api "repos/$UPSTREAM_REPO/contents/$path?ref=$ref" \
    -H "Accept: application/vnd.github.raw" 2>/dev/null \
    || echo "(could not fetch $path @ $ref)"
}

# is $1 listed as a manifest path?
is_manifest_path() {
  jq -e --arg p "$1" '.skills[] | select(.path == $p)' "$manifest" >/dev/null 2>&1
}

cmd_body() {
  [ $# -ge 1 ] || die "usage: upstream.sh body <path> [ref]"
  require
  raw_body "$1" "${2:-main}"
}

cmd_pin() {
  require
  local pending
  pending="$(jq -r '.pendingSha // ""' "$manifest")"
  [ -n "$pending" ] || die "no pendingSha to promote — run 'upstream.sh fetch' first"
  local tmp; tmp="$(mktemp)"
  jq '.pin = .pendingSha | del(.pendingSha)' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
  echo "pin advanced to the reviewed HEAD; pendingSha cleared."
  echo "(SHA handled by the script — not surfaced.)"
}

cmd_fetch() {
  local merged_only=0
  [ "${1:-}" = "--merged-only" ] && merged_only=1
  require

  local pin head
  pin="$(jq -r '.pin // ""' "$manifest")"
  head="$(gh api "repos/$UPSTREAM_REPO/commits/main" --jq .sha)"

  # Stage the reviewed HEAD. pin is left untouched until the human OK.
  local tmp; tmp="$(mktemp)"
  jq --arg sha "$head" '.pendingSha = $sha' "$manifest" > "$tmp" && mv "$tmp" "$manifest"

  echo "===================================================================="
  echo " UPSTREAM DRIFT CHECK — $UPSTREAM_REPO"
  echo "===================================================================="
  if [ -z "$pin" ]; then
    echo " baseline: pin is EMPTY — first run. No main diff to review;"
    echo " HEAD captured to pendingSha as the initial baseline."
  else
    echo " pin present (last reviewed main). HEAD captured to pendingSha."
  fi
  [ "$merged_only" = 1 ] && echo " mode: --merged-only (skipping open-PR sections)"
  echo " (SHAs are script-managed; do not copy or pass them.)"
  echo

  # full main tree (cached once; reused for the universe + PR classification)
  local tree; tree="$(mktemp)"
  gh api "repos/$UPSTREAM_REPO/git/trees/main?recursive=1" --jq '.tree[].path' > "$tree"

  # ---- universe: every SKILL.md currently in main (name<->path map) -------
  echo "===== SKILL UNIVERSE (main) ====="
  echo "(maps a referenced skill name to its path so you can recurse with:"
  echo "  ./scripts/upstream.sh body <path>)"
  grep 'SKILL\.md$' "$tree" || true
  echo

  echo "####################################################################"
  echo "# AUDIT 1 — MAIN (released state). Closure resolves WITHIN main only."
  echo "####################################################################"
  echo

  # ---- section 1a: tracked skills that changed in main since the pin ------
  echo "===== [1a] CHANGED IN MAIN SINCE PIN (tracked skills) ====="
  if [ -z "$pin" ]; then
    echo "(baseline run — nothing to compare against)"
  else
    local compare; compare="$(mktemp)"
    gh api "repos/$UPSTREAM_REPO/compare/$pin...$head" > "$compare" 2>/dev/null \
      || { echo "(compare failed — pin may be unreachable on main)"; compare=""; }
    if [ -n "$compare" ]; then
      local any=0
      while IFS=$'\t' read -r name path; do
        if jq -e --arg p "$path" '.files[]? | select(.filename == $p)' "$compare" >/dev/null 2>&1; then
          any=1
          echo "--- $name ($path) ---"
          jq -r --arg p "$path" '.files[] | select(.filename == $p) | .patch // "(no textual patch)"' "$compare"
          echo
        fi
      done < <(jq -r '.skills[] | "\(.name)\t\(.path)"' "$manifest")
      [ "$any" = 0 ] && echo "(no manifest skill changed in main since the pin)"
    fi
  fi
  echo

  # ---- section 1b material: bodies of every manifest skill (at main HEAD) -
  echo "===== [1b] MANIFEST SKILL BODIES (main) — main-only dependency closure ====="
  echo "(read each body; any skill it invokes/depends-on or merely names enters the"
  echo " frontier. Recurse with ./scripts/upstream.sh body <path>. All referenced"
  echo " skills must exist on main — a missing one is a real broken/incomplete dep.)"
  while IFS=$'\t' read -r name path; do
    echo
    echo "######## $name — $path ########"
    raw_body "$path" main
  done < <(jq -r '.skills[] | "\(.name)\t\(.path)"' "$manifest")
  echo

  # ---- AUDIT 2: open PRs on the horizon -----------------------------------
  echo "####################################################################"
  echo "# AUDIT 2 — OPEN PRS (the horizon). Each PR's closure resolves"
  echo "# within that PR's own tree (main + the PR). Inform only; never pin."
  echo "####################################################################"
  echo
  echo "===== [2] ON THE HORIZON (open PRs) ====="
  if [ "$merged_only" = 1 ]; then
    echo "(skipped — --merged-only)"
  else
  local prs; prs="$(mktemp)"
  gh pr list --repo "$UPSTREAM_REPO" --state open \
    --json number,title,headRefName,headRefOid > "$prs"
  local count; count="$(jq 'length' "$prs")"
  if [ "$count" = 0 ]; then
    echo "(no open PRs)"
  else
    while IFS=$'\t' read -r num title branch oid; do
      # SKILL.md files this PR touches
      local files
      files="$(gh pr view "$num" --repo "$UPSTREAM_REPO" --json files \
        --jq '.files[].path | select(endswith("SKILL.md"))' 2>/dev/null || true)"
      [ -z "$files" ] && continue
      echo "--- PR #$num: $title  [branch: $branch] ---"
      while IFS= read -r f; do
        [ -z "$f" ] && continue
        if is_manifest_path "$f"; then
          echo "  [touches a tracked skill]  $f"
        elif grep -qxF "$f" "$tree"; then
          echo "  [modifies existing skill]  $f"
        else
          echo "  [NEW skill introduced]     $f"
        fi
      done <<< "$files"
      # dump bodies of the relevant ones (manifest skills + brand-new skills)
      while IFS= read -r f; do
        [ -z "$f" ] && continue
        local in_main=1
        grep -qxF "$f" "$tree" || in_main=0
        if is_manifest_path "$f" || [ "$in_main" = 0 ]; then
          echo
          echo "######## PR #$num body — $f ########"
          raw_body "$f" "$oid"
        fi
      done <<< "$files"
      echo
    done < <(jq -r '.[] | "\(.number)\t\(.title)\t\(.headRefName)\t\(.headRefOid)"' "$prs")
  fi
  fi
  echo

  echo "===== PIN ADVANCE (main only) ====="
  echo "After the human OK, run: ./scripts/upstream.sh pin"
  echo "(promotes the staged pendingSha to pin; advances only for AUDIT 1 / main)"
}

main() {
  local sub="${1:-}"
  case "$sub" in
    fetch) shift; cmd_fetch "$@" ;;
    body)  shift; cmd_body "$@" ;;
    pin)   shift; cmd_pin "$@" ;;
    ""|-h|--help)
      echo "usage: upstream.sh {fetch [--merged-only] | body <path> [ref] | pin}" ;;
    *) die "unknown subcommand: $sub" ;;
  esac
}

main "$@"
