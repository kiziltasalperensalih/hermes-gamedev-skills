# hermes-gamedev-skills — Hermes additions

This fork of [gamedev-skills/awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills)
adds a Hermes-native web-game pipeline on top of the upstream skill
library. Upstream files are never modified; everything here lives under
hermes/ so `git pull upstream main` stays clean.

## What's inside

- skills/game-prototype — the trigger skill. Say "make me a game" and it
  runs: brief → scaffold → build → local headless self-check → iterate,
  chaining Hermes-native skills (superpowers brainstorming / TDD /
  verification, gamedev-router, itch-publish).
- skills/gamedev-router — upstream router adapted to Hermes: loads
  skills by name via skill_view, scoped to the installed web engines
  (Phaser, PixiJS, three.js).
- templates/web-game — zero-build game starter (Phaser 3 via CDN) with
  check.mjs: a local headless-Chromium self-check that scripts the core
  flow, captures console/page errors and failed requests, and saves a
  screenshot series + report.json for visual review.
- install.sh + curated.txt — idempotent installer for the curated skill
  set; fails loudly if upstream ever renames a curated skill.
- tests/ — install_test.sh and check_test.sh prove the above.

## Install

    bash hermes/install.sh

Copies the 10 curated upstream skills plus the 2 authored skills into
~/.hermes/skills/game-dev/ (override with HERMES_SKILLS_DIR). Preserves
upstream LICENSE and NOTICE alongside them.

## Update from upstream

    git pull upstream main
    bash hermes/install.sh

If install.sh exits 1 naming a missing skill, upstream renamed or
removed it — update hermes/curated.txt deliberately, don't ignore it.

## Self-check a game

    cd hermes/templates/web-game
    npm install && npx playwright install chromium   # once
    node check.mjs . ./check-out

Exit 0 means no captured errors — still inspect every screenshot before
calling the game good. HARD RULE: never use browser_exec / Browser Use
(paid cloud service); all browser automation is local headless Chromium.

## Credits

- Upstream skills: gamedev-skills/awesome-gamedev-agent-skills,
  Apache-2.0 (LICENSE and NOTICE preserved).
- Prototype pipeline process adapted from
  Donchitos/Claude-Code-Game-Studios /prototype (MIT) — ideas only, no
  code copied; that repo is not tracked here.
- Hermes additions in this directory: Apache-2.0.
