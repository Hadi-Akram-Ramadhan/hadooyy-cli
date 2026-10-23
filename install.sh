#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v python3 >/dev/null 2>&1; then PYTHON=python3; else PYTHON=python; fi
if command -v cygpath >/dev/null 2>&1; then REPO_DIR="$(cygpath -m "$REPO_DIR")"; fi
exec "$PYTHON" "$REPO_DIR/setup.py" "$@"
