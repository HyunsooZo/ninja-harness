# 에이전트 작업 지침

이 파일은 Codex/Claude가 작업 시작 시 읽는 짧은 진입 지도다. 세부 기준은 `docs/harness/**`와 `docs/harness/profiles/**`를 따른다.

- 공통 로컬 진입점은 `Makefile`이다. 로컬 도구 점검은 `make doctor`, 구조 검증은 `make verify`, 실제 프로젝트 placeholder 준비도 검증은 `make project-ready`, 하네스 자체 최종 무결성 검증은 `make integrity`, skill 동기화는 `make sync-skills`, 조직 표준 검증은 `HARNESS_*_SCRIPT=... make verify-org`를 우선 사용한다.

## 항상 읽을 문서

1. `docs/harness/context/BASELINE.md`
2. `docs/harness/context/INDEX.md`
3. `docs/harness/README.md`
4. `docs/harness/QUICKSTART_5_MIN.md`가 필요하면 온보딩 절차를 확인
5. 진행 중 작업이 있으면 `docs/harness/plans/active/*.md`

전체 스캔 파일(`PROJECT_CONTEXT_SCAN.md` 등)은 기본 컨텍스트로 읽지 않는다. 전체 스캔은 `docs/harness/context/generated/`의 임시 산출물로만 둔다.

작업이 아주 작으면 `docs/harness/context/INDEX.md`의 `T0_MINIMAL`/`T1_STANDARD` context tier를 따른다. 교차 레이어, 보안/계약/런타임, 하네스 정책 변경은 `T2_EXPANDED`로 올리고, 전체 스캔은 `T3_FULL_SCAN` 조건에서만 수행한다.

## 프로젝트 프로파일

- 실제 repo 경로, 행위자/리소스 용어, API prefix, package 예시는 `docs/harness/profiles/project-profile.md`에 둔다.
- 디자인 토큰/테마 이름 같은 프로젝트별 시각 기준은 `docs/harness/profiles/design-system-profile.md`에 둔다.
- 실제 프로젝트와 다르면 `docs/harness/context/BASELINE.md`와 `docs/harness/profiles/**`를 먼저 갱신한다.

## 작업 규칙

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만들거나 갱신한다.
- 동작 변경은 `docs/harness/09_EVIDENCE_GATE.md` 기준으로 RED -> GREEN -> REFACTOR -> VERIFY 증거를 남긴다.
- 자동화 RED가 부적합하면 활성 계획의 `RED Evidence`에 예외 사유, 대체 검증, 잔여 위험을 기록한다.
- 요청과 직접 연결된 파일과 직접 의존 파일만 수정한다.
- 관련 없는 리팩토링, 포맷 변경, dead code 삭제를 하지 않는다.
- 완료 시 활성 계획을 `docs/harness/plans/completed/`로 이동한다. 장기 사실은 `docs/harness/context/**`와 `docs/harness/profiles/**`에만 반영한다.

## 레이어 규칙

- 레이어별 에이전트 분리는 항상 여러 에이전트를 실행하라는 뜻이 아니다. 단일 레이어/작은 수정은 단일 에이전트가 처리하고, 여러 레이어의 도메인 규칙·트랜잭션·영속성·API 계약이 함께 바뀔 때만 `docs/harness/13_AGENT_ORCHESTRATION.md` 기준으로 분리 위임한다.
- 백엔드는 domain/application/presentation/infrastructure 경계를 유지한다. DDD/OOP/SOLID, transaction, concurrency 기준은 `docs/harness/10_BACKEND_QUALITY_GATE.md`로 점검한다.
- 행위자/리소스 범위 API 권한은 행위자, 활성 리소스, 소유/소속 관계를 먼저 검증한다. 현재 프로젝트 용어는 `docs/harness/profiles/project-profile.md`를 따른다.
- 민감 응답에는 내부 식별자, 저장 경로, 원본/공개 토큰을 노출하지 않는다.
- 프론트 사용자 표시 문구는 프로젝트의 i18n/content 시스템을 사용한다. 인라인 스타일과 승인 없는 외부 UI/스타일 프레임워크를 금지한다.
- 디자인 추가/리팩토링은 `docs/harness/07_DESIGN_SYSTEM.md`와 `docs/harness/profiles/design-system-profile.md`를 함께 따른다.
- API/인증/리소스/페이지네이션/목록 로딩 변경은 `docs/harness/04_INTEGRATION.md` 기준으로 제공자/소비자를 함께 확인한다.

## 스킬 정책

- 스킬 원본은 `.agents/skills/**`다.
- Claude native skill mirror는 `.claude/skills/**`다.
- 스킬 수정 후 `scripts/sync-skills.sh`, `python3 scripts/sync-skills.py`, 또는 PowerShell의 `pwsh -File scripts/sync-skills.ps1`로 mirror를 갱신한다.
- 구조 검증은 `.agents/skills`와 `.claude/skills`의 drift를 실패 처리한다.

## 라우팅

