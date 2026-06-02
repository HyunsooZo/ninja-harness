---
name: ux-flow
description: use for user journey, task flow, navigation, form steps, error recovery, confirmation, loading/empty states, and UX review.
---

# UX 흐름

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- 사용자가 업무를 끝내는 경로를 기준으로 본다.
- 주요 액션과 보조 액션의 위계를 분리한다.
- 실패/빈 상태/권한 없음/재시도 흐름을 빠뜨리지 않는다.
