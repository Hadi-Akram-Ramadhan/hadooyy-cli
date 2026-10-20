# =============================================================================
# Hadooyy-CLI Installer — Windows PowerShell Setup
# =============================================================================
$ErrorActionPreference = "Continue"

Write-Host "💀 [ HADOOYY-CLI ] Starting setup..." -ForegroundColor Red

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. Detect Hermes directory
if ($env:HERMES_HOME) {
    $HermesDir = $env:HERMES_HOME
} elseif (Test-Path "$env:LOCALAPPDATA\hermes") {
    $HermesDir = "$env:LOCALAPPDATA\hermes"
} else {
    $HermesDir = "$HOME\.hermes"
}
Write-Host "==> Hermes directory: $HermesDir" -ForegroundColor Yellow

# 2. Detect Claude Code directory
$ClaudeDir = "$HOME\.claude"
Write-Host "==> Claude Code directory: $ClaudeDir" -ForegroundColor Yellow

# 3. Install agent-reach via pip
Write-Host "==> Checking agent-reach python dependency..." -ForegroundColor Yellow
python -m pip install agent-reach

# 4. Copy Skin
Write-Host "==> Installing Hadooyy WH40K theme..." -ForegroundColor Yellow
$SkinDir = "$HermesDir\skins"
New-Item -ItemType Directory -Force -Path $SkinDir | Out-Null
Copy-Item -Force "$RepoDir\skins\hadooyy.yaml" "$SkinDir\"

# 5. Copy Plugins to Hermes
if (Test-Path "$RepoDir\plugins") {
    Write-Host "==> Installing plugins into Hermes..." -ForegroundColor Yellow
    $PluginDir = "$HermesDir\plugins"
    New-Item -ItemType Directory -Force -Path $PluginDir | Out-Null
    Copy-Item -Recurse -Force "$RepoDir\plugins\*" "$PluginDir\"
}

# 6. Copy Skills to Hermes
Write-Host "==> Installing skills into Hermes Agent..." -ForegroundColor Yellow
$HermesSkills = "$HermesDir\skills"
New-Item -ItemType Directory -Force -Path $HermesSkills | Out-Null
Get-ChildItem -Directory "$RepoDir\skills" | ForEach-Object {
    $Target = Join-Path $HermesSkills $_.Name
    New-Item -ItemType Directory -Force -Path $Target | Out-Null
    Copy-Item -Recurse -Force (Join-Path $_.FullName "*") $Target
}

# 7. Copy Skills to Claude Code
Write-Host "==> Installing skills into Claude Code..." -ForegroundColor Yellow
$ClaudeSkills = "$ClaudeDir\skills"
New-Item -ItemType Directory -Force -Path $ClaudeSkills | Out-Null
Get-ChildItem -Directory "$RepoDir\skills" | ForEach-Object {
    Get-ChildItem -Directory $_.FullName | ForEach-Object {
        $SkillTarget = Join-Path $ClaudeSkills $_.Name
        New-Item -ItemType Directory -Force -Path $SkillTarget | Out-Null
        Copy-Item -Recurse -Force (Join-Path $_.FullName "*") $SkillTarget
    }
}

# 8. Configure Hermes Agent
if (Get-Command hermes -ErrorAction SilentlyContinue) {
    Write-Host "==> Configuring Hermes Agent skin and MCP servers..." -ForegroundColor Yellow
    hermes config set display.skin hadooyy
    hermes config set mcp_servers.rea.command "npx"
    hermes config set mcp_servers.rea.args '["-y", "rea-agents@latest", "--mcp"]'
    hermes config set mcp_servers.rea.connect_timeout 90
    hermes config set mcp_servers.rea.timeout 180
    hermes config set mcp_servers.agent_reach.command "python"
    hermes config set mcp_servers.agent_reach.args '["-m", "agent_reach.integrations.mcp_server"]'
} else {
    Write-Host "[!] 'hermes' command not found on PATH." -ForegroundColor DarkYellow
}

# 9. Configure Claude Code settings.json
$SettingsFile = "$ClaudeDir\settings.json"
Write-Host "==> Updating Claude Code settings ($SettingsFile)..." -ForegroundColor Yellow
python -c "
import json, os
path = os.path.expanduser('$SettingsFile')
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
"

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Red
Write-Host "💀 [ OMNISSIAH ONLINE ] Hadooyy-CLI setup finished successfully!" -ForegroundColor Red
Write-Host "==========================================================" -ForegroundColor Red
Write-Host "Run 'hermes' to launch your custom agent." -ForegroundColor White
