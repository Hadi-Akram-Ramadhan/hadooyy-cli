---
name: scratch-engineering
description: Inspect, debug, patch, and extend Scratch .sb3 games.
version: 0.5.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [scratch, sb3, blockly, game-dev, debugging]
    related_skills: [systematic-debugging]
---

# Scratch Project Engineering

## Overview

Scratch projects (`.sb3`) are standard ZIP archives containing a root `project.json` AST and flat media assets. Never attempt to manipulate the graphical block editor via browser clicks or desktop UI automation — dragging blocks on canvas is fragile, slow, and error-prone. Work directly at the data layer by parsing, patching, and repackaging `project.json`.

## When to Use

- User asks to inspect, fix bugs in, or modify a Scratch game or project (`.sb3` or `scratch.mit.edu` URL).
- Diagnosing broken gameplay logic, timer freezes, backdrop transitions, or collision bugs.
- Extending Scratch games with new scenes, minigames, custom sprites, HUD monitors, or external image assets.
- Don't use for: projects built with textual game engines (Godot, Unity, Pygame) or general web apps.

## Structure of `.sb3`

An `.sb3` file is a ZIP archive containing:
- `project.json`: All sprites, costumes, sounds, variables, monitors, and block ASTs.
- `<assetId>.<ext>`: Flat media files (`.svg`, `.png`, `.wav`, `.jpg`) referenced by `costumes` and `sounds`.

Key structure of `project.json`:
- `targets`: List of objects. Target 0 has `isStage: true` (the Stage / backdrop manager); subsequent targets are sprites (`isStage: false`).
- `targets[].blocks`: Dictionary of `block_id -> block_object`.
- Top-level chains: Blocks with `topLevel: true` and no `parent` represent hat blocks (event listeners) or disconnected orphan blocks.
- Sequential chains: Connected via `next` and `parent`.
- Nested branches: Connected via `inputs.SUBSTACK[1]` (loop/if body) and `inputs.CONDITION[1]`.
- `stage.variables`: Dictionary of `var_id -> [var_name, initial_value]`.
- `stage.broadcasts`: Dictionary of `bcast_id -> bcast_name`.
- `data.monitors`: List of HUD display monitors (`id`, `opcode: 'data_variable'`, `params: {'VARIABLE': name}`, `x`, `y`, `visible`).

## Procedure

1. **Acquire project data:**
   - If public Scratch URL: Query `https://api.scratch.mit.edu/projects/<id>` to get `project_token`. Fetch JSON from `https://projects.scratch.mit.edu/<id>?token=<token>`. Download missing media assets from `https://assets.scratch.mit.edu/internalapi/asset/<md5ext>/get/`.
   - If unshared / private project: Public API returns `NotFound`. Instruct the user to export `.sb3` via `File -> Save to your computer` (or inspect `Downloads`).
2. **Extract and inspect:**
   - Unpack `.sb3` with Python `zipfile`.
   - Parse `project.json`. Enumerate targets, backdrop costumes in `Stage`, global variables, monitors, and hat blocks across all sprites.
3. **Diagnose and patch gameplay logic:**
   - Map event chains and verify input/condition block references (confirm all referenced block IDs exist in `blocks`).
   - Audit variable thresholds against total collectible points; use inequality operators (`operator_gt`) instead of exact equality (`operator_equals`) to prevent deadlocks.
   - Enforce backdrop visibility hooks: every scene must explicitly show its participants and hide all unrelated sprites.
   - Remove orphaned/disconnected top-level blocks or re-attach them to valid event hats.
4. **Inject assets, sprites, HUD monitors, and broadcasts:**
   - Assets: compute `md5 = hashlib.md5(data).hexdigest()`, write flat to ZIP root as `<md5>.<ext>`. Set costume `rotationCenterX: width // 2` and `rotationCenterY: height // 2`.
   - Custom sprites: create target object (`isStage: false`), attach costumes, standard sound (`pop`: `83a9787d4cb6f3b7632b4ddfebf74367.wav`), and AST blocks.
   - Global HUD variables: declare in `stage.variables[var_id] = [name, initial_val]`. Add monitor object in `data.monitors` with position and `visible: true`.
   - Broadcasts: register in `stage.broadcasts[bcast_id] = bcast_name`. Trigger via `event_broadcast` (`inputs.BROADCAST_INPUT: [1, [11, name, id]]`) and listen via `event_whenbroadcastreceived` (`fields.BROADCAST_OPTION: [name, id]`).
