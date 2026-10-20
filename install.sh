#!/usr/bin/env bash
# =============================================================================
# Hadooyy-CLI Installer — Hermes Agent & Claude Code Setup
# =============================================================================
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "💀 [ HADOOYY-CLI ] Starting setup..."

# 1. Detect Hermes home directory
if [ -n "$HERMES_HOME" ]; then
    HERMES_DIR="$HERMES_HOME"
elif [ -d "$LOCALAPPDATA/hermes" ]; then
    HERMES_DIR="$LOCALAPPDATA/hermes"
else
    HERMES_DIR="$HOME/.hermes"
fi
echo "==> Hermes directory: $HERMES_DIR"

# 2. Detect Claude Code directory
CLAUDE_DIR="$HOME/.claude"
echo "==> Claude Code directory: $CLAUDE_DIR"

# 3. Install agent-reach via pip if available
echo "==> Checking agent-reach python dependency..."
if command -v pip >/dev/null 2>&1; then
    pip install agent-reach || echo "[!] pip install agent-reach skipped (already installed or failed, continuing)"
elif command -v pip3 >/dev/null 2>&1; then
    pip3 install agent-reach || echo "[!] pip3 install agent-reach skipped"
fi

# 4. Copy Skin
echo "==> Installing Hadooyy WH40K theme..."
mkdir -p "$HERMES_DIR/skins"
cp "$REPO_DIR/skins/hadooyy.yaml" "$HERMES_DIR/skins/"

# 5. Copy Plugins to Hermes
if [ -d "$REPO_DIR/plugins" ]; then
    echo "==> Installing plugins into Hermes..."
    mkdir -p "$HERMES_DIR/plugins"
    cp -r "$REPO_DIR/plugins/"* "$HERMES_DIR/plugins/"
fi

# 6. Copy Skills to Hermes
echo "==> Installing skills into Hermes Agent..."
mkdir -p "$HERMES_DIR/skills"
for cat_dir in "$REPO_DIR/skills/"*; do
    if [ -d "$cat_dir" ]; then
        cat_name=$(basename "$cat_dir")
        mkdir -p "$HERMES_DIR/skills/$cat_name"
        cp -r "$cat_dir/"* "$HERMES_DIR/skills/$cat_name/"
    fi
done

# 7. Copy Skills to Claude Code (~/.claude/skills)
echo "==> Installing skills into Claude Code..."
mkdir -p "$CLAUDE_DIR/skills"
for cat_dir in "$REPO_DIR/skills/"*; do
    if [ -d "$cat_dir" ]; then
        for skill_dir in "$cat_dir/"*; do
            if [ -d "$skill_dir" ]; then
                sname=$(basename "$skill_dir")
                mkdir -p "$CLAUDE_DIR/skills/$sname"
                cp -r "$skill_dir/"* "$CLAUDE_DIR/skills/$sname/"
            fi
        done
    fi
done

# 8. Configure Hermes Agent
if command -v hermes >/dev/null 2>&1; then
    echo "==> Configuring Hermes Agent skin and MCP servers..."
    hermes config set display.skin hadooyy || true
    hermes config set mcp_servers.rea.command "npx" || true
    hermes config set mcp_servers.rea.args '["-y", "rea-agents@latest", "--mcp"]' || true
    hermes config set mcp_servers.rea.connect_timeout 90 || true
    hermes config set mcp_servers.rea.timeout 180 || true
    hermes config set mcp_servers.agent_reach.command "python" || true
    hermes config set mcp_servers.agent_reach.args '["-m", "agent_reach.integrations.mcp_server"]' || true
else
    echo "[!] 'hermes' command not found on PATH. Run 'hermes config set' after installing hermes."
fi

# 9. Configure Claude Code settings.json
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
echo "==> Updating Claude Code settings ($SETTINGS_FILE)..."
if command -v python >/dev/null 2>&1; then
    python -c "
import json, os
path = os.path.expanduser('$SETTINGS_FILE')
os.makedirs(os.path.dirname(path), exist_ok=True)
data = {}
if os.path.exists(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception:
        data = {}

if 'mcpServers' not in data:
    data['mcpServers'] = {}

data['mcpServers']['rea'] = {
    'command': 'npx',
    'args': ['-y', 'rea-agents@latest', '--mcp']
}
data['mcpServers']['agent-reach'] = {
    'command': 'python',
    'args': ['-m', 'agent_reach.integrations.mcp_server']
}

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)
print('[✓] Claude settings updated.')
" || echo "[!] Failed to update Claude settings with Python"
fi

echo ""
echo "=========================================================="
echo "💀 [ OMNISSIAH ONLINE ] Hadooyy-CLI setup finished successfully!"
echo "=========================================================="
echo "Run 'hermes' to launch your custom agent."
