#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
from pathlib import Path
import os
import re
from collections import Counter, defaultdict
from statistics import mean

root = Path('.')
completed_dir = Path(os.environ.get('HARNESS_COMPLETED_PLAN_DIR', 'docs/harness/plans/completed'))
plans = sorted(completed_dir.glob('*.md')) if completed_dir.exists() else []

modes = ['SINGLE_AGENT','SINGLE_AGENT_WITH_REVIEW','SEQUENTIAL_LAYERED','PARALLEL_INVESTIGATION','PARALLEL_REVIEW','PARALLEL_IMPLEMENT']

summary = {
    'completed_plans': len(plans),
    'fail_markers': 0,
    'concern_markers': 0,
    'skip_markers': 0,
    'blocked_or_needs_context_markers': 0,
    'rework_markers': 0,
    'regression_markers': 0,
    'fan_in_conflict_markers': 0,
}

task_type = Counter()
task_success = Counter()
mode_total = Counter()
mode_success = Counter()
mode_fail = Counter()
mode_durations = defaultdict(list)
agent_total = Counter()
agent_rework = Counter()
reviewer_fail_reason = Counter()
gate_fail_by_date = Counter()
regression_total = 0
regression_captured = 0
fan_in_total = 0
fan_in_conflict = 0

def first_match(patterns, text, default='unknown'):
    for pat in patterns:
        m = re.search(pat, text, re.I | re.M)
        if m:
            return m.group(1).strip().strip('`')
    return default

def int_match(patterns, text, default=0):
    value = first_match(patterns, text, '')
    try:
        return int(value)
    except Exception:
        return default

for plan in plans:
    text = plan.read_text(encoding='utf-8', errors='ignore')
    date = first_match([r'-\s*날짜:\s*([^\n]+)', r'Date:\s*([^\n]+)', r'##\s*Date\s*\n\s*([^\n]+)'], text, plan.stem[:10])
    ttype = first_match([r'-\s*작업 유형:\s*([^\n]+)', r'Task Type:\s*([^\n]+)'], text, 'unknown')
    verdict = first_match([r'Verdict:\s*([A-Z_]+)', r'리뷰 판정:\s*([A-Z_가-힣]+)', r'최종 판정:\s*([A-Z_가-힣]+)'], text, 'unknown').upper()
    final_success = bool(re.search(r'^\s*(?:-\s*)?(?:Verdict|Status|Review|Verify|검증|리뷰 판정|최종 판정)\s*:\s*`?(?:PASS(?:_WITH_CONCERNS)?|DONE(?:_WITH_CONCERNS)?)\b`?', text, re.I | re.M))
    table_success = bool(re.search(r'^\|[^|\n]*(?:리뷰|Review|검증|Verify|최종 품질)[^|\n]*\|[^|\n]*\|\s*(?:PASS(?:_WITH_CONCERNS)?|DONE(?:_WITH_CONCERNS)?)\s*\|', text, re.I | re.M))
    failure_outcome = bool(re.search(r'^\s*(?:-\s*)?(?:Verdict|Status|Review|Verify|검증|리뷰 판정|최종 판정)\s*:\s*`?(?:FAIL|검증 실패|리뷰 실패)\b`?', text, re.I | re.M))
    failure_outcome = failure_outcome or bool(re.search(r'^\|[^|\n]*(?:리뷰|Review|검증|Verify|최종 품질)[^|\n]*\|[^|\n]*\|\s*(?:FAIL|검증 실패|리뷰 실패)\s*\|', text, re.I | re.M))
    success = (final_success or table_success) and 'FAIL' not in verdict
    failish = failure_outcome
    concernish = bool(re.search(r'PASS_WITH_CONCERNS|DONE_WITH_CONCERNS', text, re.I))

    if failish: summary['fail_markers'] += 1
    if concernish: summary['concern_markers'] += 1
    if re.search(r'\bSKIP\b|검증 생략|자동화 테스트가 부적합', text, re.I): summary['skip_markers'] += 1
    if re.search(r'\bBLOCKED\b|NEEDS_CONTEXT', text, re.I): summary['blocked_or_needs_context_markers'] += 1
    if re.search(r'Rework Count|재작업', text, re.I): summary['rework_markers'] += 1
    if re.search(r'Regression Captured|회귀', text, re.I): summary['regression_markers'] += 1

    task_type[ttype] += 1
    if success and not failish:
        task_success[ttype] += 1

    mode = first_match([r'-\s*모드:\s*`?([A-Z_]+)`?', r'Orchestration Mode:\s*([A-Z_]+)', r'오케스트레이션 모드:\s*([A-Z_]+)'], text, 'unknown')
    if mode == 'unknown':
        for candidate in modes:
            if candidate in text:
                mode = candidate
                break
    mode_total[mode] += 1
    if success and not failish:
        mode_success[mode] += 1
    if failish:
        mode_fail[mode] += 1

    duration = int_match([r'Duration Minutes:\s*(\d+)', r'소요 시간\(분\):\s*(\d+)', r'소요시간:\s*(\d+)'], text, 0)
    if duration > 0:
        mode_durations[mode].append(duration)

    agents_field = first_match([r'Agents/Skills:\s*([^\n]+)', r'담당 에이전트:\s*([^\n]+)', r'-\s*기본 실행자:\s*`?([^`\n]+)`?'], text, '')
    agents = [a.strip().strip('`') for a in re.split(r'[,/|]', agents_field) if a.strip()]
    rework_count = int_match([r'Rework Count:\s*(\d+)', r'재작업 횟수:\s*(\d+)'], text, 0)
    for agent in agents or ['unknown']:
        agent_total[agent] += 1
        if rework_count > 0:
            agent_rework[agent] += 1

    for reason in re.findall(r'(?:Reviewer Fail Reason|Review FAIL Reason|리뷰 실패 사유)\s*:\s*([^\n]+)', text, re.I):
        reviewer_fail_reason[reason.strip()] += 1
    if failish:
        for review_line in re.findall(r'\|\s*([^|]+reviewer[^|]*)\|[^|]*\|\s*FAIL\s*\|\s*([^|]+)\|', text, re.I):
            reviewer_fail_reason[review_line[1].strip()] += 1

    gate_fail_count = int_match([r'Gate Fail Count:\s*(\d+)', r'Project Gate Fail Count:\s*(\d+)', r'게이트 실패 횟수:\s*(\d+)'], text, 0)
    if gate_fail_count:
        gate_fail_by_date[date] += gate_fail_count

    if re.search(r'Fan[- ]?in|수렴 결과|수렴 기준', text, re.I):
        fan_in_total += 1
        if re.search(r'Fan[- ]?in Conflict:\s*(yes|true)|충돌:\s*(yes|true|있음)|fan[- ]?in.*conflict', text, re.I):
            fan_in_conflict += 1
            summary['fan_in_conflict_markers'] += 1

    if re.search(r'Regression|회귀', text, re.I):
        regression_total += 1
        if re.search(r'Regression Captured:\s*(yes|true)|Regression Case:\s*(added|yes)|회귀.*(등록|반영|추가)', text, re.I):
            regression_captured += 1

