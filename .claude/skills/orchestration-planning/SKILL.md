---
name: orchestration-planning
description: use for task decomposition, single-agent vs layered delegation, fan-in ownership, backend layer sequencing, parallelization decision, reviewer routing, and active plan orchestration.
---

# 오케스트레이션 계획

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/13_AGENT_ORCHESTRATION.md`
- `docs/harness/11_PARALLEL_AGENT_GATE.md`
- `docs/harness/09_EVIDENCE_GATE.md`
- `docs/harness/plans/TEMPLATE.md`
- 관련 레이어 문서

## 목적

작업을 가장 작고 안전한 실행 단위로 분류하고, 필요한 경우에만 레이어별 에이전트로 분리한다. 오케스트레이션의 목표는 에이전트 수를 늘리는 것이 아니라 충돌, 중복 구현, 누락 검증을 줄이는 것이다.

## 작업 크기 분류

| 분류 | 기본 모드 | 기준 |
|---|---|---|
| trivial | `SINGLE_AGENT` | 문구, 오타, 문서 일부, 낮은 위험 단일 파일 |
| small | `SINGLE_AGENT` | 단일 레이어 변경, 계약/권한/스키마/트랜잭션 변화 없음 |
| medium | `SINGLE_AGENT_WITH_REVIEW` | 구현 범위는 작지만 보안/계약/접근성/테스트 충분성 검토 필요 |
| complex | `SEQUENTIAL_LAYERED` | domain/application/persistence/migration/API/test 중 둘 이상이 순서 의존 |
| parallel-review | `PARALLEL_REVIEW` | 구현 완료 후 read-only 검토를 독립적으로 나눌 수 있음 |
| parallel-implement | `PARALLEL_IMPLEMENT` | 계약 고정, 파일 범위 비중복, 단일 통합자 확보 |

## 큰 작업 감지 신호

아래 중 하나라도 있으면 main agent 단독 구현을 피하고 `task-orchestrator` 또는 이 skill로 먼저 계획한다.

- 도메인 invariant, aggregate boundary, 상태 전이 변경
- transaction boundary, idempotency, outbox/after-commit 변경
- repository query, lock, migration, schema/index 변경
- API contract, DTO, validation, error response 변경
- auth/resource scope/ownership 검증 변경
- provider-consumer contract 변경
- 단위/통합/e2e 검증이 함께 필요한 변경

## 위임 결정 절차

1. 작업 목표와 하지 않을 일을 분리한다.
2. 단일 에이전트로 충분한지 판단한다.
3. 충분하지 않으면 영향 레이어를 표시한다.
4. 순차/병렬 여부를 결정한다.
5. 각 에이전트의 수정 가능 범위와 읽기 전용 범위를 정한다.
6. 공통 결정과 통합 담당자를 active plan에 기록한다.
7. 최종 fan-in 기준과 VERIFY 명령을 고정한다.

## 백엔드 기본 순서

1. `backend-domain-modeler`: invariant, aggregate, state transition
2. `backend-application-implementer`: use case, transaction, idempotency
3. `backend-persistence-implementer`: repository, query, lock, ORM mapping
4. `backend-db-migration-implementer`: schema, index, migration order
5. `backend-api-implementer`: DTO, validation, response/error contract
6. `test-automation-reviewer`: RED/GREEN/VERIFY 충분성
7. `integration-reviewer`, `backend-security-reviewer`, `quality-reviewer`: contract/auth/quality review

## fan-in 체크리스트

- 공통 결정이 구현 결과와 일치하는가?
- 같은 규칙을 domain/application/controller/query에 중복 구현하지 않았는가?
- transaction boundary와 domain state transition이 서로 모순되지 않는가?
- migration/schema와 repository mapping이 일치하는가?
- API contract와 소비자 기대가 일치하는가?
- 각 에이전트의 수정 가능 범위를 벗어난 변경이 없는가?
- VERIFY와 read-only review가 끝났는가?

## Owned API 변경 분류

다음 변경은 단순한 프론트/백 단일 작업으로 확정하지 말고 `integration-contract`와 함께 provider/consumer 영향도를 확인한다.

- frontend API client/type/hook/composable/query key/schema 변경
- backend controller/route/DTO/schema/request/response/status/error/pagination/auth/resource scope 변경
- API matrix route owner, allowed consumer, masking, wrapper 필요 여부 변경

판단 결과:

- provider contract가 그대로면 프론트/소비자 변경만 진행하고 근거를 남긴다.
- consumer 영향이 없으면 백엔드/provider 변경만 진행하고 검색 근거를 남긴다.
- 양쪽 영향이 있으면 `SEQUENTIAL_LAYERED` 또는 `SINGLE_AGENT_WITH_REVIEW`로 전환하고 `integration-reviewer`를 포함한다.

## 출력

- 선택한 모드
- 단일 실행으로 충분한지 판단
- 레이어 영향도
- 위임할 에이전트와 순서
- 병렬 가능 여부와 근거
- 통합 담당자
- fan-in 기준
- VERIFY/review 계획