- 구현/수정/리팩토링: `.agents/skills/executor/SKILL.md` / `.claude/skills/executor/SKILL.md`
- 리뷰/PR 리뷰/감사: `.agents/skills/review-pr/SKILL.md`, `.agents/skills/review-rubric/SKILL.md` / Claude mirror `.claude/skills/**`
- 백엔드: `docs/harness/01_BACKEND.md`, `docs/harness/10_BACKEND_QUALITY_GATE.md`
- 주요 프론트엔드: `docs/harness/02_PRIMARY_FRONTEND.md`
- 보조 앱: `docs/harness/03_SECONDARY_APP.md`, `docs/harness/rubrics/secondary-app.md`
- 통합 계약: `docs/harness/04_INTEGRATION.md`, `.agents/skills/integration-contract/SKILL.md` / `.claude/skills/integration-contract/SKILL.md`
- 테스트/검증: `docs/harness/05_TESTING.md`, `.agents/skills/testing-strategy/SKILL.md` / `.claude/skills/testing-strategy/SKILL.md`
- 에이전트 위임 판단: `task-orchestrator`, `.agents/skills/orchestration-planning/SKILL.md`, `docs/harness/13_AGENT_ORCHESTRATION.md`
- 병렬 실행 판단: `docs/harness/11_PARALLEL_AGENT_GATE.md`
- 하네스 유지보수: `docs/harness/08_HARNESS_AUDIT.md`, `.agents/skills/harness-maintenance/SKILL.md` / `.claude/skills/harness-maintenance/SKILL.md`

세부 agent/skill 매핑은 `docs/harness/skill-routing.md`와 `docs/harness/harness.yaml`을 따른다.

## 에이전트 오케스트레이션

- 기본값은 `SINGLE_AGENT` 또는 `SEQUENTIAL_LAYERED`다.
- 작은 단일 수정은 한 에이전트가 처리한다.
- 여러 레이어가 얽힌 큰 작업은 main agent가 혼자 구현하지 않고 `task-orchestrator`가 domain/application/persistence/api/test/review로 분리한다.
- 분리 위임 시 active plan에 `에이전트 오케스트레이션`과 공통 결정, 통합 담당자, 레이어별 범위를 기록한다.
- 모든 분리 작업은 단일 통합자가 중복 구현, 레이어 경계, 계약 일치를 수렴한 뒤 VERIFY를 수행한다.

## 병렬 에이전트 게이트

- 기본값은 `SEQUENTIAL`이다.
- 독립 검토 작업은 `PARALLEL_REVIEW`를 우선 고려한다.
- 구현 병렬화는 API/DTO/schema 계약이 고정되고 수정 파일 범위가 겹치지 않을 때만 허용한다.
- 같은 파일, aggregate, transaction boundary, migration/schema, 권한 정책을 여러 에이전트가 동시에 수정하지 않는다.
- 병렬 실행 전 활성 계획에 `Parallelization Check`와 `Parallel Agent Dispatch`를 남긴다.
- 병렬 실행 후 단일 통합자가 결과를 수렴하고 VERIFY와 최종 REVIEW를 다시 실행한다.

## 리뷰어 안전 규칙

`*-reviewer` 에이전트는 읽기 전용이다. 리뷰어는 파일 수정, 패치 작성, 자동 수정, 커밋/푸시를 하지 않고 발견 사항, 심각도, 근거, 권장 수정안, 판정만 남긴다.

## 명령

대표 명령은 `docs/harness/context/BASELINE.md`와 `docs/harness/05_TESTING.md`를 따른다. 경로가 placeholder이면 실제 repo 경로를 먼저 확인한다.

구조 검증은 기본적으로 하네스 무결성을 확인한다. 실제 프로젝트 값이 모두 채워졌는지 확인하려면 `make project-ready` 또는 `HARNESS_REQUIRE_FILLED_PROFILE=1 HARNESS_VERIFY_MODE=project bash scripts/verify-harness-structure.sh`를 실행한다. 실제 프로젝트 build/test/lint까지 확인하려면 `HARNESS_RUN_PROJECT_CHECKS=1`과 `HARNESS_*_SCRIPT` 환경변수를 설정해 `scripts/verify-project-gates.sh`, `python3 scripts/verify-project-gates.py`, 또는 PowerShell의 `pwsh -File scripts/verify-project-gates.ps1`를 실행한다. 조직 표준에서는 repository script gate를 우선하고, legacy `HARNESS_*_CMD`는 `HARNESS_ALLOW_LEGACY_BASH_LC=1`로 명시 허용된 경우에만 사용한다.

## 실전 검증

하네스 효과는 `docs/harness/12_FIELD_VALIDATION.md` 기준으로 판단한다. completed plan, project gate 결과, eval 지표, 회귀 사례가 쌓이기 전에는 실제 품질 개선이 입증됐다고 말하지 않는다.

## 보고

- 구현/테스트 종료는 `Status`에 정확히 하나의 값을 쓴다: `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED`.
- 판정형 읽기 전용 리뷰는 `Verdict`에 정확히 하나의 값을 쓴다: `PASS`, `PASS_WITH_CONCERNS`, `FAIL`.
- Codex는 사용자가 명시적으로 요청한 경우에만 `git commit`, `git commit --amend`, `git push`를 수행한다.


## 조직 표준 메모

대형 조직 표준 적용 시 `docs/harness/GOVERNANCE.md`, `docs/harness/SECURITY_POLICY.md`, `docs/harness/ADOPTION_SCORECARD.md`를 확인한다. Project gate는 `HARNESS_*_SCRIPT`를 우선하고, legacy `HARNESS_*_CMD`는 명시적으로 허용된 경우에만 사용한다.


## Owned API Contract Impact

API DTO/request/response/status/error/pagination/auth/resource scope를 수정할 때는 `docs/harness/04_INTEGRATION.md`의 Owned API Contract Impact Rule을 따른다. 프론트발 변경은 우리 백엔드 API 의도를 확인하고, 백엔드발 변경은 해당 API를 호출하는 프론트 코드가 있는지 검색한다. 필요한 경우 양쪽 코드를 함께 수정하고, 수정하지 않는 경우 확인 근거를 active plan에 남긴다.
