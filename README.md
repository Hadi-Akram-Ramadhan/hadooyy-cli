# 💀 HADOOYY-CLI

> **Custom Hermes Agent & Claude Code Power-Suite**  
> *Pre-configured with Warhammer 40K / The Void blood-red aesthetic, dual MCP engines, and 130+ curated skills.*

---

## ⚡ Overview

`hadooyy-cli` adalah repositori konfigurasi portabel untuk **Hermes Agent** dan **Claude Code**. Repositori ini menyimpan seluruh personalisasi, skin custom, plugin, integrasi MCP server, dan ratusan skill siap pakai sehingga ketika ganti mesin/device baru, seluruh setup agent dapat direstorasi hanya dengan **1 perintah**.

---

## 🌟 Fitur & Ekosistem

### 1. 🩸 Custom Sinister Theme (`hadooyy.yaml`)
- **Theme**: Warhammer 40K Blood Red (`#ff2200` crimson gradient on `#080808` dark void).
- **Banner**: Font ANSI block `HADOOYY` yang simetris dan rapi di semua resolusi terminal.
- **Hero Emblem**: Sigil monolit abstrak (*The Void / Eldritch Shard*) dengan render Braille 100% presisi monospace (tidak ada distorsi / miring di Windows Terminal).
- **Branding**: Omnissiah prompt markers (`☠`), WH40K custom responses, dan status bar adaptif.

### 2. 🔌 Pre-configured MCP Servers
- **REA (Reverse Engineer Anything)**:
  - Deep analysis untuk native binaries, APK, Electron, WASM, SQLite, PCAP network captures, dan memory dumps.
  - Berjalan via stdio: `npx -y rea-agents@latest --mcp`.
- **Agent Reach**:
  - Routing riset internet di 16 platform (Twitter/X, Reddit, Xiaohongshu, Bilibili, YouTube, LinkedIn, Boss直聘, RSS, Jina, Exa).
  - Berjalan via stdio: `python -m agent_reach.integrations.mcp_server`.

### 3. 🧠 130+ Curated AI Skills
- **Frontend & UI/UX Award-Caliber**:
  - `awwwards`: Rancang website berstandar Awwwards Site of the Day (concept, typography, WebGL, smooth scroll, zero slop).
  - `jury`: QA & grading website otomatis berbasis rubric Awwwards.
  - `emil-design-eng`: Filosofi polish UI, spring animations, dan micro-interactions Emil Kowalski.
  - `apple-design`: Human Interface Guidelines, fluid gestures, dan typography Apple.
  - `shadcn`: Manajemen komponen shadcn/ui dan composable UI.
  - `vercel-composition-patterns` & `vercel-react-best-practices`: Arsitektur React/Next.js enterprise.
- **Security & Pentesting (Strix Suite)**:
  - OWASP Top 10, API security testing, web app pentesting, code security scanning.
- **Architecture & Backend**:
  - Clean Code, Hexagonal architecture, Redis patterns, PostgreSQL/MySQL optimization, Docker workflows, TDD workflow.
- **Research & Knowledge**:
  - `agent-reach`, `graphify` (codebase knowledge graph), `arxiv`, `grounded-citations`.
- **Anti-Slop Suite**:
  - Filter otomatis pembersih AI clichés pada UI, code comments, dan copywriting.

### 4. 🧩 Plugins
- `antislop`: Core filter pencegah generic AI code slop.
- `gopls-lsp`: Language Server Protocol integration untuk Golang.

---

## 🚀 Quick Setup di Device Baru

### Prasyarat
1. **Node.js** (v20+ / v22+) & `npm`
2. **Python** (3.10+) & `pip`
3. **Hermes Agent** sudah terpasang:
   ```bash
   curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
   ```

### 1-Command Installation

#### Di Linux / macOS / Git Bash (Windows):
```bash
git clone https://github.com/Hadi-Akram-Ramadhan/hadooyy-cli.git
cd hadooyy-cli
chmod +x install.sh
./install.sh
```

#### Di Windows (PowerShell):
```powershell
git clone https://github.com/Hadi-Akram-Ramadhan/hadooyy-cli.git
cd hadooyy-cli
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

Script installer akan otomatis:
1. Menginstall library `agent-reach` ke environment Python.
2. Menyalin skin `hadooyy.yaml` ke folder Hermes skins.
3. Menyalin semua skill ke Hermes (`~/.hermes/skills/`) dan Claude Code (`~/.claude/skills/`).
4. Menyalin plugin ke `~/.hermes/plugins/`.
5. Mendaftarkan MCP `rea` dan `agent_reach` ke Hermes (`config.yaml`) dan Claude Code (`settings.json`).
6. Mengaktifkan skin `hadooyy`.

---

## 📂 Struktur Direktori

```
hadooyy-cli/
├── config/
│   ├── mcp_servers.yaml        # Referensi config MCP server Hermes
│   └── claude_settings.json    # Referensi config MCP server Claude Code
├── plugins/
│   ├── antislop/               # Plugin anti AI slop
│   └── gopls-lsp/              # Plugin Go language server
├── skins/
│   └── hadooyy.yaml            # Skin WH40K Blood Red & Sinister Abstract Sigil
├── skills/
│   ├── antislop/               # Skill antislop (UI, code, human, mobile)
│   ├── claude-code/            # 46 Claude Code skills suite
│   ├── frontend/               # Awwwards, Emil, Apple, Vercel, Shadcn
│   ├── research/               # Agent-Reach, ArXiv, Citations
│   └── reverse-engineering/    # REA (Reverse Engineer Anything) suite
├── install.sh                  # One-click installer (Bash)
├── install.ps1                 # One-click installer (PowerShell)
├── LICENSE                     # MIT License
└── README.md
```

---

## 🛠️ Verifikasi Manual

Setelah instalasi selesai, jalankan:

```bash
hermes
```

Di banner Hermes, pastikan:
- Banner merah bertuliskan `HADOOYY` dengan lambang monolit abstrak *The Void* muncul.
- MCP Server `rea` dan `agent_reach` berstatus online / connecting.
- Jumlah skill terdeteksi > 100 skills.

Untuk Claude Code, jalankan di sembarang project:
```bash
claude
```
Dan periksa MCP tools dengan perintah `/doctor` atau periksa ketersediaan tool `rea` dan `agent-reach`.

---

*Omnissiah Online. Built by Hadi.*
