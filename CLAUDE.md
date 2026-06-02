# Claude Code 지침

이 저장소는 범용 한국어 개발 하네스를 사용한다. Claude Code는 아래 기준을 우선한다.

- 공통 로컬 진입점은 `Makefile`이다. 로컬 도구 점검은 `make doctor`, 구조 검증은 `make verify`, 실제 프로젝트 placeholder 준비도 검증은 `make project-ready`, 하네스 자체 최종 무결성 검증은 `make integrity`, skill 동기화는 `make sync-skills`, 조직 표준 검증은 `HARNESS_*_SCRIPT=... make verify-org`를 우선 사용한다.

## 우선순위

1. `AGENTS.md`
2. `docs/harness/context/BASELINE.md`
3. `docs/harness/plans/active/*.md`
4. `docs/harness/plans/completed/` 중 최근 완료 문서
5. `docs/harness/**`
   - 신규 사용자는 `docs/harness/QUICKSTART_5_MIN.md`를 먼저 확인한다.
   - 실전 검증과 성숙도 판단은 `docs/harness/12_FIELD_VALIDATION.md`를 따른다.
   - 프로젝트별 행위자/API/토큰/패키지 기준은 `docs/harness/profiles/**`를 함께 확인한다.
   - 에이전트 위임 판단은 `docs/harness/13_AGENT_ORCHESTRATION.md`를 우선 확인한다.
   - 병렬 실행 판단은 `docs/harness/11_PARALLEL_AGENT_GATE.md`를 우선 확인한다.
6. `.claude/agents/**`, `.claude/skills/**`, `.claude/commands/**`
7. `.codex/agents/**`, `.agents/skills/**` 원본 문서

## 스킬 미러 정책

- 스킬 원본은 `.agents/skills/**`다.
- Claude native skill mirror는 `.claude/skills/**`다.
- 두 디렉터리의 `SKILL.md`와 보조 파일은 동일하게 유지한다.
- 스킬을 수정한 뒤에는 `scripts/sync-skills.sh`, `python3 scripts/sync-skills.py`, 또는 PowerShell의 `pwsh -File scripts/sync-skills.ps1`로 mirror를 갱신하고 구조 검증으로 drift를 확인한다.
- Claude에서 직접 호출할 때는 `/skill-name`, Codex에서 직접 호출할 때는 `$skill-name`을 사용한다.

## 컨텍스트 로딩 규칙

- 전체 프로젝트 스캔 파일을 기본 컨텍스트로 사용하지 않는다.
- `PROJECT_CONTEXT_SCAN.md` 같은 전체 스캔 산출물은 생성 산출물로 간주한다.
- 전체 스캔은 최근 완료 문서를 대체하지 않고, 최근 완료 문서도 전체 스캔을 대체하지 않는다.
- 최근 완료 문서는 최근 변경분과 남은 리스크를 확인하는 용도다.
- 전체 스캔이 필요하면 `docs/harness/context/generated/`에 임시 산출물로 두고, 장기적으로 필요한 내용만 `BASELINE.md`, `DECISIONS.md`, 세부 컨텍스트 문서에 반영한다.
- 작업이 아주 작으면 `docs/harness/context/INDEX.md`의 `T0_MINIMAL`/`T1_STANDARD` context tier를 따른다. 교차 레이어, 보안/계약/런타임, 하네스 정책 변경은 `T2_EXPANDED`로 올리고, 전체 스캔은 `T3_FULL_SCAN` 조건에서만 수행한다.

## 작업 원칙

- 한국 프로젝트를 기본 전제로 하고, 사용자-facing 설명과 보고는 한국어로 작성한다.
- 파일명, 명령어, enum, Status 값, 코드 식별자는 원문을 유지한다.
- 동작 변경은 RED -> GREEN -> REFACTOR를 따른다.
- 증거는 `docs/harness/plans/active/`에 남기고 완료 후 `completed/`로 이동한다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 적는다.
- 구조 검증과 실제 프로젝트 검증을 구분한다. 실제 프로젝트 값이 모두 채워졌는지 확인하려면 `make project-ready` 또는 `HARNESS_REQUIRE_FILLED_PROFILE=1 HARNESS_VERIFY_MODE=project bash scripts/verify-harness-structure.sh`를 실행한다. 실제 build/test/lint 확인이 필요하면 `HARNESS_RUN_PROJECT_CHECKS=1`과 `HARNESS_*_SCRIPT` 환경변수로 project gate를 실행한다. 조직 표준에서는 repository script gate를 우선하고, legacy `HARNESS_*_CMD`는 `HARNESS_ALLOW_LEGACY_BASH_LC=1`로 명시 허용된 경우에만 사용한다.
- `.env*`, secret, key, pem 파일은 사용자 명시 없이는 수정하지 않는다.
- 사용자가 명시적으로 요청하지 않으면 커밋/푸시를 수행하지 않는다.

