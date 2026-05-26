# /plan

## 목적

작업 계획과 오케스트레이션 결정을 수행한다.

## 절차

1. 작업 목표와 제외 범위를 적는다.
2. 단일 작업인지 복합 작업인지 판단한다.
3. `SINGLE_AGENT | SINGLE_AGENT_WITH_REVIEW | SEQUENTIAL_LAYERED | PARALLEL_INVESTIGATION | PARALLEL_REVIEW | PARALLEL_IMPLEMENT` 중 하나의 오케스트레이션 모드를 고른다.
4. 큰 작업 감지 신호가 있으면 `task-orchestrator` 또는 `orchestration-planning` skill을 사용한다.
5. 영향 파일/레이어/API 계약을 정리한다.
6. 분리 위임이 필요하면 레이어 영향도, 담당 에이전트, 수정 가능 범위, 통합 담당자, 수렴 기준을 active plan에 기록한다.
7. 병렬 후보이면 `docs/harness/11_PARALLEL_AGENT_GATE.md`를 확인하고 `Parallelization Check`를 작성한다.
8. RED/GREEN/REFACTOR/VERIFY 방법을 정한다.
9. 필요한 에이전트/스킬/리뷰 게이트를 고른다.
10. 활성 계획이 필요하면 `docs/harness/plans/active/`에 작성한다.

## 완료 기준

- 단일 작업이면 단일 실행으로 충분한 이유가 명확하다.
- 복합 작업이면 오케스트레이션 블록과 수렴 기준이 채워져 있다.
- 병렬 작업이면 병렬화 점검과 단일 통합자가 지정되어 있다.
- VERIFY와 필요한 read-only review가 계획되어 있다.
