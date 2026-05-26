---
name: design-system
description: use for design tokens, component variants, density, spacing, typography, color contrast, icon usage, and shared UI consistency.
---

# 디자인 시스템

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- 기존 토큰과 컴포넌트 패턴을 우선한다.
- 인라인 스타일과 외부 UI 라이브러리를 금지한다.
- 색/타입/간격/반경/그림자 기준을 일관되게 유지한다.

## 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.

## 출력

- 적용한 기준
- 변경/리뷰 범위
- 검증 또는 검토 결과
- 남은 위험


## 필수 디자인 시스템 점검 항목

- 원시 색상/간격/radius/shadow 값을 component에 직접 넣지 않고 token으로 먼저 정의한다.
- 프로젝트별 토큰 접두사는 `docs/harness/profiles/design-system-profile.md`와 일치해야 한다.
- primary CTA, inline link, semantic status, 브랜드 강조의 역할을 분리한다.
- 기존 component tone과 충돌하는 새로운 시각 언어를 임의로 도입하지 않는다.
- focus ring, contrast, reduced motion, responsive density를 함께 확인한다.
