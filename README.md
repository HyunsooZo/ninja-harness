# Codex / Claude AI Development Harness

Codex와 Claude Code를 함께 사용하는 프로젝트를 위한 **운영형 AI 개발 하네스**입니다.

이 하네스는 단순한 프롬프트 모음이 아니라, 에이전트·스킬·검증 게이트·오케스트레이션·프로젝트 프로파일·조직 운영 규칙을 함께 제공하여 AI 코딩 작업을 더 안전하고 일관되게 수행하기 위한 구조입니다.

핵심은 세 가지입니다. 첫째, 에이전트가 작업 전에 읽을 기준을 `AGENTS.md`, `CLAUDE.md`, `docs/harness/**`에 고정합니다. 둘째, 작업 범위에 맞춰 active plan, RED/GREEN/REFACTOR/VERIFY 증거, review gate를 남깁니다. 셋째, template 구조 검증과 실제 프로젝트 build/test/lint gate를 분리해 개인 프로젝트부터 조직 표준까지 같은 골격을 단계적으로 적용합니다.

현재 하네스 버전은 루트 `VERSION`과 `docs/harness/harness.yaml`의 `harness_version`이 source of truth입니다. 다운스트림 레포 업그레이드는 `docs/harness/CHANGELOG.md`와 `docs/harness/UPGRADE.md`를 따릅니다.

소유권과 법무 메타데이터는 `LICENSE`, `.github/CODEOWNERS`, `docs/harness/OWNERSHIP.md`, `docs/harness/SECURITY_POLICY.md`에 둡니다. 새 조직에 적용할 때 placeholder를 승인된 팀/연락처/license로 교체합니다.

## 한눈에 보는 사용 경로

| 상황 | 먼저 할 일 | 권장 검증 |
|---|---|---|
| 개인 프로젝트에 처음 적용 | `BASELINE.md`, `project-profile.md` placeholder를 실제 값 또는 `N/A`로 정리 | `make doctor`, `make verify`, 필요 시 `make project-ready` |
| 작은 문서/문구/단일 파일 수정 | `T0_MINIMAL`로 대상 파일과 직접 문맥만 확인 | 대상 확인, `git diff --check` |
| 동작 변경 / 교차 레이어 / API / 보안 작업 | active plan 생성, RED 예외 또는 실패 증거 기록, editable scope 명시 | 대상 테스트, project gate, 필요 리뷰 |
| 하네스 자체 수정 | 관련 `docs/harness/**`, script, test를 함께 점검 | `make verify`, `make unit-tests`, 필요 시 `make integrity` |
| 팀/조직 표준 후보 | repository script gate를 `HARNESS_*_SCRIPT`로 연결 | `make verify-org`, `make eval`, CI required check |

처음 적용자는 `docs/harness/QUICKSTART_5_MIN.md`를 먼저 보면 됩니다. 전체 레퍼런스는 `docs/harness/README.md`, 모든 `HARNESS_*` 설정값은 `docs/harness/CONFIGURATION.md`가 기준입니다.

## 목적

이 하네스의 목적은 다음과 같습니다.

- Codex와 Claude Code가 같은 개발 기준을 따르도록 한다.
- 단일 작업과 복합 작업을 구분하여 과도한 에이전트 분산을 막는다.
- 백엔드, 프론트엔드, API 계약 변경의 영향도를 누락하지 않는다.
- 작업 계획, 검증 증거, 완료 기록을 파일로 남긴다.
- 개인 실무부터 팀/조직 표준까지 확장 가능한 운영 기준을 제공한다.

## 운영 프로파일

