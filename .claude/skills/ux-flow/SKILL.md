---
name: ux-flow
description: use for user journey, task flow, navigation, form steps, error recovery, confirmation, loading/empty states, and UX review.
---

# UX 흐름

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

## 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.

## 출력

- 적용한 기준
- 변경/리뷰 범위
- 검증 또는 검토 결과
- 남은 위험