summary['single_agent_markers'] = sum(mode_total[m] for m in ['SINGLE_AGENT','SINGLE_AGENT_WITH_REVIEW'])
summary['sequential_layered_markers'] = mode_total['SEQUENTIAL_LAYERED']
summary['parallel_markers'] = sum(mode_total[m] for m in ['PARALLEL_INVESTIGATION','PARALLEL_REVIEW','PARALLEL_IMPLEMENT'])

print('# Eval summary')
for k, v in summary.items():
    print(f'{k}={v}')
print('metrics_file=docs/harness/evals/metrics.md')

print('\n# Task type success rate')
for k in sorted(task_type):
    ok = task_success[k]
    total = task_type[k]
    rate = (ok / total * 100) if total else 0
    print(f'{k}\t{ok}/{total}\t{rate:.1f}%')

print('\n# Orchestration mode success/failure/duration')
for k in sorted(mode_total):
    total = mode_total[k]
    ok = mode_success[k]
    fail = mode_fail[k]
    durations = mode_durations.get(k, [])
    avg = mean(durations) if durations else 0
    print(f'{k}\tsuccess={ok}/{total}\tfail={fail}/{total}\tavg_duration_min={avg:.1f}')

print('\n# Agent rework rate')
for k in sorted(agent_total):
    total = agent_total[k]
    rw = agent_rework[k]
    rate = (rw / total * 100) if total else 0
    print(f'{k}\trework={rw}/{total}\t{rate:.1f}%')

print('\n# Reviewer FAIL reasons TOP 10')
if reviewer_fail_reason:
    for reason, count in reviewer_fail_reason.most_common(10):
        print(f'{count}\t{reason}')
else:
    print('none')

print('\n# Project gate failure trend')
if gate_fail_by_date:
    for date in sorted(gate_fail_by_date):
        print(f'{date}\t{gate_fail_by_date[date]}')
else:
    print('none')

print('\n# Fan-in conflict rate')
rate = (fan_in_conflict / fan_in_total * 100) if fan_in_total else 0
print(f'{fan_in_conflict}/{fan_in_total}\t{rate:.1f}%')

print('\n# Regression case capture rate')
rate = (regression_captured / regression_total * 100) if regression_total else 0
print(f'{regression_captured}/{regression_total}\t{rate:.1f}%')

if not plans:
    print('\n[WARN] no completed plan found; field validation evidence is not collected yet')
PY
