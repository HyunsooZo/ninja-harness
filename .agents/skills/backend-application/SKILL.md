---
name: backend-application
description: use for application service, transaction boundary, use case orchestration, domain event, outbox, idempotency, DTO mapping, and backend application-layer changes.
---

# 백엔드 애플리케이션

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~10` 문서
- 관련 `docs/harness/context/**` 문서
- 백엔드 구조 변경 시 `docs/harness/10_BACKEND_QUALITY_GATE.md`

## 핵심 기준

- application service가 유스케이스 오케스트레이션을 담당한다.
- 도메인 정책은 도메인으로 보내고 중복 구현하지 않는다.
- 트랜잭션 경계와 멱등성 조건을 명시한다.

- 백엔드 구조 품질 검토는 `docs/harness/10_BACKEND_QUALITY_GATE.md`를 따른다.

## 에이전트 연계

- 도메인 invariant가 핵심이면 `backend-domain-modeler`를 먼저 사용한다.
- repository/ORM/query/lock이 핵심이면 `backend-persistence-implementer`를 함께 사용한다.
- 애플리케이션 서비스는 유스케이스 조율, 트랜잭션 경계, 멱등성, 커밋 후 실행/outbox 판단을 담당한다.
