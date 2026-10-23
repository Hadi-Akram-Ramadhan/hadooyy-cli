---
name: install-external-skills
description: Install skills and MCP servers from Git repos into agents.
---

# Installing External Skills & MCP Servers

Workflow for taking GitHub repos that contain Claude/Hermes skills, MCP servers, or agent plugins and making them permanently available without slash-command invocation.

## Step 1: Inspect the repo structure

Clone with `--depth 1`, then map what's inside. Clone sequentially — no `&` backgrounding in terminal.

```bash
INSPECT_DIR="$LOCALAPPDATA/hermes/cache/scratch/repo-inspect/<name>"
mkdir -p "$INSPECT_DIR"
git clone --depth 1 <url> "$INSPECT_DIR"
find "$INSPECT_DIR" -maxdepth 3 -type f | grep -v '.git' | sort
find "$INSPECT_DIR" -name "SKILL.md"
```

Classify each repo:
- **Skills repo** — has `SKILL.md` files with YAML frontmatter under `.agents/skills/<name>/`, `skills/<name>/`, or root
- **MCP server** — ships via `npx` or has `integrations/mcp_server.py`
- **Framework** — bundles skills in `.agents/skills/` (e.g., open-slide)
- **Python tool** — has `pyproject.toml`, install via pip

Don't mistake `.claude/skills/<name>` symlink files for content — follow them to `.agents/skills/<name>/SKILL.md` for the actual skill.

## Step 2: Install skills into Hermes

```bash
HERMES_SKILLS="$LOCALAPPDATA/hermes/skills"
mkdir -p "$HERMES_SKILLS/<category>"
cp -r "$TMPDIR/repo-inspect/<repo>/.agents/skills/<skill>" "$HERMES_SKILLS/<category>/"
```

Categories: `creative`, `frontend`, `research`, `reverse-engineering`, `claude-code`, `software-development`, `media`, `productivity`.

## Step 3: Install skills into Claude Code

```bash
CLAUDE_SKILLS="$HOME/.claude/skills"
cp -r "$TMPDIR/repo-inspect/<repo>/.agents/skills/<skill>" "$CLAUDE_SKILLS/"
```

No category subdirs in Claude Code — flat list only.

## Step 4: Install Python-based tools

Install to the **Windows Store Python**, not Hermes venv (which has no pip):

```bash
# Find the right python (look for WindowsApps entry):
cmd.exe /c "where python" 2>/dev/null

# Install:
"C:/Users/$USERNAME/AppData/Local/Microsoft/WindowsApps/python.exe" -m pip install <package>

# Verify module works:
"C:/Users/.../python.exe" -m <module> --help
```

The Hermes venv at `$LOCALAPPDATA/hermes/installs/.../venv/` has no `pip` — don't use it.

## Step 5: Register MCP server in Hermes

Direct `config.yaml` edits are blocked by Hermes guard. Use `hermes config set` per key:

```bash
# npx-based (e.g., REA):
hermes config set mcp_servers.<name>.command "npx"
hermes config set mcp_servers.<name>.args '["-y", "<package>@latest", "--mcp"]'
hermes config set mcp_servers.<name>.connect_timeout 90
hermes config set mcp_servers.<name>.timeout 180

# Python module-based:
hermes config set mcp_servers.<name>.command "C:/Users/<user>/AppData/Local/Microsoft/WindowsApps/python.exe"
hermes config set mcp_servers.<name>.args '["-m", "<module.path>"]'

# Verify:
hermes config get mcp_servers
```

Tool names in Hermes: `mcp_<server_name>_<tool_name>` (hyphens/dots → underscores).

## Step 6: Register MCP server in Claude Code

Claude Code `settings.json` has no guard — edit via Python:

```bash
python -c "
import json, os
path = os.path.expanduser('~/.claude/settings.json')
with open(path, 'r', encoding='utf-8') as f:
    d = json.load(f)
if 'mcpServers' not in d:
    d['mcpServers'] = {}
d['mcpServers']['<name>'] = {
    'command': 'npx',
    'args': ['-y', '<package>@latest', '--mcp']
}
with open(path, 'w', encoding='utf-8') as f:
    json.dump(d, f, indent=2)
print('Done')
"
```

## Step 7: Activate

- **Hermes**: restart session (MCP connects at startup, no hot-reload)
- **Claude Code**: restart the app

After installing, update memory's Mandated Skills Suite entry so future sessions know what's available.

## Pitfalls

- Clone repos sequentially — `&` backgrounding is not supported in the terminal tool.
- On Windows MSYS bash, clone into a forward-slash native path (e.g. `$LOCALAPPDATA/hermes/cache/scratch/...`), never bare `/tmp` — native Windows `git` resolves `/tmp` to `C:\tmp` while bash inspects the MSYS virtual `/tmp`, causing 'file not found' or 'directory already exists' errors.
- Locate `SKILL.md` with `find <dir> -name "SKILL.md"` — skill locations vary across repos (`.agents/skills/`, `skills/`, or root).
- `.claude/skills/<name>` files are relative symlinks; read `.agents/skills/` directly for content.
- `hermes config set` args value must be a JSON array string: `'["-y", "pkg"]'` — bare string fails.
- Python MCP server needs package installed in the same interpreter as `command` key. Mismatched interpreter = `ModuleNotFoundError`.
- npx MCP servers with Node version slightly below `engines.node` requirement usually still work despite the warning.
