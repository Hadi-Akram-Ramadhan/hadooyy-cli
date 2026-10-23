---
name: live-meeting-monitor
description: "Use when monitoring live meetings. Capture screen/audio."
version: 1.1.0
author: Hermes Agent
license: MIT
platforms: [windows, macos, linux]
metadata:
  hermes:
    tags: [meetings, live-meeting, screen-capture, audio-recording, vision-analysis, productivity]
    category: productivity
---

# Live Meeting Monitor

Monitor, snapshot, and analyze live desktop meetings (Zoom, Google Meet, Microsoft Teams, Discord) on demand or periodically using non-intrusive screen capture and audio loopback.

## When to Use

- User is running a live meeting and asks to "pantau layar", "rekam meeting", or "analisis apa yang dibahas".
- Need to extract slide content, speaker names, chat, or attendees from a running meeting without interrupting the user.
- User wants background meeting capture with live updates pushed to Telegram or messaging channels.

## Procedure

### 1. Identify Running Meeting Application

Verify which meeting client is active without stealing focus:
- Windows: inspect running processes (`psutil`) and window titles (`win32gui`).
  ```bash
  py -3.12 -c "import win32gui; win32gui.EnumWindows(lambda hwnd, _: print(win32gui.GetWindowText(hwnd)) if any(k in win32gui.GetWindowText(hwnd).lower() for k in ['zoom', 'teams', 'meet']) else None, None)"
  ```
- Specifically check for active meeting windows (e.g. `'Zoom Meeting'`), as host shell launchers (`'Zoom Workplace'`) stay open even after a meeting concludes.

### 2. Capture and Analyze Visual Content

Always isolate the meeting window directly rather than capturing the full desktop:
1. **Window-isolated capture (`PrintWindow` via Win32 API)**:
   - Fullscreen `ImageGrab.grab()` captures whatever window is in front. When the user Alt-Tabs or works in an IDE/browser, desktop-wide grab captures unrelated apps and triggers false slide transition diffs.
   - Use `PrintWindow` with `PW_RENDERFULLCONTENT` (`2`) directly on the target HWND:
     ```python
     hwndDC = win32gui.GetWindowDC(hwnd)
     mfcDC = win32ui.CreateDCFromHandle(hwndDC)
     saveDC = mfcDC.CreateCompatibleDC()
     saveBitMap = win32ui.CreateBitmap()
     saveBitMap.CreateCompatibleBitmap(mfcDC, w, h)
     saveDC.SelectObject(saveBitMap)
     ctypes.windll.user32.PrintWindow(hwnd, saveDC.GetSafeHdc(), 2)
     bmpinfo = saveBitMap.GetInfo()
     bmpstr = saveBitMap.GetBitmapBits(True)
     img = Image.frombuffer('RGB', (bmpinfo['bmWidth'], bmpinfo['bmHeight']), bmpstr, 'raw', 'BGRX', 0, 1)
     ```
   - This cleanly captures the meeting canvas even if occluded by other foreground windows.
2. Deduplicate slides before pushing:
   - Crop strictly to the presentation viewport (e.g. left ~75%, top 6% to 94%) to exclude moving webcam video tiles and OS taskbar clock changes.
   - Calculate mean pixel diff on downscaled thumbnail (64x36 grayscale). Trigger ONLY when diff exceeds threshold (> 7.0).
   - Never push timer-based duplicate captures when the slide has not changed. Track seen slide indices/titles to guarantee zero repeated pushes.
3. Multi-monitor screenshot handling:
   - On multi-monitor setups (e.g. width >= 3840px), user-captured screenshots span all displays (including wallpaper or terminal windows). Check image dimensions and split/crop to the display half containing the presentation before processing or delivering to chat channels.
4. Inspect immediately with vision model:
   - Extract slide title, bullet points, and diagrams.
   - Separate slide content from speaker video tiles and attendee overlays.

### 3. Capture Audio via Loopback (Remote Speakers)

