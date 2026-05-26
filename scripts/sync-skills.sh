#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

[[ -d ".agents/skills" ]] || { echo "[FAIL] missing .agents/skills"; exit 1; }

rm -rf .claude/skills
mkdir -p .claude/skills
cp -R .agents/skills/. .claude/skills/

find .claude/skills -name ".DS_Store" -delete
find .claude/skills -name "._*" -delete
find .claude/skills -type d -name "__MACOSX" -prune -exec rm -rf {} +

echo "[OK] synced .agents/skills -> .claude/skills"
