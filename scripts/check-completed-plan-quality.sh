#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

completed_dir="docs/harness/plans/completed"
plans=("$completed_dir"/*.md)

if [[ ! -e "${plans[0]}" ]]; then
  echo "[OK] completed plan quality: no completed plans in template/package"
  exit 0
fi

failed=0
for plan in "${plans[@]}"; do
  text="$(cat "$plan")"
  missing=()
  [[ "$text" == *"RED"* || "$text" == *"사전 실패"* ]] || missing+=("RED evidence")
  [[ "$text" == *"GREEN"* || "$text" == *"구현"* ]] || missing+=("GREEN evidence")
  [[ "$text" == *"REFACTOR"* || "$text" == *"리팩토링"* || "$text" == *"리팩터링"* ]] || missing+=("REFACTOR decision")
  [[ "$text" == *"VERIFY"* || "$text" == *"검증"* ]] || missing+=("VERIFY evidence")
  [[ "$text" == *"잔여 위험"* || "$text" == *"Risk"* || "$text" == *"risk"* ]] || missing+=("residual risk")

  if [[ "$text" == *"SEQUENTIAL_LAYERED"* || "$text" == *"PARALLEL_IMPLEMENT"* || "$text" == *"PARALLEL_REVIEW"* || "$text" == *"PARALLEL_INVESTIGATION"* ]]; then
    [[ "$text" == *"통합 담당자"* ]] || missing+=("integration owner")
    [[ "$text" == *"레이어 영향도"* ]] || missing+=("layer impact")
    [[ "$text" == *"수렴 기준"* || "$text" == *"수렴 결과"* ]] || missing+=("fan-in criteria/result")
    [[ "$text" == *"중복 구현"* ]] || missing+=("duplicate implementation check")
    [[ "$text" == *"계약 일치"* ]] || missing+=("contract consistency check")
  fi

  if [[ "$text" == *"PARALLEL_IMPLEMENT"* ]]; then
    [[ "$text" == *"Parallelization Check"* || "$text" == *"병렬화 점검"* ]] || missing+=("parallelization check")
    [[ "$text" == *"겹치는 파일"* ]] || missing+=("overlapping file check")
  fi

  if (( ${#missing[@]} > 0 )); then
    echo "[FAIL] $plan missing: ${missing[*]}"
    failed=1
  else
    echo "[OK] $plan"
  fi
done

exit "$failed"
