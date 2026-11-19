# hermes-gamedev-skills

This is a fork of [gamedev-skills/awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills) for use with [Hermes Agent](https://hermes-agent.nousresearch.com) (Nous Research). The upstream skill library is kept intact — the root `README.md` and all upstream files stay untouched so `git pull upstream main` remains clean. Everything this fork adds lives here under `hermes/`: a curated installer, a Hermes-native router, a `game-prototype` trigger skill that runs the whole idea-to-playable pipeline, and a zero-build web-game template with a local headless-Chromium self-check. Say **"make me a game"** in Hermes and the pipeline takes it from there.

- **Upstream:** 79 game-dev skills for 12 engines, written from official engine docs and pinned to current releases, plus the original master router.
- **This fork:** installs a curated web-game set (12 skills) into Hermes, adds the prototype pipeline as a native skill, and checks every game locally — screenshots plus console-error capture, never a cloud browser.

## Contents

- [Quick start (Hermes)](#quick-start-hermes)
- [What you can ask](#what-you-can-ask)
- [The prototype pipeline](#the-prototype-pipeline)
- [Self-check: local headless Chromium](#self-check-local-headless-chromium)
- [How the router picks skills](#how-the-router-picks-skills)
- [Catalog](#catalog)
- [Repository layout](#repository-layout)
- [Syncing with upstream](#syncing-with-upstream)
- [Credits and license](#credits-and-license)

## Quick start (Hermes)

From the repo root:

```bash
bash hermes/install.sh
```

`install.sh` copies the 10 curated upstream skills plus the 2 authored skills into `~/.hermes/skills/game-dev/` (override with `HERMES_SKILLS_DIR`), preserving upstream `LICENSE` and `NOTICE`. It is idempotent, and it fails loudly — naming the missing skill — if upstream ever renames a curated source.

Update from upstream:

```bash
git pull upstream main
bash hermes/install.sh
```

The one-time self-check setup (Playwright + headless Chromium):

```bash
cd hermes/templates/web-game
npm install && npx playwright install chromium
```

Then just talk to Hermes: **"make me a game"**, "prototype a browser game", "publish my game on itch".

## What you can ask

Describe the task in plain language; the trigger skill and router load the right skills:

| You say | What loads / runs |
|---------|-------------------|
| "make me a game" | `game-prototype` — the full pipeline: brief → scaffold → build → self-check → iterate |
| "which gamedev skill fits this?" | `gamedev-router` — detects engine and task, names the minimal skill set |
| "set up my Phaser game" / "black screen in Phaser" | `phaser-core` |
| "add movement and collision" | `phaser-core` + `phaser-arcade-physics` |
| "render sprites with PixiJS" | `pixijs-rendering` |
| "set up a three.js scene" / "load a GLB model" | `threejs-scene-setup` (+ `threejs-gltf-loading`) |
| "make the hits feel punchy" | `game-feel` |
| "just get something playable" | `prototype-fast` |
| "ship my jam entry by Sunday" | `game-jam` |
| "publish my game on itch" | `itch-publish` |

You never type the skill names on the right — that's the router's job.

## The prototype pipeline

`game-prototype` is the trigger skill. Its description fires on game-making requests, and its body chains Hermes-native skills in order:

1. **Brief** — a few questions → a one-page brief (concept, core loop, win/lose, controls, engine). For anything beyond a toy, `superpowers:brainstorming` runs first.
2. **Scaffold** — copy `hermes/templates/web-game/` (excluding `node_modules/` and `check-out/`) into a new project dir; adapt to the brief.
3. **Build** — implement against the brief with the skills the router names; TDD for game-rules logic.
4. **Self-check** — script the core flow in `check-flow.mjs`, run it in local headless Chromium, inspect every screenshot and the error report, fix findings, re-run until clean.
5. **Iterate** — you play, changes happen by asking, each change re-checked; `itch-publish` when shipping.

Process adapted from [Donchitos/Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) `/prototype` (MIT) — ideas only, no code copied; that repo is not tracked here.

## Self-check: local headless Chromium

```bash
node hermes/templates/web-game/check.mjs <gamedir> <outdir>
```

`check.mjs` serves the game on localhost, drives headless Chromium through `check-flow.mjs` (default export `async (page, shot)`), captures console errors, page errors and failed requests, and writes `<outdir>/report.json` plus a screenshot series (boot, flow steps, final). Exit 0 means no captured problems — still look at every screenshot before calling the game good.

**Hard rule: never `browser_exec` / Browser Use (paid cloud service). All browser automation is local headless Chromium.**

## How the router picks skills

You never name a skill. On each request the router:

1. **Detects the engine** from project files — `package.json` deps or CDN script tags for the web engines (Phaser, PixiJS, three.js). If it can't tell, it asks once.
2. **Reads the request** for the task — engine mechanics, game feel, prototyping, jam deadline, publishing.
3. **Loads only the matching skills** via `skill_view`, engine basics first, then the concern. It re-routes when the task pivots.

This fork installs [`skills/gamedev-router`](skills/gamedev-router/SKILL.md) — the Hermes adaptation, scoped to the installed web engines and loading skills by name. The original cross-engine [`router/`](../router/SKILL.md) ships unchanged for use with other agents.

## Catalog

79 upstream skills across 9 categories, plus 2 Hermes additions. Each links to its `SKILL.md`; the **Say** column is an example invoker phrase. ✓ marks the 12 skills `hermes/install.sh` installs into Hermes; the rest ship in this repo and can be added to [`curated.txt`](curated.txt) to install them too.

### Hermes additions — 2 ([`skills/`](skills/))

| Skill | Scope | Say |
|-------|-------|-----|
| ✓ [`game-prototype`](skills/game-prototype/SKILL.md) | The trigger + orchestrator: brief → scaffold → build → local headless self-check → iterate, chaining Hermes-native skills | "make me a game" |
| ✓ [`gamedev-router`](skills/gamedev-router/SKILL.md) | Hermes-native router: detects web engine and task, loads the minimal installed skill set via skill_view | "which gamedev skill fits this?" |

### Engines

#### Godot — 16 ([`skills/godot/`](../skills/godot/)) · Godot 4.7

| Skill | Scope | Say |
|-------|-------|-----|
| [`godot-gdscript`](../skills/godot/godot-gdscript/SKILL.md) | GDScript 2.0: static typing, `@export`/`@onready`, `await`, porting 3.x code | "write GDScript" / "port my Godot 3 code" |
| [`godot-nodes-scenes`](../skills/godot/godot-nodes-scenes/SKILL.md) | Scene tree, instancing, autoloads, checker for broken `res://` paths and uids | "set up scenes and autoloads" |
| [`godot-signals-groups`](../skills/godot/godot-signals-groups/SKILL.md) | Typed signals, `connect()` with Callables, event buses, groups | "wire signals between nodes" |
| [`godot-2d-movement`](../skills/godot/godot-2d-movement/SKILL.md) | `CharacterBody2D` platformer and top-down movement, slopes, one-way platforms, headless landing test | "add player movement" |
| [`godot-tilemap`](../skills/godot/godot-tilemap/SKILL.md) | `TileMapLayer`/`TileSet`: atlases, data layers, terrain autotiling, runtime `set_cell` | "build a tilemap level" |
| [`godot-physics`](../skills/godot/godot-physics/SKILL.md) | Body and Area types (2D+3D), collision layers/masks, raycasts, Jolt | "fix my collisions" |
| [`godot-ui-control`](../skills/godot/godot-ui-control/SKILL.md) | `Control` nodes: anchors, containers, themes, focus, headless layout check | "lay out a menu" |
| [`godot-animation`](../skills/godot/godot-animation/SKILL.md) | `AnimationPlayer`, `AnimationTree` state machines, `AnimatedSprite2D`, `Tween` | "animate my character" |
| [`godot-shaders`](../skills/godot/godot-shaders/SKILL.md) | Godot shading language: `canvas_item`, `spatial` and particle shaders, headless compile check | "write a Godot shader" |
| [`godot-3d-essentials`](../skills/godot/godot-3d-essentials/SKILL.md) | 3D cameras, lights, `WorldEnvironment`, materials, `GridMap`, headless scene check | "set up a 3D scene" |
| [`godot-resources`](../skills/godot/godot-resources/SKILL.md) | Custom `Resource` data, `.tres`, shared vs `duplicate_deep()`, threaded loading | "make a custom Resource" |
| [`godot-audio`](../skills/godot/godot-audio/SKILL.md) | `AudioStreamPlayer` 2D/3D, buses, volume, looping, playback position for beat sync | "add music and SFX" |
| [`godot-multiplayer`](../skills/godot/godot-multiplayer/SKILL.md) | ENet, `@rpc`, `MultiplayerSpawner`/`MultiplayerSynchronizer`, two-instance headless test | "add multiplayer" |
| [`godot-export`](../skills/godot/godot-export/SKILL.md) | Export templates and presets, command-line export, web COOP/COEP headers | "export my game" |
| [`godot-csharp`](../skills/godot/godot-csharp/SKILL.md) | C#/.NET in Godot: partial classes, `[Export]`/`[Signal]`, signals as events, GDScript interop | "use C# in Godot" |
| [`godot-gdscript-headless-testing`](../skills/godot/godot-gdscript-headless-testing/SKILL.md) | GDScript tests with `godot --headless`, non-zero exit on failure, CI jobs | "test GDScript in CI" |

#### Unity — 9 ([`skills/unity/`](../skills/unity/)) · Unity 6.3 LTS (6000.3)

| Skill | Scope | Say |
|-------|-------|-----|
| [`unity-csharp-scripting`](../skills/unity/unity-csharp-scripting/SKILL.md) | `MonoBehaviour` lifecycle, serialization, `.meta`/GUID discipline, command-line compile and test checks | "write a MonoBehaviour" |
| [`unity-input-system`](../skills/unity/unity-input-system/SKILL.md) | Input System: `.inputactions`, action maps, `PlayerInput`, control schemes | "set up input actions" |
| [`unity-physics`](../skills/unity/unity-physics/SKILL.md) | 3D and 2D physics: Rigidbody and Rigidbody2D, collisions, layers, raycasts, joints | "fix Rigidbody collisions" |
| [`unity-animation`](../skills/unity/unity-animation/SKILL.md) | Animator: states and transitions, blend trees, Avatar Masks, root motion, humanoid IK | "set up an Animator" |
| [`unity-scriptableobjects`](../skills/unity/unity-scriptableobjects/SKILL.md) | `ScriptableObject` config assets, shared runtime variables, event channels | "make a ScriptableObject config" |
| [`unity-tilemap-2d`](../skills/unity/unity-tilemap-2d/SKILL.md) | Tile Palette, Tilemap Collider 2D with a Composite Collider, Rule Tiles, runtime `SetTile` | "build a 2D tilemap" |
| [`unity-navmesh`](../skills/unity/unity-navmesh/SKILL.md) | AI Navigation: `NavMeshSurface` baking, `NavMeshAgent`, `NavMeshLink`, runtime rebakes | "bake a NavMesh" |
| [`unity-build-pipeline`](../skills/unity/unity-build-pipeline/SKILL.md) | Build and player settings, IL2CPP vs Mono, code stripping, scripted and CI builds, Addressables | "script a Unity build" |
| [`unity-build-size`](../skills/unity/unity-build-size/SKILL.md) | Build Report triage, uncompressed glTF/GLB textures, texture/audio import budgets, per-platform size levers (Web, Android, iOS, desktop, Steam) | "shrink my build" |

#### Unreal — 6 ([`skills/unreal/`](../skills/unreal/)) · Unreal Engine 5.8 (5.9 in Preview)

| Skill | Scope | Say |
|-------|-------|-----|
| [`unreal-blueprints`](../skills/unreal/unreal-blueprints/SKILL.md) | Blueprint Classes vs the Level Blueprint, Event Graph, Cast, Interfaces, Event Dispatchers | "work in Blueprints" |
| [`unreal-cpp-gameplay`](../skills/unreal/unreal-cpp-gameplay/SKILL.md) | C++ reflection (`UCLASS`/`UPROPERTY`), Gameplay Framework, GC-safe pointers, command-line builds | "write UE C++ gameplay" |
| [`unreal-enhanced-input`](../skills/unreal/unreal-enhanced-input/SKILL.md) | Input Actions, Mapping Contexts, `ETriggerEvent` bindings, remappable keys | "bind Enhanced Input" |
| [`unreal-behavior-trees`](../skills/unreal/unreal-behavior-trees/SKILL.md) | Behavior Trees, Blackboards, EQS and StateTree: Observer Aborts, C++ `BTTask` nodes | "build a behavior tree" |
| [`unreal-niagara`](../skills/unreal/unreal-niagara/SKILL.md) | Niagara systems, emitters, User parameters, spawning, bounds, GPU vs CPU sim | "make a Niagara effect" |
| [`unreal-packaging`](../skills/unreal/unreal-packaging/SKILL.md) | Shipping builds, cooking, pak/IoStore, `RunUAT BuildCookRun`, reading UAT and cook logs | "package a shipping build" |

#### Ebitengine — 1 ([`skills/ebitengine/`](../skills/ebitengine/)) · Ebitengine v2.10.6 · Go 1.25+

| Skill | Scope | Say |
|-------|-------|-----|
| [`ebitengine-game`](../skills/ebitengine/ebitengine-game/SKILL.md) | Go 2D games: play-and-retry loop, input, pixel-art scaling, text, audio, tests, desktop, WASM and mobile builds | "make a 2D game in Go" |

#### Web engines — 6 ([`skills/web-engines/`](../skills/web-engines/)) · Phaser 4.2 · PixiJS 8.22 · three.js r187

| Skill | Scope | Say |
|-------|-------|-----|
| ✓ [`phaser-core`](../skills/web-engines/phaser-core/SKILL.md) | Phaser 4.2 (and pinned 3.90): Game config, Scene lifecycle, loader, Phaser 3 to 4 migration | "set up Phaser" / "black screen in Phaser" |
| ✓ [`phaser-arcade-physics`](../skills/web-engines/phaser-arcade-physics/SKILL.md) | Arcade Physics: bodies, velocity, gravity, colliders vs overlaps, groups, bullet pools | "add movement and collision" |
| ✓ [`pixijs-rendering`](../skills/web-engines/pixijs-rendering/SKILL.md) | PixiJS 8.22 for games: async init, `Assets`, `Container`/`Sprite` scene graph, pointer drag, v7 to v8 | "render sprites with PixiJS" |
| ✓ [`threejs-scene-setup`](../skills/web-engines/threejs-scene-setup/SKILL.md) | three.js r187 scene, camera, renderer, `setAnimationLoop`, resize, `OrbitControls`, `WebGPURenderer` | "set up a three.js scene" |
| ✓ [`threejs-gltf-loading`](../skills/web-engines/threejs-gltf-loading/SKILL.md) | glTF/GLB loading with DRACO, Meshopt and KTX2, `AnimationMixer` cross-fades, `SkeletonUtils` clones | "load a GLB model" |
| ✓ [`threejs-materials-lighting`](../skills/web-engines/threejs-materials-lighting/SKILL.md) | Standard, physical and unlit materials, lights, shadows, HDR environments, tone mapping | "light my three.js scene" |

#### Other engines — 12 ([`skills/other-engines/`](../skills/other-engines/)) · Bevy · pygame · LÖVE · Defold · Roblox

| Skill | Scope | Say |
|-------|-------|-----|
| [`bevy-ecs`](../skills/other-engines/bevy-ecs/SKILL.md) | Bevy ECS: components, `Query`/`Commands` systems, schedules, States, observers, headless tests (Bevy 0.20) | "write Bevy systems" |
| [`pygame-core`](../skills/other-engines/pygame-core/SKILL.md) | pygame-ce event-update-draw loop, delta time, `Surface`/`Rect`, sprite groups, headless tests (pygame-ce 2.5.8) | "make a pygame game" |
| [`love2d-core`](../skills/other-engines/love2d-core/SKILL.md) | LÖVE callbacks, `conf.lua`, fixed steps, crisp pixel-art scaling, `love.filesystem` saves (LÖVE 11.5) | "make a LÖVE game" |
| [`defold-core`](../skills/other-engines/defold-core/SKILL.md) | Defold collections, game objects, input focus, `msg.post`, factories, collection proxies, Bob builds (Defold 1.14.1) | "work in Defold" |
| [`roblox-luau`](../skills/other-engines/roblox-luau/SKILL.md) | Luau services, Instances, Script vs LocalScript vs ModuleScript, `task` library, typed Luau, selene and luau-lsp checks | "write Luau scripts" |
| [`roblox-datastores`](../skills/other-engines/roblox-datastores/SKILL.md) | `DataStoreService`: load on join, save on leave and `BindToClose`, `UpdateAsync`, session locking, ordered leaderboards | "save player data" |
| [`roblox-ui`](../skills/other-engines/roblox-ui/SKILL.md) | `ScreenGui`/`PlayerGui`, `UDim2` scaling, layouts, safe areas, StyleSheet, gamepad selection, touch controls | "build a Roblox UI" |
| [`roblox-networking`](../skills/other-engines/roblox-networking/SKILL.md) | Remote contracts, server authority, rate limits, hit validation, replication | "secure my RemoteEvents" |
| [`roblox-characters`](../skills/other-engines/roblox-characters/SKILL.md) | `CharacterAdded` lifecycle, `Humanoid`, R6/R15/custom rigs, respawn, Tools | "customize characters and respawn" |
| [`roblox-physics`](../skills/other-engines/roblox-physics/SKILL.md) | Assemblies, constraints, collision groups, `Raycast`/`Shapecast`, network ownership | "fix Roblox physics" |
| [`roblox-studio-workflow`](../skills/other-engines/roblox-studio-workflow/SKILL.md) | Safe edits to an existing place or Rojo project, proven with the right test mode or Studio MCP | "edit an existing place safely" |
| [`roblox-simulator-economy`](../skills/other-engines/roblox-simulator-economy/SKILL.md) | Simulator/tycoon/idle economy: cost curves, income per second, rebirth pacing, big numbers, paid-egg odds (Lune 0.11.1 calculator) | "balance my simulator economy" |

### Disciplines — 15 ([`skills/disciplines/`](../skills/disciplines/))

Cross-engine concepts that load alongside the detected engine skill.

| Skill | Scope | Say |
|-------|-------|-----|
| [`create-game-assets`](../skills/disciplines/create-game-assets/SKILL.md) | Consistent game art: style guides, sprites, pixel art, tilesets, icons, textures, QA and licence records | "make a cohesive art set" |
| [`game-ai`](../skills/disciplines/game-ai/SKILL.md) | Enemy and NPC AI: choosing FSM, BT, utility or GOAP; perception, steering, A* pathfinding | "design enemy AI" |
| [`ai-behavior-trees-utility-ai`](../skills/disciplines/ai-behavior-trees-utility-ai/SKILL.md) | Engine-neutral behavior tree and utility AI code: Blackboard, reactive composites, decorators, response curves | "write engine-neutral AI code" |
| [`procedural-gen`](../skills/disciplines/procedural-gen/SKILL.md) | Seeded RNG, dungeon layouts, wave function collapse, noise terrain, loot tables | "generate a dungeon" |
| [`dialogue-systems`](../skills/disciplines/dialogue-systems/SKILL.md) | Branching dialogue with Ink, Yarn Spinner or a JSON graph: choices, conditions, variables, localization IDs | "add branching dialogue" |
| [`save-systems`](../skills/disciplines/save-systems/SKILL.md) | What to serialize, slots and autosave, atomic writes, versioned migration | "design save slots" |
| [`audio-design`](../skills/disciplines/audio-design/SKILL.md) | Bus layout, decibel volume sliders, loudness, ducking, adaptive music, SFX variation | "mix my game audio" |
| [`shader-programming`](../skills/disciplines/shader-programming/SKILL.md) | How effects work (dissolve, outline, fresnel rim, post) in GLSL with HLSL equivalents | "write a dissolve effect" |
| [`physics-tuning`](../skills/disciplines/physics-tuning/SKILL.md) | Fixed timestep and interpolation, CCD against tunnelling, damping, solver iterations, layer matrices | "stop physics tunnelling" |
| [`level-design`](../skills/disciplines/level-design/SKILL.md) | Player metrics, key and ability gating with a soft-lock check, blockouts, pacing | "block out a level" |
| [`input-systems`](../skills/disciplines/input-systems/SKILL.md) | Named actions, stick deadzones, buffered presses, rebinding with conflict checks | "add rebinding and buffered input" |
| ✓ [`game-feel`](../skills/disciplines/game-feel/SKILL.md) | Juice: trauma-based screen shake, hit-stop, eased tweens, squash & stretch, knockback | "make the hits feel punchy" |
| [`game-ui-ux`](../skills/disciplines/game-ui-ux/SKILL.md) | HUD and menu rules: anchors, scaling, safe areas, gamepad focus, event-driven HUDs, accessibility minimums | "design a HUD" |
| [`camera-systems`](../skills/disciplines/camera-systems/SKILL.md) | 2D follow with deadzone and look-ahead, third-person orbit, first-person look, split-screen | "add a follow camera" |
| [`performance-optimization`](../skills/disciplines/performance-optimization/SKILL.md) | Measure first: CPU- vs GPU-bound, then the biggest fix (draw calls, pooling, GC spikes) | "my game drops FPS" |

### Genres — 9 ([`skills/genres/`](../skills/genres/))

Compositional templates that orchestrate engine + discipline skills; they never re-teach primitives. Genre skills are not in the default Hermes install yet — add the ones your game needs to `curated.txt`.

| Skill | Scope | Say |
|-------|-------|-----|
| [`platformer`](../skills/genres/platformer/SKILL.md) | Jump feel (coyote time, jump buffer, variable height, fall gravity), wall jumps, hazards, checkpoints, jump calculator | "make a platformer" / "my jump feels floaty" |
| [`roguelike`](../skills/genres/roguelike/SKILL.md) | Run structure, permadeath, meta-progression, seeded and daily runs, turn order, field of view | "make a roguelike" |
| [`rpg`](../skills/genres/rpg/SKILL.md) | Stats with a modifier stack, XP curves, damage formulas, items and equipment, quests | "make an RPG" |
| [`fps-shooter`](../skills/genres/fps-shooter/SKILL.md) | Hitscan vs projectiles, time-to-kill, damage falloff, recoil, ADS sensitivity, lag-compensated hits | "make a shooter" |
| [`tower-defense`](../skills/genres/tower-defense/SKILL.md) | Lane and maze pathing, wave pacing, targeting, armoured and flying counters, gold economy, wave-curve checker | "make a tower defense" |
| [`card-game`](../skills/genres/card-game/SKILL.md) | Cards as data with one effect interpreter, deck zones, trigger stack, seeded shuffles, roguelike deckbuilders | "make a card game" |
| [`visual-novel`](../skills/genres/visual-novel/SKILL.md) | Routes and endings, save-anywhere, backlog, skip-read-only, typewriter text (Ren'Py or any engine) | "make a visual novel" |
| [`survival-crafting`](../skills/genres/survival-crafting/SKILL.md) | Gathering, recipes and tech trees, carry weight, spoilage, needs, base building | "make a survival-crafting game" |
| [`puzzle`](../skills/genres/puzzle/SKILL.md) | Match-3 cascades, Sokoban, unique-solution grids, exact undo, solver-checked levels | "make a puzzle game" |

### Workflows — 5 ([`skills/workflows/`](../skills/workflows/))

| Skill | Scope | Say |
|-------|-------|-----|
| ✓ [`game-jam`](../skills/workflows/game-jam/SKILL.md) | Read the jam rules, scope to the clock, keep a cut list, check the build before submitting | "ship my jam entry" |
| ✓ [`prototype-fast`](../skills/workflows/prototype-fast/SKILL.md) | One-question throwaway prototype: greybox, debug HUD, playtest, then keep, kill or retune | "just get something playable" |
| [`steam-publish`](../skills/workflows/steam-publish/SKILL.md) | SteamPipe: depots, `app_build` scripts, `steamcmd` uploads, beta branches, SetLive, store review | "upload to Steam" |
| ✓ [`itch-publish`](../skills/workflows/itch-publish/SKILL.md) | `butler push` to channels, platform tags, HTML5 builds, `--userversion`, CI uploads | "publish my game on itch" |
| [`game-docs`](../skills/workflows/game-docs/SKILL.md) | One-page GDD with a feature index and short per-feature notes, kept in sync with the code | "write a one-page GDD" |

## Repository layout

```
skills/        79 upstream skills, grouped by engine / discipline / genre / workflow
router/        the upstream master router (for other agents)
hermes/        this fork's additions (this directory):
  skills/        game-prototype (trigger) + gamedev-router (Hermes adaptation)
  templates/     web-game: zero-build Phaser starter + check.mjs self-check
  install.sh     curated installer into ~/.hermes/skills/game-dev/
  curated.txt    the installed set
  tests/         install_test.sh, check_test.sh, prototype_skill_test.sh
  README.md      this file — the fork's documentation
docs/          upstream authoring standard, installation, compatibility
docs/superpowers/  this fork's design spec and implementation plan
templates/     upstream SKILL.md template
scripts/       upstream validate-skills.py, generate-site.py and tooling
tests/         upstream regression tests for the validator
```

Every skill is a plain `SKILL.md` folder in the [Agent Skills](https://agentskills.io) open standard, so the upstream library also loads natively in Claude Code, Cursor, Codex, Gemini CLI and others — see upstream [`docs/COMPATIBILITY.md`](../docs/COMPATIBILITY.md). This fork's install path and pipeline are Hermes-specific.

## Syncing with upstream

```bash
git pull upstream main
bash hermes/install.sh
```

All fork additions live under `hermes/` and `docs/superpowers/`; no upstream file is modified, so pulls stay clean. If `install.sh` exits 1 naming a missing skill, upstream renamed or removed a curated source — update `curated.txt` deliberately, don't ignore it.

## Credits and license

- Upstream [awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills) was created and is maintained by [Abhishek Barali](https://github.com/AbhishekBarali). All upstream skills, the router, docs and tooling are his project's work, used here under Apache-2.0.
- Prototype pipeline process adapted from [Donchitos/Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) `/prototype` (MIT) — ideas only, no code copied.
- Hermes additions (`hermes/`): Apache-2.0.

[Apache-2.0](../LICENSE). See [`NOTICE`](../NOTICE) for attribution and trademark notes.
