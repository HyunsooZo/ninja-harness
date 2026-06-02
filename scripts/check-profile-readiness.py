#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import sys

from harness_lib.stdio import configure_utf8_stdio


configure_utf8_stdio()

DEFAULT_FILES = [
    'docs/harness/context/BASELINE.md',
    'docs/harness/profiles/project-profile.md',
    'docs/harness/profiles/design-system-profile.md',
    'docs/harness/harness.yaml',
]


def main(argv: list[str]) -> int:
    placeholder = re.compile(r'<[^>\n]+>')
    failures: list[str] = []
    files = argv[1:] if len(argv) > 1 else DEFAULT_FILES

    for raw in files:
        path = Path(raw)
        if not path.exists():
            failures.append(f'{path}: missing readiness file')
            continue
        for lineno, line in enumerate(path.read_text(encoding='utf-8').splitlines(), start=1):
            for match in placeholder.finditer(line):
                failures.append(f'{path}:{lineno}: unresolved placeholder {match.group(0)}')

    if failures:
        print('[FAIL] project profile readiness check found unresolved placeholders')
        for item in failures:
            print(f'  - {item}')
        print('[INFO] Replace template placeholders with project values, or mark unused areas as N/A without angle brackets.')
        return 1

    print('[OK] project profile readiness verified')
    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
