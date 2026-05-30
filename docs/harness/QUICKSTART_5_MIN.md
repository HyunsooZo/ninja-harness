# 5분 온보딩

이 문서는 처음 하네스를 적용한 사람이 어디부터 읽고 어떤 명령을 실행해야 하는지 빠르게 확인하기 위한 진입 문서다.

## 1. 먼저 읽는다

1. `AGENTS.md` 또는 `CLAUDE.md`
2. `docs/harness/context/BASELINE.md`
3. `docs/harness/context/INDEX.md`
4. `docs/harness/README.md`
5. 현재 작업이 이어지는 경우 `docs/harness/plans/active/*.md`

전체 스캔 산출물은 기본 컨텍스트로 읽지 않는다. 필요할 때만 `docs/harness/context/generated/`에 임시 생성하고, 오래 유지할 사실은 `BASELINE.md`, `DECISIONS.md`, `profiles/**`, 세부 context 문서에 반영한다.

## 2. 프로젝트 값을 먼저 채운다

새 저장소에 복사했다면 아래 placeholder를 먼저 실제 값으로 정리한다.

- `docs/harness/context/BASELINE.md`: repo 경로, 실행 명령, 현재 구조
- `docs/harness/profiles/project-profile.md`: 역할 용어, 리소스 범위, API prefix, package 예시
- `docs/harness/profiles/design-system-profile.md`: 디자인 토큰, 테마, 레이아웃 기준
- `docs/harness/harness.yaml`: source of truth, workflow, review gate

프로젝트 값은 numbered core 문서에 직접 넣지 않는다. core 문서는 범용 기준으로 유지한다.

## 3. 구조 검증을 실행한다

가장 쉬운 진입점은 `Makefile`이다.

```bash
make help
make doctor
make verify
```

스크립트를 직접 실행해도 된다.

```bash
# 배포/템플릿 상태 검증
HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

# 실제 프로젝트 적용 후 검증
HARNESS_VERIFY_MODE=project bash scripts/verify-harness-structure.sh
```

`make verify`는 하네스 구조 검증이다. 실제 프로젝트 값이 모두 채워졌는지까지 보려면 placeholder readiness gate를 별도로 실행한다.

```bash
make project-ready
# 또는
HARNESS_VERIFY_MODE=project \
HARNESS_REQUIRE_FILLED_PROFILE=1 \
bash scripts/verify-harness-structure.sh
```

이 gate는 `BASELINE.md`, `profiles/**`, `harness.yaml`에 남은 `<...>` placeholder를 실패 처리한다. 사용하지 않는 영역은 `N/A`처럼 angle bracket 없는 값으로 적는다.

스킬을 수정했다면 먼저 실행한다.

```bash
make sync-skills
# 또는
bash scripts/sync-skills.sh
```

## 4. 선택적으로 실제 프로젝트 게이트를 연결한다

구조 검증과 실제 코드 검증은 분리한다. 실제 build/test/lint를 함께 확인하려면 프로젝트별 명령을 환경변수로 넘긴다.

```bash
HARNESS_RUN_PROJECT_CHECKS=1 \
HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh' \
HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT='scripts/ci/primary-frontend-test.sh' \
HARNESS_SECONDARY_APP_TEST_SCRIPT='scripts/ci/secondary-app-test.sh' \
bash scripts/verify-harness-structure.sh
```

명령이 비어 있으면 해당 게이트는 `SKIP` 처리한다. 조직 표준으로 쓰려면 최소 하나 이상의 실제 프로젝트 게이트를 연결한다. 이를 강제하려면 `HARNESS_REQUIRE_PROJECT_CHECKS=1`을 함께 지정한다.

## 5. 작업은 active plan으로 시작한다

단순하지 않은 작업은 `docs/harness/plans/active/`에 계획을 만든다.

```bash
cp docs/harness/plans/TEMPLATE.md docs/harness/plans/active/YYYY-MM-DD-task-name.md
```

계획 안에는 다음을 최소로 남긴다.

- 범위와 제외 범위
- RED Evidence
- GREEN Evidence
- REFACTOR Evidence
- VERIFY Evidence
- 에이전트 오케스트레이션
- Parallelization Check
- 남은 위험

완료 후에는 `docs/harness/plans/completed/`로 이동한다.
범용 template package 배포본에는 active/completed plan markdown을 포함하지 않는다. 실제 적용 저장소의 project mode에서는 해당 프로젝트의 작업 이력으로 누적할 수 있다.

## 6. 완료 기준

- 구조 검증 통과
- 필요한 실제 프로젝트 게이트 통과 또는 합리적 SKIP 사유 기록
- active plan의 증거 항목 작성
- 관련 context/profile 갱신
- reviewer 판정 또는 최종 self-review 작성

하네스 자체를 수정했거나 배포 전 상태를 확인할 때는 active plan을 completed로 이동한 뒤 최종 무결성 gate를 실행한다.

```bash
make integrity
```

## 7. 자주 헷갈리는 기준

- `.agents/skills/**`는 skill 원본이다.
- `.claude/skills/**`는 Claude native mirror다.
- skill 수정 후 `scripts/sync-skills.sh`를 실행한다.
- 레이어별 에이전트는 항상 자동 협업하지 않는다. 작은 작업은 단일 에이전트, 교차 레이어 작업은 `13_AGENT_ORCHESTRATION.md` 기준으로 분리한다.
- `*-reviewer`는 읽기 전용이다.
- commit/push는 사용자 요청이 있을 때만 한다.
- 프로젝트별 값은 `context/**`와 `profiles/**`에 둔다.

## 조직 표준 모드

팀/조직 표준으로 적용할 때는 `docs/harness/ORG_ROLLOUT.md`를 먼저 보고, CI에서 `HARNESS_ORG_STANDARD=1`을 사용한다. 로컬에서는 `HARNESS_INTEGRATION_TEST_SCRIPT='scripts/ci/integration-test.sh' make verify-org`처럼 Makefile 진입점을 사용할 수 있다.
