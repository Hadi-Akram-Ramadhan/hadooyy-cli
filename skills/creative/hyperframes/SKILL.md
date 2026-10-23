---
name: hyperframes
description: Render MP4/WebM videos from HTML compositions.
version: 1.0.0
author: heygen-com
license: Apache-2.0
platforms: [linux, macos, windows]
prerequisites:
  commands: [node, ffmpeg, npx]
metadata:
  hermes:
    tags: [creative, video, animation, html, gsap, motion-graphics]
    related_skills: [manim-video, meme-generation]
    category: creative
    requires_toolsets: [terminal]
---

# HyperFrames

HTML is the source of truth for video. A composition is an HTML file with `data-*` attributes for timing, a GSAP timeline for animation, and CSS for appearance. The HyperFrames engine captures the page frame-by-frame and encodes to MP4/WebM with FFmpeg.

**Complement to `manim-video`:** Use `manim-video` for mathematical/geometric explainers (equations, 3B1B-style). Use `hyperframes` for motion-graphics, talking-head with captions, product tours, social overlays, shader transitions, and anything driven by real video/audio media.

## When to Use

- User asks for a rendered video from text, a script, or a website
- Animated title cards, lower thirds, or typographic intros
- Captioned narration video (TTS + captions synced to waveform)
- Audio-reactive visuals (beat sync, spectrum bars, pulsing glow)
- Scene-to-scene transitions (crossfade, wipe, shader warp, flash-through-white)
- Social overlays (Instagram/TikTok/YouTube style)
- Website-to-video pipeline (capture a URL, produce a promo)
- Any HTML/CSS/JS animation that must render deterministically to a video file

Do **not** use this skill for:
- Pure math/equation animation (→ `manim-video`)
- Image generation or memes (→ `meme-generation`, image models)
- Live video conferencing or streaming

## Quick Reference

```bash
npx hyperframes init my-video               # scaffold a project
cd my-video
npx hyperframes lint                        # validate before preview/render
npx hyperframes preview                     # live-reload preview (long-lived server, port 3002)
npx hyperframes render --output final.mp4   # render to MP4
npx hyperframes doctor                      # diagnose environment issues
```

