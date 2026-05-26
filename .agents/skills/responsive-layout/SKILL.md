---
name: responsive-layout
description: use for breakpoint layout, mobile/tablet/desktop behavior, touch target, overflow, table-to-card conversion, and viewport testing.
---

# 반응형 레이아웃

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- 정보 우선순위가 화면 크기별로 유지되는지 확인한다.
- 터치 타겟, safe area, overflow, 겹침 위험을 점검한다.
- 테이블은 모바일에서 카드/요약 패턴을 검토한다.

## 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.

## 출력

- 적용한 기준
- 변경/리뷰 범위
- 검증 또는 검토 결과
- 남은 위험


## 필수 반응형 점검 항목

- mobile/tablet/desktop breakpoint별 정보 우선순위가 유지되는지 확인한다.
- table -> card 전환 시 column label과 값의 관계가 보존되는지 확인한다.
- touch target은 44px 이상을 기본값으로 본다.
- sticky toolbar, bottom action, safe area, keyboard open 상태에서 CTA가 가려지지 않는지 확인한다.
- overflow-x가 필요한 표는 접근 가능한 caption/summary와 스크롤 힌트를 제공한다.
- desktop에서만 보이는 hover affordance에 핵심 기능을 의존하지 않는다.
