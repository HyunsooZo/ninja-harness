# 하네스 문서 한글화 정리

## 메타데이터

- 담당자: Codex
- 날짜: 2026-05-22
- 범위: `AGENTS.md`, `CLAUDE.md`, `docs/harness/**`, `.agents/skills/**`, `.codex/agents/**`, `.claude/agents/**`, `.claude/commands/**`
- 위험 수준: low
- 기본 실행자: `executor`
- Plan State: `completed`

## 사양

### 목표

하네스를 사용하는 사람이 한 번에 이해할 수 있도록 설명문, 제목, 표 설명을 한국어 중심으로 정리한다.

### 하지 않을 일

- 파일명, 명령어, 코드 식별자, agent id, skill id, enum, `Status`/`Verdict` 값은 런타임 호환을 위해 영어를 유지한다.
- 범용화 정책을 되돌리지 않는다.

## RED 증거

- 예외 사유: 문서 한글화 작업이라 자동화 RED 테스트는 부적합하다.
- 대체 검증:
  - `rg -n "\b(This|Use|Do not|Default|Required|Checklist|Scope|Done|Review|Verification|Primary|Secondary|Backend|Frontend|Behavior|Project|Context|Agent|Skill|Routing|Status|Failure|Examples|Allowed|Forbidden|Recommended|Procedure|Purpose|Principles|Applies|Command|Sources|General|Testing|Harness|Matrix|Profile|Template|Rule|Policy|Criteria|Evidence|Report|Summary|Files|Result)\b" AGENTS.md CLAUDE.md docs/harness .agents/skills .codex/agents .claude/agents .claude/commands --glob '*.md' --glob '*.toml' --glob '*.yaml' --glob '!docs/harness/plans/completed/**'`
  - `rg -n "^# .*[A-Za-z]|^## .*[A-Za-z]|^### .*[A-Za-z]" AGENTS.md CLAUDE.md docs/harness .agents/skills .claude/commands --glob '*.md' --glob '!docs/harness/plans/completed/**'`
  - 두 스캔 모두 영어 제목/설명/표현이 core docs, profiles, rubrics, plan template, agent/skill 문서에 많이 남아 있음을 확인했다.
- 남은 위험: 호환을 위해 유지해야 하는 식별자와 값은 영어로 남겨야 한다.

## GREEN 증거

- `AGENTS.md`, `CLAUDE.md`, `docs/harness/**`의 주요 제목, 표, 설명문을 한국어 중심으로 정리했다.
- `docs/harness/plans/TEMPLATE.md`, `rubrics/**`, `profiles/**`, `context/**`에 남아 있던 영어 라벨과 문장형 표현을 한국어로 바꿨다.
- `.codex/agents/**`와 `.claude/agents/**`는 같은 의미와 같은 본문을 유지하도록 함께 수정했다.
- 런타임 식별자, 파일명, 명령어 placeholder, agent/skill id, `Status`/`Verdict`, DDD/OOP/SOLID/RED/GREEN/VERIFY 같은 표준 값은 호환을 위해 유지했다.

## 리팩터링 기록

- 기계 치환 중 agent/skill id와 command placeholder에 섞인 한글은 다시 ASCII 식별자로 복구했다.
- `Read-only Safety Contract` 제목을 `읽기 전용 안전 계약`으로 바꾸면서 구조 검증 스크립트도 새 한국어 제목을 확인하도록 맞췄다.
- `.DS_Store` 임시 파일을 제거했다.

## 검증 보고

- `bash scripts/verify-harness-structure.sh` 통과.
- 프로젝트별 표현 누수 스캔 통과: 지정된 프로젝트명/스택/도메인 표현 불일치 없음.
- 영어 문장형 잔여 표현 스캔 통과: 지정한 주요 영어 제목/문장 패턴 없음.
- `find . -name .DS_Store -print` 결과 없음.

## 완료 보고

- Summary: 하네스 문서, 프로필, 루브릭, 계획 템플릿, 에이전트/스킬 설명을 한국어 중심으로 정리했다.
- Verification: 구조 검증, Codex/Claude 미러 검증, 프로젝트별 표현 누수 스캔, 영어 문장형 잔여 표현 스캔, `.DS_Store` 확인을 통과했다.
- Risk left: 경로, placeholder, agent/skill id, 상태 enum, 표준 기술 약어는 런타임 호환을 위해 영어로 남아 있다.
