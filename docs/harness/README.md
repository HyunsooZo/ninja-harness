# 범용 개발 하네스

이 하네스는 에이전트가 작업 전 읽을 기준, 레이어별 검증 포인트, 증거 루프, 리뷰 라우팅을 짧고 일관된 문서로 유지하기 위한 운영 골격이다.

프로젝트별 경로, 행위자/리소스 용어, API prefix, 패키지 루트, 런타임 명령, 디자인 토큰 이름은 핵심 문서에 직접 쓰지 않고 `docs/harness/context/**`와 `docs/harness/profiles/**`에 둔다.

## 문서 지도

| 파일 | 대상 | 용도 |
|---|---|---|
| `00_AGENT_BRIEF.md` | 전체 작업 | 공통 원칙, 읽기 순서, 충돌 해결 |
| `01_BACKEND.md` | 백엔드 | 레이어 경계, 권한/리소스, 트랜잭션, 페이지네이션, 테스트 |
| `02_PRIMARY_FRONTEND.md` | 주요 프론트엔드 | 운영/관리 화면 UI, 스타일링, i18n, 반응형, API 상태 |
| `03_SECONDARY_APP.md` | 보조 앱 | 별도 보조 앱, 행위자별 API, 런타임/모바일 기준 |
| `04_INTEGRATION.md` | 교차 변경 | 프론트/백 계약, 인증/리소스, 페이지네이션, API 영역 |
| `05_TESTING.md` | 검증 | 변경 위험별 테스트/빌드/수동 검증 선택 |
| `07_DESIGN_SYSTEM.md` | 디자인 시스템 | 역할 기반 토큰, 레이아웃, 컴포넌트, 반응형 시각 규칙 |
| `08_HARNESS_AUDIT.md` | 하네스 정리 | 하네스 충돌 해결, 범용 핵심 문서 정리, 최종 리뷰 |
| `09_EVIDENCE_GATE.md` | 실행 증거 | RED/GREEN/REFACTOR/VERIFY 증거 게이트와 활성/완료 계획 운영 |
| `10_BACKEND_QUALITY_GATE.md` | 백엔드 구조 품질 | DDD, 트랜잭션, OOP, SOLID, Clean Code 리뷰 기준 |
| `11_PARALLEL_AGENT_GATE.md` | 병렬 실행 | 병렬 에이전트 가능 조건, 금지 조건, 수렴 기준 |
| `13_AGENT_ORCHESTRATION.md` | 에이전트 위임 | task-orchestrator, 단일/순차/병렬 위임 판단, 레이어별 협업 기준, fan-in 수렴 기준 |
| `harness.yaml` | 정책 설정 | 하네스 라우팅, 검증 게이트, 런타임별 공통 정책 |
| `skill-routing.md` | 라우팅 | 요청 유형별 기본 skill/agent |
| `rubrics/` | 호환 체크리스트 | 기존 참조를 위한 얇은 리뷰 기준 |
| `plans/` | 작업 상태 | 활성/완료 계획, 증거, 완료 보고 |
| `context/BASELINE.md` | 프로젝트 기준 | 실제 디렉터리, 기술 스택, 주요 명령, 운영 기준 |
| `context/INDEX.md` | 컨텍스트 로딩 | 전체 스캔 없이 작업별 필요 문서를 고르는 색인 |
| `QUICKSTART_5_MIN.md` | 온보딩 | 새 사용자가 5분 안에 읽을 진입 절차 |
| `12_FIELD_VALIDATION.md` | 실전 검증 | 구조 검증과 실제 품질 검증의 차이, eval 운영 기준 |
| `profiles/` | 프로젝트 프로파일 | 행위자/API prefix/토큰/패키지 등 프로젝트별 값 |

## 권장 흐름