## 에이전트 오케스트레이션 원칙

- 레이어별 에이전트는 전문가 역할이며, 모든 작업에 항상 호출하지 않는다.
- 단일 레이어/작은 수정은 `SINGLE_AGENT`로 처리한다.
- 보안/계약/접근성 위험만 있으면 `SINGLE_AGENT_WITH_REVIEW`로 구현자 1명과 read-only reviewer를 조합한다.
- 여러 레이어의 도메인 규칙, 트랜잭션, 영속성, API 계약이 함께 바뀌는 경우에는 main agent가 혼자 구현하지 않고 `task-orchestrator`가 `SEQUENTIAL_LAYERED` 또는 제한적 병렬 모드를 선택한다.
- 분리 위임 시 active plan에 공통 결정, 레이어별 책임, 수정 가능 범위, 통합 담당자를 기록한다.
- 분리 결과는 단일 통합자가 중복 구현과 레이어 경계를 수렴한다.

## 병렬 에이전트 실행 원칙

- 작업 시작 시 병렬 처리 가능 여부를 먼저 판단한다.
- 병렬 가능하면 관련 Claude subagent 또는 mirror 에이전트를 병렬 실행한다.
- 병렬 불가하거나 충돌 가능성이 있으면 순차 실행한다.
- 기본값은 `SEQUENTIAL`이다. 단, 읽기 전용 리뷰는 `PARALLEL_REVIEW`를 우선 고려한다.
- 구현 병렬화는 계약이 고정되고 파일 범위가 겹치지 않을 때만 수행한다.
- 같은 파일, 같은 도메인 aggregate, 같은 트랜잭션 경계, 같은 migration/schema, 같은 권한 정책을 병렬 수정하지 않는다.
- 백엔드 작업에서 도메인 모델과 영속성 작업이 모두 있으면 `backend-domain-modeler`와 `backend-persistence-implementer`로 분리 가능한지 먼저 판단한다. 단, 같은 aggregate/repository/interface를 동시에 수정하면 순차 실행한다.
- 병렬 실행 전 `docs/harness/plans/active/`의 활성 계획에 `Parallelization Check`와 에이전트별 범위를 기록한다.
- 병렬 실행 후 단일 통합자가 결과를 수렴하고, VERIFY와 최종 REVIEW를 다시 실행한다.


## 실전 검증 원칙

공개 사례와 비교할 때 객관적 세계 순위처럼 말하지 않는다. 이 하네스는 운영 하네스 범주에서 구조 검증이 강한 편이지만, completed plan과 project gate/eval 데이터가 쌓이기 전에는 프로덕션 효과가 입증됐다고 보지 않는다.

## 리뷰어 안전 규칙

`*-reviewer` 에이전트는 읽기 전용으로 운용한다. 리뷰어는 파일 수정, 패치 적용, 자동 수정, 커밋/푸시를 하지 않고 발견 사항, 심각도, 근거, 권장 수정안, 판정만 남긴다.


## 조직 표준 메모

대형 조직 표준 적용 시 `docs/harness/GOVERNANCE.md`, `docs/harness/SECURITY_POLICY.md`, `docs/harness/ADOPTION_SCORECARD.md`를 확인한다. Project gate는 `HARNESS_*_SCRIPT`를 우선하고, legacy `HARNESS_*_CMD`는 명시적으로 허용된 경우에만 사용한다.


## Owned API Contract Impact

API DTO/request/response/status/error/pagination/auth/resource scope를 수정할 때는 `docs/harness/04_INTEGRATION.md`의 Owned API Contract Impact Rule을 따른다. 프론트발 변경은 우리 백엔드 API 의도를 확인하고, 백엔드발 변경은 해당 API를 호출하는 프론트 코드가 있는지 검색한다. 필요한 경우 양쪽 코드를 함께 수정하고, 수정하지 않는 경우 확인 근거를 active plan에 남긴다.