| 프로파일 | 적합한 사용 | 기본 운영 |
|---|---|---|
| 개인 / 라이트 | 혼자 쓰는 프로젝트, 작은 실험, 기존 코드베이스에 점진 적용 | 작은 작업은 active plan 없이 처리하고, 큰 변경부터 plan과 증거를 사용한다. Claude hook은 필요하면 `HARNESS_EVIDENCE_HOOK_MODE=warn`으로 시작한다. |
| 팀 표준 | 여러 개발자가 같은 AI 작업 기준을 공유하는 프로젝트 | `make verify`, project gate script, completed plan 품질 검사, review routing을 CI/로컬에 연결한다. |
| 조직 표준 후보 | 여러 repo에 공통 적용하려는 platform/team | `HARNESS_ORG_STANDARD=1`, `make verify-org`, ownership/security/governance 문서, eval metric을 함께 운영한다. |
| 대형 조직 표준 | 전사 강제 표준 또는 branch protection 연결 | 파일럿 프로젝트의 completed plan, gate 실패율, reviewer FAIL 사유, regression capture 지표를 먼저 축적한다. |

라이트 운영은 규칙을 없애는 모드가 아닙니다. 작은 작업의 의식 비용을 줄이고, 위험한 작업에만 강한 증거 게이트를 집중하는 운영 방식입니다.

## 핵심 원칙

### 1. 작은 작업은 작게 처리한다

모든 작업을 여러 에이전트로 나누지 않습니다.

오타 수정, 단일 필드 변경, 작은 스타일 수정, 단일 테스트 수정처럼 영향 범위가 좁은 작업은 `SINGLE_AGENT`로 처리합니다.

### 2. 큰 작업은 먼저 분해한다

도메인 규칙, 트랜잭션, DB, API 계약, 프론트 호출부가 함께 바뀌는 작업은 `task-orchestrator`가 먼저 영향도를 분석하고 작업을 분해합니다.

### 3. API 계약 변경은 양방향 영향도를 확인한다

프론트에서 API DTO, request, response를 수정할 때는 해당 API가 우리 백엔드 API인지 확인합니다.

백엔드에서 API 요청/응답을 변경할 때는 해당 API를 호출하는 프론트 화면, hook, query key, store, validation schema, test를 검색합니다.

### 4. Codex와 Claude는 같은 기준을 사용한다

스킬 원본은 `.agents/skills`에 둡니다.  
Claude용 스킬은 `.claude/skills`에 mirror로 유지합니다.

스킬 변경 후에는 반드시 동기화와 검증을 실행합니다.

```bash
make sync-skills
make verify
```

### 5. 조직 표준에서는 실제 게이트를 연결한다

조직 표준 모드에서는 최소 하나 이상의 실제 project gate script를 연결해야 합니다.

```bash
HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh' make verify-org
```

임의 문자열 명령 실행은 기본값이 아닙니다.  
`HARNESS_*_SCRIPT`를 우선 사용합니다.

---

## 디렉터리 구조

```txt
.
├── AGENTS.md
├── CLAUDE.md
├── Makefile
├── .agents/
│   └── skills/                 # Codex/OpenAI skill source of truth
├── .codex/
│   └── agents/                 # Codex custom agents
├── .claude/
│   ├── agents/                 # Claude subagents
│   ├── skills/                 # Claude skill mirror
│   └── commands/               # Claude slash commands
├── docs/
│   └── harness/
│       ├── README.md
│       ├── QUICKSTART_5_MIN.md
│       ├── CONFIGURATION.md
│       ├── 01_BACKEND.md
│       ├── 02_PRIMARY_FRONTEND.md
│       ├── 03_SECONDARY_APP.md
│       ├── 04_INTEGRATION.md
│       ├── 10_BACKEND_QUALITY_GATE.md
│       ├── 11_PARALLEL_AGENT_GATE.md
│       ├── 13_AGENT_ORCHESTRATION.md
│       ├── GOVERNANCE.md
│       ├── SECURITY_POLICY.md
│       ├── ADOPTION_SCORECARD.md
│       ├── profiles/
│       ├── examples/
│       ├── evals/
│       ├── history/
│       └── plans/
└── scripts/
    ├── verify-harness-structure.sh
    ├── verify-harness-structure.py
    ├── verify-harness-structure.ps1
    ├── doctor.ps1
    ├── verify-project-gates.sh
    ├── verify-project-gates.py
    ├── verify-project-gates.ps1
    ├── sync-skills.sh
    ├── sync-skills.py
    ├── sync-skills.ps1
    ├── check-profile-readiness.sh
    ├── check-profile-readiness.py
    ├── check-profile-readiness.ps1
    ├── collect-eval-metrics.sh
    ├── collect-eval-metrics.py
    ├── collect-eval-metrics.ps1
    ├── check-completed-plan-quality.sh
    ├── check-completed-plan-quality.py
    ├── check-completed-plan-quality.ps1
    ├── set-codex-agent-model.sh
    ├── set-codex-agent-model.py
    ├── set-codex-agent-model.ps1
    ├── check-harness-upgrade.py
    └── check-harness-upgrade.ps1
```

