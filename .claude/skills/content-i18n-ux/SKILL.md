---
name: content-i18n-ux
description: use for Korean/English copy, i18n keys, empty/error/loading text, terminology consistency, truncation, and user-facing content UX.
---

# 콘텐츠/i18n UX

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- visible copy는 i18n key를 사용한다.
- actor/resource 용어를 프로젝트 profile과 일관되게 쓴다.
- empty/error/loading/retry 문구를 실제 업무 흐름에 맞춘다.

## 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.

## 출력

- 적용한 기준
- 변경/리뷰 범위
- 검증 또는 검토 결과
- 남은 위험
