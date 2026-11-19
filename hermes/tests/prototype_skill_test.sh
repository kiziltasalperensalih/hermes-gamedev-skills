#!/usr/bin/env bash
# prototype_skill_test.sh — the orchestrator's scaffold→self-check path
# must work on first use: template copy excludes node_modules/check-out,
# and the self-check phase states the npm install prerequisite.
set -u
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
F="$REPO_ROOT/hermes/skills/game-prototype/SKILL.md"
fail() { echo "FAIL: $1"; exit 1; }

[ -f "$F" ] || fail "game-prototype SKILL.md missing"
grep -qi 'node_modules' "$F" || fail "Phase 2 must exclude node_modules when copying the template"
grep -qi 'check-out' "$F" || fail "Phase 2 must exclude check-out when copying the template"
grep -qi 'npm install' "$F" || fail "Phase 4 must state the npm install prerequisite in the game dir"
echo "PASS: prototype_skill_test (scaffold exclusions + npm install prerequisite)"