마이그레이션/적용 이력 문서는 루트가 아니라 `docs/harness/history/`에 둡니다.

---

## 빠른 시작

설정 가능한 `HARNESS_*` 환경변수 전체 목록은 `docs/harness/CONFIGURATION.md`를 본다.

### 0. 최소 적용 경로

개인 프로젝트나 작은 팀에서 처음 적용할 때는 아래만 먼저 끝냅니다.

1. `docs/harness/context/BASELINE.md`의 프로젝트 구조와 검증 명령 placeholder를 실제 값 또는 `N/A`로 바꿉니다.
2. `docs/harness/profiles/project-profile.md`의 행위자, 리소스, API prefix, package 예시를 실제 프로젝트 용어로 바꿉니다.
3. 디자인 기준을 쓰는 프로젝트라면 `docs/harness/profiles/design-system-profile.md`만 추가로 채웁니다.
4. `make doctor`와 `make verify`를 실행합니다.
5. 실제 build/test/lint script가 준비된 뒤 `HARNESS_*_SCRIPT`로 project gate를 연결합니다.

이 단계에서는 모든 문서를 다 읽을 필요가 없습니다. `AGENTS.md`, `docs/harness/context/BASELINE.md`, `docs/harness/context/INDEX.md`, `docs/harness/QUICKSTART_5_MIN.md`만 먼저 봅니다.

### 1. 하네스 상태 확인

```bash
make doctor
```

필수 파일, shell script, 실행 권한, shell syntax를 확인합니다.

PowerShell 환경에서는 아래 진입점을 사용할 수 있습니다.

```powershell
pwsh -File scripts/doctor.ps1
pwsh -File scripts/sync-skills.ps1
pwsh -File scripts/check-harness-upgrade.ps1
```

### 2. 전체 구조 검증

```bash
make verify
```

template mode와 project mode를 모두 검증합니다.

PowerShell 환경에서는 template/project 구조 검증을 아래처럼 실행할 수 있습니다. `HARNESS_*_SCRIPT` project gate도 `scripts/verify-project-gates.ps1`로 실행할 수 있으며, `.ps1` gate는 하네스 runner가 `-NoProfile -NonInteractive`로 실행하고 `.py` gate는 네이티브로 실행됩니다. `.sh` gate만 Bash가 필요합니다.

```powershell
$env:HARNESS_VERIFY_MODE = "template"
pwsh -File scripts/verify-harness-structure.ps1
$env:HARNESS_VERIFY_MODE = "project"
pwsh -File scripts/verify-harness-structure.ps1

$env:HARNESS_BACKEND_TEST_SCRIPT = "scripts/ci/backend-test.ps1"
pwsh -File scripts/verify-project-gates.ps1
```

### 3. 스킬 동기화

```bash
make sync-skills
```

`.agents/skills`를 기준으로 `.claude/skills`를 동기화합니다.

### 4. 동기화 포함 검증

```bash
make check-sync
```

스킬을 동기화한 뒤 하네스 구조를 검증합니다.

### 5. 조직 표준 모드 검증

조직 표준 모드는 실제 project gate script가 필요합니다.

```bash
HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh' make verify-org
```

---

## 검증 범위 구분

하네스 검증은 세 층으로 나뉩니다.

