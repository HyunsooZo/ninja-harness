---
name: testing-strategy
description: use for test plan, RED evidence, unit/integration/e2e selection, flaky risk, coverage gap, and verification commands.
---

# 테스트 전략

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

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

- 백엔드 구조 품질 검토는 `docs/harness/10_BACKEND_QUALITY_GATE.md`를 따른다.
