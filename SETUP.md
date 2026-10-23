# Agent-first setup

User flow: clone/copy this repository, open Claude Code or Hermes in its folder,
then say: "Setup agent ini pakai repo ini. Baca SETUP.md, tanya preferensi gw dulu."
An already installed, authenticated agent is required to perform the setup.
Never copy this repository wholesale into an agent configuration directory.

## 1. Ask once, then act

Ask the recipient in their language:
- Target: Claude Code, Hermes, or both? Which Hermes profile?
- Their nickname, assistant nickname, language/tone/persona (free text allowed).
- Keep current login/provider, official login, or configure their own provider/model/base URL?
- Install dependencies/MCP/plugins now? Optional Hadooyy skin or keep existing theme?

Never default to the author's nickname/persona, proxy, model or API key.
Never ask for secrets in chat, command arguments, screenshots, or a tracked file.
Use `claude auth login` or `hermes setup` / `hermes model` locally for login.
For a custom provider, let the recipient use a local hidden input or official config UI.
Do not reset working authentication. Stop at login/2FA until the recipient completes it.
Keep permission prompts enabled. Do not transplant bypassPermissions or blanket Bash grants.

## 2. Preflight and copy

Inspect `python --version`, `node --version`, `claude --version`, `hermes --version` as applicable.
Use Python 3.10+; REA currently requires Node ^22.19.0, ^24.11.0, or >=26.
Use actual native absolute paths on Windows, not Git Bash /tmp paths in native programs.
Check `HERMES_HOME` / `CLAUDE_CONFIG_DIR`; never edit another profile implicitly.

Run a read-only plan, show destination paths, obtain install consent:

    python setup.py --target claude

Then pass the recipient's own answers (not literal placeholders):

    python setup.py --target claude --name "RECIPIENT" --assistant-name "ASSISTANT" --persona "RECIPIENT STYLE" --apply

Use --target hermes or both when requested. --skin only copies optional skin assets.
The copier preserves unrelated skills, backs up changed files as .bak-*, safely merges
settings, and appends managed rules/identity without deleting existing context.
It does NOT install executables, register MCP, log in, or assert services are online.
If existing identity rules conflict, show the conflict and ask before removing them.
Do not copy user sessions, memories, credentials, cron jobs or chat/channel IDs.

## 3. Claude Code plugins (persistent, user scope)

Review the local marketplace/plugin manifests first. After install consent:

    claude plugin marketplace add "ABSOLUTE_CLONE_PATH"
    claude plugin install antislop@hadooyy --scope user
    claude plugin install gopls-lsp@hadooyy --scope user

Both plugin sources are bundled. Keep the clone available for updates.
Go LSP also needs `gopls` on PATH. With recipient approval:

    go install golang.org/x/tools/gopls@latest

If Go is absent, ask to install it; report gopls pending instead of claiming it works.
Antislop includes its own contrast MCP. Check its runtime prerequisites independently.
Hermes does NOT load these Claude plugin manifests as native Hermes plugins.
For Hermes, six standalone antislop skills are already copied. Do not claim gopls is
active in Hermes merely because its folder exists. Use native compatible LSP tooling
only when supported by the recipient's Hermes version.

## 4. Dependencies and MCP

Inventory is in config/mcp.template.json. It combines actual Hermes and Claude user
registrations: rea, agent-reach, exa, headroom. Plugin contrast MCP is separate.
Install missing runtimes only with consent; check existing same-name entries before adding.
Use real paths discovered on this machine. Never reuse paths from the author's PC.

Agent Reach: use a dedicated venv/pipx with MCP extra, not the obsolete PyPI-only build:

    python -m venv "RECIPIENT_TOOL_HOME/agent-reach-venv"
    "VENV_PYTHON" -m pip install "agent-reach[mcp] @ https://github.com/Panniantong/agent-reach/archive/main.zip"
    "VENV_PYTHON" -c "import agent_reach.integrations.mcp_server"

On Windows VENV_PYTHON is venv/Scripts/python.exe, POSIX venv/bin/python.
Agent Reach MCP exposes status/doctor, not all platform search tools. Follow the
agent-reach skill to install/check upstream CLIs. Cookies/logins stay recipient-local.
Headroom: follow https://docs.headroomlabs.ai/docs and verify `headroom mcp --help`.
RTK: optional existing Claude hook is documented in config/claude_optional.json;
install/check rtk before enabling the hook. Do not leave a missing-command hook enabled.

Claude registrations (user scope, NOT settings.json):

    claude mcp add --scope user rea -- npx -y rea-agents@6.7.0 --mcp
    claude mcp add --scope user agent-reach -- "VENV_PYTHON" -m agent_reach.integrations.mcp_server
    claude mcp add --scope user --transport http exa https://mcp.exa.ai/mcp
    claude mcp add --scope user headroom -- headroom mcp serve

For Hermes, use its supported connection flow. Within Hermes agent tools, use
manage_connections for catalog/local MCP installation; do not hand-edit mcp_servers.
If doing CLI setup outside that tool environment, inspect `hermes mcp add --help`, then:

    hermes mcp add rea --command npx --connect-timeout 90 --args -y rea-agents@6.7.0 --mcp
    hermes mcp add agent_reach --command "VENV_PYTHON" --args -m agent_reach.integrations.mcp_server

Preserve existing server registrations. Exa/headroom were Claude-specific; offer them
for Hermes rather than silently extending its source setup.
Merge non-secret preferences from config/hermes_config.template.yaml via
`hermes config set section.key VALUE`, not by replacing live config.yaml.
Prefer recipient's settings on conflicts. Skip unsupported keys with an explicit note.
If optional skin was copied and recipient selected it: `hermes config set display.skin hadooyy`.

## 5. Verify before completion

- `python test_setup.py` validates copier behavior in an isolated scratch home.
- Count actual SKILL.md files; compare names with INVENTORY.json, not a hardcoded claim.
- `claude plugin validate .`, `claude plugin list`, `gopls version` when applicable.
- `claude mcp list` / `hermes mcp test NAME`: record each healthy/pending/failed server.
- Run Agent Reach doctor; platform login gaps are not setup success.
- Restart the agent. Confirm skills are discoverable, plugin tools load, selected persona applies.
- Smoke-test one harmless MCP tool; do not execute unknown binaries or security scans.
- Report installed versus pending, exact destinations, backup paths and errors.
Never report "all online" based on file copies. Never auto-commit/push/merge.

References: https://code.claude.com/docs/en/mcp
https://code.claude.com/docs/en/plugins-reference
https://hermes-agent.nousresearch.com/docs/user-guide/configuration
