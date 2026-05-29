# 범용 화면 네이밍 정리

## 메타데이터

- 담당자: Codex
- 날짜: 2026-05-22
- 범위: `AGENTS.md`, `CLAUDE.md`, `docs/harness/**`, `.agents/skills/**`, `.codex/agents/**`, `.claude/agents/**`, `.claude/commands/**`, `scripts/verify-harness-structure.sh`
- 위험 수준: medium
- 기본 실행자: `executor`
- Plan State: `completed`

## 목표

이전 추출 원본 프로젝트의 표면/앱 네이밍을 범용 표면/앱 용어로 바꾼다. 사용하지 않는 호환 파일과 빈 디렉터리도 정리한다.

## 하지 않을 일

- 런타임 호환에 필요한 `Status`, `Verdict`, agent model, 명령 placeholder 형식 자체는 임의로 바꾸지 않는다.
- 실제 적용 프로젝트 값은 `profiles/**`와 `context/**` 자리표시자로 유지한다.

## RED 증거

- 예외 사유: 하네스 문서/라우팅/파일명 정리 작업이라 자동화 RED 테스트는 부적합하다.
- 대체 검증:
  - 금지된 이전 표면/앱 네이밍 패턴을 찾는 `rg` 스캔
  - `find . -type d -empty ...`
  - 참조 스캔과 구조 검증으로 정리 전후를 비교한다.
- 남은 위험: 파일명과 agent/skill id를 바꾸므로 모든 참조를 함께 갱신해야 한다.

## GREEN 증거

- 핵심 화면 문서명을 범용 표면 기준으로 바꿨다.
  - `docs/harness/02_PRIMARY_FRONTEND.md`
  - `docs/harness/03_SECONDARY_APP.md`
  - `docs/harness/rubrics/secondary-app.md`
- 이전 호환 wrapper 문서는 실제 기준 문서가 아니어서 삭제했다.
- Codex/Claude agent mirror와 OpenAI/Codex repo skill id를 주요 프론트엔드/보조 앱 기준으로 함께 바꿨다.
- `AGENTS.md`, `CLAUDE.md`, `docs/harness/harness.yaml`, `docs/harness/skill-routing.md`, `.claude/commands/**`, 루트 migration/adaptation notes의 참조를 새 이름으로 맞췄다.
- 검증 스크립트에 이전 표면/앱 네이밍 누수 게이트를 추가했다.

## 리팩터링 기록

- 런타임 호환에 필요한 `Status`, `Verdict`, model, command placeholder 형식은 유지했다.
- 실제 프로젝트에서 바꿔야 하는 값은 `<primary-frontend-dir>`, `<secondary-app-dir>` 같은 자리표시자로 유지했다.
- 표면 구분은 프로젝트별 역할명이 아니라 `primary frontend`, `secondary app` 기준으로 정리했다.
- 빈 디렉터리는 발견되지 않아 삭제할 대상이 없었다.

## 검증 보고

- `bash scripts/verify-harness-structure.sh` -> PASS.
- 이전 표면/앱 네이밍과 원본 프로젝트 표현 직접 스캔 -> no matches.
- 이전 파일명 패턴 스캔 -> no output.
- `find . -type d -empty -not -path './.git/*' -print | sort` -> no output.
- `find . -name .DS_Store -print` -> no output.

## 완료 보고

- Summary: 핵심 문서, rubric, agent/skill id, routing, verifier를 범용 표면/앱 이름으로 정리했다.
- Verification: 구조 검증, 직접 누수 스캔, 파일명 스캔, 빈 디렉터리 스캔, `.DS_Store` 스캔을 통과했다.
- Risk left: 완료 계획은 이력 문서이므로 장기 범용 누수 게이트에서는 제외된다.