1. `AGENTS.md` 또는 `CLAUDE.md`, `docs/harness/context/BASELINE.md`, `docs/harness/context/INDEX.md`를 읽는다. 신규 사용자는 `QUICKSTART_5_MIN.md`도 읽는다.
2. 이 문서에서 작업 범위에 맞는 레이어/게이트 문서로 이동한다. 여러 에이전트가 필요한지 애매하면 `13_AGENT_ORCHESTRATION.md`를 먼저 확인한다.
3. 대상 도메인/화면/API의 `docs/harness/context/**`와 필요한 `docs/harness/profiles/**` 문서를 추가로 읽는다.
4. 단순하지 않은 작업은 `docs/harness/plans/active/`에 계획을 만들거나 기존 활성 계획을 갱신한다.
5. 작업 계획을 `1. [Step] 구현 -> verify: [검증 방법]` 형식으로 짧게 고정한다.
6. 동작 변경은 `09_EVIDENCE_GATE.md` 기준으로 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
7. 구현 후 `05_TESTING.md` 기준으로 검증하고 관련 컨텍스트/프로필 문서를 갱신한다.
8. 완료 시 활성 계획을 `completed/`로 이동하고 완료 보고를 채운다.
9. 교차 변경은 `04_INTEGRATION.md` 기준으로 리뷰한다.

## 번호 문서 정책

- `00_AGENT_BRIEF.md`는 `AGENTS.md`와 `CLAUDE.md`를 짧게 유지하기 위한 확장 운영 브리프다.
- `01`~`05`, `07`, `09`~`11`은 활성 핵심 문서다.
- `06_PROJECT_BASELINE.md`는 `context/BASELINE.md`, `profiles/**`, `harness.yaml`로 흡수했으므로 다시 만들지 않는다.
- `12_CONTEXT_LOADING_RULE.md`는 `context/INDEX.md`, `context/README.md`, `CLAUDE.md`로 흡수했으므로 다시 만들지 않는다.
- 현재 `12_FIELD_VALIDATION.md`는 실전 검증/eval 루프 기준 문서다.
- `13_AGENT_ORCHESTRATION.md`는 레이어별 에이전트가 항상 자동 협업한다는 오해를 막고, 단일/순차/병렬 위임 기준을 정의한다.
- 핵심 문서는 프로젝트별 값을 직접 담지 않는다. 그런 값은 프로필/컨텍스트로 이동한다.

## 라우팅 요약

- 리뷰/PR 리뷰/감사: `review-pr`
- 구현/수정/리팩토링/멀티스텝 작업: `executor`
- 백엔드: `01_BACKEND.md`, `10_BACKEND_QUALITY_GATE.md`
- 주요 프론트엔드: `02_PRIMARY_FRONTEND.md`
- 보조 앱: `03_SECONDARY_APP.md`
- 프론트/백 계약 변경: `04_INTEGRATION.md`
- 디자인 추가/리팩토링: `07_DESIGN_SYSTEM.md`, `profiles/design-system-profile.md`
- 검증 계획: `05_TESTING.md`
- 하네스 유지보수: `08_HARNESS_AUDIT.md`, `.agents/skills/harness-maintenance/SKILL.md`
- 에이전트 위임 판단: `task-orchestrator`, `orchestration-planning`, `13_AGENT_ORCHESTRATION.md`

세부 매트릭스는 `skill-routing.md`를 따른다.

## 스킬/에이전트 구성

프로젝트 로컬 스킬의 원본은 `.agents/skills/` 아래에 두고, Claude native skill mirror는 `.claude/skills/` 아래에 둔다. 오케스트레이션/백엔드 도메인/백엔드 애플리케이션/보안/영속성, 프론트엔드 UI/접근성/타입스크립트, 디자인 시스템/반응형/UX 흐름/데이터 시각화/콘텐츠 i18n, 보조 앱 런타임, 통합 계약, 테스트 전략, 하네스 유지보수를 분리한다.

스킬 수정 후에는 `bash scripts/sync-skills.sh`로 `.agents/skills`를 `.claude/skills`에 동기화한다. 구조 검증은 두 디렉터리의 drift를 실패 처리한다.

역할별 에이전트는 `.codex/agents/`와 `.claude/agents/` 아래에 둔다. 구현 에이전트는 파일 소유 범위를 좁게 잡고, 보안/접근성/런타임/테스트/디자인 리뷰 계열은 읽기 전용 리뷰어로 운용한다.