| 층 | 명령 | 확인 대상 |
|---|---|---|
| 로컬 도구 준비 | `make doctor` / `pwsh -File scripts/doctor.ps1` | Python, Git, Bash/Make, POSIX utility, script 실행 가능 여부 |
| 하네스 구조 검증 | `make verify` / `verify-harness-structure.ps1` | core 문서, agents, skills, profiles, `HARNESS_*` 설정 drift, template/project 구조 |
| 실제 프로젝트 검증 | `HARNESS_*_SCRIPT=... make verify-org` 또는 `verify-project-gates.*` | 해당 repo의 build/test/lint/security/a11y script |

`make verify`가 통과했다는 말은 하네스 구조가 맞다는 뜻입니다. 실제 프로젝트 코드 품질까지 확인하려면 project gate를 별도로 연결해야 합니다. 반대로 개인 프로젝트 초기 적용에서는 project gate가 준비되지 않았으면 `SKIP`으로 시작하고, 실제 스크립트가 생긴 뒤 연결해도 됩니다.

`make integrity`는 하네스 자체를 수정했거나 릴리스 전 확인이 필요할 때 쓰는 최종 gate입니다. `doctor`, `verify`, gate self-test, unit test, completed plan 품질 검사, active plan 잔여 검사, `git diff --check`를 묶어서 실행합니다.

---

## Makefile 명령어

```bash
make help
```

사용 가능한 명령을 확인합니다.

| 명령 | 설명 |
|---|---|
| `make doctor` | 로컬 하네스 실행 환경을 점검합니다. |
| `make verify` | template / project 검증을 모두 실행합니다. |
| `make verify-template` | template mode 검증을 실행합니다. |
| `make verify-project` | project mode 검증을 실행합니다. |
| `make project-ready` | project mode에서 profile/context placeholder가 남아 있으면 실패합니다. |
| `make check-profile` | project profile/context placeholder만 점검합니다. |
| `make self-test-gates` | 핵심 positive/negative gate self-test를 실행합니다. |
| `make unit-tests` | Python 하네스 라이브러리 단위 테스트를 실행합니다. |
| `make integrity` | 최종 로컬 하네스 무결성 검증을 실행합니다. |
| `make check-active-plans` | 완료되지 않은 active plan이 남아 있으면 실패합니다. |
| `make verify-org` | 조직 표준 모드 검증을 실행합니다. 최소 하나의 gate script가 필요합니다. |
| `make project-gates` | 설정된 project gate를 실행합니다. |
| `make project-gates-required` | project gate가 없으면 실패합니다. |
| `make sync-skills` | `.agents/skills`를 `.claude/skills`로 동기화합니다. |
| `make check-sync` | skill sync 후 하네스 검증을 실행합니다. |
| `make eval` | completed plan 기반 eval metrics를 수집합니다. |
| `make check-plans` | completed plan 품질을 점검합니다. |
| `make set-model MODEL=<model>` | Codex agent model 값을 일괄 변경합니다. |
| `make harness-upgrade` | 하네스 버전과 업그레이드 메타데이터를 점검합니다. |
| `make clean` | 로컬 생성 메타데이터와 런타임 캐시를 제거합니다. |

---

## 에이전트 운영 방식

### 기본값

작업은 기본적으로 단일 에이전트로 처리합니다.

복합 작업이라고 판단될 때만 `task-orchestrator`가 작업을 분해합니다.

### 오케스트레이션 모드

| 모드 | 사용 기준 |
|---|---|
| `SINGLE_AGENT` | 단일 파일 또는 단일 레이어의 작은 변경 |
| `SINGLE_AGENT_WITH_REVIEW` | 작은 변경이지만 보안, 접근성, API 계약 등 검토가 필요한 경우 |
| `SEQUENTIAL_LAYERED` | 도메인, 트랜잭션, DB, API, 프론트 영향이 순차적으로 연결되는 경우 |
| `PARALLEL_INVESTIGATION` | 읽기 전용 영향도 조사를 병렬로 수행할 수 있는 경우 |
| `PARALLEL_REVIEW` | 구현 후 독립 리뷰를 병렬로 수행할 수 있는 경우 |
| `PARALLEL_IMPLEMENT` | 계약이 고정되어 있고 파일 충돌이 없는 경우에만 제한적으로 사용 |

