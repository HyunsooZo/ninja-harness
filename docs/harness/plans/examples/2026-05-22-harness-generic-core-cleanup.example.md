# 하네스 범용 핵심 정리

## 메타데이터

- Plan State: completed
- 날짜: 2026-05-22
- 담당자: Codex
- 범위: `AGENTS.md`, `docs/harness/**`, `.agents/skills/**`, `.codex/agents/**`, `.claude/agents/**`, `.claude/commands/**`, `scripts/verify-harness-structure.sh`

## 목표

핵심 하네스 문서에서 특정 적용 프로젝트 표현을 제거하고, 그런 세부 값은 `docs/harness/context/**` 또는 `docs/harness/profiles/**`에 두어 프로젝트 간 재사용 가능하게 만든다.

## 계획

1. 핵심 하네스 문서의 제품별 행위자/리소스/API/스택 표현을 프로필 기반 용어로 바꾼다.
2. 호환 문서와 rubric이 프로젝트별 가정을 다시 들여오지 않도록 정리한다.
3. 핵심 문서에서 프로젝트별 표현을 거부하는 검증을 추가한다. `profiles/**`, `context/**`, `plans/**`는 제외한다.
4. 하네스 검증과 직접 누수 스캔을 실행한다.

## RED 증거

- 예외 사유: 문서와 하네스 정책 정리 작업이라 자동화 RED는 부적합하다.
- 대체 검증:
  - 프로젝트별 행위자/리소스/API/스택/디자인 토큰 표현을 찾는 `rg` 스캔을 실행했다.
  - 스캔 결과 핵심 문서, 라우팅 문서, rubric, 호환 문서에 프로젝트별 표현이 남아 있음을 확인했다.
- 남은 위험: `docs/harness/context/**`와 `docs/harness/profiles/**`는 의도적으로 적용 프로젝트 사실을 담을 수 있으므로 검증에서 제외해야 한다.

## GREEN 증거

- 핵심 하네스 문서를 프로필 기반 용어로 다시 썼다.
  - `00_AGENT_BRIEF.md`
  - `01_BACKEND.md`
  - `02_PRIMARY_FRONTEND.md`
  - `03_SECONDARY_APP.md`
  - `04_INTEGRATION.md`
  - `05_TESTING.md`
  - `07_DESIGN_SYSTEM.md`
  - `08_HARNESS_AUDIT.md`
  - `09_EVIDENCE_GATE.md`
  - `10_BACKEND_QUALITY_GATE.md`
  - `11_PARALLEL_AGENT_GATE.md`
- 라우팅, rubric, 호환 문서, 컨텍스트/프로필 템플릿, 루트 에이전트 지침, 스킬, Codex/Claude 에이전트 미러에서 프로젝트별 행위자, 스택, API prefix, 패키지, 디자인 토큰 값을 제거했다.
- `.DS_Store`, `.codex/.DS_Store`, `docs/.DS_Store`를 제거했다.

## 리팩터링 기록

- `scripts/verify-harness-structure.sh`에 범용 하네스 누수 게이트를 추가했다.
- 게이트는 `AGENTS.md`, `CLAUDE.md`, `docs/harness`, `.codex/agents`, `.agents/skills`, `.claude/agents`, `.claude/commands`를 스캔하되 활성/완료 이력 계획은 제외한다.
- 병렬 계획 템플릿에서 수렴 책임을 뜻하는 표현을 통합 담당자 용어로 정리했다.

## 검증 보고

- `bash scripts/verify-harness-structure.sh` -> PASS.
- 프로젝트별 표현 직접 스캔 -> no matches.
- `find . -name .DS_Store -print` -> no output.

## 완료 보고

- Plan State: completed.
- 변경 파일: 루트 지침, 하네스 문서, 프로필/컨텍스트 템플릿, rubric, 라우팅, 계획 템플릿, Codex/Claude 에이전트, Codex 스킬, Claude 명령, 검증 스크립트.
- 검증: 구조 검증 통과, 직접 누수 스캔 통과, `.DS_Store` 스캔 통과.
- 남은 위험: 완료 계획은 이력 문서이므로 범용 누수 검사에서 제외한다.
