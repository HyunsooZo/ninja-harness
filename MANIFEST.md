project:
  name: 범용 개발 하네스
  maintainer: <project-maintainer>
  workspace_root: <workspace-root>
  mode: korean-strict-tdd-with-baseline-context

repositories:
  backend:
    path: <backend-dir>
    stack: <backend-stack-and-runtime>
  primary_frontend:
    path: <primary-frontend-dir>
    stack: <primary-frontend-stack-and-runtime>
  secondary_app:
    path: <secondary-app-dir>
    stack: <secondary-app-stack-and-runtime>

source_of_truth:
  entry:
    - AGENTS.md
    - CLAUDE.md
    - docs/harness/context/BASELINE.md
    - docs/harness/context/INDEX.md
    - docs/harness/README.md
    - docs/harness/QUICKSTART_5_MIN.md
  harness:
    - docs/harness/00_AGENT_BRIEF.md
    - docs/harness/01_BACKEND.md
    - docs/harness/02_PRIMARY_FRONTEND.md
    - docs/harness/03_SECONDARY_APP.md
    - docs/harness/04_INTEGRATION.md
    - docs/harness/05_TESTING.md
    - docs/harness/07_DESIGN_SYSTEM.md
    - docs/harness/08_HARNESS_AUDIT.md
    - docs/harness/09_EVIDENCE_GATE.md
    - docs/harness/10_BACKEND_QUALITY_GATE.md
    - docs/harness/11_PARALLEL_AGENT_GATE.md
    - docs/harness/12_FIELD_VALIDATION.md
    - docs/harness/13_AGENT_ORCHESTRATION.md
    - docs/harness/ORG_ROLLOUT.md
    - docs/harness/CI_EXAMPLES.md
    - docs/harness/GOVERNANCE.md
    - docs/harness/SECURITY_POLICY.md
    - docs/harness/ADOPTION_SCORECARD.md
    - docs/harness/rubrics/backend.md
    - docs/harness/rubrics/frontend.md
    - docs/harness/rubrics/integration.md
    - docs/harness/rubrics/secondary-app.md
    - docs/harness/profiles/project-profile.md
    - docs/harness/profiles/design-system-profile.md
  skills:
    repo_source: .agents/skills
    claude_mirror: .claude/skills
    sync_script: scripts/sync-skills.sh
    require_mirror_match: true
  state:
    active_plans: docs/harness/plans/active
    completed_plans: docs/harness/plans/completed
    current_context: docs/harness/context
    baseline: docs/harness/context/BASELINE.md
    decisions: docs/harness/context/DECISIONS.md
    context_index: docs/harness/context/INDEX.md
    generated_context: docs/harness/context/generated

workflow:
  default:
    - triage
    - plan
    - spec
    - red
    - green
    - refactor
    - verify
    - review
    - complete
  trivial_allowed_without_plan: true
  non_trivial_requires_active_plan: true
  optional_project_gates: true
  project_readiness_gate: scripts/check-profile-readiness.sh
  final_integrity_target: make integrity
  gate_self_test: scripts/self-test-harness-gates.sh
  orchestration_default_mode: SINGLE_AGENT
  orchestration_requires_active_plan_when_split: true

