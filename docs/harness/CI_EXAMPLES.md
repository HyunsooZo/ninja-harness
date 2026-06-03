# CI 예시

## 로컬 Makefile 진입점

CI와 같은 스크립트를 로컬에서 점검할 때는 `Makefile`을 사용할 수 있다.

```bash
make integrity
HARNESS_INTEGRATION_TEST_SCRIPT='scripts/ci/integration-test.sh' make verify-org
make eval
```



조직 표준에서는 구조 검증과 실제 프로젝트 게이트를 분리해서 실행한다. 대형 조직에서는 임의 문자열 명령(`HARNESS_*_CMD`)보다 repository script(`HARNESS_*_SCRIPT`)를 우선한다.

## GitHub Actions

배포 템플릿은 활성 workflow를 직접 포함하지 않는다. 예시는
`docs/harness/examples/github-actions/harness-verify.yml`에 두고, 실제
프로젝트에서 `scripts/ci/**` gate script를 만든 뒤 `.github/workflows/`로
복사해 사용한다.

```yaml
name: harness-verify

on:
  pull_request:
  push:
    branches: [main]

jobs:
  harness:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Verify harness integrity
        run: |
          make integrity

      - name: Verify organization gates
        run: |
          HARNESS_VERIFY_MODE=project \
          HARNESS_ORG_STANDARD=1 \
          HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 \
          HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh' \
          HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT='scripts/ci/primary-frontend-test.sh' \
          HARNESS_SECURITY_SCAN_SCRIPT='scripts/ci/security-scan.sh' \
          bash scripts/verify-harness-structure.sh

  powershell-structure:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Verify PowerShell structure entrypoints
        shell: pwsh
        run: |
          python --version
          git --version
          pwsh -File scripts/doctor.ps1
          $env:HARNESS_VERIFY_MODE = "template"
          pwsh -File scripts/verify-harness-structure.ps1
          $env:HARNESS_VERIFY_MODE = "project"
          pwsh -File scripts/verify-harness-structure.ps1
          if (Test-Path "scripts/ci/windows-smoke.ps1") {
            $env:HARNESS_BACKEND_TEST_SCRIPT = "scripts/ci/windows-smoke.ps1"
            pwsh -File scripts/verify-project-gates.ps1
          }
```

`powershell-structure` job은 Windows native PowerShell에서 template/project 구조 검증 entrypoint가 실행되는지 확인한다. 실제 project gate도 `scripts/verify-project-gates.ps1`로 실행할 수 있다. `.ps1` gate는 하네스 runner가 `-NoProfile -NonInteractive`로 실행하고, `.py` gate는 네이티브 실행이다. `.sh` gate를 선택하면 Bash가 필요하므로 Linux/WSL/Git Bash 계열 job에서 검증한다.

## 권장 repository script 예시

```bash
# scripts/ci/backend-test.sh
#!/usr/bin/env bash
set -euo pipefail
./gradlew test
```

```bash
# scripts/ci/security-scan.sh
#!/usr/bin/env bash
set -euo pipefail
npm audit --audit-level=high
```

## 명령 실행 정책

권장:

- `HARNESS_*_SCRIPT`에 `scripts/ci/**`, `.github/scripts/**`, `ci/**` 아래의 파일을 지정한다.
- `.sh` gate는 Bash로 실행되며 실행 권한이 필요하다.
- `.ps1` gate는 `pwsh` 또는 Windows PowerShell로 실행하며, 하네스 runner는 `-NoProfile -NonInteractive`를 붙인다.
- `.py` gate는 현재 Python interpreter로 실행한다.
- Gate script 파일과 경로 구성 요소는 symlink이면 안 된다.
- 조직 표준 CI에서는 `HARNESS_ACK_TRUSTED_PROJECT_CMDS=1`을 설정해 gate 설정이 maintainer-controlled임을 명시한다.
- workflow와 `scripts/ci/**` 변경은 code-owner/branch protection으로 리뷰 필수 처리한다.
- Windows runner에서는 PowerShell job을 추가해 `scripts/doctor.ps1`, `scripts/verify-harness-structure.ps1`, 필요 시 `scripts/verify-project-gates.ps1`를 실행한다.

Legacy:

- `HARNESS_*_CMD`는 `bash -lc`로 실행되는 legacy escape hatch다.
- 조직 표준에서 `HARNESS_*_CMD`를 쓰려면 `HARNESS_ALLOW_LEGACY_BASH_LC=1`과 `HARNESS_ACK_TRUSTED_PROJECT_CMDS=1`을 모두 설정해야 한다.
- 외부 입력, PR/issue 본문, 사용자 입력을 `HARNESS_*_CMD`에 연결하지 않는다.

금지:

- secret/token/key를 출력하는 명령을 gate로 등록
- 외부 contributor가 임의로 수정 가능한 값으로 gate 구성
- PR 본문 또는 issue 본문에서 명령 문자열을 읽어 실행
