# 하네스 운영 지표

이 파일은 실제 프로젝트 적용 후 갱신한다. 배포 템플릿에서는 형식과 집계 기준만 제공한다.

## Completed plan 권장 메타데이터

`collect-eval-metrics.sh`는 completed plan에서 아래 marker를 최대한 읽어 집계한다. 모두 필수는 아니지만, 조직 표준에서는 가능한 한 채운다.

```md
- 날짜: YYYY-MM-DD
- 작업 유형: feature | bugfix | refactor | docs | security | migration
- 기본 실행자: task-orchestrator | backend-application-implementer | ...
- 모드: SINGLE_AGENT | SINGLE_AGENT_WITH_REVIEW | SEQUENTIAL_LAYERED | PARALLEL_REVIEW | PARALLEL_IMPLEMENT
- Duration Minutes: 35
- Rework Count: 1
- Gate Fail Count: 0
- Regression Captured: yes | no
- Fan-in Conflict: yes | no
- Reviewer Fail Reason: <reason>
- Verdict: PASS | PASS_WITH_CONCERNS | FAIL
```

## 수집 지표

`scripts/collect-eval-metrics.sh`는 다음을 출력한다.

- 작업 유형별 성공률
- agent별 재작업률
- reviewer FAIL 사유 TOP 5 / reviewer별 또는 사유별 FAIL TOP N
- project gate 실패율 추이
- fan-in 충돌 발생률
- regression case 반영률
- orchestration mode별 성공률/실패율/평균 소요 시간
- 기존 marker count: FAIL, SKIP, BLOCKED, rework, regression
- 운영 임계값: review fail, rework, project gate fail, fan-in conflict, regression capture 기준 초과 여부

격리된 fixture나 외부 completed plan 디렉터리를 집계할 때는 `HARNESS_COMPLETED_PLAN_DIR`를 지정한다. 기본 source는 `HARNESS_COMPLETED_PLAN_SOURCE=local`이며 ignored local completed plan까지 포함한다. CI/package parity처럼 git에 tracked 된 completed plan만 보려면 `HARNESS_COMPLETED_PLAN_SOURCE=tracked`를 지정한다.

```bash
HARNESS_COMPLETED_PLAN_DIR=/tmp/completed-plans bash scripts/collect-eval-metrics.sh
HARNESS_COMPLETED_PLAN_SOURCE=tracked bash scripts/collect-eval-metrics.sh
```

실패 지표는 RED 증거의 의도된 실패나 서술형 "실패" 표현이 아니라 `Verdict`, `Status`, `Review`, `Verify`, 리뷰/검증 표의 최종 결과가 `FAIL`인 경우를 중심으로 집계한다. regression capture 지표도 서술형 "회귀" 표현이 아니라 `Regression Captured`, `Regression Case`, `회귀 사례`, `회귀 반영` 같은 명시 marker만 분모로 삼는다.

## 운영 임계값

collector는 기본적으로 임계값 초과 여부를 보고만 한다. `make verify-org`는 조직 표준 경로이므로 `HARNESS_EVAL_FAIL_ON_GUARDRAIL=1`로 eval을 hard gate로 실행한다. 개별 CI나 별도 eval job에서 hard gate로 쓰려면 같은 환경변수를 설정한다.

| 환경변수 | 기본값 | 의미 |
|---|---:|---|
| `HARNESS_MAX_REVIEW_FAIL_RATE` | 10 | completed plan 중 최종 리뷰/검증 FAIL 비율 상한 |
| `HARNESS_MAX_REWORK_RATE` | 20 | 재작업이 발생한 completed plan 비율 상한 |
| `HARNESS_MAX_GATE_FAIL_RATE` | 10 | project gate 실패가 발생한 completed plan 비율 상한 |
| `HARNESS_MAX_FAN_IN_CONFLICT_RATE` | 10 | fan-in 충돌 발생률 상한 |
| `HARNESS_MIN_REGRESSION_CAPTURE_RATE` | 80 | 회귀/실패 사례가 regression case로 반영된 비율 하한 |

임계값을 넘으면 `action_required=yes`와 `guardrail_findings=...`를 출력한다. 같은 원인이 반복되면 `docs/harness/evals/regression-cases.md`에 등록하고 test, project gate, skill, agent, numbered core 문서 중 하나로 되돌린다.

## 운영 기준

- `Verify=SKIP`은 반드시 사유를 completed plan에 남긴다.
- `Review=FAIL`은 `regression-cases.md` 반영 여부를 검토한다.
- 같은 원인으로 2회 이상 재작업하면 skill, agent, gate, 문서 기준으로 되돌린다.
- `SEQUENTIAL_LAYERED` 또는 `PARALLEL_*`이면 fan-in 결과가 completed plan에 있어야 한다.
- fan-in conflict가 반복되면 병렬 구현 허용 조건을 좁힌다.
- 특정 agent의 rework rate가 높으면 agent instruction 또는 skill preload를 조정한다.
