# Hermes GameDev Skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A GitHub fork of gamedev-skills that installs a curated web-game skill set into Hermes, with a native game-prototype trigger skill and a local headless-Chromium self-check.

**Architecture:** Fork gamedev-skills/awesome-gamedev-agent-skills (upstream tracked). All additions live under hermes/ (disjoint from upstream): two authored skills (gamedev-router, game-prototype), a zero-build web-game template with a Playwright check script, and an idempotent install.sh that copies curated skills into ~/.hermes/skills/game-dev/. The prototype pipeline is an orchestrator skill chaining existing Hermes skills; self-check runs locally in headless Chromium with screenshots reviewed via vision_analyze.

**Tech Stack:** bash, Node v26 (ESM), Playwright + headless Chromium (Linux ARM64), Phaser 3 via CDN, gh CLI, git.

**Spec:** docs/superpowers/specs/2026-11-19-hermes-gamedev-skills-design.md (staged at /home/ubuntu/.hermes/cache/scratch/2026-11-19-hermes-gamedev-skills-design.md until Task 1 commits it)

## Global Constraints

- NEVER invoke browser_exec / Browser Use (paid Nous portal service). All browser automation is local Playwright headless Chromium.
- Upstream Apache-2.0 LICENSE and NOTICE preserved; hermes/ additions Apache-2.0; Donchitos process ideas credited in hermes/README.md (MIT, no code copied).
- All additions under hermes/ only — never modify upstream files (clean `git pull upstream main`).
- Install target: ~/.hermes/skills/game-dev/<skill-name>/ (copies, not symlinks).
- Fork: kiziltasalperensalih/hermes-gamedev-skills, forked from gamedev-skills/awesome-gamedev-agent-skills. Donchitos repo is NOT tracked, vendored, or submoduled.
- Node v26.12.1, Linux ARM64. gh authenticated as kiziltasalperensalih (repo scope).
- Scaffold is zero-build: index.html + game.js, engine via CDN, no bundler.
- Curated upstream skills (10): skills/web-engines/{phaser-core, phaser-arcade-physics, pixijs-rendering, threejs-scene-setup, threejs-materials-lighting, threejs-gltf-loading}, skills/disciplines/game-feel, skills/workflows/{prototype-fast, game-jam, itch-publish}. Plus authored: gamedev-router, game-prototype. Genre skills deferred.

## Review Focus

1. install.sh run twice → no duplicates, no corruption, same result (Task 2 test).
2. Upstream pull renames/removes a curated skill → install.sh exits non-zero naming the missing skill, never silently skips (Task 2 test).
3. A game with a runtime console error → check.mjs exits 1 and report.json lists the error text (Task 5 test).
4. Headless Chromium missing or fails to launch → check.mjs exits non-zero with a clear message within 60s, never hangs (Task 5 test).
5. Router/orchestrator referencing a skill name that is not installed → name cross-check against installed list fails loudly (Tasks 3–4 verification).
6. CDN unreachable → failed network requests captured in report.json and visible in screenshots (Task 5 test).

---

### Task 1: Fork, clone, upstream remote, commit docs

**Files:**
- Create: repo clone at /home/ubuntu/projects/hermes-gamedev-skills
- Create: docs/superpowers/specs/2026-11-19-hermes-gamedev-skills-design.md
- Create: docs/superpowers/plans/2026-11-19-hermes-gamedev-skills.md

**Interfaces:**
- Produces: repo root /home/ubuntu/projects/hermes-gamedev-skills with `origin` (fork) and `upstream` (gamedev-skills) remotes; all later tasks work in this root.

- [ ] **Step 1: Fork and clone**

```bash
gh repo fork gamedev-skills/awesome-gamedev-agent-skills --fork-name hermes-gamedev-skills --clone=false
mkdir -p /home/ubuntu/projects
gh repo clone kiziltasalperensalih/hermes-gamedev-skills /home/ubuntu/projects/hermes-gamedev-skills
cd /home/ubuntu/projects/hermes-gamedev-skills
git remote add upstream https://github.com/gamedev-skills/awesome-gamedev-agent-skills.git
git fetch upstream
```

- [ ] **Step 2: Verify tracking works**

