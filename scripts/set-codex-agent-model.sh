#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || -z "${1// }" ]]; then
  echo "Usage: bash scripts/set-codex-agent-model.sh <model-name>"
  exit 1
fi

MODEL="$1"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 - "$MODEL" <<'PYMODEL'
from pathlib import Path
import re
import sys

model = sys.argv[1]
root = Path('.')

for path in sorted((root/'.codex/agents').glob('*.toml')):
    text = path.read_text(encoding='utf-8')
    if re.search(r'^model\s*=', text, flags=re.M):
        text = re.sub(r'^model\s*=\s*"[^"]*"', f'model = "{model}"', text, count=1, flags=re.M)
    else:
        text = text.replace('\n', f'\nmodel = "{model}"\n', 1)
    path.write_text(text, encoding='utf-8')

harness = root/'docs/harness/harness.yaml'
text = harness.read_text(encoding='utf-8')
if re.search(r'^  codex_agent_model:', text, flags=re.M):
    text = re.sub(r'^  codex_agent_model:\s*.*$', f'  codex_agent_model: {model}', text, count=1, flags=re.M)
else:
    text += f'\n\nruntime:\n  codex_agent_model: {model}\n  codex_model_override_env: HARNESS_EXPECTED_CODEX_MODEL\n'
harness.write_text(text, encoding='utf-8')
PYMODEL

echo "[OK] set Codex agent model -> $MODEL"