rules:
  tdd:
    require_red_before_product_edit: true
    require_green_before_refactor: true
    require_verify_before_done: true
    exception_requires_rationale: true
  scope:
    edit_only_requested_files_or_direct_dependencies: true
    avoid_unrelated_refactor: true
    avoid_unrequested_library: true
  frontend:
    require_i18n_for_visible_copy: true
    forbid_inline_style: true
    prefer_existing_style_tokens: true
    forbid_external_ui_library_without_approval: true
  backend:
    keep_layer_boundary: true
    validate_resource_scoped_auth: true
    avoid_sensitive_response_leak: true
    require_ddd_boundary_review: true
    require_transaction_boundary_review: true
    require_oop_solid_review: true
    split_domain_and_persistence_agents: true
  integration:
    review_api_auth_resource_pagination_changes: true
  commits:
    require_explicit_user_request: true
  project_gates:
    enabled_by_env: HARNESS_RUN_PROJECT_CHECKS
    profile_readiness_enabled_by_env: HARNESS_REQUIRE_FILLED_PROFILE
    profile_readiness_script: scripts/check-profile-readiness.sh
    script: scripts/verify-project-gates.sh
    preferred_scripts:
      backend: HARNESS_BACKEND_TEST_SCRIPT
      primary_frontend: HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT
      secondary_app: HARNESS_SECONDARY_APP_TEST_SCRIPT
      integration: HARNESS_INTEGRATION_TEST_SCRIPT
      security: HARNESS_SECURITY_SCAN_SCRIPT
      accessibility: HARNESS_A11Y_CHECK_SCRIPT
    legacy_commands:
      backend: HARNESS_BACKEND_TEST_CMD
      primary_frontend: HARNESS_PRIMARY_FRONTEND_TEST_CMD
      secondary_app: HARNESS_SECONDARY_APP_TEST_CMD
      integration: HARNESS_INTEGRATION_TEST_CMD
      security: HARNESS_SECURITY_SCAN_CMD
      accessibility: HARNESS_A11Y_CHECK_CMD
    org_standard_requires_ack: HARNESS_ACK_TRUSTED_PROJECT_CMDS
    legacy_bash_lc_opt_in: HARNESS_ALLOW_LEGACY_BASH_LC

  context:
    default_load_full_scan: false
    full_scan_is_generated_artifact: true
    prefer_baseline_and_recent_completed_plan: true
    generated_scan_dir: docs/harness/context/generated
    baseline: docs/harness/context/BASELINE.md
    decisions: docs/harness/context/DECISIONS.md

review_gates:
  backend_auth_or_security:
    - backend-security-reviewer
    - integration-reviewer
  api_contract:
    - integration-reviewer
    - test-automation-reviewer
  primary_frontend_ui:
    - primary-frontend-style-a11y-reviewer
    - content-i18n-reviewer
  secondary_app:
    - secondary-app-runtime-ux-reviewer
    - integration-reviewer
  orchestration:
    - task-orchestrator
  backend_domain_persistence_split:
    - task-orchestrator
    - backend-domain-modeler
    - backend-persistence-implementer
    - backend-application-implementer
  final_quality:
    - quality-reviewer

agent_orchestration:
  default_mode: SINGLE_AGENT
  orchestrator_agent: task-orchestrator
  orchestration_skill: orchestration-planning
  allow_single_agent_for_small_changes: true
  require_active_plan_for_split_delegation: true
  require_common_decisions_when_split: true
  require_single_integrator: true
  modes:
    - SINGLE_AGENT
    - SINGLE_AGENT_WITH_REVIEW
    - SEQUENTIAL_LAYERED
    - PARALLEL_INVESTIGATION
    - PARALLEL_REVIEW
    - PARALLEL_IMPLEMENT
  backend_layer_order:
    - task-orchestrator
    - backend-domain-modeler
    - backend-application-implementer
    - backend-persistence-implementer
    - backend-db-migration-implementer
    - backend-api-implementer
    - test-automation-reviewer
    - integration-reviewer
    - quality-reviewer

parallel_agents:
  default_mode: SEQUENTIAL
  prefer_parallel_review: true
  allow_parallel_implementation: conditional
  require_parallelization_check: true
  require_single_integration_coordinator: true
  forbid_overlapping_file_edits: true
  forbid_shared_transaction_boundary_edits: true
  forbid_shared_migration_schema_edits: true
  require_verify_after_fan_in: true
  allow_backend_domain_persistence_parallelism: conditional

organization:
  rollout_guide: docs/harness/ORG_ROLLOUT.md
  ci_examples: docs/harness/CI_EXAMPLES.md
  governance: docs/harness/GOVERNANCE.md
  security_policy: docs/harness/SECURITY_POLICY.md
  adoption_scorecard: docs/harness/ADOPTION_SCORECARD.md
  org_standard_flag: HARNESS_ORG_STANDARD
  eval_scripts:
    - scripts/collect-eval-metrics.sh
    - scripts/check-completed-plan-quality.sh

runtime:
  codex_agent_model: gpt-5.5
  codex_model_override_env: HARNESS_EXPECTED_CODEX_MODEL
  supported_os: macos_linux_windows
  shell_entrypoints: bash_make_powershell
  unsupported_windows_native: false
  required_tools: python3 git
  posix_required_tools: bash make
  powershell_entrypoints: scripts/doctor.ps1 scripts/verify-harness-structure.ps1
  powershell_required_tool: pwsh_or_windows_powershell
  powershell_structure_verification: true
  project_gate_runner: bash_required
  python_verifier: scripts/verify-harness-structure.py
  posix_utilities: find cp rm mkdir chmod rmdir sed env uname head cat dirname pwd
  toml_parser: tomllib_or_tomli
  note: 조직 표준 적용 시 모델명은 scripts/set-codex-agent-model.sh로 일괄 변경한다.

