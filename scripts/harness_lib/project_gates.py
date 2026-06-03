from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parent.parent.parent

GATES = [
    ('backend', 'HARNESS_BACKEND_TEST_SCRIPT', 'HARNESS_BACKEND_TEST_CMD'),
    ('primary-frontend', 'HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT', 'HARNESS_PRIMARY_FRONTEND_TEST_CMD'),
    ('secondary-app', 'HARNESS_SECONDARY_APP_TEST_SCRIPT', 'HARNESS_SECONDARY_APP_TEST_CMD'),
    ('integration', 'HARNESS_INTEGRATION_TEST_SCRIPT', 'HARNESS_INTEGRATION_TEST_CMD'),
    ('security', 'HARNESS_SECURITY_SCAN_SCRIPT', 'HARNESS_SECURITY_SCAN_CMD'),
    ('accessibility', 'HARNESS_A11Y_CHECK_SCRIPT', 'HARNESS_A11Y_CHECK_CMD'),
]

ALLOWED_ROOTS = (
    ('scripts', 'ci'),
    ('.github', 'scripts'),
    ('ci',),
)

SHELL_METACHARS = (';', '&', '|', '`', '$(', '${')


def fail(message: str) -> None:
    print(f'[FAIL] {message}', file=sys.stderr)
    raise SystemExit(1)


def is_blank(value: str | None) -> bool:
    return value is None or not value.strip()


def powershell_executable() -> str | None:
    return shutil.which('pwsh') or shutil.which('powershell')


def python_executable() -> str:
    return sys.executable or shutil.which('python3') or shutil.which('python') or 'python'


def validate_repo_script(value: str) -> Path | None:
    if is_blank(value):
        return None

    script_value = value.strip()
    candidate = Path(script_value)
    if candidate.is_absolute():
        fail(f'absolute script paths are not allowed: {script_value}')
    if any(part == '..' for part in candidate.parts):
        fail(f'parent directory traversal is not allowed in script path: {script_value}')
    if any(token in script_value for token in SHELL_METACHARS):
        fail(f'script path contains shell metacharacters: {script_value}')
    if not any(candidate.parts[:len(prefix)] == prefix for prefix in ALLOWED_ROOTS):
        fail(f'script gate must live under scripts/ci/, .github/scripts/, or ci/: {script_value}')

    current = ROOT
    for part in candidate.parts:
        current = current / part
        if current.is_symlink():
            rel = current.relative_to(ROOT).as_posix()
            fail(f'script gate path component must not be a symlink: {rel}')

    resolved = ROOT / candidate
    if not resolved.is_file():
        fail(f'script gate not found: {script_value}')
    return resolved


def command_for_script(script: Path) -> list[str]:
    suffix = script.suffix.lower()
    if suffix == '.sh':
        if not os.access(script, os.X_OK):
            fail(f'shell script gate must be executable: {script.relative_to(ROOT).as_posix()}')
        bash = shutil.which('bash')
        if not bash:
            fail('bash is required to run .sh project gate scripts')
        return [bash, str(script)]
    if suffix == '.ps1':
        ps = powershell_executable()
        if not ps:
            fail('pwsh or Windows PowerShell is required to run .ps1 project gate scripts')
        return [ps, '-NoProfile', '-NonInteractive', '-File', str(script)]
    if suffix == '.py':
        return [python_executable(), str(script)]
    if not os.access(script, os.X_OK):
        fail(f'project gate must be executable or use .sh/.ps1/.py: {script.relative_to(ROOT).as_posix()}')
    return [str(script)]


def run_script_gate(name: str, script_value: str | None) -> bool:
    script = validate_repo_script(script_value or '')
    if script is None:
        return False
    rel = script.relative_to(ROOT).as_posix()
    print(f'[RUN] {name} script: {rel}')
    result = subprocess.run(command_for_script(script), cwd=ROOT)
    if result.returncode != 0:
        fail(f'{name} script failed: {rel}')
    print(f'[OK] {name}')
    return True


def run_legacy_cmd_gate(name: str, command: str | None) -> bool:
    if is_blank(command):
        return False
    if os.environ.get('HARNESS_ALLOW_LEGACY_BASH_LC', '0') != '1':
        fail('HARNESS_*_CMD is legacy; prefer HARNESS_*_SCRIPT or set HARNESS_ALLOW_LEGACY_BASH_LC=1')
    if os.environ.get('HARNESS_ORG_STANDARD', '0') == '1' and os.environ.get('HARNESS_ACK_TRUSTED_PROJECT_CMDS', '0') != '1':
        fail('HARNESS_*_CMD in organization mode requires HARNESS_ACK_TRUSTED_PROJECT_CMDS=1')
    bash = shutil.which('bash')
    if not bash:
        fail('bash is required for legacy HARNESS_*_CMD execution through bash -lc')

    print(f'[WARN] {name} uses legacy HARNESS_*_CMD through bash -lc; prefer HARNESS_*_SCRIPT')
    print(f'[RUN] {name} legacy command: {command}')
    result = subprocess.run([bash, '-lc', command], cwd=ROOT)
    if result.returncode != 0:
        fail(f'{name} legacy command failed')
    print(f'[OK] {name}')
    return True


def main() -> int:
    if os.environ.get('HARNESS_ORG_STANDARD', '0') == '1' and os.environ.get('HARNESS_ACK_TRUSTED_PROJECT_CMDS', '0') != '1':
        fail('organization mode requires HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 to acknowledge trusted gate configuration')

    ran_any = False
    for name, script_var, command_var in GATES:
        if run_script_gate(name, os.environ.get(script_var)):
            ran_any = True
            continue
        if run_legacy_cmd_gate(name, os.environ.get(command_var)):
            ran_any = True
            continue
        print(f'[SKIP] {name}: script/command not configured')

    if not ran_any:
        print('[WARN] no project gate script/command configured')
        print('[WARN] set HARNESS_*_SCRIPT variables, or legacy HARNESS_*_CMD with explicit opt-in')
        if os.environ.get('HARNESS_REQUIRE_PROJECT_CHECKS', '0') == '1':
            fail('HARNESS_REQUIRE_PROJECT_CHECKS=1 requires at least one project gate')

    return 0
