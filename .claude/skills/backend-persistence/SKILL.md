---
name: backend-persistence
description: use for repository adapter, ORM mapping, query, pagination, index, migration impact, optimistic/pessimistic lock, cache, and persistence tests.
---

# 백엔드 영속성

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

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

- 백엔드 구조 품질 검토는 `docs/harness/10_BACKEND_QUALITY_GATE.md`를 따른다.

## 에이전트 연계

- 영속성 구현은 `backend-persistence-implementer`가 담당한다.
- Entity, Value Object, Aggregate, invariant 판단은 `backend-domain-modeler`가 담당한다.
- 트랜잭션 경계와 멱등성는 `backend-application-implementer`와 맞춘다.
- migration/schema/index 변경은 `backend-db-migration-implementer`와 분리한다.