5. **Implement interceptor / barrier mechanics (e.g. Shield/Drone):**
   - Place controlled interceptors at an intermediate Y-coordinate (`y: 15`) between hazard spawn (`y: 170`) and protected targets (`y: -80` to `-110`).
   - In player steering loops, lock Y-position (`motion_sety`) to prevent vertical drift during horizontal arrow movement.
   - In hazard falling loops, check collision with interceptor FIRST: increment score, play deflecting sound, teleport off-screen (`motion_sety 200`), hide, and break. Only if interceptor was not touched, check collision with protected targets (decrement lives).
   - Tune falling speeds: use `change y by -4` to `-5` with small tick delays (~0.015-0.03s) for readable human reaction time.
6. **Implement interactive multi-station reconstruction / click tasks:**
   - Model interactive repair stations as separate sprites with dual costumes (`<name>_rusak` vs `<name>_bagus`).
   - In `when this sprite clicked`, inspect costume number (`looks_costumenumbername == 1`): switch costume to repaired, increment score and counter (`kota_dibangun`), play audio feedback (`pop` / chime), and immediately `stop this script` to prevent duplicate clicks from double-counting.
   - When counter reaches target count (`operator_gt N-1`), broadcast completion (`event_broadcast kota_selesai`).
7. **Multi-phase quest transitions & state guarding:**
   - Never call `control_stop all` upon finishing an intermediate phase; call `control_stop this script` on the phase controller and emit a transition broadcast (`event_broadcast mulai_rekonstruksi`).
   - If reusing a backdrop across different phases (e.g. backdrop 2 used for both a pre-hazard walk and a final restored city victory), guard event handlers with a phase state variable (`if status == 5`) or attach them exclusively to phase-specific broadcasts.
8. **Manage HUD monitor layout and dynamic phase visibility:**
   - In `data.monitors`, allocate non-overlapping horizontal slots across the 480px canvas (Slot 1 `x: 5`, Slot 2 `x: 140`, Slot 3 `x: 250`, Slot 4 `x: 390`, all `y: 5`).
   - In Stage or scene manager scripts, wire `data_showvariable` and `data_hidevariable` so only monitors relevant to the active scene display (e.g. countdown timer only during time-trials, lives counter only during hazard defense, rebuild progress only during reconstruction; hide all inactive HUD elements).
9. **Repackage into `.sb3`:**
   - Write updated `project.json` using `writestr("project.json", ...)` to prevent duplicate entries if an exported JSON exists in the assets directory.
   - Create a ZIP archive using `zipfile.ZIP_DEFLATED` containing `project.json` at root and all asset files flat (skip any `.json` files in the assets directory).
   - Re-open and verify the ZIP integrity, target counts, and asset presence in Python.
10. **Implement endgame victory screens, dynamic score presentation, and restart loops:**
    - To create a replayable victory screen, design a dedicated backdrop costume (`kemenangan_kota`) with celebration graphics.
    - Present the final score dynamically: never leave a blank "SKOR AKHIR" static banner on the background. Have the protagonist announce the score using string concatenation (`looks_say [operator_join "Skor Akhir Kamu: " (score)]`) and ensure `data_showvariable score` is explicitly called.
    - Create a dedicated restart button sprite (`tombol_mulai_ulang`) formatted as a flat PNG (not SVG with filters) placed at bottom center (`x: 0, y: -110`, `layerOrder: 99`).
    - On `when this sprite clicked`, emit `event_broadcast mulai_ulang` IMMEDIATELY (use non-blocking `sound_play`, never `sound_playuntildone` before broadcast), then hide.
    - Wire `when I receive mulai_ulang` across all targets:
      - In Stage: reset all variables (`score = 0`, `nyawa = 3`, `status = 0`, `timer = 0`, etc.), call `sound_stopallsounds`, reset monitor visibilities, and switch backdrop to the opening scene.
      - In Protagonist: execute `control_stop other scripts in sprite`, reset position and costume, and replay the opening cutscene/dialogue sequence.
      - In all gameplay sprites: execute `looks_hide` and `control_stop other scripts in sprite`.
11. **Repackage into `.sb3`:**
   - Write updated `project.json` using `writestr("project.json", ...)` to prevent duplicate entries if an exported JSON exists in the assets directory.
   - Create a ZIP archive using `zipfile.ZIP_DEFLATED` containing `project.json` at root and all asset files flat (skip any `.json` files in the assets directory).
   - Re-open and verify the ZIP integrity, target counts, and asset presence in Python.
