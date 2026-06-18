#!/usr/bin/env bash
# Reaplica mi único delta de preferencia sobre las skills de Matt instaladas
# verbatim: voltear "disable-model-invocation" de true a false en las skills que
# invoco conversacionalmente, para poder llamarlas a mitad de prompt, encadenadas
# o referenciadas desde un handoff. La lista vive en upstream/matt-skills.json
# (campo allowModelInvocation). Idempotente: solo voltea true -> false, nunca
# añade la línea si está ausente (ausencia ya significa invocable).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${MATT_SKILLS_MANIFEST:-$REPO_ROOT/upstream/matt-skills.json}"
SKILLS_DIR="${MATT_SKILLS_DIR:-$HOME/.agents/skills}"

FLAG="disable-model-invocation"

while IFS= read -r name; do
  [ -z "$name" ] && continue
  skill_md="$SKILLS_DIR/$name/SKILL.md"

  if [ ! -f "$skill_md" ]; then
    echo "warning: $name no instalada — no existe $skill_md" >&2
    continue
  fi

  if ! grep -qE "^$FLAG:" "$skill_md"; then
    echo "warning: $name sin flag $FLAG — ya es invocable, nada que voltear" >&2
    continue
  fi

  if grep -qE "^$FLAG:[[:space:]]*false" "$skill_md"; then
    echo "warning: $name ya tiene $FLAG: false — intacta" >&2
    continue
  fi

  tmp="$(mktemp)"
  sed "s/^\($FLAG:[[:space:]]*\)true/\1false/" "$skill_md" > "$tmp"

  if cmp -s "$skill_md" "$tmp"; then
    rm -f "$tmp"
    echo "warning: $name tiene $FLAG con un valor distinto de 'true' literal — sin tocar" >&2
    continue
  fi

  mv "$tmp" "$skill_md"
  echo "patched $name: $FLAG true -> false"
done < <(jq -r '.skills[] | select(.allowModelInvocation == true) | .name' "$MANIFEST")