### 복합 백엔드 작업 기본 순서

```txt
task-orchestrator
→ backend-domain-modeler
→ backend-application-implementer
→ backend-persistence-implementer
→ backend-db-migration-implementer
→ backend-api-implementer
→ test/review
```

---

## 백엔드 작업 기준

백엔드 작업은 다음 경계를 기준으로 분리합니다.

| 레이어 | 책임 |
|---|---|
| Domain | 불변식, 상태 전이, 도메인 규칙, Aggregate, Entity, Value Object |
| Application | Use case, 트랜잭션 경계, 멱등성, orchestration |
| Persistence | Repository, Query, Lock, Mapping, DB access |
| Migration | Schema 변경, index, constraint, migration script |
| API | Controller, DTO, validation, response mapping, error contract |

백엔드 작업에서 반드시 확인해야 하는 기준:

- transaction boundary
- self-invocation / proxy boundary
- rollback / propagation
- idempotency
- optimistic lock / pessimistic lock / distributed lock
- unique constraint
- outbox / after-commit side effect
- repository query에 도메인 규칙이 숨겨져 있는지 여부
- API 요청/응답 변경 시 프론트 호출부 영향도

---

## 프론트엔드 작업 기준

프론트엔드 작업은 다음 기준을 따릅니다.

- 디자인 시스템 기준 준수
- 접근성 기준 준수
- 반응형 레이아웃 확인
- API client / fetcher / hook / query key 영향도 확인
- loading / empty / error / permission / stale state 확인
- i18n / content policy 준수
- 테스트 영향도 확인

프론트 profile 예시:

```txt
docs/harness/profiles/examples/react-next.md
docs/harness/profiles/examples/vue-vite.md
docs/harness/profiles/examples/frontend-testing.md
```

커버 기준:

- React Query / TanStack Query
- Next.js Server / Client Component
- Vue Composition API
- Pinia / Store
- Router / Auth / Resource Scope
- Playwright
- Storybook / Histoire
- Visual Regression
- Testing Library / Component Test

---

## Owned API Contract Impact Rule

API 계약 변경은 단일 레이어 변경으로 보지 않습니다.

### 프론트에서 API DTO/request/response를 수정하는 경우

다음을 확인합니다.

1. 해당 API가 우리 백엔드 API인지 확인합니다.
2. 우리 백엔드 API라면 backend route/controller/DTO/schema/use case/API matrix를 확인합니다.
3. 프론트 매핑만 바꾸면 되는지, 백엔드 계약 수정이 필요한지 판단합니다.
4. 백엔드 수정이 필요하면 backend-api/application/persistence 영향도를 확인합니다.
5. contract/test evidence를 active plan에 남깁니다.

### 백엔드에서 API request/response를 수정하는 경우

다음을 확인합니다.

1. 해당 API를 호출하는 프론트 코드가 있는지 검색합니다.
2. API service, fetcher, hook/composable, query key, store/cache, validation schema, 화면 컴포넌트, 테스트를 확인합니다.
3. 필요하면 프론트 타입, 매핑, UI state, 테스트까지 수정합니다.
4. 프론트 수정이 필요 없다고 판단한 경우에도 검색 근거를 남깁니다.

---

## Active Plan

복합 작업은 active plan을 사용합니다.

위치:

```txt
docs/harness/plans/active/
```

새 작업은 template을 복사해서 시작합니다.

```txt
docs/harness/plans/TEMPLATE.md
```

active plan에는 다음을 남깁니다.

- 작업 목표
- 오케스트레이션 모드
- 단일 작업으로 충분한지 여부
- 레이어 영향도
- 위임할 agent / skill
- 공통 결정사항
- fan-in 기준
- API 계약 영향도
- RED / GREEN / REFACTOR / VERIFY evidence
- 완료 후 completed plan 이동 여부

범용 template package 배포본에는 active plan markdown을 포함하지 않습니다.
실제 적용 저장소의 project mode에서는 해당 프로젝트의 진행 기록으로 누적할 수 있습니다.

---

## Completed Plan

