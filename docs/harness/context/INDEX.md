# 컨텍스트 색인

작업 시작 시 전체 프로젝트를 스캔하지 않고, 필요한 문서만 고르기 위한 색인이다.

## 기본 읽기 순서

1. `AGENTS.md` 또는 `CLAUDE.md`
2. `docs/harness/context/BASELINE.md`
3. `docs/harness/plans/active/*.md`
4. `docs/harness/plans/completed/` 중 최근 완료 문서
5. 필요한 경우에만 관련 코드와 관련 completed 문서를 추가 탐색한다.

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