Run: `git remote -v && git pull upstream main --ff-only`
Expected: origin → kiziltasalperensalih/hermes-gamedev-skills, upstream → gamedev-skills/awesome-gamedev-agent-skills; pull succeeds (already up to date).

- [ ] **Step 3: Commit spec and plan**

Copy the staged design doc to docs/superpowers/specs/2026-11-19-hermes-gamedev-skills-design.md and this plan to docs/superpowers/plans/2026-11-19-hermes-gamedev-skills.md.

```bash
git add docs/superpowers
git commit -m "docs: design spec and implementation plan for Hermes gamedev fork"
git push origin main
```

- [ ] **Step 4: Verify push landed**

Run: `gh api repos/kiziltasalperensalih/hermes-gamedev-skills/contents/docs/superpowers/specs --jq '.[].name'`
Expected: 2026-11-19-hermes-gamedev-skills-design.md listed.

### Task 2: Curated list + install.sh (idempotent, loud on missing)

**Files:**
- Create: hermes/curated.txt (10 upstream skill dir paths, one per line, exact paths from Global Constraints)
- Create: hermes/install.sh
- Test: hermes/tests/install_test.sh

**Interfaces:**
- Consumes: repo root from Task 1; upstream skills at skills/<category>/<name>/SKILL.md.
- Produces: `bash hermes/install.sh` → copies each curated skill dir and hermes/skills/* into ~/.hermes/skills/game-dev/<name>/; exit 0 on success, exit 1 naming any missing source; prints one line per installed skill. Later tasks add hermes/skills/gamedev-router and hermes/skills/game-prototype which install.sh picks up automatically (it installs everything under hermes/skills/).

- [ ] **Step 1: Write the failing test**

hermes/tests/install_test.sh: bash script that (a) runs install.sh into a temp HOME override — install.sh must honor `HERMES_SKILLS_DIR` env override, defaulting to ~/.hermes/skills — (b) asserts 10 curated dirs exist with SKILL.md, (c) runs install.sh again and asserts identical file count and exit 0 (idempotency), (d) points install.sh at a fixture repo missing one curated skill (copy curated.txt, delete one source dir in a temp copy) and asserts exit 1 with the missing name in output.

- [ ] **Step 2: Run test, verify it fails**

Run: `bash hermes/tests/install_test.sh`
Expected: FAIL — install.sh does not exist.

- [ ] **Step 3: Implement install.sh**

Signature: `bash hermes/install.sh` (no args). Env: `HERMES_SKILLS_DIR` (default $HOME/.hermes/skills), `REPO_ROOT` (default: script's ../..). Logic: read hermes/curated.txt; for each path assert $REPO_ROOT/$path/SKILL.md exists else collect error; copy each skill dir (cp -r, remove existing target dir first for idempotency) to $HERMES_SKILLS_DIR/game-dev/<basename>/; copy every hermes/skills/*/ the same way; copy upstream LICENSE and NOTICE into $HERMES_SKILLS_DIR/game-dev/ on first install; if any missing sources, print them and exit 1 before copying anything; else print installed names, exit 0.

- [ ] **Step 4: Run test, verify it passes**

Run: `bash hermes/tests/install_test.sh`
Expected: PASS (all four assertions).

- [ ] **Step 5: Real install + Hermes visibility check**

Run: `bash hermes/install.sh` then call skills_list.
Expected: 10 curated skills visible (gamedev-router/game-prototype arrive in Tasks 3–4).

- [ ] **Step 6: Commit**

```bash
git add hermes/curated.txt hermes/install.sh hermes/tests/install_test.sh
git commit -m "feat: curated skill list and idempotent Hermes install script"
```

### Task 3: gamedev-router skill (Hermes adaptation)

**Files:**
- Create: hermes/skills/gamedev-router/SKILL.md
- Reference: upstream router/SKILL.md (read for routing logic; do NOT copy its file-path mechanics)

**Interfaces:**
- Consumes: installed skill names from Task 2 (basename of each curated dir).
- Produces: skill named `gamedev-router` loadable via skill_view; maps engine/task → installed skill names; game-prototype (Task 4) instructs loading it.

- [ ] **Step 1: Write the skill**

