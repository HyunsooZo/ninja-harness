#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ "$#" -gt 0 ]]; then
  files=("$@")
else
  files=(
    "docs/harness/context/BASELINE.md"
    "docs/harness/profiles/project-profile.md"
    "docs/harness/profiles/design-system-profile.md"
    "docs/harness/harness.yaml"
  )
fi

python3 - "${files[@]}" <<'PY'
from pathlib import Path
import re
import sys

placeholder = re.compile(r'<[^>\n]+>')
failures = []

for raw in sys.argv[1:]:
    path = Path(raw)
    if not path.exists():
        failures.append(f'{path}: missing readiness file')
        continue
    text = path.read_text(encoding='utf-8')
    for lineno, line in enumerate(text.splitlines(), start=1):
        for match in placeholder.finditer(line):
            failures.append(f'{path}:{lineno}: unresolved placeholder {match.group(0)}')

if failures:
    print('[FAIL] project profile readiness check found unresolved placeholders')
    for item in failures:
        print(f'  - {item}')
    print('[INFO] Replace template placeholders with project values, or mark unused areas as N/A without angle brackets.')
    raise SystemExit(1)

print('[OK] project profile readiness verified')
PY
