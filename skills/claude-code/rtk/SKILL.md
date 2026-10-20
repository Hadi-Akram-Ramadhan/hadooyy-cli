---
name: rtk
description: >
  RTK (Rust Token Killer) integration skill. Provides guidance on using the RTK CLI proxy
  to reduce LLM token consumption by 60-90% on common dev commands. Auto-triggers on
  tasks involving bash commands, git operations, testing, and any CLI usage that could
  benefit from output compression.
triggers:
  - "rtk"
  - "token savings"
  - "optimize tokens"
  - "reduce context"
  - "bash output"
  - "command output"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
effort: low
tags: [rtk, token-optimization, cli, hooks, bash, performance]
---

# RTK Skill

RTK (Rust Token Killer) is a high-performance CLI proxy that filters and compresses command outputs before they reach your LLM context, saving 60-90% of tokens on common operations.

## When to Use

- Any task involving bash/shell commands
- Git operations (status, diff, log, etc.)
- Running tests (cargo test, pytest, go test, npm test, etc.)
- Build commands (cargo build, npm run build, etc.)
- Linting/formatting (cargo fmt, ruff, prettier, etc.)
- Any command producing verbose output

## Quick Commands

```bash
# Check RTK is installed and working
rtk --version
rtk gain

# Initialize RTK for this project (if not already global)
rtk init

# Verify hook is active
rtk init --show
```

## How It Works

RTK intercepts Bash tool calls and rewrites commands transparently:
- `git status` → `rtk git status`
- `cargo test` → `rtk cargo test`
- `npm test` → `rtk npm test`

The hook is already installed globally. You just run commands normally — RTK handles the rest.

## Common RTK-Wrapped Commands

| Category | Commands |
|----------|----------|
| Git | `git status`, `git diff`, `git log`, `git show`, `git branch` |
| Cargo | `cargo test`, `cargo build`, `cargo check`, `cargo fmt`, `cargo clippy` |
| npm/pnpm | `npm test`, `npm run build`, `pnpm test`, `pnpm lint` |
| Python | `pytest`, `ruff`, `mypy`, `pip` |
| Go | `go test`, `go build`, `golangci-lint` |
| Docker | `docker ps`, `docker logs`, `docker build` |
| Kubernetes | `kubectl get`, `kubectl logs`, `kubectl describe` |
| Search | `grep`, `rg`, `find` |
| File ops | `cat`, `head`, `tail`, `ls` |

## Meta Commands (use directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Command usage history with savings
rtk discover          # Analyze history for missed opportunities
rtk proxy <cmd>       # Execute raw without filtering (debugging)
rtk rewrite <cmd>     # Test what command would be rewritten to
```

## Configuration

- **Global filters**: `%APPDATA%\rtk\filters.toml` (Windows) / `~/.config/rtk/filters.toml`
- **Project filters**: `.rtk/filters.toml` in project root

## Verification

After running commands, check savings:
```bash
rtk gain
```

Expected: 60-90% token reduction on supported commands.

## Troubleshooting

If hook not working:
1. Verify `rtk --version` works
2. Check `rtk init --show` shows hook as `[ok]`
3. Restart Claude Code
4. Run `git status` — should show compressed output
