---
name: game-prototype
description: Use when the user asks to make, prototype, or build a web/browser game, or says 'make me a game'. Runs brief → scaffold → build → local headless self-check → iterate.
---

# Game Prototype — the Hermes web-game pipeline

Turn a game idea into a playable, self-checked browser game. This skill
is the trigger and the orchestrator: it chains Hermes-native skills in
order and keeps the loop honest. Process adapted from
Donchitos/Claude-Code-Game-Studios /prototype (MIT) — ideas only, no code.

HARD RULE: never invoke browser_exec / Browser Use (paid cloud service).
All browser automation is local headless Chromium via check.mjs below.

Template location: hermes/templates/web-game/ inside the
hermes-gamedev-skills fork (this machine:
/home/ubuntu/projects/hermes-gamedev-skills).

## Phase 1 — Brief

Ask a few questions, then write a one-page brief: game concept, core
loop, win/lose conditions, controls, engine pick (load
skill_view("gamedev-router") to decide). For anything beyond a toy,
invoke superpowers:brainstorming first and let its design gate stand.
The brief is the contract the self-check verifies against.

## Phase 2 — Scaffold

Copy hermes/templates/web-game/ into a new project directory, excluding
node_modules/ and check-out/ (local artifacts, not template files).
Adapt index.html and game.js to the brief. Zero build step: engine via
CDN, plain files, open index.html and it runs.

## Phase 3 — Build

Implement against the brief. Load skill_view("gamedev-router") and the
skills it names before writing engine code. Follow
superpowers:test-driven-development for game-rules logic (scoring,
win/lose, spawn rules): failing test first, then minimal code. Keep the
game exposing window.game so checks can force states.

## Phase 4 — Self-check (local, headless, repeatable)

Prerequisite (once per game dir): run `npm install` in the game dir, and
`npx playwright install chromium` if Chromium is not present — check.mjs
imports playwright from the game dir's node_modules.

1. Write check-flow.mjs in the game dir: default export
   `async (page, shot) => { ... }` scripting the brief's core flow with
   real inputs; `await shot("name")` captures a screenshot at each step.
2. Run: `node check.mjs <gamedir> <outdir>` (check.mjs ships in the
   template). It serves the game locally, drives headless Chromium,
   captures console errors, page errors and failed requests, and writes
   <outdir>/report.json plus the screenshot series.
3. Inspect EVERY screenshot with vision_analyze against the brief, and
   read report.json. A clean exit code is not a pass — look at the game.
4. Fix every finding, re-run until exit 0 AND the screenshots show the
   brief's flow working.

## Phase 5 — Iterate

Hand it to the user to play. Changes happen by asking: each change goes
through the same self-check before it is called done. Grow the game
feature-by-feature; load skill_view("itch-publish") when shipping.
Apply superpowers:verification-before-completion before claiming any
state is finished.
