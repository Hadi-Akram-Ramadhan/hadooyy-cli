---
name: remotion-video
description: Create programmatic React videos with Remotion.
version: 0.5.0
author: Hadi (kkhad), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [Remotion, React, Video, MotionGraphics, Animation]
    related_skills: [manim-video, bolt-slides, ui-styling]
---

# Remotion Video Production

Programmatic motion graphics and video synthesis using React, TypeScript, and Remotion.

## When to Use

- Creating programmatic explainer videos, case studies, or slide presentations as video.
- Building AI-generated video templates (faceless stories, SaaS explainers, dynamic clips).
- Automating batch video rendering driven by data or JSON props.
- Don't use for: purely mathematical derivations / 3B1B animations (use `manim-video`).

## Core Remotion Rules

1. **Anti-PPT Motion Law & Continuous Visual Storytelling (Strict):**
   - DILARANG membuat video berformat slide presentasi (kartu kotak statis berisi kicker + judul 2 baris + bullet text yang di-fade bergantian).
   - DILARANG membiarkan background kosong saat narator berbicara panjang lebar. Setiap konsep/klaim narasi WAJIB memiliki elemen visual nyata yang tampil aktif via `getWordFrame()` (mockup HP feed, kwitansi klinik, stempel merah, stopwatch analog, map berkas hukum, papan checklist inspeksi, dokumen kop surat resmi).
   - DILARANG menyembunyikan struktur visual dengan `opacity: 0` selama puluhan frame menunggu kata narator. Struktur visual utama (kartu komparasi, dossier, dashboard) WAJIB tampak sejak awal (frame 0–15) agar penonton memiliki jangkar visual; narasi bertugas memicu highlight, glow, dan pop-in detail pendukung.
   - 1 shot = 1 pernyataan lugas (<= 5 kata per pukulan). Objek produk/hero bergerak ke tengah.
   - Kamera WAJIB memiliki *smooth continuous drift* (sinusoidal float + scale 1.0 -> 1.025) via `CameraRig` dengan kurva bezier halus `Easing.bezier(0.2, 0.8, 0.2, 1)`. Hindari lompatan keyframe mendadak.
   - Transisi WAJIB menggunakan `TransitionSeries` dengan overlap cukup (20-25 frames) dan variasi (slide multi-arah, wipe, depth zoom). Dilarang `<Series>` polos tanpa overlap.

2. **Widescreen 1920x1080 Viewport & Screen Filling (Anti-Dead Space):**
   - DILARANG membatasi lebar layout dengan `max-w-7xl` (1280px) atau `max-w-5xl` (1024px) di kanvas 1080p, karena akan menyisakan 33–40% area kosong mati di sisi kiri dan kanan. Gunakan `max-w-[1780px] w-full` (93% viewport coverage) dengan safe-zone margin horizontal ~70px.
   - DILARANG menggunakan `items-center justify-center` pada container 100% height (1080px) karena akan mengelompokkan konten di tengah dan menyisakan 30% area kosong mati di atas dan bawah. Gunakan `justify-start pt-7 pb-36` dengan tinggi kartu utama `h-[700px]` hingga `h-[820px]`.
   - Subtitle Clearance: Kartu visual terendah wajib berakhir di `y <= 920px`, menyisakan zona aman 40–50px di atas subtitle banner yang berada di `bottom: 40-50px` agar tidak pernah bertabrakan atau terpotong.

3. **1080p Typography & Legibility Standards:**
   - DILARANG menggunakan font kecil (<= 12px) untuk konten utama di resolusi 1920x1080 karena akan buram dan tidak terbaca.
   - Judul Utama / Header: `48px` – `64px` (`text-5xl` / `text-6xl`, font-black).
   - Judul Kartu / Subjudul: `24px` – `32px` (`text-2xl` / `text-3xl`, font-black/extrabold).
   - Teks Penjelas / Body: `14px` – `18px` (`text-sm` / `text-base`, font-semibold/bold).
   - Kontras Tinggi: Teks gelap di atas kartu putih/terang, teks terang di atas aksen gelap/pekat.

