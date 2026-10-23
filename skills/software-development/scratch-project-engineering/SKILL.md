---
name: scratch-project-engineering
description: Inspect, debug, and patch Scratch .sb3 project files.
version: 0.2.0
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
- Don't use for: projects built with textual game engines (Godot, Unity, Pygame) or general web apps.

## Structure of `.sb3`

An `.sb3` file is a ZIP archive containing:
- `project.json`: All sprites, costumes, sounds, variables, and block ASTs.
- `<assetId>.<ext>`: Flat media files (`.svg`, `.png`, `.wav`) referenced by `costumes` and `sounds`.

Key structure of `project.json`:
- `targets`: List of objects. Target 0 has `isStage: true` (the Stage / backdrop manager); subsequent targets are sprites (`isStage: false`).
- `targets[].blocks`: Dictionary of `block_id -> block_object`.
- Top-level chains: Blocks with `topLevel: true` and no `parent` represent hat blocks (event listeners) or disconnected orphan blocks.
- Sequential chains: Connected via `next` and `parent`.
- Nested branches: Connected via `inputs.SUBSTACK[1]` (loop/if body) and `inputs.CONDITION[1]`.

## Procedure

1. **Acquire project data:**
   - If public Scratch URL: Query `https://api.scratch.mit.edu/projects/<id>` to get `project_token`. Fetch JSON from `https://projects.scratch.mit.edu/<id>?token=<token>`. Download missing media assets from `https://assets.scratch.mit.edu/internalapi/asset/<md5ext>/get/`.
   - If unshared / private project: Public API returns `NotFound`. Instruct the user to export `.sb3` via `File -> Save to your computer` (or look in `Downloads`).
2. **Extract and inspect:**
   - Unpack `.sb3` with Python `zipfile`.
   - Parse `project.json`. Enumerate targets, backdrop costumes in `Stage`, and hat blocks across all sprites.
3. **Diagnose and patch `project.json`:**
   - Map event chains and verify input/condition block references (confirm all referenced block IDs exist in `blocks`).
   - Sanitize all serialized variable states: ensure `stage.variables[id]` and `data.monitors` in `project.json` have clean initial values (e.g. `score: 0`). Stage's `event_whenflagclicked` must explicitly reset all variables (`data_setvariableto 0`) on frame 0.
   - Audit variable thresholds against total collectible points; use inequality operators (`operator_gt`) instead of exact equality (`operator_equals`) to prevent deadlocks. Never embed accidental score increments in non-gameplay story sequences (e.g. turning off a bedroom light).
   - Never attach progression milestone checks (e.g. `if score >= 20`) to `event_whenflagclicked`—scope them strictly to the scene where the task occurs (e.g. `when backdrop switches to <task_backdrop>`) so residual or test scores cannot trigger premature scene skips.
   - Enforce backdrop visibility hooks: every scene must explicitly show its participants and hide all unrelated sprites.
   - Remove orphaned/disconnected top-level blocks or re-attach them to valid event hats.
   - Arrange HUD monitors (`data.monitors`) with distinct X-coordinates (e.g. X=5, 140, 250, 390) and control their scene visibility dynamically with `data_showvariable` / `data_hidevariable`.
   - When introducing a Start Menu or Title Screen, detach the original story/gameplay hat from `event_whenflagclicked` to a dedicated `when I receive start_game` broadcast; flag-clicked must solely initialize variables, HUD monitors, and present the menu.
   - On victory screens, display the player's earned score dynamically using `operator_join("Skor Akhir: ", score)` via `looks_say` or a centered variable monitor.
4. **Repackage into `.sb3`:**
   - Write updated `project.json`.
   - Create a ZIP archive using `zipfile.ZIP_DEFLATED` containing `project.json` at root and all asset files flat.
   - Re-open and verify the ZIP integrity in Python.
5. **Deliver to user:**
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
13. **Drag penalty disappearance bug:** In drag-and-drop sorting games (e.g. recycling bins), an incorrect placement penalty must NEVER call `looks_hide` on the dragged sprite. Hiding during drag-release cancels pointer interaction and leaves the sprite or target bin stuck in an invisible state. Instead: play a buzzer/rejection sound, say "salah", and smoothly `motion_glidesecstoxy` back to the starting shelf coordinates while remaining visible. Ensure bin receptacles also call `looks_gotofrontback('front')` so dragged items do not render behind them.
14. **Persistent loop debris bleeding into subsequent scenes:** Continuous spawners or falling obstacle loops survive backdrop transitions unless explicitly terminated. Relying solely on `when backdrop switches to X -> looks_hide` fails because the active loop can still execute `looks_show` on the next spawn cycle. Always: (a) terminate the loop upon scene exit using `control_stop('other scripts in sprite')`, and (b) gate the loop body with a state condition (e.g. `if status == active_gameplay`).
15. **Interactive UI button hit-testing (SVG vs PNG & non-blocking events):** Complex vector buttons with SVG filter effects (`<feDropShadow>`), gradients, or deep transforms can fail hit-testing on the Scratch VM canvas, making buttons unclickable. Prefer clean rasterized PNG buttons with explicit pixel centers. In `when this sprite clicked`, never insert blocking audio blocks (`sound_playuntildone`) before the transition `event_broadcast`—trigger the broadcast immediately to ensure instant responsiveness.
16. **Serialized variable state & frame-0 scene skips:** Scratch saves active variable values directly into `stage.variables` and `data.monitors`. If a project is packaged with non-zero progress values (e.g. `score = 22`), any global listener (`when flag clicked -> forever if score > 20`) executes *instantly on frame 0*, skipping the title screen and early acts entirely. Always sanitize initial values in `project.json` and reset them via `data_setvariableto 0` on Stage flag-click. Crucially, scope all milestone transitions (`if score > N`) to the specific backdrop event (`when backdrop switches to <scene>`) where the player actually earns that score, never to a global green-flag loop.