완료된 작업은 다음 위치로 이동합니다.

```txt
docs/harness/plans/completed/
```

completed plan은 eval metrics의 근거가 됩니다.

```bash
make eval
```

completed plan 품질은 다음 명령으로 확인합니다.

```bash
make check-plans
```

범용 template package 배포본에는 completed plan markdown을 포함하지 않습니다.

---

## Project Gate

조직 표준에서는 실제 project gate를 연결해야 합니다.

권장 방식은 `HARNESS_*_SCRIPT`입니다.

GitHub Actions 예시는 `docs/harness/examples/github-actions/harness-verify.yml`에
비활성 파일로 보관합니다. 실제 프로젝트에서 `scripts/ci/**` gate script를
만든 뒤 `.github/workflows/`로 복사해 사용합니다.

```bash
HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh' make verify-org
```

지원하는 gate script:

```txt
HARNESS_BACKEND_TEST_SCRIPT
HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT
HARNESS_SECONDARY_APP_TEST_SCRIPT
HARNESS_INTEGRATION_TEST_SCRIPT
HARNESS_SECURITY_SCAN_SCRIPT
HARNESS_A11Y_CHECK_SCRIPT
```

허용되는 script 경로:

```txt
scripts/ci/**
.github/scripts/**
ci/**
```

허용 경로 안의 script 파일과 경로 구성 요소는 symlink이면 안 됩니다. Gate script는 실제 repository 파일이어야 하며, symlink로 repository 밖 스크립트를 가리키는 구성은 거부됩니다.

legacy command 방식인 `HARNESS_*_CMD`는 기본 사용하지 않습니다.  
필요한 경우 아래 값을 명시해야 합니다.

```bash
HARNESS_ALLOW_LEGACY_BASH_LC=1
HARNESS_ACK_TRUSTED_PROJECT_CMDS=1
```

---

## Windows / PowerShell 운영 메모

Windows native 환경에서는 PowerShell wrapper를 우선 사용할 수 있습니다.

```powershell
pwsh -File scripts/doctor.ps1
$env:HARNESS_VERIFY_MODE = "template"
pwsh -File scripts/verify-harness-structure.ps1
$env:HARNESS_VERIFY_MODE = "project"
pwsh -File scripts/verify-harness-structure.ps1
```

PowerShell project gate는 `HARNESS_*_SCRIPT`에 `.ps1` 또는 `.py` script를 지정하는 방식이 가장 안정적입니다. `.sh` gate를 쓰면 Git Bash, MSYS2, Cygwin, WSL, Linux runner 중 하나가 필요합니다.

Windows에서 `.git/index.lock` 지연이 자주 보이면 하네스 자체보다 Git index를 쓰는 작업과 IDE/백신/동기화 도구가 겹치는 경우가 많습니다. 일상 작업 중에는 `make verify`와 대상 테스트를 우선 사용하고, `make integrity`는 커밋 전이나 최종 확인 시점에 실행하는 편이 낫습니다. OneDrive/Dropbox 동기화 폴더 안의 repo는 피하고, 필요하면 Windows Defender 예외나 IDE Git auto-refresh 설정을 조정합니다.

stale lock이 의심될 때는 Git 프로세스가 없는지 먼저 확인합니다.

```powershell
Get-Process git,git-remote-https -ErrorAction SilentlyContinue
Test-Path .git\index.lock
```

Git 프로세스가 없을 때만 stale lock을 제거합니다.

```powershell
Remove-Item .git\index.lock
```

---

## 조직 표준 적용

조직 적용은 다음 순서를 권장합니다.

1. 1개 프로젝트에 파일럿 적용
2. completed plan 20개 이상 축적
3. project gate 실패/통과 로그 수집
4. reviewer FAIL 사유 수집
5. fan-in 충돌률 확인
6. regression case 반영률 확인
7. branch protection / required check 연결
8. 팀 표준으로 확장
9. 조직 표준으로 확장

관련 문서:

```txt
docs/harness/ORG_ROLLOUT.md
docs/harness/GOVERNANCE.md
docs/harness/SECURITY_POLICY.md
docs/harness/ADOPTION_SCORECARD.md
```

