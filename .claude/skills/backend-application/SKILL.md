---
name: backend-application
description: use for application service, transaction boundary, use case orchestration, domain event, outbox, idempotency, DTO mapping, and backend application-layer changes.
---

# 백엔드 애플리케이션

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

## 백엔드 구조 품질

- DDD: 도메인 규칙을 domain model/domain service/policy로 모으고 Controller/DTO/Repository에 흩어두지 않는다.
- Transaction: `@Transactional` 위치, readOnly, propagation, rollback, self-invocation, 커밋 후 실행/outbox 필요성을 확인한다.
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

- 도메인 invariant가 핵심이면 `backend-domain-modeler`를 먼저 사용한다.
- repository/ORM/query/lock이 핵심이면 `backend-persistence-implementer`를 함께 사용한다.
- 애플리케이션 서비스는 유스케이스 조율, 트랜잭션 경계, 멱등성, 커밋 후 실행/outbox 판단을 담당한다.
