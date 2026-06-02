# 실전 검증과 성숙도 기준

이 문서는 하네스가 자기 구조를 잘 지키는 수준을 넘어 실제 프로젝트 산출물 품질을 높였는지 확인하기 위한 기준이다.

## 평가 전제

공개적으로 표준화된 에이전트 하네스 순위표나 단일 벤치마크는 없다. 비교는 다음 층위를 구분해서 판단한다.

- 프레임워크: agent orchestration, handoff, tracing, guardrail, eval을 제공하는 SDK/플랫폼
- 런타임 컨벤션: `AGENTS.md`, `CLAUDE.md`, subagent, skill, command 구성
- 운영 하네스: 기존 코딩 에이전트 위에 올려 작업 상태, 게이트, evidence, routing, mirror drift를 강제하는 문서/스크립트 묶음

이 하네스는 세 번째 범주에 속한다. 따라서 프레임워크와 직접 같은 점수표로 비교하지 않는다.

## 현재 강점

- Codex/Claude agent mirror와 skill mirror를 구조 검증으로 강제한다.
- 스킬 원본과 mirror drift를 실패 처리한다.
- reviewer read-only 계약을 구조 검증으로 강제한다.
- template/project 모드를 분리해 core 범용성과 프로젝트 적용성을 함께 다룬다.
- RED -> GREEN -> REFACTOR -> VERIFY 증거를 active/completed plan에 남기도록 한다.
- 병렬 실행 전 파일 범위, 계약 고정, fan-in verify를 요구한다.

## 현재 한계

구조 검증은 하네스 파일의 무결성을 보장하지만, 실제 코드 품질을 직접 증명하지 않는다. 다음 항목은 프로젝트별 게이트나 eval 루프로 보강해야 한다.

- build/test/lint/typecheck가 실제로 실행됐는지
- 테스트 커버리지나 핵심 시나리오가 충분한지
- 보안 스캔, 의존성 스캔, 접근성 검증이 자동화됐는지
- 에이전트 적용 전후 산출물 품질이 개선됐는지
- 실패 사례가 regression case로 축적됐는지

## 성숙도 단계

| 단계 | 상태 | 기준 |
|---|---|---|
| L1 | 구조 하네스 | agent/skill/command/context 구조가 검증된다. |
| L2 | 프로젝트 게이트 연결 | build/test/lint/typecheck 같은 실제 명령이 verify에 연결된다. |
| L3 | evidence 운영 | completed plan에 RED/GREEN/VERIFY 로그와 잔여 위험이 축적된다. |
| L4 | 회귀 학습 | 실패 사례가 test, checklist, skill, rule로 되돌아간다. |
| L5 | 성능 측정 | task 성공률, 재작업률, review fail률, escape defect를 추적한다. |

현재 템플릿 배포본은 L1에 가깝다. 실제 프로젝트에 적용하면서 L2~L5를 채워야 조직 표준으로 볼 수 있다.

## 실전 데이터 최소 수집 기준

배포본 자체에는 completed plan을 비워둔다. 실제 프로젝트에서는 최소 5개 이상의 완료 기록을 쌓은 뒤 하네스 효과를 판단한다.

각 completed plan은 다음을 포함한다.

- 작업 유형: feature, bugfix, refactor, docs, infra, test 중 하나
- 사용 agent/skill
- RED Evidence와 실패 원인
- GREEN Evidence와 실행 명령
- VERIFY Evidence와 결과
- reviewer Verdict
- 재작업 횟수
- 남은 위험
- 다음에 하네스 규칙으로 되돌릴 개선점

## 권장 지표

| 지표 | 의미 | 목표 |
|---|---|---|
| plan_completion_rate | active plan이 completed로 정상 이동한 비율 | 상승 |
| verify_pass_rate | VERIFY가 PASS 또는 DONE으로 끝난 비율 | 상승 |
| review_fail_rate | reviewer가 FAIL을 낸 비율 | 초기에는 높아도 정상, 이후 하락 |
| rework_count | 같은 작업의 재수정 횟수 | 하락 |
| regression_capture_rate | 실패 사례가 테스트/문서/스킬로 반영된 비율 | 상승 |
| context_drift_count | 오래된 context/profile 때문에 발생한 오류 수 | 하락 |

## 운영 임계값과 되먹임

`make eval` 또는 `scripts/collect-eval-metrics.py`는 completed plan 지표를 모아 운영 임계값을 계산한다. 기본 source는 `HARNESS_COMPLETED_PLAN_SOURCE=local`이라 ignored local evidence도 포함한다. CI/package parity 검토처럼 tracked completed plan만 보려면 `HARNESS_COMPLETED_PLAN_SOURCE=tracked`를 설정한다. 기본 임계값은 보고용이고, 조직 표준 CI에서 hard gate로 쓰려면 `HARNESS_EVAL_FAIL_ON_GUARDRAIL=1`을 설정한다.

| 신호 | 기본 임계값 | 되돌릴 위치 |
|---|---:|---|
| review fail rate | 10% 초과 | reviewer skill, numbered core doc, project gate |
| rework rate | 20% 초과 | implementer skill, plan template, context/profile |
| project gate fail rate | 10% 초과 | project gate script, testing doc, CI example |
| fan-in conflict rate | 10% 초과 | `11_PARALLEL_AGENT_GATE.md`, `13_AGENT_ORCHESTRATION.md` |
| regression capture rate | 80% 미만 | `evals/regression-cases.md`, tests/gates/skills |

임계값을 넘긴 항목은 다음 completed plan에 `Regression Captured: yes` 또는 명시적 예외 사유를 남긴다. 반복 원인이 2회 이상 나오면 문서 설명만 추가하지 않고 테스트, project gate, skill/agent 지침, core 문서 중 하나가 재발 방지를 강제해야 한다.

## 90점대 진입 조건

다음 조건이 충족되면 하네스를 조직 표준 후보로 평가할 수 있다.

1. 최소 하나 이상의 실제 프로젝트 게이트가 `HARNESS_RUN_PROJECT_CHECKS=1`에서 실행된다. 조직 표준 후보라면 `HARNESS_REQUIRE_PROJECT_CHECKS=1`로 빈 게이트를 실패 처리한다.
2. completed plan example이 실제 프로젝트 로그를 익명화한 형태로 2개 이상 제공된다.
3. 실패 사례가 `docs/harness/evals/regression-cases.md`에 축적된다.
4. `docs/harness/evals/metrics.md`에 최근 작업 지표가 기록된다.
5. 신규 사용자가 `QUICKSTART_5_MIN.md`만 보고 첫 작업 계획을 만들 수 있다.

## 공개 사례와 비교할 때의 표현 기준

다음 표현은 허용한다.

- 산문형 `AGENTS.md`/`CLAUDE.md`보다 구조 무결성 검증이 강하다.
- 기존 코딩 에이전트 위에 얹는 운영 하네스 범주에서는 상위권 설계로 볼 수 있다.
- 단, 실제 프로젝트 게이트와 eval 데이터가 없으면 프로덕션 검증 완료라고 말하지 않는다.

다음 표현은 피한다.

- 객관적 세계 순위
- 검증된 최고급 하네스
- 모든 프레임워크보다 우수함
- 실제 품질 개선이 입증됨
