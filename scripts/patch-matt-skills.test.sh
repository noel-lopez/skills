#!/usr/bin/env bash
# Test autocontenido de patch-matt-skills.sh: monta un directorio de skills de
# mentira y un manifest propio, corre el script y comprueba el resultado en disco
# y en stderr. Sin framework: bash + asserts simples.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH="$SCRIPT_DIR/patch-matt-skills.sh"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

skills="$tmp/skills"
mkdir -p "$skills/flip-me" "$skills/already-false" "$skills/no-flag" "$skills/weird-value"

cat > "$skills/flip-me/SKILL.md" <<'EOF'
---
name: flip-me
disable-model-invocation: true
description: voltéame
---
cuerpo
EOF

cat > "$skills/already-false/SKILL.md" <<'EOF'
---
name: already-false
disable-model-invocation: false
description: ya en false
---
cuerpo
EOF

cat > "$skills/no-flag/SKILL.md" <<'EOF'
---
name: no-flag
description: sin flag
---
cuerpo
EOF

cat > "$skills/weird-value/SKILL.md" <<'EOF'
---
name: weird-value
disable-model-invocation: True
description: valor no-true-literal
---
cuerpo
EOF

manifest="$tmp/manifest.json"
cat > "$manifest" <<'EOF'
{
  "skills": [
    { "name": "flip-me", "allowModelInvocation": true },
    { "name": "already-false", "allowModelInvocation": true },
    { "name": "no-flag", "allowModelInvocation": true },
    { "name": "weird-value", "allowModelInvocation": true },
    { "name": "not-installed", "allowModelInvocation": true },
    { "name": "untouched", "allowModelInvocation": false }
  ]
}
EOF

run() {
  MATT_SKILLS_MANIFEST="$manifest" MATT_SKILLS_DIR="$skills" \
    bash "$PATCH" >"$tmp/out" 2>"$tmp/err"
}

fails=0
check() {
  if eval "$2"; then
    echo "ok   - $1"
  else
    echo "FAIL - $1"
    fails=$((fails + 1))
  fi
}

run

check "flip-me queda en false" \
  'grep -qE "^disable-model-invocation:[[:space:]]*false$" "$skills/flip-me/SKILL.md"'
check "flip-me reporta éxito en stdout" \
  'grep -q "patched flip-me" "$tmp/out"'

check "already-false intacta" \
  'grep -qE "^disable-model-invocation:[[:space:]]*false$" "$skills/already-false/SKILL.md"'
check "already-false avisa de flag ya en false" \
  'grep -q "already-false ya tiene" "$tmp/err"'

check "no-flag sigue sin flag" \
  '! grep -qE "^disable-model-invocation:" "$skills/no-flag/SKILL.md"'
check "no-flag avisa de flag ausente" \
  'grep -q "no-flag sin flag" "$tmp/err"'

check "weird-value no se toca (valor no-true-literal)" \
  'grep -qE "^disable-model-invocation:[[:space:]]*True$" "$skills/weird-value/SKILL.md"'
check "weird-value avisa en vez de reportar patched" \
  'grep -q "weird-value tiene" "$tmp/err" && ! grep -q "patched weird-value" "$tmp/out"'

check "not-installed avisa de skill no instalada" \
  'grep -q "not-installed no instalada" "$tmp/err"'

check "untouched (sin allowModelInvocation) se ignora" \
  '! grep -q "untouched" "$tmp/err" && ! grep -q "untouched" "$tmp/out"'

before="$(cat "$skills/flip-me/SKILL.md")"
run
after="$(cat "$skills/flip-me/SKILL.md")"
check "idempotente: segunda corrida no cambia flip-me" \
  '[ "$before" = "$after" ]'
check "idempotente: segunda corrida avisa de flip-me ya en false" \
  'grep -q "flip-me ya tiene" "$tmp/err"'

echo
if [ "$fails" -eq 0 ]; then
  echo "todos los tests pasan"
else
  echo "$fails test(s) fallan"
  exit 1
fi
