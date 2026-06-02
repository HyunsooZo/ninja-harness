# 스킬 라우팅 매트릭스

요청 유형별 기본 하네스/스킬 라우팅이다. 아주 작은 단일 수정은 직접 처리할 수 있지만, 계약/권한/공통 UI/테스트 정책이 얽히면 하네스를 적용한다.

## 라우팅 규칙

| 요청 유형 | 기본값 | 필수 문서 |
|---|---|---|
| 리뷰, PR 리뷰, diff 리뷰, 감사 | `review-pr` | `00_AGENT_BRIEF.md`, `04_INTEGRATION.md`, `05_TESTING.md`, 관련 레이어 문서 |
| 구현, 수정, 리팩토링, 멀티스텝 작업 | `executor` | `00_AGENT_BRIEF.md`, 관련 레이어 문서, `05_TESTING.md` |
| 계획 수립, 영향도 분석, 리스크 정리 | `task-orchestrator` + `orchestration-planning` | `00_AGENT_BRIEF.md`, `13_AGENT_ORCHESTRATION.md`, `08_HARNESS_AUDIT.md` |
| 에이전트 분리/위임 판단 | `task-orchestrator` 또는 `orchestration-planning` | `13_AGENT_ORCHESTRATION.md`, `11_PARALLEL_AGENT_GATE.md` |
| 백엔드 컨트롤러/DTO/검증/표현 경계 | 백엔드 API 구현 범위 | `01_BACKEND.md`, `04_INTEGRATION.md`, `backend-api`, 관련 백엔드 컨텍스트 |
| 백엔드 애플리케이션 서비스/유스케이스/트랜잭션/멱등성 | 백엔드 애플리케이션 구현 범위 | `01_BACKEND.md`, `backend-application` |
| 백엔드 도메인/리포지토리/영속성 | 도메인은 `backend-domain`, 영속성은 `backend-persistence` | `01_BACKEND.md`, `backend-domain`, `backend-persistence` |
| 백엔드 스키마/마이그레이션/인덱스/DB 런타임 | DB migration 구현 범위 | `01_BACKEND.md`, `10_BACKEND_QUALITY_GATE.md`, `backend-db-migration` |
| 백엔드 보안 민감 변경 | 백엔드 보안 리뷰어 | `01_BACKEND.md`, `backend-security` |
| 주요 프론트엔드 UI/UX | 프론트엔드 화면/컴포넌트 구현 범위 | `02_PRIMARY_FRONTEND.md`, `primary-frontend-ui` |
| 주요 프론트엔드 타입 API/서비스 작업 | 프론트엔드 TypeScript 구현 범위 | `02_PRIMARY_FRONTEND.md`, `frontend-typescript` |
| 주요 프론트엔드 접근성/반응형 리뷰 | 프론트엔드 스타일/접근성 리뷰어 | `02_PRIMARY_FRONTEND.md`, `frontend-a11y` |
| 디자인 시스템/스타일 기반 | 디자인 시스템 구현자 | `07_DESIGN_SYSTEM.md`, `02_PRIMARY_FRONTEND.md`, `design-system` |
| 반응형 레이아웃/모바일 가독성 | 반응형 레이아웃 리뷰어 | `02_PRIMARY_FRONTEND.md` 또는 `03_SECONDARY_APP.md`, `responsive-layout` |
| UX 흐름/로딩/오류/재시도 | UX 흐름 리뷰어 | `02_PRIMARY_FRONTEND.md` 또는 `03_SECONDARY_APP.md`, `ux-flow` |
| 대시보드/차트/달력/상태 시각화 | 데이터 시각화 리뷰어 | `02_PRIMARY_FRONTEND.md`, `data-visualization` |
| UI 문구/i18n/접근성 라벨 | 콘텐츠 i18n 리뷰어 | `02_PRIMARY_FRONTEND.md` 또는 `03_SECONDARY_APP.md`, `content-i18n-ux` |
| 보조 앱 | 보조 앱 구현자 + 런타임 UX 리뷰어 | `03_SECONDARY_APP.md`, `secondary-app-runtime` |
| 프론트/백 계약 변경 | executor + 통합 리뷰 | `04_INTEGRATION.md`, `integration-contract` |
| Owned API DTO/request/response 변경 | `task-orchestrator` + `integration-contract` + 필요 시 백엔드/프론트 구현자 | `04_INTEGRATION.md`, `13_AGENT_ORCHESTRATION.md`, `docs/harness/context/integration/api-matrix.md` |
| 테스트 전략/검증 점검 | 테스트 자동화 리뷰어 | `05_TESTING.md`, `testing-strategy` |
| 리뷰 판정/심각도/증거 품질 일관성 | 리뷰 기준 스킬 | `05_TESTING.md`, `09_EVIDENCE_GATE.md`, `review-rubric` |
| 최종 납품 품질/잔여 위험/인계 요약 | 납품 품질 스킬 | `05_TESTING.md`, `09_EVIDENCE_GATE.md`, `delivery-rubric` |
| 하네스 유지보수 | 하네스 유지보수 스킬 | `08_HARNESS_AUDIT.md`, `harness-maintenance` |
| 최종 품질 점검 | 품질 리뷰어 범위 | `05_TESTING.md`, `08_HARNESS_AUDIT.md` |

## 스킬 런타임 경로

- Codex native skills: `.agents/skills/<skill-name>/SKILL.md`
- Claude native skills: `.claude/skills/<skill-name>/SKILL.md`
- 원본은 `.agents/skills/**`이고 Claude mirror는 `scripts/sync-skills.py`와 shell/PowerShell wrapper로 갱신한다.
- 직접 호출 시 Codex는 `$skill-name`, Claude는 `/skill-name`을 사용한다.

## 강한 기본값

