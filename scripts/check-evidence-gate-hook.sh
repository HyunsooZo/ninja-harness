#!/usr/bin/env bash
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT"

if command -v python3 >/dev/null 2>&1; then
  exec python3 "$ROOT/scripts/check-evidence-gate-hook.py"
fi

if command -v python >/dev/null 2>&1; then
  exec python "$ROOT/scripts/check-evidence-gate-hook.py"
fi

echo "[evidence-gate] python3 or python is required" >&2
exit 2
