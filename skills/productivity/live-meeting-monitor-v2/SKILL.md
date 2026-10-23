---
name: live-meeting-monitor-v2
description: "Use when monitoring live meetings. Capture screen/audio."
version: 1.2.0
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
- User wants background meeting capture with live updates pushed to Telegram, WhatsApp, or messaging groups.

## Procedure

### 1. Identify Running Meeting Application

Verify which meeting client is active without stealing focus:
- Windows: inspect running processes (`psutil`) and window titles (`win32gui`).
  ```bash
  py -3.12 -c "import win32gui; win32gui.EnumWindows(lambda hwnd, _: print(win32gui.GetWindowText(hwnd)) if any(k in win32gui.GetWindowText(hwnd).lower() for k in ['zoom', 'teams', 'meet']) else None, None)"
  ```
- Specifically check for active meeting windows (e.g. `'Zoom Meeting'`), as host shell launchers (`'Zoom Workplace'`) stay open even after a meeting concludes.

### 2. Standby Mode & Pre-Meeting Handling

When launching the monitor before the presentation or meeting has officially begun:
1. **Sample baseline idle screen**:
   - Capture `idle_thumb` on startup. Distinguish the inactive meeting view (dark background, centered user avatar tile, `std < 24.0` and `mean < 30.0`) from an active presentation.
2. **Transition trigger**:
   - Only transition from standby to active presentation when `diff(thumb, idle_thumb) > 10.0` or presentation contrast indicators fire (`std > 24.0 or mean > 40.0`).
3. **Periodic standby heartbeats**:
   - While in standby, emit a concise status ping every ~5 minutes (e.g. "Standby in room, waiting for screen share/speaker"). Never let the monitor stay silent for 15+ minutes during pre-meeting, or users will assume it stalled.

### 3. Capture and Analyze Visual Content

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

### 4. Audio Capture & Hardware Fallbacks

1. **Query loopback vs hardware input**:
   - Query Stereo Mix first: `[(i, d['name']) for i, d in enumerate(sd.query_devices()) if d['max_input_channels'] > 0 and 'stereo mix' in d['name'].lower()]`.
   - **Bluetooth headset trap**: When Bluetooth headphones (e.g. Mithril, Sony, AirPods) are connected, Windows routes system audio exclusively to the Bluetooth sink, leaving Realtek Stereo Mix dead silent (amplitude ~0.0001).
   - If Stereo Mix records no signal, probe active input devices (e.g. `Microphone Array` via WASAPI) and record at native rate (48000Hz), then decimate 3x to 16000Hz mono.
2. Stream audio continuously into WAV:
   - Record in native rate (e.g. 48000Hz stereo `int16`).
   - Note: Python `wave.open()` does NOT support `'ab'` (append mode); use unique timestamped files for each recording session.
3. Downsample cleanly for speech-to-text / multimodal model input:
   - Convert `int16` stereo to `float32` mono: `mono = (stereo[:, 0] + stereo[:, 1]) / 2.0`.
   - Downsample by decimation to 16kHz: `mono_16k = mono[::3].astype(np.int16)`.
   - Do NOT multiply already-scaled `int16` buffers by 32767; it causes integer overflow and clipped static noise.

### 5. Multi-Target Delivery (WhatsApp & Telegram)

1. **Dual-target routing hygiene (Personal DM vs Group)**:
   - Keep test probes, connection tests, and experimental debugging strictly in personal DM.
   - Group channels must receive ONLY clean, final deliverables: verified slide photos, verbatim transcripts, structured summaries, and clean milestone status updates.
2. **Accumulate audio for the full slide lifetime**:
   - Begin buffering audio when a slide first appears.
   - Accumulate throughout the entire duration that slide stays on screen (1-5+ minutes).
   - Upon detecting a transition to the next slide, extract the entire audio segment recorded for the completed slide and reset the buffer for the incoming slide.
3. **Full verbatim transcript & in-depth breakdown**:
   - Pass the slide image + full audio buffer to the multimodal AI endpoint.
   - Request verbatim dialogue transcript without shortening or pruning, followed by a granular breakdown of how the speaker's points tie to the slide content.
4. **Message delivery & payload formatting**:
   - Send slide image with a concise header caption.
   - Send the complete verbatim transcript and detailed explanation in a separate text message immediately after the photo.
   - Telegram enforces a strict 1024-character caption limit on photos; WhatsApp captions exceed easily but separate text bubbles remain easier to quote-reply.
   - **Interim updates on long slides**: If a speaker stays on the same slide for > 2.5 minutes without transitioning, send an interim audio transcript update.
5. **Silence thinking logs on WhatsApp / chat platforms**:
   - When users reply to the bot in a group or DM, default gateway streaming or reasoning logs pollute the conversation. Ensure reasoning and progress streams are silenced:
     ```bash
     hermes config set display.platforms.whatsapp.tool_progress off
     hermes config set display.platforms.whatsapp.interim_assistant_messages false
     hermes config set display.platforms.whatsapp.show_reasoning false
     hermes config set display.platforms.whatsapp.busy_ack_detail false
     hermes config set display.platforms.whatsapp.streaming false
     ```
6. **Auto-termination**:
   - Automatically stop background audio and capture workers when the meeting window closes (`Zoom Meeting` window destroyed). Flush and analyze the final active slide before exiting.

## Pitfalls

- **Do not record microphone only**: remote speaker voices come through system output (Stereo Mix / WASAPI loopback).
- **Never re-use stale scratch frames**: users check clock and slide numbers; always take a fresh capture at the trigger moment.
- **Whole-screen diff causes duplicate spam**: participant camera motion and taskbar clocks change constantly; crop to the slide container before computing visual diff.
- **Arbitrary 20-30s audio slicing loses context**: slides often last 2-5 minutes; slicing only the trailing 20 seconds drops 90% of what the speaker said. Accumulate audio continuously from slide appearance to transition.
- **Do not send raw audio files by default**: users want transcribed text and clear actionable notes in chat, not large raw audio files cluttering their messaging app.
- **Telegram photo caption 1024-char limit**: full verbatim transcripts cause `PHOTO_CAPTION_TOO_LONG` errors on `sendPhoto`. Send the slide image with a concise header caption, then send the full detailed transcript via text message.
- **Audio int16 overflow bug**: audio buffers already in `int16` will overflow into noise if multiplied by 32767. Normalize safely before sending to AI endpoints.
- **wave.open mode**: `wave.open()` only supports `'r'`, `'rb'`, `'w'`, and `'wb'`. It throws `wave.Error` on `'ab'`.
- **Baileys WhatsApp pairing rejection**: Using custom browser strings like `['Hermes Agent', 'Chrome', '120.0']` triggers disconnect code 515 / "couldn't link device" on WhatsApp servers. Use `Browsers.ubuntu('Chrome')`.
- **WhatsApp group open policy requires allow-all**: Setting `WHATSAPP_GROUP_POLICY=open` refuses startup unless `WHATSAPP_ALLOW_ALL_USERS=true` or `GATEWAY_ALLOW_ALL_USERS=true` is set.
- **Leaking debug logs to shared groups**: Never test API pings or send debug logs to public/shared team groups. Isolate all diagnostic sends to the owner's personal DM.
