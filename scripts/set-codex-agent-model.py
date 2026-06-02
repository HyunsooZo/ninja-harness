#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import sys

from harness_lib.stdio import configure_utf8_stdio


configure_utf8_stdio()

RUNTIME_FALLBACK = """\
runtime:
  codex_agent_model: {model}
  codex_model_override_env: HARNESS_EXPECTED_CODEX_MODEL
  supported_os: macos_linux_windows
  shell_entrypoints: bash_make_powershell
  unsupported_windows_native: false
  required_tools: python3 git
  posix_required_tools: bash make
  powershell_entrypoints: scripts/doctor.ps1 scripts/verify-harness-structure.ps1 scripts/verify-project-gates.ps1 scripts/check-completed-plan-quality.ps1 scripts/sync-skills.ps1 scripts/check-profile-readiness.ps1 scripts/collect-eval-metrics.ps1 scripts/set-codex-agent-model.ps1 scripts/check-evidence-gate-hook.ps1
  powershell_required_tool: pwsh_or_windows_powershell
  powershell_structure_verification: true
  project_gate_runner: python_cross_platform
  python_verifier: scripts/verify-harness-structure.py
  evidence_gate_hook: scripts/check-evidence-gate-hook.py
  claude_pretooluse_hook: true
  posix_utilities: find cp rm mkdir chmod rmdir sed env uname head cat dirname pwd
  toml_parser: tomllib_or_tomli
  note: 조직 표준 적용 시 모델명은 scripts/set-codex-agent-model.py로 일괄 변경한다.
"""


def sync_runtime_model(path: Path, model: str) -> None:
    text = path.read_text(encoding='utf-8')
    if re.search(r'^  codex_agent_model:', text, flags=re.M):
        text = re.sub(r'^  codex_agent_model:\s*.*$', f'  codex_agent_model: {model}', text, count=1, flags=re.M)
    else:
        text += '\n\n' + RUNTIME_FALLBACK.format(model=model)
    path.write_text(text, encoding='utf-8')


def main(argv: list[str]) -> int:
    if len(argv) != 2 or not argv[1].strip():
        print('Usage: python3 scripts/set-codex-agent-model.py <model-name>')
        return 1

    model = argv[1]
    root = Path('.')

    for path in sorted((root/'.codex/agents').glob('*.toml')):
        text = path.read_text(encoding='utf-8')
        if re.search(r'^model\s*=', text, flags=re.M):
            text = re.sub(r'^model\s*=\s*"[^"]*"', f'model = "{model}"', text, count=1, flags=re.M)
        else:
            text = text.replace('\n', f'\nmodel = "{model}"\n', 1)
        path.write_text(text, encoding='utf-8')

    sync_runtime_model(root/'docs/harness/harness.yaml', model)
    sync_runtime_model(root/'MANIFEST.md', model)

    print(f'[OK] set Codex agent model -> {model}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
