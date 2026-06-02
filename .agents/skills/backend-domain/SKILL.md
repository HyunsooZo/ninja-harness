---
name: backend-domain
description: use for aggregate boundary, entity, value object, invariant, state transition, domain service, domain event, policy object, primitive obsession, and domain model design.
---

# 백엔드 도메인 모델링

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/01_BACKEND.md`
- `docs/harness/10_BACKEND_QUALITY_GATE.md`
- `docs/harness/13_AGENT_ORCHESTRATION.md`
- 관련 `docs/harness/context/backend/**` 문서

## 핵심 기준

- 도메인 불변 조건은 domain model, domain service, policy object 중 가장 좁은 책임 위치에 둔다.
- Entity는 식별자와 생명주기를 갖고, Value Object는 값 동등성과 유효성을 스스로 보호한다.
- Aggregate는 transaction consistency boundary로 본다. 단순 테이블 묶음이나 API 응답 형태로 정하지 않는다.
- 상태 전이는 명시적인 메서드나 policy로 표현하고, setter/flag 조합으로 흩어두지 않는다.
- primitive obsession을 줄이고 업무 용어가 드러나는 타입/값 객체를 우선 고려한다.

## 도메인 모델링 체크

- Aggregate root가 외부 변경 진입점을 통제하는가?
- invariant가 controller, DTO, mapper, repository query, application service에 흩어져 있지 않은가?
- domain event가 필요한 경우 event 발생 시점과 after-commit 처리 책임이 application/outbox와 분리되어 있는가?
- domain service는 특정 Entity/Value Object에 자연스럽게 속하지 않는 도메인 행위에만 사용했는가?
- policy object는 조건 분기를 명명하고 테스트할 필요가 있을 때만 사용했는가?
- ORM annotation을 도메인 모델에 함께 쓰는 프로젝트라면, 영속성 편의 때문에 도메인 규칙이 왜곡되지 않았는가?

## 레이어 경계

- Domain은 HTTP, framework, transaction annotation, repository adapter, SQL, message broker, file I/O에 직접 의존하지 않는다.
- Application은 use case orchestration, transaction boundary, idempotency, external call ordering을 담당한다.
- Persistence는 repository 구현, query, lock, pagination, ORM mapping을 담당한다.
- API/Presentation은 validation, request/response mapping, protocol concern을 담당한다.

## 테스트 기준

- 도메인 invariant와 상태 전이는 가능하면 빠른 단위 테스트로 검증한다.
- aggregate boundary 변경은 기존 상태 전이/예외 테스트가 깨지는 RED 증거를 우선 남긴다.
- 동시성/트랜잭션은 domain 단위 테스트만으로 충분하지 않으면 application/persistence 테스트로 넘긴다.

## 오케스트레이션 연계

- 도메인 규칙만 바뀌고 저장/API 계약이 고정되어 있으면 `SINGLE_AGENT`가 가능하다.
- 도메인 규칙과 transaction/persistence/API가 함께 바뀌면 `task-orchestrator`가 `SEQUENTIAL_LAYERED`를 선택하도록 요청한다.
- 같은 aggregate나 invariant를 여러 에이전트가 동시에 수정하지 않는다.

## 출력

- 도메인 결정
- aggregate/entity/value object 영향
- invariant/state transition 변경
- application/persistence/API로 넘길 결정
- 테스트/검증 결과
- 남은 위험