Remote speaker voices come through system output (Realtek / WASAPI loopback / Stereo Mix). Microphone captures ambient room noise and misses remote participants.
1. Query loopback device (Stereo Mix or WASAPI output):
   ```bash
   py -3.12 -c "import sounddevice as sd; print([(i, d['name']) for i, d in enumerate(sd.query_devices()) if d['max_input_channels'] > 0 and 'stereo mix' in d['name'].lower()])"
   ```
2. Stream audio continuously into WAV:
   - Record in native rate (e.g. 48000Hz stereo `int16`).
   - Note: Python `wave.open()` does NOT support `'ab'` (append mode); use unique timestamped files for each recording session.
3. Downsample cleanly for speech-to-text / multimodal model input:
   - Convert `int16` stereo to `float32` mono: `mono = (stereo[:, 0] + stereo[:, 1]) / 2.0`.
   - Downsample by decimation to 16kHz: `mono_16k = mono[::3].astype(np.int16)`.
   - Do NOT multiply already-scaled `int16` buffers by 32767; it causes integer overflow and clipped static noise.

### 4. Continuous Live Updates & Push to Telegram

When streaming live meeting progress to messaging platforms (e.g. Telegram):
1. **Accumulate audio for the full slide lifetime**:
   - Begin buffering audio when a slide first appears.
   - Keep accumulating throughout the entire duration that slide stays on screen (can be 1-5+ minutes).
   - Upon detecting a transition to the next slide, extract the entire audio segment recorded for the completed slide and reset the buffer for the incoming slide.
2. **Full verbatim transcript & in-depth breakdown**:
   - Pass the slide image + full audio buffer to the multimodal AI endpoint.
   - Request verbatim dialogue transcript without shortening or pruning, followed by a granular breakdown of how the speaker's points tie to the slide content.
3. **Message delivery & payload splitting**:
   - Send `sendPhoto` with the fresh slide image and a concise header caption (e.g. slide title and brief thesis).
   - Send the complete verbatim transcript and detailed explanation in a separate `sendMessage` immediately after the photo. Telegram photos enforce a strict 1024-character caption limit that drops or fails long analyses.
   - Do NOT send raw `.wav` or `.mp3` audio files unless the user explicitly requests raw recordings.
   - **Interim updates on long slides**: If a speaker stays on the same slide for > 2.5 minutes without transitioning, send an interim audio transcript update. Otherwise, prolonged silence causes users to assume the monitor died or crashed.
4. **Auto-termination**:
   - Automatically stop background audio and capture workers when the meeting window closes (`Zoom Meeting` window destroyed). Flush and analyze the final active slide before exiting.

## Pitfalls

- **Do not record microphone only**: remote speaker voices come through system output (Stereo Mix / WASAPI loopback).
- **Never re-use stale scratch frames**: users check clock and slide numbers; always take a fresh `ImageGrab.grab()` at the trigger moment.
- **Whole-screen diff causes duplicate spam**: participant camera motion and taskbar clocks change constantly; crop to the slide container before computing visual diff.
- **Arbitrary 20-30s audio slicing loses context**: slides often last 2-5 minutes; slicing only the trailing 20 seconds drops 90% of what the speaker said. Accumulate audio continuously from slide appearance to transition.
- **Do not send raw audio files by default**: users want transcribed text and clear actionable notes in chat, not large raw audio files cluttering their messaging app.
- **Telegram photo caption 1024-char limit**: full verbatim transcripts cause `PHOTO_CAPTION_TOO_LONG` errors on `sendPhoto`. Send the slide image with a concise header caption, then send the full detailed transcript via `sendMessage`.
- **Audio int16 overflow bug**: audio buffers already in `int16` will overflow into noise if multiplied by 32767. Normalize safely before sending to AI endpoints.
- **wave.open mode**: `wave.open()` only supports `'r'`, `'rb'`, `'w'`, and `'wb'`. It throws `wave.Error` on `'ab'`.
