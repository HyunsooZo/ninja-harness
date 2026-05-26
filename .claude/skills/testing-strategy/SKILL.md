---
name: testing-strategy
description: use for test plan, RED evidence, unit/integration/e2e selection, flaky risk, coverage gap, and verification commands.
---

# 테스트 전략

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~10` 문서
- 관련 `docs/harness/context/**` 문서
- 백엔드 구조 변경 시 `docs/harness/10_BACKEND_QUALITY_GATE.md`

## 핵심 기준

- 변경 위험에 맞춰 대상 테스트와 전체 검증을 고른다.
- 자동화가 부적합하면 예외 사유와 대체 검증을 남긴다.
- RED 실패 이유가 요구사항 미구현/버그와 연결되는지 확인한다.

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
