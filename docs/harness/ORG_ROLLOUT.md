# 조직 표준 배포 가이드

이 문서는 하네스를 개인 도구가 아니라 조직 표준으로 배포할 때 필요한 최소 운영 기준을 정의한다.

## 배포 원칙

- 하네스 core 문서, agent, skill은 프로젝트별 사실을 포함하지 않는다.
- 프로젝트별 사실은 `docs/harness/context/**`와 `docs/harness/profiles/**`에만 둔다.
- 조직 표준 모드는 구조 검증뿐 아니라 최소 하나 이상의 실제 프로젝트 게이트를 요구한다.
- 예외는 active/completed plan에 사유, 승인자, 잔여 위험, 후속 조치를 남긴다.
- 대형 조직에서는 `GOVERNANCE.md`, `SECURITY_POLICY.md`, `ADOPTION_SCORECARD.md`를 함께 적용한다.

## 필수 게이트

조직 표준으로 사용할 때는 프로젝트 성격에 맞춰 최소 하나 이상을 필수로 연결한다. 기본은 `HARNESS_*_SCRIPT`다.

| 영역 | 권장 환경변수 | 예시 |
|---|---|---|
| 백엔드 테스트 | `HARNESS_BACKEND_TEST_SCRIPT` | `scripts/ci/backend-test.sh`, `scripts/ci/backend-test.ps1` |
| 주요 프론트엔드 테스트 | `HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT` | `scripts/ci/primary-frontend-test.sh`, `scripts/ci/primary-frontend-test.ps1` |
| 보조 앱 테스트 | `HARNESS_SECONDARY_APP_TEST_SCRIPT` | `scripts/ci/secondary-app-test.sh`, `scripts/ci/secondary-app-test.ps1` |
| 통합 테스트 | `HARNESS_INTEGRATION_TEST_SCRIPT` | `scripts/ci/integration-test.sh`, `scripts/ci/integration-test.ps1` |
| 보안 스캔 | `HARNESS_SECURITY_SCAN_SCRIPT` | `scripts/ci/security-scan.sh`, `scripts/ci/security-scan.ps1` |
| 접근성 검사 | `HARNESS_A11Y_CHECK_SCRIPT` | `scripts/ci/a11y-check.sh`, `scripts/ci/a11y-check.ps1` |

Legacy `HARNESS_*_CMD`는 `bash -lc`로 실행되는 escape hatch다. 조직 표준에서는 예외 승인 없이는 쓰지 않는다.

## 조직 표준 검증 명령

```bash
HARNESS_VERIFY_MODE=project \
HARNESS_ORG_STANDARD=1 \
HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 \
HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh' \
bash scripts/verify-harness-structure.sh
```

Windows PowerShell에서는 같은 계약을 `pwsh -File scripts/verify-project-gates.ps1`로 실행할 수 있다. `.ps1` gate는 하네스 runner가 `-NoProfile -NonInteractive`로 실행하고, `.py` gate는 네이티브 실행이다. `.sh` gate는 Bash가 있는 환경에서만 실행된다.

`HARNESS_ORG_STANDARD=1`은 다음을 의미한다.

- 구조 검증을 통과해야 한다.
- project gate가 실행되어야 한다.
- 권장 Makefile 진입점인 `make verify-org`는 최소 하나 이상의 `HARNESS_*_SCRIPT`를 요구한다.
- completed plan 품질 검사를 통과해야 한다.
- gate 설정이 신뢰된 CI 또는 maintainer-controlled임을 `HARNESS_ACK_TRUSTED_PROJECT_CMDS=1`로 확인해야 한다.

## 적용 체크리스트

- [ ] `docs/harness/context/BASELINE.md`를 현재 프로젝트 기준으로 작성했다.
- [ ] `docs/harness/profiles/project-profile.md`에 런타임, API, 배포 범위를 작성했다.
- [ ] 실제 build/test/lint/security/a11y 명령 중 최소 하나 이상을 `scripts/ci/**` script로 연결했다.
- [ ] reviewer agent는 read-only tool set을 유지한다.
- [ ] skill 수정 후 `scripts/sync-skills.sh`, `python3 scripts/sync-skills.py`, 또는 `pwsh -File scripts/sync-skills.ps1`를 실행했다.
- [ ] `make integrity`를 통과했다.
- [ ] 실제 프로젝트 값 적용 전후로 필요 시 `make project-ready`를 실행했다.
- [ ] 조직 표준 적용 시 `HARNESS_ORG_STANDARD=1` 검증을 통과했다.

## 예외 승인

예외는 임의로 통과시키지 않는다. 다음 항목을 completed plan에 남긴다.

- 예외 대상 gate 또는 규칙
- 예외 사유
- 승인자 또는 판단 주체
- 대체 검증
- 잔여 위험
- 후속 제거 일정

## 버전 업그레이드 정책

- patch 버전: 문구, 검증 보강, 동기화 스크립트 개선
- minor 버전: 디렉터리 구조, source of truth, 필수 게이트 변경
- major 버전: 런타임 호환성 또는 agent/skill 계약의 breaking change

## Codex agent 모델 관리

Codex agent TOML의 모델명은 `docs/harness/harness.yaml`의 `runtime.codex_agent_model`을 기준으로 검증한다. 조직 표준 모델이 바뀌면 `bash scripts/set-codex-agent-model.sh <model-name>`로 일괄 변경한다.

## 에이전트 위임 운영 원칙

조직 표준으로 배포할 때는 레이어별 에이전트를 무조건 많이 실행하지 않는다. 단일 레이어/작은 수정은 `SINGLE_AGENT`, 리뷰만 필요한 변경은 `SINGLE_AGENT_WITH_REVIEW`, 교차 레이어 변경은 `SEQUENTIAL_LAYERED`를 기본값으로 둔다. 병렬 모드는 `13_AGENT_ORCHESTRATION.md`와 `11_PARALLEL_AGENT_GATE.md`를 모두 통과한 경우에만 사용한다.

## Project gate 명령 실행 정책

- 기본: `HARNESS_*_SCRIPT`로 repository script를 실행한다.
- 허용 경로: `scripts/ci/**`, `.github/scripts/**`, `ci/**`.
- 허용 경로 안의 script 파일과 경로 구성 요소는 symlink이면 안 된다.
- `.sh` gate는 Bash와 실행 권한이 필요하다.
- `.ps1` gate는 `pwsh` 또는 Windows PowerShell로 실행하며, 하네스 runner는 `-NoProfile -NonInteractive`를 붙인다.
- `.py` gate는 Python으로 실행한다.
- Legacy: `HARNESS_*_CMD`는 `bash -lc`로 실행된다.
- 조직 표준에서 legacy command를 쓰려면 `HARNESS_ACK_TRUSTED_PROJECT_CMDS=1`과 `HARNESS_ALLOW_LEGACY_BASH_LC=1`을 모두 설정하고, Makefile 진입점 대신 `scripts/verify-project-gates.*` 같은 lower-level runner를 예외 승인과 함께 직접 실행한다.
- 외부 입력, PR 본문, 이슈 내용, 사용자 입력을 그대로 gate 변수에 연결하지 않는다.
- workflow 또는 gate script 변경은 code-owner review/branch protection으로 리뷰를 강제한다.
- secret, token, key를 출력하는 명령은 gate로 등록하지 않는다.