owned_api_contract_impact:
  policy_doc: docs/harness/04_INTEGRATION.md
  required_plan_block: API 계약 영향도
  router_agent: task-orchestrator
  router_skill: integration-contract
  frontend_to_backend_check: true
  backend_to_frontend_search: true


## v3.5.3 보정

- `.agents/skills/**`를 스킬 원본으로 유지하고 `.claude/skills/**`를 Claude native skill mirror로 추가했다.
- `scripts/sync-skills.sh`를 추가해 OpenAI/Codex repo skill 원본을 Claude skill mirror로 동기화한다.
- `verify-harness-structure.sh`에서 repo/Claude skill set과 파일 drift를 검증한다.
- `CLAUDE.md`, `AGENTS.md`, `docs/harness/README.md`, `skill-routing.md`에 스킬 미러 정책을 명시했다.


## v3.5.4 보정

- `QUICKSTART_5_MIN.md`를 추가해 신규 사용자의 진입 경로를 한 장으로 압축했다.
- `12_FIELD_VALIDATION.md`와 `docs/harness/evals/**`를 추가해 구조 검증과 실전 품질 검증을 분리했다.
- `scripts/verify-project-gates.sh`를 추가하고 `HARNESS_RUN_PROJECT_CHECKS=1`일 때 실제 프로젝트 build/test/lint 명령을 선택적으로 실행할 수 있게 했다. `HARNESS_REQUIRE_PROJECT_CHECKS=1`을 함께 쓰면 빈 project gate를 실패 처리한다.
- `verify-harness-structure.sh`가 project gate script 존재와 실행 권한을 검증한다.
- 공개 사례와 비교할 때 객관적 순위처럼 표현하지 않고, 운영 하네스 범주와 실전 데이터 부족을 명시하도록 보강했다.


## v3.6.0 조직 표준 보강

- OpenAI/Codex repo skill 원본을 `.agents/skills/**`로 이동하고 `.claude/skills/**`를 native mirror로 유지한다.
- `scripts/sync-skills.sh`는 `.agents/skills -> .claude/skills` 단방향 동기화를 수행한다.
- Claude subagent frontmatter에 `tools` allowlist와 `skills` preload를 추가했다.
- reviewer 계열은 `tools: [Read, Grep, Glob]`만 허용하고 read-only 안전 계약을 유지한다.
- `docs/harness/ORG_ROLLOUT.md`, `docs/harness/CI_EXAMPLES.md`, `docs/harness/examples/github-actions/harness-verify.yml`을 추가했다.
- `scripts/collect-eval-metrics.sh`, `scripts/check-completed-plan-quality.sh`를 추가해 eval/완료 계획 품질 점검 루프를 보강했다.
- `HARNESS_ORG_STANDARD=1` 모드는 실제 project gate와 completed plan 품질 점검을 조직 표준 검증으로 연결한다.


## Codex agent 모델 관리

Codex agent TOML의 모델명은 `docs/harness/harness.yaml`의 `runtime.codex_agent_model`을 기준으로 검증한다. 조직 표준 모델이 바뀌면 `bash scripts/set-codex-agent-model.sh <model-name>`로 일괄 변경한다.


## v3.6.1 보정

- `docs/harness/13_AGENT_ORCHESTRATION.md`를 추가해 단일/순차/병렬 위임 기준을 분리했다.
- 레이어별 에이전트가 항상 자동 협업한다는 오해를 막고, 작은 작업은 `SINGLE_AGENT`로 처리하는 원칙을 문서화했다.
- active plan template에 `에이전트 오케스트레이션` 블록을 추가했다.
- `AGENTS.md`, `CLAUDE.md`, `README.md`, `skill-routing.md`, `harness.yaml`, `11_PARALLEL_AGENT_GATE.md`에 오케스트레이션 정책을 연결했다.


## v3.7.0 보정

