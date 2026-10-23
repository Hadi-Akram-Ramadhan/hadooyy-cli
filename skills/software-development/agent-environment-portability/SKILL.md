---
name: agent-environment-portability
description: Export, customize, and replicate agent environments.
---

# Agent Environment Portability & Customization

Workflow for capturing, branding, and packaging Hermes Agent and Claude Code setups into portable Git repositories for single-command cross-device replication.

## When to Use

Use when backing up an agent environment, designing terminal themes/emblems, wiring multi-agent skills/MCPs, or setting up a new device from a config repository.

## Step 1: Skin & Terminal Branding

Hermes custom skins live in `~/.hermes/skins/<name>.yaml`. Activate via `hermes config set display.skin <name>`.

### Banner Text (`banner_logo`)
- Use ANSI block font characters (`██╗`, `╚═╝`) rather than figlet fonts. Figlet letters generate wide, irregular spacing that looks disjointed in modern terminals.
- Bound width to <= 60 columns so the banner does not wrap on split terminal panes.

### Hero Art (`banner_hero`)
- **Avoid box diagonals and wide symbols**: Characters like `╱`, `╲`, `◉`, `▲`, `☩` have ambiguous display width. Windows Terminal and CJK fonts often treat them as 2 columns, twisting symmetrical art into lopsided shapes.
- **Use Braille patterns (U+2800..U+28FF)**: Braille dots (`⠀`, `⢀`, `⣴`, `⣿`) and Braille spaces (`\u2800`) are guaranteed strict 1-column monospace across all terminal fonts and OSes.
- **Aesthetic restraint**: Avoid literal cartoon skulls unless requested. Abstract, geometric, occult, or monolith sigils look significantly more refined and sinister.

## Step 2: Portable Repository Layout

When structuring a setup repository (e.g., `hadooyy-cli`):

```
repo/
├── config/             # MCP server templates (mcp_servers.yaml, claude_settings.json)
├── plugins/            # Bundled plugins (e.g. antislop, gopls-lsp)
├── skins/              # Custom YAML skins
├── skills/             # Skills by category (frontend, research, reverse-engineering, etc.)
├── install.sh          # One-click POSIX installer (Linux, macOS, Git Bash)
├── install.ps1         # One-click Windows PowerShell installer
└── README.md           # Setup instructions and inventory
```

## Step 3: Installation & Replication Scripting

### Skill Distribution
- **Hermes**: Copy categorized directories to `$HERMES_HOME/skills/<category>/<skill>/`.
- **Claude Code**: Claude does not support category subfolders. Flatten all skills directly into `~/.claude/skills/<skill>/`.

### MCP Server Registration
- **Hermes**: Direct edits to `config.yaml` are blocked by an internal guard. Use CLI commands:
  ```bash
  hermes config set mcp_servers.<name>.command "npx"
  hermes config set mcp_servers.<name>.args '["-y", "pkg@latest", "--mcp"]'
  hermes config set mcp_servers.<name>.connect_timeout 90
  hermes config set mcp_servers.<name>.timeout 180
  ```
- **Claude Code**: Update `~/.claude/settings.json` under `mcpServers` via a python script.

### Python Environment Isolation
- On Windows, install Python-based agent CLIs (like `agent-reach`) to the system or Windows Store Python (`python -m pip install <pkg>`), not the Hermes virtualenv (which lacks `pip`).

## Step 4: Strict Git Safety

- **NEVER auto-commit or auto-push to user repositories.** Always prepare the files, stage them, and request explicit human confirmation before executing `git commit` or `git push`.
- Never commit `.env`, secret tokens, session transcripts, or SQLite database files.

## Pitfalls

- Bare string in `hermes config set args`: Must be a valid JSON array string `'["-y", "pkg"]'`, otherwise Hermes refuses to parse it.
- Python MCP servers must run using the python binary where dependencies are actually installed; mismatched interpreters cause silent `ModuleNotFoundError` during startup discovery.