`preview` is a **long-lived** Next.js server that holds Chrome render workers open. Always stop it when done (see [Cleanup](#cleanup)) — a forgotten preview keeps idle `chrome-headless-shell` workers alive that, on GPU-less hosts (WSL, containers, CI), spin a CPU core each indefinitely via software WebGL (swiftshader).

Render flags: `--quality draft|standard|high` · `--fps 24|30|60` · `--format mp4|webm` · `--docker` (reproducible) · `--strict`.

Full CLI reference: [references/cli.md](references/cli.md).

## Setup (one-time)

```bash
bash "$(dirname "$(find ~/.hermes/skills -path '*/hyperframes/SKILL.md' 2>/dev/null | head -1)")/scripts/setup.sh"
```

The script:
1. Verifies Node.js >= 22 and FFmpeg are installed (prints fix instructions if not).
2. Installs the `hyperframes` CLI globally (`npm install -g hyperframes@>=0.4.2`).
3. Pre-caches `chrome-headless-shell` via Puppeteer — **required** for best-quality rendering via Chrome's `HeadlessExperimental.beginFrame` capture path.
4. Runs `npx hyperframes doctor` and reports the result.

See [references/troubleshooting.md](references/troubleshooting.md) if setup fails.

## Procedure

### 1. Plan before writing HTML

Before touching code, articulate at a high level:
- **What** — narrative arc, key moments, emotional beats
- **Structure** — compositions, tracks (video/audio/overlays), durations
- **Visual identity** — colors, fonts, motion character (explosive / cinematic / fluid / technical)
- **Hero frame** — for each scene, the moment when the most elements are simultaneously visible. This is the static layout you'll build first.

**Visual Identity Gate (HARD-GATE).** Before writing ANY composition HTML, a visual identity must be defined. Do NOT write compositions with default or generic colors (`#333`, `#3b82f6`, `Roboto` are tells that this step was skipped). Check in order:

1. **`DESIGN.md` at project root?** → Use its exact colors, fonts, motion rules, and "What NOT to Do" constraints.
2. **User named a style** (e.g. "Swiss Pulse", "dark and techy", "luxury brand")? → Generate a minimal `DESIGN.md` with `## Style Prompt`, `## Colors` (3-5 hex with roles), `## Typography` (1-2 families), `## What NOT to Do` (3-5 anti-patterns).
3. **None of the above?** → Ask 3 questions before writing any HTML:
   - Mood? (explosive / cinematic / fluid / technical / chaotic / warm)
   - Light or dark canvas?
   - Any brand colors, fonts, or visual references?

   Then generate a `DESIGN.md` from the answers. Every composition must trace its palette and typography back to `DESIGN.md` or explicit user direction.

### 2. Scaffold

```bash
npx hyperframes init my-video --non-interactive
```

Templates: `blank`, `warm-grain`, `play-mode`, `swiss-grid`, `vignelli`, `decision-tree`, `kinetic-type`, `product-promo`, `nyt-graph`. Pass `--example <name>` to pick one, `--video clip.mp4` or `--audio track.mp3` to seed with media.

### 3. Layout before animation

Write the static HTML+CSS for the **hero frame first** — no GSAP yet. The `.scene-content` container must fill the scene (`width:100%; height:100%; padding:Npx`) with `display:flex` + `gap`. Use padding to push content inward — never `position: absolute; top: Npx` on a content container (content overflows when taller than the remaining space).

Only after the hero frame looks right, add `gsap.from()` entrances (animate **to** the CSS position) and `gsap.to()` exits (animate **from** it).

See [references/composition.md](references/composition.md) for the full data-attribute schema and composition rules.

### 4. Animate with GSAP

Every composition must:
- Register its timeline: `window.__timelines["<composition-id>"] = tl`
- Start paused: `gsap.timeline({ paused: true })` — the player controls playback
- Use finite `repeat` values (no `repeat: -1` — breaks the capture engine). Calculate: `repeat: Math.ceil(duration / cycleDuration) - 1`.
- Be deterministic — no `Math.random()`, `Date.now()`, or wall-clock logic. Use a seeded PRNG if you need pseudo-randomness.
- Build synchronously — no `async`/`await`, `setTimeout`, or Promises around timeline construction.

See [references/gsap.md](references/gsap.md) for the core GSAP API (tweens, eases, stagger, timelines).

### 5. Transitions between scenes

Multi-scene compositions require transitions. Rules:
1. **Always use a transition between scenes** — no jump cuts.
2. **Always use entrance animations** on every scene element (`gsap.from(...)`).
3. **Never use exit animations** except on the final scene — the transition IS the exit.
4. The final scene may fade out.

Use `npx hyperframes add <transition-name>` to install shader transitions (`flash-through-white`, `liquid-wipe`, etc.). Full list: `npx hyperframes add --list`.

### 6. Audio, captions, TTS, audio-reactive, highlighting

- **Audio:** always a separate `<audio>` element (video is `muted playsinline`).
- **TTS:** `npx hyperframes tts "Script text" --voice af_nova --output narration.wav`. List voices with `--list`. Voice ID first letter encodes language (`a`/`b`=English, `e`=Spanish, `f`=French, `j`=Japanese, `z`=Mandarin, etc.) — the CLI auto-infers the phonemizer locale; pass `--lang` only to override. Non-English phonemization requires `espeak-ng` installed system-wide.
- **Captions:** `npx hyperframes transcribe narration.wav` → word-level transcript. Pick style from the transcript tone (hype / corporate / tutorial / storytelling / social — see the table in `references/features.md`). **Language rule:** never use `.en` whisper models unless the audio is confirmed English — `.en` translates non-English audio instead of transcribing it. Every caption group MUST have a hard `tl.set(el, { opacity: 0, visibility: "hidden" }, group.end)` kill after its exit tween — otherwise groups leak visible into later ones.
- **Audio-reactive visuals:** pre-extract audio bands (bass / mid / treble) and sample per-frame inside the timeline with a `for` loop of `tl.call(draw, [], f / fps)` — a single long tween does NOT react to audio. Map bass → `scale` (pulse), treble → `textShadow`/`boxShadow` (glow), overall amplitude → `opacity`/`y`/`backgroundColor`. Avoid equalizer-bar clichés — let content guide the visual, audio drive its behavior.
- **Marker-style highlighting:** highlight, circle, burst, scribble, sketchout effects for text emphasis are deterministic CSS+GSAP — see `references/features.md#marker-highlighting`. Fully seekable, no animated SVG filters.
- **Scene transitions:** every multi-scene composition MUST use transitions (no jump cuts). Pick from CSS primitives (push slide, blur crossfade, zoom through, staggered blocks) or shader transitions (`flash-through-white`, `liquid-wipe`, `cross-warp-morph`, `chromatic-split`, etc.) via `npx hyperframes add`. Mood and energy tables live in `references/features.md#transitions`. Do not mix CSS and shader transitions in the same composition.

### 7. Lint, validate, inspect, preview, render

```bash
npx hyperframes lint              # catches missing data-composition-id, overlapping tracks, unregistered timelines
npx hyperframes validate          # WCAG contrast audit at 5 timestamps
npx hyperframes inspect           # visual layout audit — overflow, off-frame elements, occluded text
npx hyperframes preview           # live browser preview
npx hyperframes render --quality draft --output draft.mp4    # fast iteration
npx hyperframes render --quality high --output final.mp4     # final delivery
```

`hyperframes validate` samples background pixels behind every text element and warns on contrast ratios below 4.5:1 (or 3:1 for large text). `hyperframes inspect` is the layout-side companion — runs the page at multiple timestamps and flags issues that a static lint can't see (a caption that wraps past the safe area only at 4.5s, a card that overflows when its title is the longest variant, an element that ends up behind a transition shader). Run `inspect` especially on compositions with speech bubbles, cards, captions, or tight typography.

### 8. Website-to-video (if the user gives a URL)

Use the 7-step capture-to-video workflow in [references/website-to-video.md](references/website-to-video.md): capture → DESIGN.md → SCRIPT.md → storyboard → composition → render → deliver.

## Cleanup

`render` is one-shot (workers exit when it finishes). `preview` is **not** — it runs a background Next.js server that keeps Chrome workers resident until you stop it. Never leave one running: on GPU-less hosts each idle worker's swiftshader process pegs a CPU core, and a preview left open for days stacks up multiple.

Stop a preview when the user is done reviewing (or before starting a new one):

```bash
pkill -f "hyperframes.*preview"     # the Studio server (frees port 3002)
pkill -f chrome-headless-shell      # its render workers; only safe if nothing else uses them
```

If unsure whether other tools use `chrome-headless-shell`, check first: `pgrep -af chrome-headless-shell`. Recover a wedged host (many idle workers spinning CPU) the same way — see [references/troubleshooting.md](references/troubleshooting.md#runaway-cpu-from-leftover-preview-workers).

## Pitfalls

- **Incremental Synchronized Patching vs Full-File Rewrite** — when asked to synchronize character assets or props across existing completed scenes, NEVER rewrite the whole scene composition from scratch. Full-file reconstructions inadvertently drop ambient crowd layers, secondary character staging, and finely tuned narrative timing, causing regressions. Always maintain the proven baseline layout and apply surgical edits exclusively to the targeted vector definitions and coordinates.
- **Contextual Audio Palette (No Playful Melodies on Serious/Crisis Topics)** — background music and procedural audio must strictly match the emotional gravity of the scene. On consumer complaints, product defects, or ethical dilemmas, avoid bouncy lo-fi beats, playful kalimbas, or jaunty melodies. Use slow (~70 BPM) atmospheric sine pads in minor progressions (e.g. Am-F-C-G), low sub-bass, and subtle accents. Shift to warm, optimistic progressions (e.g. C-G-Am-F at 90 BPM) only during resolution and recovery.
- **`<audio>` Tag Placement Inside Viewport** — in standalone Hyperframes HTML compositions, always nest the `<audio id="scene-audio">` element inside the root viewport container (`#viewport`), never outside in `<body>`. Placing `<audio>` outside the composition container leads to DOM compilation warnings and audio pipeline sync mismatches during single-worker headless rendering.
- **Modular Multi-Scene Pipeline for Long-Form Videos (RAM < 2GB)** — attempting to render a monolithic 5-minute+ (9,000+ frames) composition in a single Chromium headless session risks memory exhaustion (OOM), swiftshader cache bloat, and browser worker crashes on resource-constrained hosts. Scaffold the project as modular scene directories (`scene1/`, `scene2/`, ...), each with its own `index.html` and isolated audio track. Render each scene independently with `npx hyperframes render --workers 1 --fps 30 --quality standard --output sceneX.mp4`, then assemble the final master video using FFmpeg concat demuxer: `ffmpeg -y -f concat -safe 0 -i concat_list.txt -c:v copy -c:a aac -b:a 192k -t <total_duration> full_video.mp4`. This caps worker RAM usage below 1GB, enables fast per-scene visual inspection, and guarantees exact cumulative duration.
- **Broadcast Audio Normalization (EBU R128) for Mixed TTS & BGM** — mixing multi-character TTS voice tracks with procedural Web Audio API synthesizers or background music without loudness processing leads to clipping or muddy dialog. Pass the combined audio stream through FFmpeg's loudnorm filter (`[amixed]loudnorm=I=-16:TP=-1.5:LRA=11[aout]`) to normalize integrated loudness to broadcast standard (-16 LUFS, True Peak -1.5 dBTP). Verify with `ffmpeg -i audio.wav -af volumedetect -f null -` before embedding into the composition `<audio>` tag.
- **Articulated Kinematics Stickman Rigging in SVG** — never rotate limb segments using global coordinates on single `<line>` elements, which detaches knees and elbows during walk cycles. Rig each limb segment in nested `<g>` elements where each joint sits at local origin `(0, 0)`: Parent hip/shoulder `transform="translate(x, y)"` -> Upper segment `<g id="thigh">` -> Joint `transform="translate(0, len)"` -> Lower segment `<g id="shin">` -> Foot/Hand. Animate rotation with GSAP `transformOrigin: "0 0"` so child segments remain permanently locked to their parent joints.
- **Double-Group Hierarchy for Pinned Props/Spirits** — when attaching mini-figures or props to a character's shoulder or head, use an outer `<g transform="translate(x, y)">` for absolute socket placement and an inner `<g>` for GSAP bounce/wobble/rotations. Tweening position directly on the socket element overwrites placement coordinates.
- **Quote Escaping in Dynamic Subtitle Injections (`tl.call`)** — when injecting spoken dialogue containing quotes (e.g. `Pak Budi: "Kami memohon maaf..."`) into subtitle or speech DOM elements via `tl.call()`, always use JavaScript template literals (backticks) or `&quot;`. Unescaped double quotes inside double-quoted string literals produce syntax errors that cause `hyperframes lint` to fail with `invalid_inline_script_syntax`.
- **Checklist & Multi-Item Infographic Entrance Pacing** — in multi-item lists, checklists, or step-by-step diagnostic diagrams, pace item entrance keyframes so the final item enters at least 1.5s–2.0s before the shot's exit transition. Delaying the final item's entrance toward the end of the voiceover block causes visual QA frame extractions and viewers to catch the card with missing items and awkward empty whitespace at the bottom.
- **Pacing Long Subtitle Lines via Sequential Segments** — long voiceover lines (>60 characters) at broadcast font sizes (32-38px) easily overflow the 1920px canvas or get truncated at screen boundaries. Split long sentences into natural spoken micro-segments triggered sequentially at audio pauses via `tl.call()` to keep text on a single readable line without clipping.
- **High-Contrast Outlines for Accents in Volumetric Light Cones** — light-colored translucent vectors (e.g., golden halos, yellow sparkles, thin glows) wash out and disappear when placed inside bright volumetric spotlights (e.g. amber lamp cones). Always give accent vectors solid contrasting borders (e.g. `stroke="#78350f"`) and opaque fills so they remain crisp against light beams.
- **Leaving `preview` running** — it's a long-lived server holding Chrome workers; on WSL/containers/CI those idle workers spin a CPU core each (software WebGL). Stop it when done — see [Cleanup](#cleanup).
- **Phonetic vs Display Subtitle Spelling in TTS Workflows** — when modifying spellings for TTS phonetics (e.g., `le-vel`, `i-te-e`, `pe-de-pe`), NEVER apply the phonetic respelling to the visual subtitle or speech bubble DOM elements. Subtitles and onscreen graphics must always keep original authentic spelling (`level`, `ITE`, `PDP`), while phonetic adjustments stay strictly in the voice-generation pipeline.
- **Verbatim Caption Fidelity (Zero-Deviation Rule)** — in narrated storytelling or explainer animations, onscreen subtitles and captions must match the spoken audio voice-over 100% word-for-word. Never paraphrase, condense, or omit words in the caption relative to the voice track, as discrepancy between auditory input and visual reading causes immediate viewer disorientation.
- **Context-Driven BGM Mood & Emotional Arc** — background music must strictly match the narrative gravity of each scene (e.g. slow, atmospheric minor pads Am-F-C-G for problem discovery, crisis, and ethical dilemmas; warm, resolved C-G-Am-F for resolution). Avoid bouncy, playful, or overly fun lead melodies on serious real-world problem or crisis topics. Keep BGM volume well ducked (-24 to -28 dBFS) behind dialogue.
- **Subtitle Line-Breaking & Word-Hyphenation Guard** — containers for subtitles and captions must enforce clean typographic wrapping (`white-space: nowrap` for timed single lines, or explicit balanced breaks with `max-width`). Never allow container boundaries to auto-hyphenate words across lines (e.g., `le-` on line 1, `vel tiga` on line 2), which looks amateurish and breaks readability.
- **Position Absolute on SVG Layers** — when placing SVG character illustrations or animated props inside positioned scene shots, explicitly declare `position: absolute` (either via CSS class or inline style). Relying on default static flow will cause SVGs to drop below parent containers or get clipped off-screen by `overflow: hidden`.
- **Visual Contrast & Environmental Lighting** — avoid washed-out, low-contrast monotone backdrops (e.g., flat pale yellow or murky mud tones). Use structured architectural backgrounds (e.g., wall paneling with wainscoting, localized light sources like pendant lamps or desk lamps that cast explicit light cones) to create depth and separate characters from background layers.
- **Git Tracking on Modular Multi-Step Production** — when a user requests progress tracking via git repository for modular rendering, initialize the repo early, define a strict `.gitignore` (ignoring node_modules, temp logs, huge intermediate cache), and commit/push after each verified scene milestone.
- **2.5D Studio Depth over Heavy 3D Engines** — while Three.js/WebGL runs in Hyperframes, per-frame shader evaluation takes ~15x longer per frame and easily triggers OOM crashes on constrained RAM (<2 GB). Reserve Three.js for isolated hero props; use 2.5D SVG/GSAP (ambient occlusion drop shadows, directional light cones, architectural wainscoting) for scene layouts and character storytelling.
- **SVG Layer Occlusion Behind Parent Silhouette** — when drawing stick figures and wearable accessories (e.g. apron straps, neckties, hair ribbons), coordinates drawn inside the head's bounding radius (`cx`, `cy`, `r`) get occluded by the head stroke/fill. Always loop straps and ties visibly outward across the shoulder plane so they stay legible in visual QA.
- **Visual QA Keyframe Timestamp Alignment** — when extracting snapshot frames via `ffmpeg -ss` to verify elements entering with GSAP `tl.fromTo()`, never sample at the exact start timestamp where opacity is 0. Sample at `start + 0.5s` to `+1.0s` so animated badges, callouts, and alert cards have completed their entrance springs.
- **Single-Worker Render Timeouts on 30s+ Compositions** — rendering 900+ frames with complex DOM/SVG effects on single-worker mode typically takes 130-150 seconds. Standard 180s command timeouts will prematurely terminate the job during final frame assembly. Configure tool execution timeouts to 300s-360s.

- **`HeadlessExperimental.beginFrame' wasn't found`** — Chromium 147+ removed this protocol. Ensure you're on `hyperframes@>=0.4.2` (auto-detects and falls back to screenshot mode). Escape hatch: `export PRODUCER_FORCE_SCREENSHOT=true`. See [hyperframes#294](https://github.com/heygen-com/hyperframes/issues/294) and [references/troubleshooting.md](references/troubleshooting.md).
- **System Chrome (not `chrome-headless-shell`)** — renders hang for 120s then timeout. Run `npx puppeteer browsers install chrome-headless-shell` (setup.sh does this). `hyperframes doctor` reports which binary will be used.
- **`repeat: -1` anywhere** — breaks the capture engine. Always compute a finite repeat count.
- **`gsap.set()` on clip elements that enter later** — the element doesn't exist at page load. Use `tl.set(selector, vars, timePosition)` inside the timeline instead, at or after the clip's `data-start`.
- **`<br>` inside content text** — forced breaks don't know the rendered font width, so natural wrap + `<br>` double-breaks. Use `max-width` to let text wrap. Exception: short display titles where each word is deliberately on its own line.
- **Animating `visibility` or `display`** — GSAP can't tween these. Use `autoAlpha` (handles both visibility and opacity).
- **Calling `video.play()` or `audio.play()`** — the framework owns playback. Never call these yourself.
- **Building timelines async** — the capture engine reads `window.__timelines` synchronously after page load. Never wrap timeline construction in `async`, `setTimeout`, or a Promise.
- **Standalone `index.html` wrapped in `<template>`** — hides all content from the browser. Only **sub-compositions** loaded via `data-composition-src` use `<template>`.
- **Using video for audio** — always muted `<video>` + separate `<audio>`.
- **Using raw Unicode emojis in animations** — never use emojis (`📍`, `🔥`, `🚨`, `❤️`, `💬`) in composition text, badges, mockups, or speech bubbles. They render inconsistently across headless Chrome platforms and look like amateur AI slop. Always use clean inline SVG vector glyphs.
- **Continuous Walk Cycle Cadence vs Static Scissor Poses** — never animate character walking using loose keyframe arrays with large intervals returning to zero rotation; random frame extractions will capture the character frozen in static vertical or scissor poses. Use a continuous walk cycle helper (~0.4s - 0.5s per stride) where Phase 1 (leading leg forward -26°, knee straight -4°, trailing leg back +24°, knee bent +38°, torso bounce y: +10px) smoothly transitions directly into Phase 2 (trailing leg strides forward, leading leg pushes back with bent knee). Reset to rotation 0 only when the walk duration completes.
- **Headgear & Anatomical Proportion Alignment** — when adding headwear (chef toque, hat, helmet) to stylized stick figures, never leave a visual gap or let the brim float above the head contour. Align the brim band flush against the skull top chord (`y_brim = cy_head - r_head`, `rx ≈ 0.7 * r_head`) and expand the dome/puff outward (`rx ≈ 1.2 * r_head` to 120px) to create an organic, balanced silhouette rather than an awkward cylindrical stump.
- **Floating or Ungrounded Props & Characters (Anti-Float Guard)** — seated characters must align pelvis and thighs flush against chair seats; props on tables must mathematically overlap the surface (2-4px) with an explicit cast shadow beneath them (`fill="#000000" opacity="0.25"`). For standing/walking characters, mathematically compute the shoe Y-coordinate to touch the floor baseline (e.g. container bottom + shoe offset = floor line) and ALWAYS include an elliptical contact shadow (`<ellipse id="shadow" rx="38" ry="8" fill="rgba(0,0,0,0.5)">`) directly under feet that pulses (`scaleX: 1.15`) with step cadence; without a contact shadow, characters appear to float in mid-air to viewers and vision QA.
- **CSS `transform` conflicts with GSAP** — never declare `transform: scale(...)` or `translate(...)` in CSS on elements animated with GSAP `scale`/`x`/`y`. GSAP overwrites the entire CSS transform matrix, breaking layout offsets. Set initial transform states strictly with `gsap.set()` or `tl.fromTo()`.
- **Passing raw SSML XML tags to Edge-TTS** — `edge-tts` takes plain text and literally speaks `<speak>` tags aloud. Structure pauses using conversational punctuation (`...`, `,`, `.`) and command flags (`rate="-3%"`, `pitch="+0Hz"`).
- **Windows CLI buffer overflow on large compositions** — giant inline heredocs (`cat << 'EOF' > ...`) fail on Windows MSYS with `WinError 206: The filename or extension is too long`. Generate multi-KB composition files via Python scripts or dedicated generators.

## Verification

Before and after rendering:

1. **Lint + validate + inspect pass:** `npx hyperframes lint --strict && npx hyperframes validate && npx hyperframes inspect` (lint catches structural issues, validate catches contrast, inspect catches visual layout / overflow issues — see troubleshooting.md if warnings appear).
2. **Animation choreography** — for new compositions or significant animation changes, run the animation map. `npx hyperframes init` copies the skill scripts into the project, so the path is project-local:
   ```bash
   node skills/hyperframes/scripts/animation-map.mjs <composition-dir> \
     --out <composition-dir>/.hyperframes/anim-map
   ```
   Outputs a single `animation-map.json` with per-tween summaries, ASCII Gantt timeline, stagger detection, dead zones (>1s with no animation), element lifecycles, and flags (`offscreen`, `collision`, `invisible`, `paced-fast` <0.2s, `paced-slow` >2s). Scan summaries and flags — fix or justify each. Skip on small edits.
3. **File exists + non-zero:** `ls -lh final.mp4`.
4. **Duration matches `data-duration`:** `ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 final.mp4`.
5. **Visual check:** extract a mid-composition frame: `ffmpeg -i final.mp4 -ss 00:00:05 -vframes 1 preview.png`.
6. **Audio present if expected:** `ffprobe -v error -show_streams -select_streams a -of default=nw=1:nk=1 final.mp4 | head -1`.

If `hyperframes render` fails, run `npx hyperframes doctor` and attach its output when reporting.

## References

- [composition.md](references/composition.md) — data attributes, timeline contract, non-negotiable rules, typography/asset rules
- [cli.md](references/cli.md) — every CLI command (init, capture, lint, validate, inspect, preview, render, transcribe, tts, doctor, browser, info, upgrade, benchmark)
- [gsap.md](references/gsap.md) — GSAP core API for HyperFrames (tweens, eases, stagger, timelines, matchMedia)
- [features.md](references/features.md) — captions, TTS, audio-reactive, marker highlighting, transitions (load on demand)
- [website-to-video.md](references/website-to-video.md) — 7-step capture-to-video workflow
- [troubleshooting.md](references/troubleshooting.md) — OpenClaw fix, env vars, common render errors
