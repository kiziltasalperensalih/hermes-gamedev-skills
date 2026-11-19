#!/usr/bin/env bash
# install_test.sh — proves install.sh: fresh install, 10 curated skills,
# idempotency, and loud exit 1 naming a missing curated source.
set -u
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
INSTALL="$REPO_ROOT/hermes/install.sh"
fail() { echo "FAIL: $1"; exit 1; }

[ -f "$INSTALL" ] || fail "install.sh does not exist"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# (a)+(b) fresh install into an override dir; all 10 curated skills present
OUT="$TMP/skills"
HERMES_SKILLS_DIR="$OUT" REPO_ROOT="$REPO_ROOT" bash "$INSTALL" >"$TMP/log1" 2>&1 \
  || fail "first install exited non-zero: $(cat "$TMP/log1")"
count=0
while IFS= read -r p; do
  [ -n "$p" ] || continue
  name=$(basename "$p")
  [ -f "$OUT/game-dev/$name/SKILL.md" ] || fail "missing installed skill: $name"
  count=$((count+1))
done < "$REPO_ROOT/hermes/curated.txt"
[ "$count" -eq 10 ] || fail "expected 10 curated entries, got $count"

# (c) idempotency: second run exits 0, identical file count
n1=$(find "$OUT" -type f | wc -l)
HERMES_SKILLS_DIR="$OUT" REPO_ROOT="$REPO_ROOT" bash "$INSTALL" >"$TMP/log2" 2>&1 \
  || fail "second install exited non-zero: $(cat "$TMP/log2")"
n2=$(find "$OUT" -type f | wc -l)
[ "$n1" -eq "$n2" ] || fail "file count changed on re-run: $n1 -> $n2"

# (d) fixture repo missing the second curated skill -> exit 1 naming it
FIX="$TMP/fixture"
mkdir -p "$FIX/hermes"
cp "$REPO_ROOT/hermes/curated.txt" "$FIX/hermes/curated.txt"
first=$(sed -n 1p "$REPO_ROOT/hermes/curated.txt")
second=$(sed -n 2p "$REPO_ROOT/hermes/curated.txt")
mkdir -p "$FIX/$(dirname "$first")"
cp -r "$REPO_ROOT/$first" "$FIX/$first"
HERMES_SKILLS_DIR="$TMP/skills2" REPO_ROOT="$FIX" bash "$INSTALL" >"$TMP/log3" 2>&1
rc=$?
[ "$rc" -eq 1 ] || fail "missing-source install expected exit 1, got $rc"
grep -q "$(basename "$second")" "$TMP/log3" || fail "missing skill name not named in output"
[ ! -d "$TMP/skills2/game-dev" ] || fail "copied skills despite missing source (must fail before copying)"

echo "PASS: install_test (fresh install, 10 skills, idempotency, missing-source exit 1)"
