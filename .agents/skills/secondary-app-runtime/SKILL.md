---
name: secondary-app-runtime
description: use for secondary app, mobile webview, PWA/hybrid runtime, native bridge risk, offline/network state, and touch UX.
---

# 보조 앱 모바일

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- 주요 프론트엔드의 축소판으로 만들지 않는다.
- target runtime, touch flow, 한 손 조작 가능성을 고려한다.
- native/PWA/browser back, safe area, keyboard, 권한/세션 흐름을 확인한다.

## 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.

## 출력

- 적용한 기준
- 변경/리뷰 범위
- 검증 또는 검토 결과
- 남은 위험
