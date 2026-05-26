---
name: harness-maintenance
description: use for harness structure, AGENTS/CLAUDE docs, agent/skill mirror sync, verification scripts, leakage checks, and packaging.
---

# 하네스 유지보수

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- 공통 기준은 AGENTS.md와 docs/harness/**에 둔다.
- 런타임별 파일은 공통 기준을 mirror한다.
- 오래된 특정 프로젝트 표현과 깨진 참조를 정리한다.

## 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.

## 출력

- 적용한 기준
- 변경/리뷰 범위
- 검증 또는 검토 결과
- 남은 위험
