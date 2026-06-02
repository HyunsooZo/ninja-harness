# 조직 적용 점수표

대형 조직 표준으로 승격하기 전 프로젝트별 적용 상태를 평가한다.

| 영역 | 기준 | 점수 |
|---|---|---:|
| 최종 무결성 | `make integrity` 통과 | 0/2 |
| 프로젝트 준비도 | 적용 저장소에서 `make project-ready` 또는 동등한 profile readiness 통과 | 0/1 |
| 조직 게이트 | `HARNESS_ORG_STANDARD=1` + 최소 1개 script gate | 0/2 |
| 보안 ACK | `HARNESS_ACK_TRUSTED_PROJECT_CMDS=1` 사용 | 0/1 |
| Script gate 사용 | legacy `HARNESS_*_CMD` 없이 `HARNESS_*_SCRIPT` 사용 | 0/2 |
| Context/Profile | `BASELINE`, `INDEX`, `project-profile` 최신화 | 0/2 |
| Completed Plan | 20개 이상 또는 2주 이상 운영 기록 | 0/2 |
| Eval 지표 | 성공률/재작업률/FAIL 사유/project gate 추이 수집 | 0/2 |
| Regression | 반복 실패를 regression case에 반영 | 0/2 |
| Orchestration | 복합 작업에 task-orchestrator/fan-in 기록 | 0/2 |
| Reviewer Safety | reviewer read-only 계약 유지 | 0/1 |
| Eval Guardrail | `make eval`의 `action_required=no` 또는 초과 항목의 regression 반영 | 0/2 |

## 판정

- 0~10: 파일럿 전 준비 부족
- 11~15: 파일럿 가능
- 16~19: 팀 표준 가능
- 20 이상: 조직 표준 후보

## 운영 메모

점수표는 품질 보증이 아니라 adoption readiness를 보는 도구다. 실제 표준 승격 전에는 실패 사례, 보안 예외, CI 비용, 팀 피드백을 함께 검토한다.

`make eval`에서 `action_required=yes`가 나오면 점수만 깎지 말고 원인을 `docs/harness/evals/regression-cases.md`에 등록한 뒤 test, project gate, skill, agent, numbered core 문서 중 하나로 되돌린다. 임계값은 `docs/harness/evals/metrics.md`의 `HARNESS_MAX_*` / `HARNESS_MIN_*` 환경변수로 조직별 조정한다.
