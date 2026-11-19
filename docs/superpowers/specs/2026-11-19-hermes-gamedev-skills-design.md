# Hermes GameDev Skills — Short Design

Date: 2026-11-19
Status: awaiting approval
Repo (proposed): kiziltasalperensalih/hermes-gamedev-skills (fork of gamedev-skills/awesome-gamedev-agent-skills)

## Intent and why

User wants to make web games in Hermes. One fork repo should carry the
game-dev craft knowledge (gamedev-skills) plus the "idea → playable
browser game" pipeline functionality popularized by Donchitos's
/prototype — implemented Hermes-natively, tracking only gamedev-skills
upstream. Donchitos is not tracked; its process is borrowed as ideas,
credited in the README.

## Goals

- Fork gamedev-skills as base; upstream updates via `git pull upstream main`.
- Curated install (~11 skills) into ~/.hermes/skills/game-dev/ via an
  idempotent install.sh, re-runnable after upstream pulls.
- `game-prototype` orchestrator skill: its description is the trigger
  (fires on "make/prototype/build a web game"); its body chains the
  pipeline: brief → scaffold → build → self-check → iterate.
- Self-check fully local: Playwright + headless Chromium drives the
  game's core flow with scripted inputs, captures console/page errors,
  saves a screenshot series; agent inspects every screenshot with
  vision_analyze against the brief, fixes findings, re-runs.
- Zero-build scaffold template (index.html + game.js, Phaser or p5.js
  via CDN) with check.mjs included so every game inherits the check.
- Router adapted to Hermes: loads skills by name via skill_view instead
  of upstream's file-path reads; installed instead of upstream's router.

## Non-goals

- No Donchitos tracking, vendoring, agents, hooks, or studio machinery.
- No Claude Code compatibility layer.
- Not installing all 79 upstream skills (context cost); genre skills
  deferred until a game is chosen.
- No Vite/TS build pipeline yet (add later if a game outgrows the CDN
  scaffold). No paid/cloud browser services.

## Anti-goals (failure even if it technically works)

- Invoking browser_exec / Browser Use (paid Nous portal service) — forbidden.
- Skill-index bloat from irrelevant engines (Unity/Unreal/Roblox...).
- Our additions overlapping upstream paths, causing merge conflicts on pull.

## Constraints

- Hermes skills dir: /home/ubuntu/.hermes/skills/; SKILL.md format native.
- gh authenticated as kiziltasalperensalih (repo scope); fork under this account.
- Node v26 present; no Chromium/Playwright yet → install locally as repo
  dev dependencies (Linux ARM64).
- Licenses: upstream Apache-2.0 preserved with LICENSE/NOTICE; our
  additions Apache-2.0; Donchitos ideas credited (MIT; no code copied).

## Approaches considered

A. Donchitos base + gamedev-skills vendored via git subtree.
   Pipeline intact for Claude Code; but user is Hermes-only, so the
   49-agent studio machinery is dead weight and the pipeline needs
   re-wiring anyway. Rejected.
B. gamedev-skills base + port of Donchitos /prototype skill and scaffold.
   Portable base, but /prototype is path-sensitive Claude Code wiring;
   porting duplicates what Hermes skills already do. Rejected.
C. CHOSEN — gamedev-skills base + Hermes-native orchestrator skill that
   re-implements the prototype process by chaining existing Hermes
   skills (brainstorming, writing-plans, spike/p5js, TDD,
   verification-before-completion, dogfood). No Claude Code code, one
   upstream, trigger via skill description.
Also dropped: git submodules (no real merge; skills not auto-discovered).

## Decided by the user

- Hermes-only usage.
- Do not track Donchitos.
- Pipeline functionality must live in this repo as a trigger-like native skill.
- Self-check = local headless Chromium + screenshot series + visual
  inspection; never the paid browser service.

## Builder calls (mine, correctable)

- Scaffold: zero-build CDN template; Vite path later if needed.
- Curated list: phaser-core, phaser-arcade-physics, pixijs-rendering,
  threejs-scene-setup, threejs-materials-lighting, threejs-gltf-loading,
  game-feel, prototyping/game-jam workflow skills (exact names verified
  from upstream tree at build time), itch-publish, plus game-prototype
  and the adapted router.
- install.sh copies (not symlinks) into ~/.hermes/skills/game-dev/.
- All additions under hermes/ (disjoint from upstream): skills/,
  templates/web-game/, install.sh, README.md.
- Playwright + headless Chromium as repo dev dependencies; check.mjs
  ships inside templates/web-game/.

## Left to the builder

- Exact upstream workflow skill names/paths; router name-mapping details.
- check.mjs scripted-input API and screenshot step list.
- Fork repo name (proposal: hermes-gamedev-skills).

## Acceptance / verification

- Fork exists under kiziltasalperensalih with upstream remote; pull works.
- install.sh installs the curated set; skills appear in skills_list.
- game-prototype loads via skill_view; description matches game requests.
- Template + check.mjs exercised end-to-end on a sample mini-game:
  headless Chromium produces screenshots + console log; screenshots
  reviewed with vision_analyze; findings fixed and re-checked.
- No browser_exec invocation anywhere in the flow.
