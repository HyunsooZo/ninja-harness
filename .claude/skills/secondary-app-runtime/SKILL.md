---
name: secondary-app-runtime
description: use for secondary app, mobile webview, PWA/hybrid runtime, native bridge risk, offline/network state, and touch UX.
---

# 보조 앱 모바일

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

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
