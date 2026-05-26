---
name: primary-frontend-ui
description: use for primary frontend views, component composition, forms, tables, modals, state feedback, and UI behavior implementation.
---

# 주요 프론트엔드 UI

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- 기존 주요 프론트엔드 컴포넌트와 SCSS 톤을 우선한다.
- visible copy는 i18n을 적용한다.
- 인라인 스타일과 외부 UI 프레임워크를 금지한다.

## 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.

## 출력

- 적용한 기준
- 변경/리뷰 범위
- 검증 또는 검토 결과
- 남은 위험