- 리뷰 성격이면 `review-pr`를 기본값으로 본다.
- 구현 성격이면 아주 작은 단일 수정이 아닌 한 `executor`를 기본값으로 본다.
- 레이어별 에이전트는 항상 호출하지 않는다. 단일 레이어 작업은 `SINGLE_AGENT`, 보안/계약 위험이 있으면 `SINGLE_AGENT_WITH_REVIEW`, 교차 레이어 작업은 `SEQUENTIAL_LAYERED`를 기본값으로 본다.
- 인증, 권한, 리소스 선택, 페이지네이션/목록 로딩, 요청/응답 계약, DTO/schema/status/error, 공개 토큰/다운로드 URL, i18n, 공유 UI 변경은 구현 전 관련 하네스 문서를 확인한다. 우리 소유 API 변경은 Owned API Contract Impact Rule에 따라 provider/consumer 양쪽 영향도를 확인한다.
- 현재 런타임에 없는 도구 이름은 필수가 아니다. 사용 가능하면 쓰고, 없으면 현재 에이전트가 같은 게이트를 직접 적용한다.
- 스킬은 `.agents/skills/**`와 `.claude/skills/**` 양쪽에 native path로 존재해야 한다. 없거나 drift가 있으면 `scripts/sync-skills.sh`, `python3 scripts/sync-skills.py`, 또는 `pwsh -File scripts/sync-skills.ps1` 후 검증한다.

## 오케스트레이션 모드

| 모드 | 기본 사용 조건 |
|---|---|
| `SINGLE_AGENT` | 단일 레이어/단일 파일/낮은 위험 수정 |
| `SINGLE_AGENT_WITH_REVIEW` | 구현은 작지만 보안, 계약, 접근성, 테스트 충분성 검토가 필요함 |
| `SEQUENTIAL_LAYERED` | domain -> application -> persistence -> api -> test 순서 의존성이 있음 |
| `PARALLEL_INVESTIGATION` | 구현 전 영향도 조사만 안전하게 나눌 수 있음 |
| `PARALLEL_REVIEW` | 구현 후 독립 read-only review를 병렬화함 |
| `PARALLEL_IMPLEMENT` | 계약이 고정됐고 수정 파일 범위가 겹치지 않음 |

큰 작업 감지 신호가 있으면 `task-orchestrator`를 먼저 사용한다. 세부 판단은 `13_AGENT_ORCHESTRATION.md`를 따른다. 병렬 실행은 추가로 `11_PARALLEL_AGENT_GATE.md`를 통과해야 한다.

## 에이전트 매핑

| 범위 | 에이전트 / 스킬 |
|---|---|
| 작업 분해, 위임, fan-in 수렴 | `task-orchestrator`, `orchestration-planning` |
| 백엔드 컨트롤러, DTO, 검증, 표현 경계 | `backend-api-implementer`, `backend-api` |
| 백엔드 애플리케이션 서비스, 유스케이스, 트랜잭션 경계, 멱등성 | `backend-application-implementer` |
| 백엔드 도메인 모델, 애그리거트, 불변 조건 | `backend-domain-modeler` |
| 백엔드 리포지토리, ORM, 쿼리, 잠금, 영속성 테스트 | `backend-persistence-implementer` |
| 백엔드 스키마/마이그레이션/데이터/런타임 의존성 | `backend-db-migration-implementer`, `backend-db-migration` |
| 백엔드 보안 리뷰 | `backend-security-reviewer` |
| 주요 프론트엔드 화면, 스타일, i18n | `primary-frontend-view-implementer` |
| 주요 프론트엔드 공유 컴포넌트 | `primary-frontend-component-implementer` |
| 주요 프론트엔드 타입 서비스/헬퍼 | `frontend-typescript-implementer` |
| 주요 프론트엔드 스타일/접근성 리뷰 | `primary-frontend-style-a11y-reviewer` |
| 디자인 시스템 구현 | `design-system-implementer` |
| 반응형 레이아웃 리뷰 | `responsive-layout-reviewer` |
| UX 흐름 리뷰 | `ux-flow-reviewer` |
| 데이터 시각화 리뷰 | `data-viz-reviewer` |
| 콘텐츠/i18n 리뷰 | `content-i18n-reviewer` |
| 보조 앱 구현 | `secondary-app-implementer` |
| 보조 앱 모바일/런타임 UX 리뷰 | `secondary-app-runtime-ux-reviewer` |
| 테스트 충분성 리뷰 | `test-automation-reviewer` |
| 위험 마일스톤/스펙 리뷰 | `spec-reviewer` |
| API/인증/리소스/페이지네이션 통합 리뷰 | `integration-reviewer` |
| 리뷰 판정/심각도/증거 품질 일관성 | `review-rubric` |
| 최종 납품 품질/잔여 위험/인계 요약 | `quality-reviewer`, `delivery-rubric` |

## 상태 용어

- 구현/테스트 종료는 `Status` 필드에 정확히 하나의 `AgentStatus`를 쓴다: `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED`
- 판정형 읽기 전용 리뷰 종료는 `Verdict` 필드에 정확히 하나의 `ReviewVerdict`를 쓴다: `PASS`, `PASS_WITH_CONCERNS`, `FAIL`
- diff 리뷰처럼 발견 사항 전용 형식이 지정된 하네스는 해당 디스패치 프롬프트의 출력 형식을 우선한다.

## 프로젝트 기준

프로젝트별 디렉터리, 스택, 명령, 행위자/리소스 용어, API prefix, 패키지 루트, 디자인 토큰은 아래 문서에 정의한다.

- `docs/harness/context/BASELINE.md`
- `docs/harness/profiles/project-profile.md`
- `docs/harness/profiles/design-system-profile.md`