4. **Zero CSS Transitions/Animations:**
   - DILARANG menggunakan `transition-all`, `@keyframes`, atau utility `animate-*`.
   - Headless Chrome renders frame-by-frame; CSS transitions are non-deterministic and desync under concurrency.
   - Semua gerak dan perubahan visual WAJIB dikendalikan oleh `useCurrentFrame()` dan `useVideoConfig()`.

5. **Physics Springs & Clamped Interpolation:**
   - Gunakan `spring({ frame, fps, config: { damping: 14, stiffness: 140, mass: 0.8 } })` untuk entrance kartu, ikon pop-in, atau scaling.
   - Offset start frame dengan `Math.max(0, frame - delay)`.
   - Selalu berikan options `extrapolateLeft: 'clamp'` dan `extrapolateRight: 'clamp'` pada setiap `interpolate()`.

6. **Viral Social Captions & Native Voiceover:**
   - **Subtitle Style**: DILARANG membungkus 6+ kata dalam pill sempit mirip navbar. Gunakan *phrase chunking* (2–3 kata per burst) di lower third (`bottom: 40-50px`) dengan ukuran font besar (`48px`–`52px` font-black) berlatar blur gelap (`bg-slate-950/85 backdrop-blur-md`). Kata aktif membal (`scale 1.12x`) dan menyala aksen (Amber `#f59e0b` / Emerald `#10b981`) dengan glow text-shadow, kata pasif putih `#ffffff`.
   - **Voice Accent Rule**: Untuk narasi bahasa Indonesia, hindari memaksakan model multilingual dengan voice library persona Barat (menghasilkan aksen bule/asing aneh). Gunakan Edge-TTS `id-ID-ArdiNeural` (pria, otoritatif) atau `id-ID-GadisNeural` (wanita) untuk intonasi 100% lokal autentik dan bersih.
   - Durasi video DILARANG di-hardcode. `Root.tsx` memakai `calculateMetadata` membaca `timing.json` secara dinamis.

7. **Audio Hierarchy & Ducking:**
   - Narasi 1.0 > SFX 0.25-0.45 > BGM 0.08-0.20.
   - Pasang narasi dan BGM di level composition utama (di luar `TransitionSeries` agar tidak terpotong transisi).
   - BGM WAJIB ducking otomatis ke 0.08-0.10 saat narasi aktif (jendela +/- 6 frame dari kata aktif), kembali ke 0.20 saat hening, dan naik ke 0.25 di outro sebelum fade out 90 frame terakhir.
   - Normalisasi: Voiceover -16 LUFS, SFX -18 LUFS, BGM -23 LUFS.

## Architecture & File Structure

```
project-dir/
  public/
    voiceover-lengkap.mp3     # Audio narasi gabungan (Native Indonesian)
    timing.json               # Word & character alignment data
    sfx/*.mp3                 # Sound effects (whoosh, pop, chime, etc.)
    music/bgm.mp3             # Background music bed
  src/
    constants.ts              # Single source of truth: naskah teks, tema warna, data studi kasus
    lib/
      timing.ts               # Parser alignment karakter ke kata, Sequence duration math, hook & context
    components/
      Background.tsx          # Dynamic subtle grid + parallax radial glow
      CameraRig.tsx           # Transform wrapper (continuous sinusoidal drift, deduplicated keyframes)
      WordCaptions.tsx        # 2-3 words viral punchy subtitle (48-52px) with dark blur backdrop
      KineticWord.tsx         # Large punchy keyword entrance with spring overshoot
      Sfx.tsx                 # <Sequence from={at}><Audio src={...} /></Sequence>
      PhoneMockup.tsx         # Responsive UI / device mockup
    scenes/
      Scene1Hook.tsx          # Modular scene components (max-w-[1780px], h-[700-820px])
      Scene2Dilemma.tsx
    MainVideo.tsx             # <TransitionSeries> wrapper + Audio ducking mixer
    Root.tsx                  # <Composition> + calculateMetadata
    index.ts                  # registerRoot(Root)
    index.css                 # @import "tailwindcss" + CSS animation/transition reset
```

## Verification Gates

1. **Typecheck & Lint:**
   ```bash
   npx tsc --noEmit
   ```
2. **Per-Scene Keyframe Inspection (Still):**
   Render minimal 2 frame kunci per scene untuk memverifikasi layout dan keterbacaan:
   ```bash
   npx remotion still MainVideo out/s1.png --frame=100
   npx remotion still MainVideo out/s2.png --frame=950
   ```
