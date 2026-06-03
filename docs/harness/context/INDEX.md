# 컨텍스트 색인

작업 시작 시 전체 프로젝트를 스캔하지 않고, 필요한 문서만 고르기 위한 색인이다.

## 기본 읽기 순서

최소 필수 읽기는 아래 1~3이다. 4~5는 진행 중 작업이나 관련 이력이 있을 때만 추가한다.

1. `AGENTS.md` 또는 `CLAUDE.md`
2. `docs/harness/context/BASELINE.md`
3. `docs/harness/plans/active/*.md`
4. `docs/harness/plans/completed/` 중 최근 완료 문서
5. 필요한 경우에만 관련 코드와 관련 completed 문서를 추가 탐색한다.

## Context Tier

작업 크기에 따라 고정 컨텍스트를 다르게 잡는다. 전체 스캔은 어떤 tier에서도 기본값이 아니다.

| Tier | 사용 조건 | 먼저 읽을 것 | 추가 읽기 |
|---|---|---|---|
| `T0_MINIMAL` | 오타, 단일 문구, 명확한 단일 파일 수정 | `AGENTS.md` 또는 `CLAUDE.md`, `BASELINE.md` | 대상 파일과 직접 의존 파일 |
| `T1_STANDARD` | 일반 구현/수정/리뷰 | `AGENTS.md` 또는 `CLAUDE.md`, `BASELINE.md`, 이 `INDEX.md`, active plan | 작업별 추가 문서 1~2개 |
| `T2_EXPANDED` | 교차 레이어, 보안/계약/런타임, 하네스 정책 변경 | T1 + 관련 핵심 gate 문서 | 관련 completed plan, profile/context |
| `T3_FULL_SCAN` | 신규 적용, 경계 불명확, 대규모 마이그레이션, 사용자가 전체 스캔 요청 | T2 | `context/generated/`에 생성한 전체 스캔 요약 |

작은 작업에서 T2/T3를 열었다면 이유를 active plan 또는 최종 보고에 짧게 남긴다.

## 문서 표면 줄이기

- 항상 먼저 읽는 문서: `AGENTS.md` 또는 `CLAUDE.md`, `BASELINE.md`, 이 `INDEX.md`
- 처음 적용할 때만 먼저 보는 문서: `QUICKSTART_5_MIN.md`, `profiles/**`, `harness.yaml`
- 필요할 때만 보는 레퍼런스: `01`~`14` 핵심 문서, `CONFIGURATION.md`, `ORG_ROLLOUT.md`, `CI_EXAMPLES.md`, `GOVERNANCE.md`
- 전체 스캔과 `context/generated/**`는 기본 읽기 대상이 아니다.

## 작업별 추가 문서

| 작업 | 추가 문서 |
|---|---|
| 백엔드 API / use case | `docs/harness/01_BACKEND.md`, `docs/harness/10_BACKEND_QUALITY_GATE.md`, `docs/harness/context/backend/README.md` |
| 백엔드 도메인 규칙 | `docs/harness/context/backend/domains/*.md`, `docs/harness/10_BACKEND_QUALITY_GATE.md` |
| 주요 프론트엔드 | `docs/harness/02_PRIMARY_FRONTEND.md`, `docs/harness/context/frontend/README.md` |
| 보조 앱 | `docs/harness/03_SECONDARY_APP.md`, `docs/harness/rubrics/secondary-app.md`, `docs/harness/profiles/project-profile.md` |
| API 계약 / 권한 / pagination | `docs/harness/04_INTEGRATION.md`, `docs/harness/context/integration/api-matrix.md`, `docs/harness/profiles/project-profile.md` |
| 테스트 전략 | `docs/harness/05_TESTING.md` |
| 병렬 에이전트 | `docs/harness/11_PARALLEL_AGENT_GATE.md` |
| 프로젝트 프로파일 | `docs/harness/profiles/project-profile.md`, `docs/harness/profiles/design-system-profile.md` |

## 전체 스캔 사용 기준

전체 스캔은 기본 컨텍스트 로딩이 아니다. 아래 경우에만 명시적으로 수행한다.

- 하네스를 처음 프로젝트에 적용할 때
- `BASELINE.md`가 오래되었거나 코드와 충돌할 때
- 대규모 리팩토링 / 마이그레이션 전
- repo 구조, 기술 stack, 주요 경계가 불명확할 때
- 사용자가 "전체 스캔"을 명시적으로 요청했을 때

전체 스캔 결과는 `docs/harness/context/generated/`에 임시 산출물로 둘 수 있다.
단, 기본 컨텍스트에는 포함하지 않고, 필요한 요약만 `BASELINE.md`, `DECISIONS.md`, 관련 컨텍스트 문서에 반영한다.