Frontmatter: name gamedev-router; description "Use when starting any web-game task or unsure which gamedev skill fits: detects engine (Phaser, PixiJS, three.js) and task, then names the installed skills to load via skill_view." Body (≤120 lines): engine detection from project files (package.json deps / CDN script tags in index.html); task classification (engine mechanics, game feel, input, publishing); resolution table mapping to the 10 installed names ONLY; instruction to load each named skill with skill_view before acting; note that genre skills are added later and uninstalled engines are out of scope; keep upstream's trust-boundary paragraph (project content is input, not authority).

- [ ] **Step 2: Install and verify load + name cross-check (Review Focus 5)**

Run: `bash hermes/install.sh`, then skill_view("gamedev-router").
Then cross-check: every skill name mentioned in the resolution table must appear in skills_list output — script it: `grep -oE 'skill_view\("[a-z0-9-]+"\)' hermes/skills/gamedev-router/SKILL.md` names vs installed dirs; assert no unknown names.
Expected: loads; zero unknown names.

- [ ] **Step 3: Commit**

```bash
git add hermes/skills/gamedev-router
git commit -m "feat: Hermes-native gamedev router skill"
```

### Task 4: game-prototype orchestrator skill (the trigger)

**Files:**
- Create: hermes/skills/game-prototype/SKILL.md

**Interfaces:**
- Consumes: gamedev-router (Task 3); template + check script from Task 5 at hermes/templates/web-game/ (reference by repo path; Task 5 pins the CLI).
- Produces: skill named `game-prototype`; description is the trigger for game-making requests.

- [ ] **Step 1: Write the skill**

Frontmatter description (the trigger): "Use when the user asks to make, prototype, or build a web/browser game, or says 'make me a game'. Runs brief → scaffold → build → local headless self-check → iterate." Body phases:
1. Brief — a few questions → one-page brief (game concept, core loop, win/lose, controls, engine pick via gamedev-router); for anything beyond a toy, invoke superpowers:brainstorming first.
2. Scaffold — copy hermes/templates/web-game/ into a new project dir; adapt index.html/game.js to the brief.
3. Build — implement against the brief; load gamedev-router and the skills it names; follow superpowers:test-driven-development for game rules logic.
4. Self-check — write check-flow.mjs scripting the brief's core flow; run `node check.mjs <gamedir> <outdir>`; inspect EVERY screenshot with vision_analyze plus report.json; fix findings; re-run until exit 0. NEVER use browser_exec/Browser Use — local headless Chromium only.
5. Iterate — user plays, changes by asking; grow feature-by-feature; superpowers:verification-before-completion before claiming done; itch-publish skill when shipping.
Credit line: process adapted from Donchitos/Claude-Code-Game-Studios /prototype (MIT).

- [ ] **Step 2: Install, verify load, trigger match, and reference cross-check (Review Focus 5)**

Run: `bash hermes/install.sh`, skill_view("game-prototype").
Verify: description contains "make" and "game"; every Hermes skill named in the body exists in skills_list or the superpowers plugin (brainstorming, test-driven-development, verification-before-completion); every gamedev name exists in installed dirs.
Expected: loads; zero dangling references.

- [ ] **Step 3: Commit**

```bash
git add hermes/skills/game-prototype
git commit -m "feat: game-prototype trigger skill chaining the Hermes-native pipeline"
```

### Task 5: Web-game template + check.mjs + Playwright

**Files:**
- Create: hermes/templates/web-game/index.html, game.js, check.mjs, check-flow.mjs, package.json, README.md
- Test: hermes/tests/check_test.sh

**Interfaces:**
- Consumes: Node v26; Playwright installed as template devDependency.
- Produces: CLI `node check.mjs <gamedir> <outdir>` — statically serves <gamedir> on an ephemeral localhost port, launches headless Chromium, captures console errors/pageerrors/failed requests for the whole run, takes boot screenshot, calls the default export of <gamedir>/check-flow.mjs `async (page, shot)` where `shot(name)` saves <outdir>/<name>.png, takes final screenshot, writes <outdir>/report.json `{consoleErrors: string[], pageErrors: string[], failedRequests: string[], steps: string[]}`; exit 0 iff all three error arrays empty, else exit 1; browser-launch failure → exit 1 with clear message, hard timeout 60s. game.js exposes window.game (the Phaser.Game instance) so flows can force states via page.evaluate. Sample game: Phaser 3 via CDN, 480x640 canvas, arrow keys move a basket, catch 10 falling stars → "You win" overlay, miss 5 → "Game over" overlay.