## 컨텍스트 문서와의 관계

- `docs/harness/**`: 범용 작업 기준과 검증 기준
- `docs/harness/plans/active/**`: 진행 중인 작업 상태와 RED/GREEN/VERIFY 증거. 범용 template package에는 tracked active plan markdown을 포함하지 않는다.
- `docs/harness/plans/completed/**`: 완료된 작업의 실행 요약, 검증 결과, 남은 위험. 범용 template package에는 tracked completed plan markdown을 포함하지 않는다.
- `docs/harness/context/**`: 현재 시스템 사실과 도메인/화면/API별 상세 맥락
- `docs/harness/profiles/**`: 행위자/API prefix/토큰/패키지처럼 프로젝트별로 바뀌는 프로필
- `docs/harness/context/BASELINE.md`: 반복적으로 필요한 프로젝트 고정 기준
- `docs/harness/context/DECISIONS.md`: 장기 의사결정
- `docs/harness/context/generated/**`: 전체 스캔 등 임시 산출물. 기본 컨텍스트에 포함하지 않음

프로젝트별 실제 경로, 런타임, 행위자/API prefix, 디자인 토큰은 번호가 붙은 핵심 문서가 아니라 `docs/harness/context/BASELINE.md`와 `docs/harness/profiles/**`에 둔다. 전체 스캔 로딩 정책은 `docs/harness/context/INDEX.md`와 `docs/harness/context/README.md`를 따른다.

작업 결과가 시스템 동작이나 화면/도메인 맥락을 바꾸면 `docs/harness/context/**`를 갱신한다. 상세 실행 로그는 완료 계획에 남긴다. 전체 스캔 산출물은 생성 산출물로만 취급하고 기본 컨텍스트에 포함하지 않는다.

## Codex / Claude 호환성

