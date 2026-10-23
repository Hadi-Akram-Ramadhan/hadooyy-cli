# Custom Launcher — Rename the `hermes` Command

How to give Hermes a custom command name (e.g. `hadooyy`) while keeping all
features, skills, MCP, plugins, and auto-update fully intact. The binary is never
copied or modified — wrappers delegate to it.

## When to Use

- User wants to type something other than `hermes` to open the CLI.
- User wants a custom identity without forking the install.

## Procedure (Windows + Git Bash — verified)

Hermes installs its bin directory at `$LOCALAPPDATA/hermes/bin/` (already on
`PATH`). Drop two files there:

### 1. Shell script (Git Bash / MSYS2 / WSL)

Create a no-extension file named after the desired command:

```bash
cat > "$LOCALAPPDATA/hermes/bin/<name>" << 'EOF'
#!/usr/bin/env bash
hermes "$@"
EOF
chmod +x "$LOCALAPPDATA/hermes/bin/<name>"
```

Test immediately: `<name> --version` should print the Hermes version string.

### 2. Windows `.cmd` wrapper (PowerShell / cmd.exe / Windows Run)

```bat
@echo off
"%~dp0hermes.cmd" %*
```

Save as `$LOCALAPPDATA/hermes/bin/<name>.cmd`.

### 3. Shell alias (belt-and-suspenders)

Append to `~/.bashrc` and `~/.bash_profile`:

```bash
alias <name>="hermes"
```

## Pitfalls

- **A `.cmd` file alone does NOT work in Git Bash.** Git Bash resolves commands
  without extensions only if a matching no-extension file or alias exists.
  Always create BOTH the no-extension shell script AND the `.cmd` — one for each
  shell family.
- **Never copy or symlink `hermes.exe` directly.** The `.exe` launcher contains
  a hardcoded base64 bootstrap that references the exact install path; copying it
  to a new name does not change that path and the copy breaks on update. Use the
  shell-script wrapper approach only.
- **Do not edit `hermes.cmd`.** It contains a signed bootstrap payload; any edit
  breaks the signature check and the launcher refuses to start.
- **The alias in `.bashrc` only covers interactive bash sessions.** Scripts,
  cron jobs, and non-login shells will not see it. The bin-directory files cover
  those cases — put both in place.

## Identity (branding) — pair with a skin

The command rename is purely a launcher concern; the CLI still announces itself
as "Hermes Agent" unless you also set a skin with a `branding` block. Pair the
launcher rename with a skin that sets `agent_name`, `welcome`, `goodbye`,
`response_label`, and `prompt_symbol` — see `references/themes.md` and
`templates/skin.yaml`.

Minimum `branding` block to add to any skin YAML:

```yaml
branding:
  agent_name: "<Name>"
  welcome: "<Name> — type a message or /help."
  goodbye: "Bye! 👋"
  response_label: " 👾 <Name> "
  prompt_symbol: "⚡"
  help_header: "(⚡) Commands"
```

Activate the skin: `hermes config set display.skin <skin-name>`
