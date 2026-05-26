---
name: frontend-a11y
description: use for dialog focus, aria-label, labelledby/describedby, disabled/aria-disabled, table/grid roles, keyboard navigation, and accessible names.
---

# 프론트 접근성

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- 포커스 이동과 복귀 위치를 명확히 한다.
- ARIA는 의미를 보완할 때만 사용한다.
- 접근성 라벨과 visible copy/i18n을 함께 확인한다.

## 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.

## 출력

- 적용한 기준
- 변경/리뷰 범위
- 검증 또는 검토 결과
- 남은 위험


## 필수 접근성 점검 항목

- dialog/modal open 시 focus가 dialog 내부의 의미 있는 첫 지점으로 이동하는지 확인한다.
- dialog/modal close 후 trigger button으로 focus가 복귀하는지 확인한다.
- keyboard 사용자는 Tab, Shift+Tab, Escape, Enter, Space 흐름으로 주요 작업을 완료할 수 있어야 한다.
- date grid/calendar는 방향키 이동, Enter/Space 선택, 현재 날짜/선택 날짜/비활성 날짜 상태를 screen reader가 구분할 수 있어야 한다.
- `aria-label`은 native label/visible label을 대체하지 않으며, 금지 role 또는 의미 없는 `div`에 남용하지 않는다.
- `disabled` 요소에 불필요한 `aria-disabled`를 중복하지 않는다.
- table 내부 `tr/th/td`에 table ancestor와 충돌하는 role을 추가하지 않는다.
- 중복 id, 깨진 `aria-labelledby`/`aria-describedby`, 보이지 않는 title/description 누락을 점검한다.
- 색상만으로 상태를 전달하지 않고 label/icon/text를 함께 제공한다.