- Codex: `.codex/agents/*.toml`, `.agents/skills/*/SKILL.md`를 사용한다. Codex agent TOML은 `skills = [...]`로 역할별 스킬 preload metadata를 선언한다.
- Claude Code: `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, `.claude/commands/*.md`, `CLAUDE.md`를 사용한다.
- 스킬 원본은 `.agents/skills/**`이고, `.claude/skills/**`는 `scripts/sync-skills.sh`로 생성/갱신하는 native skill mirror다.
- 공통 기준은 `AGENTS.md`, `CLAUDE.md`, `docs/harness/**`다.
- 런타임별 파일은 같은 역할, 범위, 안전 제약, skill preload metadata를 미러링한다.

## 실전 검증과 프로젝트 게이트

구조 검증은 하네스 파일의 무결성을 확인한다. 실제 프로젝트의 build/test/lint/typecheck는 선택적 project gate로 연결한다.

```bash
HARNESS_RUN_PROJECT_CHECKS=1 \
HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh' \
HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT='scripts/ci/primary-frontend-test.sh' \
bash scripts/verify-harness-structure.sh
```

Script gate가 비어 있으면 기본적으로 `SKIP` 처리한다. 조직 표준처럼 최소 하나 이상의 실제 게이트를 강제하려면 `HARNESS_REQUIRE_PROJECT_CHECKS=1`을 함께 지정한다. legacy `HARNESS_*_CMD`는 `HARNESS_ALLOW_LEGACY_BASH_LC=1`로 명시 허용된 경우에만 사용한다. 세부 성숙도 기준과 eval 루프는 `12_FIELD_VALIDATION.md`와 `docs/harness/evals/`를 따른다.

## Runtime / OS 지원 범위

하네스 구조 검증의 최소 공통 도구는 `python3` 또는 `python`, `git`, Python TOML 파서다. Python TOML 파서는 Python 3.11+ 내장 `tomllib` 또는 Python 3.10 이하의 `tomli` fallback이 필요하다. Makefile/Bash 진입점은 추가로 `bash`, `make`와 `find`/`cp`/`rm`/`mkdir`/`chmod`/`rmdir`/`sed`/`env`/`uname`/`head`/`cat`/`dirname`/`pwd` 같은 POSIX 유틸리티를 전제로 한다. 기본 지원 대상은 macOS, Linux/WSL, Windows의 Git Bash/MSYS/Cygwin/PowerShell 진입점이다. 조직 CI parity가 필요하면 Linux runner 또는 WSL을 우선한다.

Windows native PowerShell에서는 아래 wrapper를 사용한다. 구조 검증의 source of truth는 `scripts/verify-harness-structure.py`이고, project gate의 source of truth는 `scripts/verify-project-gates.py`다. Bash와 PowerShell wrapper가 같은 Python verifier/runner를 호출한다. `scripts/doctor.ps1`은 PowerShell, Python, Git, Bash/Make 준비 상태를 분리해서 보고한다. PowerShell에서 직접 실행 가능한 범위는 template/project 구조 검증과 allowlist된 `.ps1`/`.py` project gate 실행이다. shell project gate 실행 중 `.sh` script를 선택하면 `bash`가 필요하므로 Git Bash/MSYS2/WSL 또는 Linux runner를 사용한다. `make verify-org` 같은 Makefile 진입점은 계속 `bash`, `make`, POSIX 유틸리티를 전제로 한다.

```bash
make doctor
```

```powershell
pwsh -File scripts/doctor.ps1

$env:HARNESS_VERIFY_MODE = "template"
pwsh -File scripts/verify-harness-structure.ps1

$env:HARNESS_VERIFY_MODE = "project"
pwsh -File scripts/verify-harness-structure.ps1

$env:HARNESS_BACKEND_TEST_SCRIPT = "scripts/ci/backend-test.ps1"
pwsh -File scripts/verify-project-gates.ps1
```

`make doctor`는 필수 스크립트 실행 권한, bash 문법, `bash`/`python3`/`make`/`git` 존재 여부, POSIX 유틸리티, Python TOML 파서 준비 상태, 지원 OS 범위를 확인한다. `scripts/doctor.ps1`은 PowerShell 진입점에서 Python/Git과 Bash/Make 준비 상태를 확인한다. 이 검증은 프로젝트 build/test를 실행하지 않는다.

## 프로젝트 적용 준비도

`make verify`는 template/project 구조 검증이며, 실제 프로젝트 값이 모두 채워졌다는 뜻은 아니다. 새 저장소에 하네스를 적용한 뒤에는 placeholder를 실제 값 또는 angle bracket 없는 `N/A`로 바꾸고 readiness gate를 실행한다.

```bash
make project-ready
# 또는
HARNESS_VERIFY_MODE=project \
HARNESS_REQUIRE_FILLED_PROFILE=1 \
bash scripts/verify-harness-structure.sh
```

이 gate는 `docs/harness/context/BASELINE.md`, `docs/harness/profiles/project-profile.md`, `docs/harness/profiles/design-system-profile.md`, `docs/harness/harness.yaml`에 남은 `<...>` placeholder를 실패 처리한다.

## 프로파일 예시

백엔드/프론트엔드 프로젝트에 바로 맞춰볼 수 있는 예시는 `docs/harness/profiles/examples/`에 둔다.

- `spring-boot-rest.md`: spring-boot-rest/JPA 백엔드 예시
- `node-nestjs.md`: node-nestjs 백엔드 예시
- `react-next.md`: react-next 프론트엔드 예시
- `vue-vite.md`: vue-vite 프론트엔드 예시
- `frontend-testing.md`: 공통 프론트 테스트/시각 회귀/접근성 게이트

## 구조 검증

검증 전 스킬을 수정했다면 먼저 `bash scripts/sync-skills.sh`를 실행한다. 검증 스크립트는 Python 3.11+의 `tomllib`를 사용한다. Python 3.10 이하에서는 `tomli`를 설치하면 fallback으로 동작한다.

```bash
# 배포/템플릿 검증: core, agents, skills, context/profile placeholder까지 범용성을 검사
HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

# 실제 프로젝트 적용 후 검증: core/agent/skill의 범용성은 검사하되 context/profile의 프로젝트 값은 허용
HARNESS_VERIFY_MODE=project bash scripts/verify-harness-structure.sh
```

`HARNESS_VERIFY_MODE`를 생략하면 `template` 모드로 실행한다.

## 최종 무결성 검증

릴리스 전 또는 하네스 자체를 수정한 뒤에는 분리된 확인을 한 번에 묶은 최종 gate를 실행한다.

```bash
make integrity
```

이 target은 `make doctor`, `make verify`, gate self-test, completed plan 품질 검사, active plan 잔여 여부, `git diff --check`를 함께 확인한다. 실제 프로젝트 build/test/lint는 여전히 project gate 영역이므로 조직 표준에서는 `HARNESS_*_SCRIPT=... make verify-org`를 별도로 연결한다.

## 에이전트 오케스트레이션

레이어별 에이전트 분리는 작업을 무조건 여러 에이전트에게 나누라는 뜻이 아니다. 작은 단일 수정은 `SINGLE_AGENT`로 처리하고, 여러 레이어의 도메인 규칙/트랜잭션/영속성/API 계약이 함께 바뀔 때는 main agent가 혼자 구현하지 않고 `task-orchestrator`와 `13_AGENT_ORCHESTRATION.md` 기준으로 분리한다. 분리 후에는 단일 통합자가 결정사항과 충돌을 수렴한다.

## 병렬 에이전트 실행

- 병렬 실행 전 `11_PARALLEL_AGENT_GATE.md` 기준으로 가능 여부를 판단한다.
- 독립 검토는 병렬화할 수 있지만, 같은 파일/트랜잭션/도메인/API 경계 수정은 순차 실행한다.
- 병렬 결과는 단일 통합자가 수렴하고 VERIFY를 다시 실행한다.

## 조직 표준 배포

조직 표준 적용 전에는 `docs/harness/ORG_ROLLOUT.md`와 `docs/harness/CI_EXAMPLES.md`를 확인한다. CI에서는 `HARNESS_ORG_STANDARD=1`로 실제 프로젝트 gate와 completed plan 품질 검사를 함께 실행한다.


## Codex agent 모델 관리

Codex agent TOML의 모델명은 `docs/harness/harness.yaml`의 `runtime.codex_agent_model`을 기준으로 검증한다. 조직 표준 모델이 바뀌면 `bash scripts/set-codex-agent-model.sh <model-name>`로 일괄 변경한다.


## 조직 거버넌스

대형 조직 표준 후보로 적용할 때는 `docs/harness/GOVERNANCE.md`, `docs/harness/SECURITY_POLICY.md`, `docs/harness/ADOPTION_SCORECARD.md`를 함께 사용한다. Project gate는 `HARNESS_*_SCRIPT`를 우선하며 legacy `HARNESS_*_CMD`는 명시 opt-in이 필요하다.

## Makefile 진입점

로컬/CI에서 자주 쓰는 하네스 명령은 `Makefile`로도 실행할 수 있다. 스크립트가 source of truth이고, `Makefile`은 팀원이 긴 명령을 외우지 않게 하는 얇은 진입점이다.

```bash
make help
make doctor
make verify
make verify-template
make verify-project
make verify-org
make project-ready
make check-profile
make self-test-gates
make check-active-plans
make integrity
make project-gates
make project-gates-required
make sync-skills
make check-sync
make eval
make check-plans
make set-model MODEL=<model>
make clean
```

조직 표준 검증은 최소 하나 이상의 trusted repository script gate를 연결해야 한다.

```bash
HARNESS_INTEGRATION_TEST_SCRIPT='scripts/ci/integration-test.sh' make verify-org
```

`make verify-org`는 `HARNESS_ORG_STANDARD=1`과 `HARNESS_ACK_TRUSTED_PROJECT_CMDS=1`을 내부에서 설정한다. legacy `HARNESS_*_CMD`는 Makefile 진입점에서 안내하지 않는다.
