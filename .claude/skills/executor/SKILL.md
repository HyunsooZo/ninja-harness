---
name: executor
description: use for scoped implementation, file changes, RED/GREEN/REFACTOR/VERIFY execution, plan updates, and safe task completion.
---

# 실행 오케스트레이터

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~13` 문서
- 단순하지 않은 작업이면 `docs/harness/13_AGENT_ORCHESTRATION.md`
- 병렬 후보이면 `docs/harness/11_PARALLEL_AGENT_GATE.md`
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- 범위와 영향을 먼저 정리한다.
- 단순하지 않은 작업은 활성 계획을 만든다.
- 동작 변경은 RED -> GREEN -> REFACTOR를 따른다.
- 검증과 문서 갱신까지 완료 기준에 포함한다.

## 오케스트레이션 기준

- 단순하지 않은 작업은 구현 전에 `SINGLE_AGENT`, `SINGLE_AGENT_WITH_REVIEW`, `SEQUENTIAL_LAYERED`, `PARALLEL_INVESTIGATION`, `PARALLEL_REVIEW`, `PARALLEL_IMPLEMENT` 중 하나를 선택한다.
- 큰 작업 감지 신호가 있으면 main agent가 혼자 구현하지 않고 `task-orchestrator` 또는 `orchestration-planning` skill로 active plan을 먼저 작성한다.
- 분리 위임이 필요하면 active plan의 `에이전트 오케스트레이션` 블록에 공통 결정, 레이어 영향도, 통합 담당자, fan-in 기준을 채운다.
- 분리 결과는 단일 통합자가 중복 구현, 레이어 경계, 계약 일치, VERIFY 결과를 수렴한다.

## Owned API 계약 변경 주의

API DTO/request/response/status/error/pagination/auth/resource scope를 수정하는 작업은 구현 전 `docs/harness/04_INTEGRATION.md`의 Owned API Contract Impact Rule을 확인한다. 프론트발 API 변경이면 백엔드 API 의도를 확인하고, 백엔드발 API 변경이면 해당 API를 호출하는 프론트 코드가 있는지 검색한다. 양쪽 수정이 필요하면 `task-orchestrator`로 분리 위임한다.
