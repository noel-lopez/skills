#!/usr/bin/env bash
# Adapted from github.com/mattpocock/skills — MIT © 2026 Matt Pocock
#
# Symlinks every skill under this repo's skills/ into ~/.claude/skills/ so edits
# in the repo are live. Idempotent: re-running refreshes the links. A real
# directory colliding with a target is removed first, then replaced by a symlink.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
TARGET_DIR="$HOME/.claude/skills"

# Guard: refuse to run if ~/.claude/skills is itself a symlink (e.g. pointing
# back at this repo) — linking into it would corrupt the source tree.
if [ -L "$TARGET_DIR" ]; then
  echo "Refusing to run: $TARGET_DIR is a symlink, not a real directory." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

for skill_md in "$SKILLS_SRC"/*/SKILL.md; do
  skill_dir="$(dirname "$skill_md")"
  name="$(basename "$skill_dir")"
  rm -rf "$TARGET_DIR/$name"
  ln -sfn "$skill_dir" "$TARGET_DIR/$name"
  echo "linked $name -> $skill_dir"
done