- `task-orchestrator` agent 추가
- `backend-domain` skill 추가
- `orchestration-planning` skill 추가
- `/plan`, executor, active plan template의 오케스트레이션 강제력 보강
- completed plan fan-in 품질 검사 강화
- CI 예시 가독성 개선
- project gate 명령 실행 trust policy 명시
- eval 지표 확장
- backend stack profile examples 추가


## v3.8.0 보정

- project gate 기본 경로를 `HARNESS_*_SCRIPT`로 승격하고 legacy `HARNESS_*_CMD`는 명시 opt-in으로 제한.
- CI 예시에 `HARNESS_ACK_TRUSTED_PROJECT_CMDS=1`과 script gate 사용을 반영.
- eval collector를 marker count에서 작업 유형별 성공률, agent별 재작업률, reviewer FAIL 사유, project gate 실패 추이, fan-in conflict, regression capture, orchestration duration/failure 집계로 확장.
- 중앙 거버넌스 문서 `GOVERNANCE.md`, `SECURITY_POLICY.md`, `ADOPTION_SCORECARD.md` 추가.

## v3.8.1 보정

- `AGENTS.md`와 `CLAUDE.md`의 project gate 안내를 `HARNESS_*_SCRIPT` 우선 정책으로 정리했다.
- legacy `HARNESS_*_CMD`는 `HARNESS_ALLOW_LEGACY_BASH_LC=1`로 명시 허용된 경우에만 사용하는 escape hatch로 표현했다.
- 프론트엔드 framework-specific profile 예시를 추가했다.
  - `docs/harness/profiles/examples/react-next.md`
  - `docs/harness/profiles/examples/vue-vite.md`
  - `docs/harness/profiles/examples/frontend-testing.md`
- 백엔드 profile 예시의 gate 안내도 script-first 방식으로 정리했다.


## v3.8.2 보정

- Owned API Contract Impact Rule 추가.
- 프론트발 API DTO/request/response 변경 시 우리 백엔드 API 의도 확인 기준 추가.
- 백엔드발 API contract 변경 시 프론트 호출부 검색 및 필요 수정 기준 추가.
- active plan의 API 계약 영향도 블록과 검증 스크립트 검사 추가.

## v3.8.3 보정

- `scripts/verify-project-gates.sh`의 script gate 검증을 command substitution 의존 방식에서 명시적 return-code 방식으로 수정했다.
- invalid script path가 CI에서 exit 0으로 통과하지 않도록 negative test를 `verify-harness-structure.sh`에 추가했다.
- 금지 케이스: absolute path, parent traversal, shell metacharacter, missing script.
- 프론트 profile 예시를 React Query/TanStack Query, Next Server/Client Component, Vue Composition API, Pinia, Playwright, Storybook/Histoire, visual regression 기준까지 확장했다.

## v3.8.4 보정

- 배포본에 test/dummy gate script가 포함되지 않도록 정리했다.
- `scripts/ci/__tmp-ok.sh` 같은 항상 성공하는 임시 gate script를 금지 대상으로 명시했다.
- `verify-harness-structure.sh`가 배포본 내 dummy/temporary gate script 재발을 검사하도록 보강했다.


## v3.8.5 보정

- `Makefile`을 추가해 로컬/CI 공통 진입점을 제공한다.
- 주요 target: `help`, `verify`, `verify-template`, `verify-project`, `verify-org`, `project-gates`, `sync-skills`, `eval`, `check-plans`, `set-model`, `clean`.
- 조직 표준 검증은 `HARNESS_*_SCRIPT=... make verify-org`를 우선 사용하며 legacy `HARNESS_*_CMD`를 Makefile 진입점에서 안내하지 않는다.
- `verify-harness-structure.sh`가 Makefile 존재와 주요 target/policy token을 검증한다.

## v3.8.6 보정

- `Makefile`을 조직 표준 진입점으로 더 체계화했다.
- `verify-org`가 `HARNESS_INTEGRATION_TEST_SCRIPT`를 포함한 모든 script gate 변수를 최소 gate 후보로 인식한다.
- `doctor`, `project-gates-required`, `check-sync` target을 추가했다.
- Makefile은 조직 표준에서 script gate를 우선하고 legacy `HARNESS_*_CMD` 문자열은 primary path로 안내하지 않는다.
- `verify-harness-structure.sh`가 Makefile target, organization gate 변수, integration script gate 지원 여부를 검증한다.
