#!/usr/bin/env bash
# install.sh — copy curated upstream skills + hermes/skills/* into the
# Hermes skills directory. Idempotent; fails loudly (exit 1, names the
# missing sources) BEFORE copying anything if a curated source is gone.
# Env: HERMES_SKILLS_DIR (default $HOME/.hermes/skills), REPO_ROOT
# (default: this script's repo root).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
DEST="${HERMES_SKILLS_DIR:-$HOME/.hermes/skills}/game-dev"
CURATED="$REPO_ROOT/hermes/curated.txt"

[ -f "$CURATED" ] || { echo "ERROR: $CURATED not found"; exit 1; }

# Validate every curated source first; copy nothing if any is missing.
missing=()
while IFS= read -r p; do
  [ -n "$p" ] || continue
  if [ ! -f "$REPO_ROOT/$p/SKILL.md" ]; then
    missing+=("$p")
  fi
done < "$CURATED"
if [ "${#missing[@]}" -gt 0 ]; then
  echo "ERROR: missing curated skill sources (upstream renamed or removed?):"
  printf '  %s\n' "${missing[@]}"
  exit 1
fi

mkdir -p "$DEST"

install_dir() {
  local src="$1" name
  name="$(basename "$src")"
  rm -rf "$DEST/$name"
  cp -r "$src" "$DEST/$name"
  echo "installed: $name"
}

while IFS= read -r p; do
  [ -n "$p" ] || continue
  install_dir "$REPO_ROOT/$p"
done < "$CURATED"

if [ -d "$REPO_ROOT/hermes/skills" ]; then
  for d in "$REPO_ROOT"/hermes/skills/*/; do
    if [ -d "$d" ]; then
      install_dir "${d%/}"
    fi
  done
fi

# Preserve upstream Apache-2.0 attribution alongside the installed skills.
for f in LICENSE NOTICE; do
  if [ -f "$REPO_ROOT/$f" ]; then
    cp "$REPO_ROOT/$f" "$DEST/$f"
  fi
done

exit 0