3. **Slice Video Render (5 Detik):**
   Uji encoding H.264 / audio ducking pada rentang pendek:
   ```bash
   npx remotion render MainVideo out/test.mp4 --frames=0-150 --codec=h264
   ```
4. **Full Production Render & Loudness Check:**
   ```bash
   npx remotion render MainVideo out/video.mp4 --codec=h264
   ffmpeg -i out/video.mp4 -af loudnorm=print_format=summary -f null -
   ```

## Pitfalls

- **CameraRig Keyframe Monotonicity:** `interpolate()` di Remotion melempar fatal error `inputRange must be strictly monotonically increasing` jika keyframe memiliki frame duplikat atau tidak urut. `CameraRig` wajib memfilter keyframe: `uniqueKeyframes.push(kf)` hanya jika `kf.frame > prev.frame`.
- **Tailwind max-w-7xl Void on 1080p:** `max-w-7xl` bernilai 1280px, meninggalkan 640px ruang kosong mati di resolusi 1920x1080. Gunakan `max-w-[1780px]` untuk mengisi 93% layar secara seimbang.
- **Vertical Clustered Centering Void:** Menggunakan `items-center justify-center` pada container 100% height menyisakan 30% area kosong mati di atas dan bawah. Gunakan `justify-start pt-7 pb-36` dengan kartu setinggi `700-820px`.
- **Tiny Text on 1080p Displays:** Teks di bawah 14px tidak terbaca di video 1080p. Gunakan minimal `14px-18px` untuk detail sekunder dan `24px-32px` untuk subjudul/kartu.
- **Continuous Narration Sync:** Hindari frame kosong saat narasi berjalan. Setiap konsep yang disebut narator wajib memicu visual concrete via `getWordFrame()`.
- **Google Fonts Signature:** `@remotion/google-fonts` membutuhkan style parameter terlebih dahulu: `loadFont('normal', { weights: ['600', '700'], ignoreTooManyRequestsWarning: true })`. Melewatkan objek opsi sebagai parameter pertama menyebabkan runtime error `font does not have style [object Object]`.
- **ElevenLabs Free Tier Limits:** Akun ElevenLabs gratis menolak suara library via API (status 402). Selalu gunakan ID premade standar (Bella: `EXAVITQu4vr4xnSDxMaL`, Brian: `nPczCjzI2devNBz1zQrb`, Adam: `pNInz6obpgDQGcFmaJgB`). Sound generation API memerlukan `duration_seconds >= 0.5`. Music API memerlukan tier Creator berbayar; gunakan fallback prosedural FFmpeg chord pad jika 402.
- **Unclamped Interpolation:** Memanggil `interpolate` tanpa `clamp` menyebabkan nilai translasi atau opacity terus bertambah di luar durasi scene.
- **Transparent Canvas Artifact:** Lupa menyetel `backgroundColor` eksplisit pada container utama menghasilkan artifact hitam kotor pada kompresi H.264.
- **Series vs Absolute Frames:** Di dalam `<TransitionSeries.Sequence>`, `useCurrentFrame()` otomatis direset mulai dari 0 untuk sequence tersebut. Jangan menghitung offset frame global di dalam scene individual tanpa context.
- **Windows Pathing in CLI Audio Tools (edge-tts / ffmpeg):** Native Windows binaries executed from MSYS bash fail with `FileNotFoundError` when given `/c/Users/...` POSIX paths. Always supply `C:/Users/...`-style forward-slash paths for `--write-media` and `-i` arguments.
- **Procedural Audio Generation via Web Audio API:** When external SFX/music assets are prohibited or unavailable, generate audio programmatically using `OfflineAudioContext` in a headless browser runtime. Enforce 10-30ms attack and exponential release ramps to eliminate clicks, constrain harmonies to pentatonic scales with low-pass filters (2-5 kHz), and synthesize impulse responses for natural convolver reverb.
- **Background Processes on Long Renders:** Render di atas 600 detik dipromosikan ke background process oleh terminal Hermes. Pantau dan tunggu hingga tuntas via `process_manage(action='wait')`.
