#!/usr/bin/env python3
from pathlib import Path, PurePosixPath
import fnmatch
import json
import os
import re
import sys

from harness_lib.stdio import configure_utf8_stdio


configure_utf8_stdio()

ROOT = Path(os.environ.get('CLAUDE_PROJECT_DIR', '.')).resolve()
ACTIVE_PLAN_DIR = ROOT / 'docs/harness/plans/active'
ACTIVE_PLAN_PREFIX = 'docs/harness/plans/active/'
SCOPE_HEADINGS = (
    'Editable Scope',
    '수정 가능 범위',
    'Edit Scope',
    'Scope',
    '대상 범위',
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


def is_active_plan_path(path: str) -> bool:
    return path == ACTIVE_PLAN_PREFIX.rstrip('/') or path.startswith(ACTIVE_PLAN_PREFIX)


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
    red = section(text, ('RED Evidence', 'RED 증거'))
    if not red:
        return False

    has_exception_reason = has_non_empty_field(red, ('예외 사유', 'RED가 부적합할 때의 예외 사유'))
    has_alternative_verification = has_non_empty_field(red, ('대체 검증',))
    if has_exception_reason and has_alternative_verification:
        return True

    has_failure_check = has_non_empty_field(red, ('명령', '실패 테스트 / 확인'))
    has_failure_reason = has_non_empty_field(red, ('실패 이유', '이 실패가 예상되는 이유'))
    if has_failure_check and has_failure_reason:
        return True

    return False


def scoped_patterns(scope_text: str, root: Path | None = None) -> set[str]:
    root = root if root is not None else ROOT
    patterns: set[str] = set()
    for match in re.findall(r'`([^`\n]+)`', scope_text):
        value = match.strip()
        if not value or any(ch.isspace() for ch in value):
            # Multi-word backticks are commands, not scope paths.
            continue
        # Accept directory/glob paths, dotted filenames (MANIFEST.md), and real
        # root-level files without an extension (VERSION, LICENSE, Makefile).
        if (
            '/' in value
            or '.' in value
            or any(ch in value for ch in '*?[')
            or (root / value).is_file()
        ):
            patterns.add(value)

    for match in re.findall(r'(?<![\w./-])(?:[A-Za-z0-9_.-]+/[\w./*\-]+|\.[\w./*\-]+)(?![\w./-])', scope_text):
        patterns.add(match.strip())

    return patterns


def explicit_scope_patterns(text: str) -> set[str]:
    scope_text = section(text, SCOPE_HEADINGS)
    if not scope_text:
        return set()
    return scoped_patterns(scope_text)


def pattern_allows(pattern: str, target: str) -> bool:
    target_normalized = target.strip().replace('\\', '/')
    target_parsed = PurePosixPath(target_normalized)
    if not target_normalized or target_parsed.is_absolute() or any(part == '..' for part in target_parsed.parts):
        return False
    target_normalized = target_parsed.as_posix()

    normalized = pattern.strip().replace('\\', '/')
    if not normalized or normalized in {'/', '.', './'}:
        return False
    while normalized.startswith('./'):
        normalized = normalized[2:]
    parsed = PurePosixPath(normalized)
    if parsed.is_absolute() or any(part == '..' for part in parsed.parts):
        return False
    normalized = parsed.as_posix()
    if normalized.endswith('/'):
        normalized = f'{normalized}**'
    if normalized.endswith('/**'):
        prefix = normalized[:-3]
        return target_normalized == prefix or target_normalized.startswith(f'{prefix}/')
    if any(ch in normalized for ch in '*?[]'):
        return fnmatch.fnmatch(target_normalized, normalized)
    return target_normalized == normalized


def plan_allows_target(plan: Path, target: str) -> bool:
    text = plan.read_text(encoding='utf-8', errors='ignore')
    if not has_red_evidence(plan):
        return False
    return any(pattern_allows(pattern, target) for pattern in explicit_scope_patterns(text))


def evidence_ready_for_target(target: str) -> bool:
    return any(plan_allows_target(plan, target) for plan in active_plan_files())


def main() -> int:
    mode = os.environ.get('HARNESS_EVIDENCE_HOOK_MODE', 'strict').strip().lower()
    if mode in {'off', 'disabled', '0', 'false'}:
        reason = os.environ.get('HARNESS_EVIDENCE_HOOK_BYPASS_REASON', '').strip()
        if not reason:
            fail(
                '[evidence-gate] blocked bypass without audit reason. '
                'Set HARNESS_EVIDENCE_HOOK_BYPASS_REASON with the approved emergency reason before using '
                'HARNESS_EVIDENCE_HOOK_MODE=off.'
            )
        print(f'[evidence-gate] bypassed with approved reason: {reason}', file=sys.stderr)
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

    if is_active_plan_path(path):
        return 0

    if evidence_ready_for_target(path):
        return 0

    message = (
        '[evidence-gate] blocked direct file edit before RED evidence. '
        f'target={path}. Create/update docs/harness/plans/active/*.md first, '
        'then record RED Evidence or a documented RED exception and include the target file or glob scope '
        'inside an explicit Editable Scope/Scope section '
        'before editing non-plan files. '
        'Set HARNESS_EVIDENCE_HOOK_MODE=off only with HARNESS_EVIDENCE_HOOK_BYPASS_REASON for an approved '
        'emergency bypass.'
    )
    if mode == 'warn':
        print(message, file=sys.stderr)
        return 0
    fail(message)


if __name__ == '__main__':
    raise SystemExit(main())
