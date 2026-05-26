---
name: backend-persistence
description: use for repository adapter, ORM mapping, query, pagination, index, migration impact, optimistic/pessimistic lock, cache, and persistence tests.
---

# 백엔드 영속성

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~10` 문서
- 관련 `docs/harness/context/**` 문서
- 백엔드 구조 변경 시 `docs/harness/10_BACKEND_QUALITY_GATE.md`

## 핵심 기준

- 마이그레이션은 데이터 영향도와 롤백 가능성을 확인한다.
- 쿼리/인덱스 변경은 pagination과 성능 영향을 함께 본다.
- cache 변경은 만료, 키 충돌, 일관성 위험을 적는다.

## 백엔드 구조 품질

- DDD: 도메인 규칙을 domain model/domain service/policy로 모으고 Controller/DTO/Repository에 흩어두지 않는다.
- 트랜잭션: 프레임워크 트랜잭션 경계, readOnly, propagation, rollback, self-invocation/proxy, 커밋 후 실행/outbox 필요성을 확인한다.
- OOP: 데이터와 행위를 과도하게 분리하지 않고 invariant를 객체가 보호하게 한다.
- SOLID: SRP/OCP/LSP/ISP/DIP 위반이 실제 변경 비용과 버그 위험을 키우는지 본다.

## 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.

## 출력

- 적용한 기준
- 변경/리뷰 범위
- 검증 또는 검토 결과
- 남은 위험


## 에이전트 연계

- 영속성 구현은 `backend-persistence-implementer`가 담당한다.
- Entity, Value Object, Aggregate, invariant 판단은 `backend-domain-modeler`가 담당한다.
- 트랜잭션 경계와 멱등성는 `backend-application-implementer`와 맞춘다.
- migration/schema/index 변경은 `backend-db-migration-implementer`와 분리한다.
