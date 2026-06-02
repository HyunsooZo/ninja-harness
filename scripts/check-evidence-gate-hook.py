#!/usr/bin/env python3
from pathlib import Path
import json
import os
import re
import sys


ROOT = Path(os.environ.get('CLAUDE_PROJECT_DIR', '.')).resolve()
ACTIVE_PLAN_DIR = ROOT / 'docs/harness/plans/active'
PLAN_ALLOWED_PREFIXES = (
    'docs/harness/plans/active/',
    'docs/harness/plans/completed/',
)


def fail(message: str) -> None:
    print(message, file=sys.stderr)
    sys.exit(2)


def relative_path(value: str) -> str:
    if not value:
        return ''
    raw = Path(value)
    if not raw.is_absolute():
        raw = ROOT / raw
    try:
        return raw.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return raw.as_posix()


def target_path(payload: dict) -> str:
    tool_input = payload.get('tool_input') or {}
    for key in ('file_path', 'path', 'notebook_path'):
        value = tool_input.get(key)
        if isinstance(value, str) and value.strip():
            return relative_path(value.strip())
    return ''


def is_plan_path(path: str) -> bool:
    return any(path == prefix.rstrip('/') or path.startswith(prefix) for prefix in PLAN_ALLOWED_PREFIXES)


def active_plan_files() -> list[Path]:
    if not ACTIVE_PLAN_DIR.exists():
        return []
    return sorted(
        p for p in ACTIVE_PLAN_DIR.glob('*.md')
        if p.name != '.gitkeep' and p.is_file()
    )


def section(text: str, headings: tuple[str, ...]) -> str:
    escaped = '|'.join(re.escape(item) for item in headings)
    match = re.search(
        rf'(?ims)^##+\s*(?:{escaped})\s*$'
        rf'(?P<body>.*?)(?=^##+\s+\S|\Z)',
        text,
    )
    return match.group('body') if match else ''


def has_non_empty_field(body: str, labels: tuple[str, ...]) -> bool:
    for label in labels:
        pattern = rf'(?im)^\s*-?\s*{re.escape(label)}\s*:\s*(?P<value>.+?)\s*$'
        for match in re.finditer(pattern, body):
            value = match.group('value').strip().strip('`')
            if value and value.lower() not in {'n/a', 'na', 'none', 'pending', '대기 중'}:
                return True
    return False


def has_red_evidence(path: Path) -> bool:
    text = path.read_text(encoding='utf-8', errors='ignore')
    if re.search(r'(?im)^\s*-\s*Plan State:\s*`?(red|green|refactor|verify|review|completed)`?\s*$', text):
        return True

    red = section(text, ('RED Evidence', 'RED 증거'))
    if not red:
        return False

    if has_non_empty_field(red, ('예외 사유', 'RED가 부적합할 때의 예외 사유', '대체 검증', 'Risk left')):
        return True

    if has_non_empty_field(red, ('명령', '실패 테스트 / 확인', '실패 이유', '이 실패가 예상되는 이유')):
        return True

    return bool(re.search(r'(?i)\bexpect_fail\b|\bFAIL\b|실패|재현', red))


def evidence_ready() -> bool:
    plans = active_plan_files()
    return any(has_red_evidence(plan) for plan in plans)


def main() -> int:
    mode = os.environ.get('HARNESS_EVIDENCE_HOOK_MODE', 'strict').strip().lower()
    if mode in {'off', 'disabled', '0', 'false'}:
        return 0

    try:
        payload = json.load(sys.stdin)
    except Exception as exc:
        fail(f'[evidence-gate] invalid hook input JSON: {exc}')

    tool = str(payload.get('tool_name') or '')
    if tool not in {'Edit', 'MultiEdit', 'Write', 'NotebookEdit'}:
        return 0

    path = target_path(payload)
    if not path:
        fail('[evidence-gate] blocked: edit tool did not provide a target file path')

    if is_plan_path(path):
        return 0

    if evidence_ready():
        return 0

    message = (
        '[evidence-gate] blocked direct file edit before RED evidence. '
        f'target={path}. Create/update docs/harness/plans/active/*.md first, '
        'then record RED Evidence or a documented RED exception before editing non-plan files. '
        'Set HARNESS_EVIDENCE_HOOK_MODE=off only for an approved emergency bypass.'
    )
    if mode == 'warn':
        print(message, file=sys.stderr)
        return 0
    fail(message)


if __name__ == '__main__':
    raise SystemExit(main())
