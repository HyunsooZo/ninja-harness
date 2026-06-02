---
name: backend-db-migration
description: use for database schema migration, indexes, seeds, ORM mapping, query/runtime dependency, cache, and local data-service readiness work.
---

# 백엔드 DB / Migration 스킬

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/01_BACKEND.md`
- `docs/harness/05_TESTING.md`
- `docs/harness/10_BACKEND_QUALITY_GATE.md`
- `docs/harness/context/BASELINE.md`
- `docs/harness/context/backend/README.md`

## 적용 범위

- Schema migration, index, seed, data backfill, rollback plan
- ORM mapping, persistence runtime configuration, query/index alignment
- Local database/cache/search/message runtime dependency readiness
- Migration ordering and compatibility with application/domain decisions

## 핵심 기준

- Schema/index 변경은 domain invariant, repository contract, query pattern과 함께 검토한다.
- Migration 순서는 기존 데이터, 배포 순서, rollback 가능성, zero-downtime 필요성을 기준으로 정한다.
- ORM 편의를 위해 domain invariant를 약화시키지 않는다.
- Query나 index에 권한/도메인 정책을 숨기지 않는다. 필요한 정책은 application/domain에서 명시하고 persistence는 그 계약을 구현한다.
- Lock, unique constraint, optimistic/pessimistic strategy, cascade, lazy loading, N+1, flush timing은 선택한 stack의 실제 동작을 확인한다.
- Runtime dependency가 필요하면 시작/중지/정리 절차와 project gate script 위치를 active plan에 남긴다.

## 증거 게이트

- 동작/스키마 변경은 RED -> GREEN -> REFACTOR -> VERIFY 증거를 남긴다.
- 자동화 RED가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.
- 가능하면 migration validation, repository/persistence test, integration test, runtime startup check 중 위험에 맞는 검증을 실행한다.

## 출력

- 적용한 DB/migration 기준
- schema/index/runtime 영향
- domain/application/persistence 계약 일치 확인
- 실행한 검증과 남은 위험