12. **Deliver to user:**
   - Provide the absolute path to the `.sb3` file.
   - Instruct the user to load it via `File -> Load from your computer` in the Scratch editor.

## Pitfalls

1. **Backdrop re-trigger thread abort & safe screen shake:** In the Scratch VM, whenever `looks_switchbackdropto X` is executed, the runtime automatically halts and restarts ALL active scripts starting with `when backdrop switches to X`. If a script is waiting (`wait N seconds`) or gliding, switching back to X instantly aborts the wait. Guarding with `if state == 0` causes the aborted thread to NEVER re-enter, permanently breaking the cutscene or progression. NEVER put timed sequences or progression logic inside `when backdrop switches to X` if backdrop X alternates for visual effects (like screen shake between backdrops 3 and 4). Instead, `when backdrop switches to X` must ONLY fire a broadcast (`broadcast start_intro`), and all waits, glides, and timers must listen to `when I receive start_intro`—Scratch broadcast threads are independent and never aborted by backdrop changes.
2. **Backdrop costume name mismatch:** Costumes frequently have divergent names (e.g. `'3'` vs `'backdrop3'`). If an event listener expects `'backdrop3'` while Stage switches to `'3'`, the script will silently never execute. Verify `stage.costumes` names.
3. **Stateful sprite leakage across scenes:** Sprite visibility persists across backdrop changes. If a sprite shows in scene A (e.g. outdoor utility pole), it will float inside scene B (e.g. indoor bedroom) or earlier gameplay stages (e.g. yard trash pickup, sorting screen) unless explicitly hidden with `when backdrop switches to B -> looks_hide`. Audit all props/lamps across every preceding and succeeding backdrop.
4. **Spatial clustering in multi-character cutscenes:** When scripting multiple NPCs/civilians in panic or cutscenes, assign distinct, distributed spawn coordinates (`x0, y0`) and varied glide paths across the full canvas width. Placing multiple characters at near-identical coordinates (e.g. `x ≈ -150 to -200`) visually stacks them into an overlapping clump that looks like a cloning bug.
5. **Dangling condition/input block IDs:** Deleting or replacing blocks can leave `inputs.CONDITION` pointing to missing IDs. In `control_if`, a missing or dangling condition silently evaluates to false, permanently blocking progression. Always verify that IDs in `inputs` exist in `target.blocks`.
6. **Exact threshold deadlocks:** Transitioning via `score == N` deadlocks if the total reachable items/points in preceding tasks is less than `N` (e.g. 21 reachable points vs `score == 22`). Always sum possible points and use inequality guards (`score > N-1` or `>= N`).
7. **Disconnected orphan blocks:** Blocks with `topLevel: true` that lack an `event_*` opcode (e.g. `set timer to 15 -> forever ...`) are disconnected blocks on the canvas. They never execute. Attach them to an explicit hat block.
8. **Conflicting handlers:** Multiple scripts on the same event (e.g. one hiding a sprite and another gliding it) race and cause flickering or permanent invisibility. Consolidate into a single handler.
9. **Missing victory/game over hide hooks:** When switching to a win or loss backdrop, all active gameplay sprites must hide (`when backdrop switches to <end_backdrop> -> looks_hide`). Otherwise debris, enemies, and UI elements persist into the endgame screen.
10. **Local vs global variables:** Stage defines global variables in `stage.variables`. Always verify variable IDs match across blocks (`fields.VARIABLE: [name, id]`).
11. **Collision race on click-destroyed sprites:** When an obstacle is destroyed via `when this sprite clicked`, calling `looks_hide` alone does not prevent collision checks in concurrent falling loops on the same tick. Immediately teleport it off-screen (`motion_sety 200` or `motion_gotoxy 0, 200`) before yielding, otherwise the falling loop can detect collision with a civilian/player before hiding completes.
12. **Asset dimension center offsets:** Costume rotation centers must be explicit integers (`width // 2`, `height // 2`). Omitting `rotationCenterX` or defaulting to 0 places the sprite anchor at the top-left corner, misaligning collision boxes and click targets.
13. **Spurious game-over from unstopped timer loops:** When scripting a countdown timer for a task (e.g. 15s sorting), a loop that checks `if timer < 1 -> game over` will trigger even after the player successfully finishes if not terminated. Always place a success guard inside the loop (`if score >= target -> stop this script`) so completing the objective cleanly halts the countdown.
14. **Endgame backdrop reuse collision:** When reusing an early-game backdrop asset (e.g. undamaged street) as an endgame victory scene, generic `when backdrop switches to X` handlers will fire early-game cutscenes (e.g. character entering house). Guard early-game event chains with phase checks (`if status == 0`) or drive endgame scenes via phase-specific broadcasts.
15. **HUD monitor stacking on shared top-left coordinates:** In `project.json`, new monitors default to `(0-5, 0-5)`. If multiple monitors (`score`, `timer`, `nyawa`, `progress`) are added without explicit `x, y` offsets, they render on top of each other into an illegible stacked pill. Assign discrete coordinates across the 480px top bar and dynamically toggle visibility with `data_showvariable` / `data_hidevariable` per phase.
16. **Legacy prop sprite leakage on shared backdrops:** When deprecating or removing visual props (e.g. decorative poles, light cones, weather clouds), leaving partial event handlers or relying on omission causes them to reappear whenever common backdrops (like outdoor streets) are reused. Neutralize deprecated props completely by replacing their blocks with unconditional `when flag clicked -> looks_hide` and `when backdrop switches to * -> looks_hide` (and set `visible: false`).
17. **Costume duplication and NPC clone army glitch:** When generic civilian or crowd sprites share identical costume assets with the protagonist or each other, rendering multiple NPC sprites in static dialogue or celebration scenes visually looks like an army of duplicate clones. Restrict static dialogue and victory scenes to the protagonist and unique companions (e.g. drone/mascot); confine generic duplicate actor sprites strictly to dynamic crowd motion (e.g. fleeing evacuation).
18. **Unstopped concurrent spawn loops leaking across scenes:** In Scratch, starting a `control_forever` loop via a broadcast (e.g. `when I receive start_minigame`) continues executing across backdrop switches even if an event handler runs `when backdrop switches to <next_scene> -> looks_hide`. The loop continues ticking, executing `motion_gotoxy` and `looks_show` in the background, causing debris, enemies, or powerups to continually spawn and fall over subsequent cutscenes or victory screens. Every scene-exit handler MUST execute `control_stop other scripts in sprite` alongside `looks_hide`, and the loop body itself MUST check a phase state guard (`if status == active`) before each spawn cycle.
19. **Premature hiding on incorrect drag-and-drop classification:** In sorting mechanics (e.g. dragging trash into bins), calling `looks_hide` when an item touches the WRONG bin makes the item visually vanish as if it were accepted, confusing the player while blocking audio (`sound_playuntildone`) prolongs the hidden state. On incorrect drops, NEVER call `looks_hide`. Keep the item visible, play the rejection sound, display error feedback (`looks_sayforsecs "salah!"`), and glide it back to its starting coordinates (`motion_glidesecstoxy`). Additionally, ensure target bins execute `looks_gotofrontback front` on scene start so dragged items never appear behind bin art.
20. **Standalone asset export workflows:** When the user requests external image assets for in-game entities (e.g. repair station cards, icons, UI buttons), generate transparent PNGs into a dedicated folder under `Downloads/<asset_folder>/` providing both base and state-variant files (`<name>_rusak.png`, `<name>_bagus.png`, `<name>.png`) for immediate external inspection or manual re-import.
21. **Vector filter & gradient failures on UI button hitboxes:** In Scratch's SVG renderer (`paper.js`), SVG files containing `<defs>`, `<linearGradient>`, or `<filter>` (e.g. `feDropShadow`) frequently drop or miscalculate element bounding boxes. This causes custom UI buttons (like Play or Restart buttons) to render blank or become completely unclickable (`event_whenthisspriteclicked` never registers). Always format interactive UI buttons as solid bitmap PNGs (`dataFormat: 'png'`) with explicit canvas dimensions and `rotationCenterX/Y`, and assign top layer priority (`layerOrder: 99` / `looks_gotofrontback front`) to guarantee pixel-accurate click hit-testing.
22. **Blocking audio delaying or freezing click broadcasts:** In `event_whenthisspriteclicked` handlers, placing `sound_playuntildone` before `event_broadcast` blocks script execution until the sound buffer finishes or stalls if audio output is muted or busy. This makes buttons appear unresponsive to user clicks. Always invoke `event_broadcast` first (or use non-blocking `sound_play`), then perform visual feedback (`looks_hide`) and script termination.
