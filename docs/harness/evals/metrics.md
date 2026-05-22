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

## 운영 기준

- `Verify=SKIP`은 반드시 사유를 completed plan에 남긴다.
- `Review=FAIL`은 `regression-cases.md` 반영 여부를 검토한다.
- 같은 원인으로 2회 이상 재작업하면 skill, agent, gate, 문서 기준으로 되돌린다.
- `SEQUENTIAL_LAYERED` 또는 `PARALLEL_*`이면 fan-in 결과가 completed plan에 있어야 한다.
- fan-in conflict가 반복되면 병렬 구현 허용 조건을 좁힌다.
- 특정 agent의 rework rate가 높으면 agent instruction 또는 skill preload를 조정한다.