---

## Eval Metrics

completed plan을 기준으로 eval metrics를 수집합니다.

```bash
make eval
```

수집 대상:

- 작업 유형별 성공률
- agent별 재작업률
- reviewer FAIL 사유 TOP N
- project gate 실패율
- fan-in 충돌 발생률
- regression case 반영률
- orchestration mode별 성공률 / 실패율 / 평균 소요 시간

---

## 모델 변경

Codex agent model을 일괄 변경할 수 있습니다.

```bash
make set-model MODEL=<model-name>
```

모델 값은 `docs/harness/harness.yaml` 기준과 동기화됩니다.

---

## 배포 전 체크리스트

배포 전 다음 명령을 실행합니다.

```bash
make doctor
make verify
make check-sync
make harness-upgrade
make integrity
make eval
```

조직 표준 배포 전에는 실제 project gate를 연결합니다.

```bash
HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh' make verify-org
```

ZIP 배포 전에는 OS 메타 파일을 제거합니다.

```bash
make clean
```

배포본에는 다음 파일이 포함되면 안 됩니다.

```txt
.DS_Store
._*
__MACOSX
.claude/settings.local.json
.codex/skills
__tmp-*.sh
docs/harness/plans/active/*.md
docs/harness/plans/completed/*.md
.env*
*.pem
*.p12
*.key
*.keystore
*secret*.json
*secret*.yml
*secret*.yaml
*secret*.txt
*secret*.conf
*secret*.config
*secret*.ini
*secret*.properties
*secret*.toml
*token*.json
*token*.yml
*token*.yaml
*token*.txt
*token*.conf
*token*.config
*token*.ini
*token*.properties
*token*.toml
```

`token-policy.md`처럼 정책을 설명하는 문서 파일명은 허용하지만, secret/token 이름을 가진 로컬 설정성 산출물은 배포 전에 제거합니다.

---

## 권장 사용 예시

### 작은 수정

```txt
회원 목록 화면의 라벨 문구만 수정해줘.
```

예상 처리:

```txt
SINGLE_AGENT
```

### 백엔드 기능 추가

```txt
포인트 적립 API를 추가해줘. 중복 적립은 막아야 하고, 동시 요청도 고려해줘.
```

예상 처리:

```txt
task-orchestrator
→ backend-domain-modeler
→ backend-application-implementer
→ backend-persistence-implementer
→ backend-api-implementer
→ test/review
```

### API 계약 변경

```txt
회원 상세 API 응답에 membershipLevel을 추가해줘.
```

예상 처리:

```txt
Owned API Contract Impact Rule
→ 백엔드 DTO/API 수정
→ 프론트 호출부 검색
→ 필요한 화면 타입/매핑/UI/test 수정
→ integration review
```

### 프론트 접근성 점검

```txt
이 모달 컴포넌트를 frontend-a11y 기준으로 점검해줘.
```

예상 처리:

```txt
frontend-a11y
→ dialog focus
→ aria-labelledby / describedby
→ keyboard navigation
→ close focus return
```

---

## 운영 상태

현재 하네스는 다음 용도에 적합합니다.

```txt
개인 실무 사용: 가능
백엔드 개발자 사용: 가능
프론트엔드 개발자 사용: 가능
소규모 팀 표준: 가능
일반 조직 표준 후보: 가능
대형 조직 표준 후보: 파일럿 후 가능
```

전사 강제 표준으로 사용하려면 실제 프로젝트 파일럿을 통해 completed plan, project gate 결과, reviewer FAIL 사유, regression case 반영률을 먼저 축적합니다.

---

## 라이선스 / 적용 범위

이 하네스는 특정 프로젝트에 강하게 묶이지 않는 범용 구조를 지향합니다.

프로젝트별 정보는 core 문서에 직접 넣지 않고, 다음 위치에 분리합니다.

```txt
docs/harness/context/
docs/harness/profiles/
```

core 문서에는 조직 공통 규칙과 하네스 운영 원칙만 유지합니다.
