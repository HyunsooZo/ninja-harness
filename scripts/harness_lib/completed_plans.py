from __future__ import annotations

import os
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent.parent


def completed_plan_dir() -> Path:
    configured = Path(os.environ.get('HARNESS_COMPLETED_PLAN_DIR', 'docs/harness/plans/completed'))
    return configured if configured.is_absolute() else ROOT / configured


def relative_label(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return str(path)


def plan_missing_markers(text: str) -> list[str]:
    missing: list[str] = []
    if 'RED' not in text and '사전 실패' not in text:
        missing.append('RED evidence')
    if 'GREEN' not in text and '구현' not in text:
        missing.append('GREEN evidence')
    if 'REFACTOR' not in text and '리팩토링' not in text and '리팩터링' not in text:
        missing.append('REFACTOR decision')
    if 'VERIFY' not in text and '검증' not in text:
        missing.append('VERIFY evidence')
    if '잔여 위험' not in text and 'Risk' not in text and 'risk' not in text:
        missing.append('residual risk')

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


def main() -> int:
    completed_dir = completed_plan_dir()
    plans = sorted(completed_dir.glob('*.md')) if completed_dir.exists() else []
    if not plans:
        print(f'[OK] completed plan quality: no completed plans in {relative_label(completed_dir)}')
        return 0

    failed = False
    for plan in plans:
        missing = plan_missing_markers(plan.read_text(encoding='utf-8'))
        label = relative_label(plan)
        if missing:
            print(f'[FAIL] {label} missing: {" ".join(missing)}')
            failed = True
        else:
            print(f'[OK] {label}')

    return 1 if failed else 0
