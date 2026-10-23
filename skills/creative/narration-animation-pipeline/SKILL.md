---
name: narration-animation-pipeline
description: Use when creating multi-scene animated explainer videos.
version: 1.0.0
platforms: [linux, macos, windows]
prerequisites:
  commands: [ffmpeg, ffprobe, node, python3]
metadata:
  hermes:
    tags: [creative, video, narration, tts, audio-sync, subtitles, animation]
    category: creative
    requires_toolsets: [terminal]
---

# Narration Animation Pipeline

Standardized end-to-end workflow for producing multi-scene 2D explainer and storytelling animated videos with multi-character voice-overs (VO), contextual procedural background music (BGM), zero-collision audio muxing, and millisecond-accurate verbatim captions.

## When to Use

- User asks for a complete narrative or explainer animated video from a script or concept.
- Multi-scene video projects requiring voiceover narration (Edge-TTS, ElevenLabs, etc.) synchronized to onscreen subtitles and visuals.
- Audio muxing involving background music and multiple character dialogue clips.
- Multi-scene rendering on memory-constrained systems (RAM < 2GB) requiring modular concat assembly.

## Procedure

### 1. Audio Scripting & Voice Synthesis
1. Split script into distinct character lines and narrative beats.
2. Structure speech pauses using conversational punctuation (`...`, `,`, `.`). If using phonetics for correct pronunciation in TTS engines (e.g., `le-vel`), keep phonetics strictly in the audio generation pipeline; never leak phonetic respellings into onscreen subtitles or graphics.
3. Generate clean 24kHz/48kHz audio clips per character/part.

### 2. Audio Timing & Zero-Collision Delay Calculation
When sequencing multiple voice-over clips against background music:
1. Run `ffprobe` to extract the EXACT duration of every single audio file:
   ```bash
   ffprobe -v error -show_entries format=duration -of json clip.mp3
   ```
2. Mathematically verify that each subsequent clip starts AFTER the previous clip finishes:
   $$\text{Start}_{i+1} \ge \text{Start}_i + \text{Duration}_i + \text{Buffer (0.4s–0.5s)}$$
3. Automated Probe: Always run a Python probe before mixing to assert `total_collisions == 0`.

### 3. Sub-Sentence Caption Timing via Silence Detection
If an audio file contains multiple sentences or clauses that must be displayed as separate sequential subtitles:
1. Run FFmpeg silence detection:
   ```bash
   ffmpeg -i clip.mp3 -af silencedetect=noise=-30dB:d=0.3 -f null -
   ```
2. Identify the exact timestamp of speech pause boundaries.
3. Trigger subtitle DOM updates (`tl.call`) at `ClipStart + PauseOffset` so the text updates at the exact millisecond the next sentence is spoken.

### 4. Background Music Palette & Ducking
- **Emotional Gravity Match:** Avoid jaunty, bouncy, or playful lead melodies during serious topics (complaints, crisis, dilemmas, regulations). Use slow (~70 BPM) atmospheric sine pads in minor progressions (Am-F-C-G) with sub-bass. Shift to warm, optimistic progressions (C-G-Am-F, 90 BPM) only during resolution and recovery.
- **Ducking:** Set background music volume between -24 dBFS and -28 dBFS behind voiceover.
- **Broadcast Loudness Normalization:** Mux VO and BGM through EBU R128 filter:
   ```text
   [amixed]loudnorm=I=-16:TP=-1.5:LRA=11[aout]
   ```
   Target: -16 LUFS integrated loudness, True Peak <= -1.5 dBTP.

### 5. Modular Per-Scene Rendering & Master Concat
On hosts with constrained memory (<2GB RAM):
1. Render each scene independently as an isolated MP4:
   ```bash
   npx hyperframes render --workers 1 --fps 30 --quality standard --output sceneX.mp4
   ```
2. Concatenate into master video using FFmpeg concat demuxer (lossless stream copy):
   ```bash
   ffmpeg -y -f concat -safe 0 -i concat_list.txt -c copy full_video.mp4
   ```
3. Audit total duration and exact frame count with `ffprobe`.

### 6. Visual Style Trade-offs: 2D vs 3D / Hybrid 3D
When considering 3D or hybrid treatments for narrative explainer videos:
- **2.5D Volumetric Kurzgesagt Style (Recommended):** Uses SVG radial gradients, ambient occlusion shadows, and articulated joint rigs. Retains maximum cartoon expressiveness (facial details, squash-and-stretch, hair sway) while rendering fast and reliably on low-RAM systems.
- **CSS 3D Parallax:** Lightweight, but planes render as flat 2D cardboard cut-outs in 3D space rather than true volumetric meshes.
- **Three.js WebGL Integration:** Enables genuine 3D meshes and lighting, but stickman characters look rigid and lifeless like wooden mannequins. When rendering WebGL in headless Chromium via Hyperframes, always attach `tl.eventCallback("onUpdate", () => renderer.render(scene, camera))` because discrete timeline seeks do not trigger the standard `gsap.ticker` or `requestAnimationFrame`.

## Pitfalls

- **Manual Audio Delay Estimation (Voice Collision)** — never hardcode delay timestamps without calculating `start + duration`. Unverified delays lead to overlapping voices talking simultaneously. Always enforce `next_start >= prev_start + prev_duration + buffer`.
- **Verbatim Caption Divergence** — in narrative storytelling, onscreen subtitles must match the spoken voice-over 100% word-for-word. Paraphrasing or omitting spoken words disorients viewers.
- **Full-File Layout Rewrite on Asset Updates** — when asked to synchronize character props or assets across existing scenes, never rewrite the entire HTML from scratch. Surgical edits preserve complex background layouts and fine-tuned timeline keyframes.
- **GSAP Relative Value Second-Writer Collision (`gsap_relative_value_second_writer`)** — never apply relative tweens (e.g. `x: "+=4"`) while a previous position writer is active. Wait until previous transitions complete, or use explicit `fromTo()` with `immediateRender: false`.
- **GSAP Repeated FromTo State Bleed (`gsap_repeated_fromto_without_baseline`)** — when sequencing multiple `tl.fromTo()` calls on the same target across shots (such as camera rigs or characters), set `immediateRender: false` on every call after the first. Otherwise, GSAP applies the later "from" values at timeline init, corrupting earlier frames.
- **CSS Transform vs GSAP Writer Conflict (`gsap_css_transform_conflict`)** — never mix stylesheet `transform: translateZ(...)` or `rotateY(...)` with GSAP property tweens (`x`, `y`, `z`). GSAP completely overwrites the CSS `transform` attribute, wiping out static 3D transforms. Give GSAP full ownership of all transform axes.
- **Three.js Headless Seek Stall** — headless renderers advance timelines via discrete `tl.seek()`, skipping browser render loops. Without an `onUpdate` callback invoking `renderer.render()`, WebGL captures stale or blank frames.
- **Phonetic Spelling Leakage** — pronunciation respellings belong exclusively in the audio generator. Subtitles and display text must always retain correct dictionary spelling.
- **Raw Unicode Emojis in Vector Animation** — emojis render inconsistently across headless Chromium platforms. Always use pure inline SVG vector illustrations.
