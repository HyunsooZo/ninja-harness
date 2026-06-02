#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import shutil
import sys

from harness_lib.stdio import configure_utf8_stdio


configure_utf8_stdio()

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / '.agents/skills'
TARGET = ROOT / '.claude/skills'


def fail(message: str) -> None:
    print(f'[FAIL] {message}', file=sys.stderr)
    raise SystemExit(1)


def remove_local_artifacts(path: Path) -> None:
    for item in path.rglob('.DS_Store'):
        item.unlink()
    for item in path.rglob('._*'):
        item.unlink()
    for item in sorted(path.rglob('__MACOSX'), reverse=True):
        if item.is_dir():
            shutil.rmtree(item)


def main() -> int:
    if not SOURCE.is_dir():
        fail('missing .agents/skills')

    if TARGET.exists():
        shutil.rmtree(TARGET)
    shutil.copytree(SOURCE, TARGET)
    remove_local_artifacts(TARGET)
    print('[OK] synced .agents/skills -> .claude/skills')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
