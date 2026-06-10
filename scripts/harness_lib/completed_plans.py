from __future__ import annotations

import argparse
import os
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent.parent


def completed_plan_dir() -> Path:
    configured = Path(os.environ.get('HARNESS_COMPLETED_PLAN_DIR', 'docs/harness/plans/completed'))
    return configured if configured.is_absolute() else ROOT / configured


def completed_plan_source() -> str:
    return os.environ.get('HARNESS_COMPLETED_PLAN_SOURCE', 'local').strip().lower() or 'local'


def completed_plan_files(completed_dir: Path | None = None, source: str | None = None) -> list[Path]:
    completed_dir = completed_dir or completed_plan_dir()
    source = source or completed_plan_source()
    if source == 'local':
        return sorted(completed_dir.glob('*.md')) if completed_dir.exists() else []
    if source != 'tracked':
        raise ValueError(f'HARNESS_COMPLETED_PLAN_SOURCE must be local or tracked: {source}')

    try:
        rel_dir = completed_dir.resolve().relative_to(ROOT)
    except ValueError:
        return []

    result = subprocess.run(
        ['git', 'ls-files', f'{rel_dir.as_posix()}/*.md'],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(f'git ls-files failed for completed plans: {result.stderr.strip()}')
    return sorted(ROOT / line for line in result.stdout.splitlines() if line.strip().endswith('.md'))


def relative_label(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return str(path)


def has_unresolved_evidence_placeholder(text: str) -> bool:
    placeholder_value = r'(?:pending|대기 중)'
    for line in text.splitlines():
        stripped = line.strip()
        if re.search(rf'(?i)^\s*-?\s*`?{placeholder_value}`?\s*:', stripped):
            return True
        if re.search(rf'(?i)(?:^|\||:)\s*`?{placeholder_value}`?\s*(?:\||$)', stripped):
            return True
    return False


REQUIRED_MARKERS = (
    ('RED evidence', ('RED Evidence', 'RED 증거', 'RED', '사전 실패')),
    ('GREEN evidence', ('GREEN / REFACTOR Evidence', 'GREEN Evidence', 'GREEN 증거', 'GREEN', '구현 증거', '구현')),
    (
        'REFACTOR decision',
        (
            'GREEN / REFACTOR Evidence',
            'REFACTOR Decision',
            'REFACTOR Evidence',
            'REFACTOR 증거',
            'REFACTOR 기록',
            'Refactor Note',
            'REFACTOR',
            '리팩토링 기록',
            '리팩터링 기록',
            '리팩토링',
            '리팩터링',
        ),
    ),
    ('VERIFY evidence', ('VERIFY Evidence', 'VERIFY 증거', 'Verify Report', 'VERIFY', '검증 보고', '검증')),
    ('residual risk', ('Residual risk / 잔여 위험', 'Residual Risk', 'Risks left', 'Risk left', 'Risk Left', 'Risk', '잔여 위험', '남은 위험', '위험')),
)


def _marker_value(line: str, aliases: tuple[str, ...]) -> str | None:
    candidate = re.sub(r'^\s*#+\s*', '', line).strip()
    candidate = re.sub(r'^\s*[-*]\s*', '', candidate).strip()
    for alias in aliases:
        if re.search(rf'(?i)\|\s*{re.escape(alias)}\s*\|', line):
            return 'table row'
        match = re.match(rf'(?i)^{re.escape(alias)}(?:\s*[:：]\s*(?P<value>.*)|\s*)$', candidate)
        if match:
            return (match.group('value') or '').strip()
    return None


def _is_any_required_marker(line: str) -> bool:
    return any(_marker_value(line, aliases) is not None for _, aliases in REQUIRED_MARKERS)


def _has_evidence_marker(text: str, aliases: tuple[str, ...]) -> bool:
    lines = text.splitlines()
    for index, line in enumerate(lines):
        value = _marker_value(line, aliases)
        if value is None:
            continue
        if value:
            return True
        for following in lines[index + 1:]:
            if not following.strip():
                continue
            if _is_any_required_marker(following):
                break
            return True
    return False


def plan_missing_markers(text: str) -> list[str]:
    missing: list[str] = []
    if has_unresolved_evidence_placeholder(text):
        missing.append('pending evidence placeholders')
    for label, aliases in REQUIRED_MARKERS:
        if not _has_evidence_marker(text, aliases):
            missing.append(label)

    if any(mode in text for mode in ('SEQUENTIAL_LAYERED', 'PARALLEL_IMPLEMENT', 'PARALLEL_REVIEW', 'PARALLEL_INVESTIGATION')):
        if '통합 담당자' not in text:
            missing.append('integration owner')
        if '레이어 영향도' not in text:
            missing.append('layer impact')
        if '수렴 기준' not in text and '수렴 결과' not in text:
            missing.append('fan-in criteria/result')
        if '중복 구현' not in text:
            missing.append('duplicate implementation check')
        if '계약 일치' not in text:
            missing.append('contract consistency check')

    if 'PARALLEL_IMPLEMENT' in text:
        if 'Parallelization Check' not in text and '병렬화 점검' not in text:
            missing.append('parallelization check')
        if '겹치는 파일' not in text:
            missing.append('overlapping file check')

    return missing


def quality_failures(plans: list[Path]) -> list[tuple[Path, list[str]]]:
    failures: list[tuple[Path, list[str]]] = []
    for plan in plans:
        if not plan.exists():
            failures.append((plan, ['file not found']))
            continue
        if not plan.is_file():
            failures.append((plan, ['not a file']))
            continue
        if plan.suffix != '.md':
            failures.append((plan, ['not a markdown plan']))
            continue
        missing = plan_missing_markers(plan.read_text(encoding='utf-8'))
        if missing:
            failures.append((plan, missing))
    return failures


def print_plan_results(plans: list[Path], failures: list[tuple[Path, list[str]]]) -> None:
    failure_map = {plan: missing for plan, missing in failures}
    for plan in plans:
        label = relative_label(plan)
        missing = failure_map.get(plan)
        if missing:
            print(f'[FAIL] {label} missing: {" ".join(missing)}')
        else:
            print(f'[OK] {label}')


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Check completed plan evidence quality.')
    parser.add_argument(
        '--file',
        action='append',
        default=[],
        metavar='PATH',
        help='Check one completed-plan candidate file before moving it to completed/. May be repeated.',
    )
    return parser.parse_args(argv)


def candidate_plan_path(value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else ROOT / path


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    if args.file:
        plans = [candidate_plan_path(value) for value in args.file]
        print(f'[INFO] completed plan candidate files: {len(plans)}')
        failures = quality_failures(plans)
        print_plan_results(plans, failures)
        return 1 if failures else 0

    completed_dir = completed_plan_dir()
    source = completed_plan_source()
    try:
        plans = completed_plan_files(completed_dir, source)
    except (RuntimeError, ValueError) as exc:
        print(f'[FAIL] {exc}')
        return 1
    print(f'[INFO] completed plan source: {source} dir={relative_label(completed_dir)}')
    if not plans:
        print(f'[OK] completed plan quality: no completed plans in {relative_label(completed_dir)} source={source}')
        return 0

    failures = quality_failures(plans)
    print_plan_results(plans, failures)
    return 1 if failures else 0