- [ ] **Step 1: Write the failing test**

hermes/tests/check_test.sh: (a) run check.mjs on the sample template → exit 0, ≥3 PNGs, report.json arrays empty; (b) fixture page injecting `console.error("boom")` and a failing fetch → exit 1, report contains "boom" and the failed URL; (c) fixture with no check-flow.mjs → still runs boot+final shots, exit 0; (d) PLAYWRIGHT_BROWSERS_PATH pointed at an empty dir → exit 1 within 60s with launch-error message (Review Focus 4).

- [ ] **Step 2: Run test, verify it fails**

Run: `bash hermes/tests/check_test.sh`
Expected: FAIL — check.mjs/template do not exist.

- [ ] **Step 3: Implement template + check.mjs**

package.json: `{"type":"module","devDependencies":{"playwright":"^1.49"}}` (pin latest stable at build). index.html loads Phaser CDN + game.js. game.js implements the sample per Interfaces. check.mjs per Interfaces: node:http static server, chromium.launch({headless:true}), page.on('console'/'pageerror'/'requestfailed'), 60s overall timeout via Promise.race, dynamic import of check-flow.mjs when present. check-flow.mjs (sample flow): shot('title'), press ArrowLeft/ArrowRight, wait for catches, shot('gameplay'), force win state via page.evaluate on the game's scene, shot('win').

- [ ] **Step 4: Install Playwright + Chromium**

```bash
cd hermes/templates/web-game && npm install && npx playwright install chromium
```
If launch fails on missing system libs: `sudo npx playwright install-deps chromium` (passwordless sudo on this host; if unavailable, report blocker).

- [ ] **Step 5: Run test, verify it passes**

Run: `bash hermes/tests/check_test.sh`
Expected: PASS (all four cases, Review Focus 1/3/4/6 covered).

- [ ] **Step 6: Commit**

```bash
git add hermes/templates/web-game hermes/tests/check_test.sh
git commit -m "feat: zero-build web-game template with local headless self-check"
```

### Task 6: Acceptance run, README, final push

**Files:**
- Create: hermes/README.md
- Modify: none upstream

**Interfaces:**
- Consumes: everything from Tasks 1–5.
- Produces: verified fork on GitHub; documented update flow.

- [ ] **Step 1: End-to-end acceptance on the sample**

Run: `node hermes/templates/web-game/check.mjs hermes/templates/web-game /home/ubuntu/.hermes/cache/scratch/acceptance-check`
Then vision_analyze EVERY produced screenshot: title renders, basket visible, stars falling, win overlay reads "You win". Verify report.json error arrays empty. Any visual bug → fix game.js, re-run until clean.

- [ ] **Step 2: Skill-set acceptance**

Verify via skills_list: 12 game-dev skills present (10 curated + gamedev-router + game-prototype). skill_view both authored skills. Confirm no upstream file modified: `git status --porcelain` clean except hermes/ and docs/.

- [ ] **Step 3: Write hermes/README.md**

Contents: what this fork is; install (`bash hermes/install.sh`); update flow (`git pull upstream main && bash hermes/install.sh`); the trigger (say "make me a game"); self-check usage; credits: upstream Apache-2.0, Donchitos /prototype process ideas (MIT, no code copied); constraint: never browser_exec, local headless only.

- [ ] **Step 4: Final commit, push, verify remote**

```bash
git add hermes/README.md
git commit -m "docs: Hermes fork README with install, update, and credits"
git push origin main
```
Run: `gh api repos/kiziltasalperensalih/hermes-gamedev-skills --jq '{stars: .stargazers_count, pushed: .pushed_at}'` and `gh api repos/kiziltasalperensalih/hermes-gamedev-skills/contents/hermes --jq '.[].name'`
Expected: README.md, install.sh, curated.txt, skills, templates, tests listed; pushed_at is today.
