#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VERIFY_MODE="${HARNESS_VERIFY_MODE:-template}"
case "$VERIFY_MODE" in
  template|project) ;;
  *) echo "[FAIL] HARNESS_VERIFY_MODE must be template or project: $VERIFY_MODE"; exit 1 ;;
esac

required=(
  "Makefile"
  "AGENTS.md"
  "CLAUDE.md"
  "docs/harness/README.md"
  "docs/harness/QUICKSTART_5_MIN.md"
  "docs/harness/09_EVIDENCE_GATE.md"
  "docs/harness/12_FIELD_VALIDATION.md"
  "docs/harness/harness.yaml"
  "docs/harness/CI_EXAMPLES.md"
  "docs/harness/ORG_ROLLOUT.md"
  "docs/harness/GOVERNANCE.md"
  "docs/harness/SECURITY_POLICY.md"
  "docs/harness/ADOPTION_SCORECARD.md"
  "docs/harness/context/BASELINE.md"
  "docs/harness/context/DECISIONS.md"
  "docs/harness/context/INDEX.md"
  "docs/harness/profiles/README.md"
  "docs/harness/profiles/project-profile.md"
  "docs/harness/profiles/design-system-profile.md"
  "scripts/doctor.ps1"
  "scripts/verify-harness-structure.ps1"
  ".codex/agents"
  ".agents/skills"
  ".claude/skills"
  ".claude/agents"
  ".claude/commands"
  "scripts/sync-skills.sh"
  "scripts/check-profile-readiness.sh"
  "scripts/self-test-harness-gates.sh"
  "scripts/verify-project-gates.sh"
  "scripts/collect-eval-metrics.sh"
)

for path in "${required[@]}"; do
  [[ -e "$path" ]] || { echo "[FAIL] missing: $path"; exit 1; }
done

VERIFY_MODE="$VERIFY_MODE" python3 - <<'PY'
from pathlib import Path
import os
import re
import subprocess
import sys

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:
    try:
        import tomli as tomllib  # Python 3.10 and below fallback
    except ModuleNotFoundError:
        raise SystemExit('[FAIL] Python 3.11+ is required, or install tomli for Python 3.10 and below: python3 -m pip install tomli')

mode = os.environ.get('VERIFY_MODE', 'template')
root = Path('.')
text_file_suffixes = {'.md','.toml','.yaml','.yml','.json','.sh'}

def fail(message: str) -> None:
    raise SystemExit(f'[FAIL] {message}')

def check(condition: bool, message: str) -> None:
    if not condition:
        fail(message)

check(not sys.flags.optimize, 'Python optimization mode is not supported for harness verification; unset PYTHONOPTIMIZE and do not run python with -O')

# Retired duplicate core docs must stay merged into their source documents.
retired_docs = [
    root/'docs/harness/06_PROJECT_BASELINE.md',
    root/'docs/harness/12_CONTEXT_LOADING_RULE.md',
]
check(not any(p.exists() for p in retired_docs), f'retired duplicate docs must not exist: {[str(p) for p in retired_docs if p.exists()]}')


# Makefile should provide one stable local/CI entry point for common harness tasks.
makefile = root/'Makefile'
make_text = makefile.read_text(encoding='utf-8')
check(re.search(r'^SHELL := bash$', make_text, re.M), 'Makefile must use PATH-resolved bash, not a hardcoded /bin/bash path')
check('SHELL := /bin/bash' not in make_text, 'Makefile must not hardcode /bin/bash')
for target in ['help','doctor','verify','verify-template','verify-project','project-ready','check-profile','self-test-gates','check-active-plans','integrity','verify-org','project-gates','project-gates-required','sync-skills','check-sync','eval','check-plans','set-model','clean']:
    check(re.search(rf'^{re.escape(target)}:', make_text, re.M), f'Makefile missing target: {target}')
for token in ['HARNESS_VERIFY_MODE=template','HARNESS_VERIFY_MODE=project','HARNESS_REQUIRE_FILLED_PROFILE=1','HARNESS_ORG_STANDARD=1','HARNESS_ACK_TRUSTED_PROJECT_CMDS=1','HARNESS_REQUIRE_PROJECT_CHECKS=1','HARNESS_INTEGRATION_TEST_SCRIPT','ORG_GATE_SCRIPT_VARS','scripts/sync-skills.sh','scripts/check-profile-readiness.sh','scripts/self-test-harness-gates.sh','scripts/collect-eval-metrics.sh','scripts/check-completed-plan-quality.sh','scripts/set-codex-agent-model.sh']:
    check(token in make_text, f'Makefile missing command/policy token: {token}')
help_match = re.search(r'^help:\n(?P<body>.*?)(?=^[A-Za-z0-9_.-]+:|\Z)', make_text, re.M | re.S)
check(help_match, 'Makefile missing help target body')
help_body = help_match.group('body')
public_make_targets = [
    target
    for target in re.findall(r'^([A-Za-z0-9_.-]+):', make_text, re.M)
    if target not in {'help'} and not target.startswith('.')
]
missing_help_targets = [target for target in public_make_targets if f'make {target}' not in help_body]
check(not missing_help_targets, f'Makefile help missing public targets: {missing_help_targets}')
for token in ['integrity: doctor verify self-test-gates check-plans check-active-plans', 'git diff --check', 'no active plans']:
    check(token in make_text, f'Makefile missing integrity token: {token}')
clean_match = re.search(r'^clean:\n(?P<body>.*?)(?=^[A-Za-z0-9_.-]+:|\Z)', make_text, re.M | re.S)
check(clean_match, 'Makefile missing clean target body')
clean_body = clean_match.group('body')
for token in ['find . -name ".DS_Store" -delete', 'find . -name "._*" -delete', 'find . -type d -name "__MACOSX" -prune -exec rm -rf {} +', 'find . -name "__tmp-*.sh" -delete']:
    check(token in clean_body, f'Makefile clean target missing cleanup token: {token}')
for token in ['command -v bash','command -v python3','HARNESS_POSIX_UTILITIES','POSIX utility is required','find_spec("tomllib")','find_spec("tomli")','Python TOML parser','supported OS','unsupported OS']:
    check(token in make_text, f'Makefile doctor missing runtime readiness token: {token}')
for gate_var in ['HARNESS_BACKEND_TEST_SCRIPT','HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT','HARNESS_SECONDARY_APP_TEST_SCRIPT','HARNESS_INTEGRATION_TEST_SCRIPT','HARNESS_SECURITY_SCAN_SCRIPT','HARNESS_A11Y_CHECK_SCRIPT']:
    check(gate_var in make_text, f'Makefile verify-org must recognize gate variable: {gate_var}')
check('HARNESS_*_SCRIPT' in make_text, 'Makefile help must mention script-based organization gates')
check('legacy HARNESS_*_CMD strings' in make_text, 'Makefile must frame legacy command gates as non-primary')
check('HARNESS_*_CMD strings' in make_text and 'Makefile 진입점에서 안내하지 않는다' not in make_text, 'Makefile policy should be explicit in Makefile, not only docs')

# No local OS/editor artifacts in package.
ds_store = sorted(str(p) for p in root.rglob('.DS_Store'))
check(not ds_store, f'.DS_Store files must be removed: {ds_store}')
apple_double = sorted(str(p) for p in root.rglob('._*'))
check(not apple_double, f'AppleDouble files must be removed: {apple_double}')
macosx_dirs = sorted(str(p) for p in root.rglob('__MACOSX') if p.is_dir())
check(not macosx_dirs, f'__MACOSX directories must be removed: {macosx_dirs}')
check(not (root/'.claude/settings.local.json').exists(), '.claude/settings.local.json must not be distributed')
check(not (root/'.codex/skills').exists(), '.codex/skills is retired; use .agents/skills as skill source of truth')
workflow_dir = root/'.github/workflows'
active_example_workflows = sorted(str(p) for p in workflow_dir.glob('*.example.y*ml')) if workflow_dir.exists() else []
check(not active_example_workflows, f'GitHub Actions example workflows must live outside .github/workflows: {active_example_workflows}')
# Distribution packages must not include always-success temporary gate scripts.
for forbidden_gate in [root/'scripts/ci/__tmp-ok.sh']:
    check(not forbidden_gate.exists(), f'temporary/dummy project gate script must not be distributed: {forbidden_gate}')
for p in root.rglob('*'):
    if p.is_file() and p.name.startswith('__tmp-') and p.suffix == '.sh':
        fail(f'temporary shell script must not be distributed: {p}')
sensitive_artifacts = []
sensitive_config_suffixes = {'', '.json', '.yaml', '.yml', '.txt', '.conf', '.config', '.ini', '.properties', '.toml'}
for p in root.rglob('*'):
    if not p.is_file():
        continue
    if any(part == '.git' for part in p.parts):
        continue
    lower_name = p.name.lower()
    lower_suffix = p.suffix.lower()
    if (
        lower_name.startswith('.env')
        or lower_name.endswith(('.pem', '.p12', '.key', '.keystore'))
        or (('secret' in lower_name or 'token' in lower_name) and lower_suffix in sensitive_config_suffixes)
    ):
        sensitive_artifacts.append(str(p))
check(not sensitive_artifacts, f'sensitive artifact must not be distributed: {sensitive_artifacts}')

# Codex agent TOML validation.
agents = sorted((root/'.codex/agents').glob('*.toml'))
claude_agents = sorted((root/'.claude/agents').glob('*.md'))
codex_names = {p.stem for p in agents}
claude_names = {p.stem for p in claude_agents}
check(codex_names == claude_names, f'codex/claude agent set mismatch: codex_only={sorted(codex_names-claude_names)}, claude_only={sorted(claude_names-codex_names)}')

def parse_claude_agent(path: Path):
    text = path.read_text(encoding='utf-8')
    frontmatter = {}
    match = re.match(r'^---\n(?P<body>.*?)\n---\n(?P<rest>.*)$', text, re.S)
    check(match, f'missing frontmatter: {path}')
    for line in match.group('body').splitlines():
        if ':' in line:
            key, value = line.split(':', 1)
            frontmatter[key.strip()] = value.strip().strip('"')
    body = match.group('rest').strip()
    body = re.sub(r'^#\s+[A-Za-z0-9_-]+\n\n?', '', body).strip()
    body = re.sub(r'\n## (?:런타임 메모|Claude Code 호환 메모)\n.*\Z', '', body, flags=re.S).strip()
    body = re.sub(r'\n{3,}', '\n\n', body)
    return frontmatter, body

def parse_frontmatter_list(value: str):
    value = (value or '').strip()
    if value.startswith('[') and value.endswith(']'):
        value = value[1:-1]
    return {item.strip().strip('\"\'') for item in value.split(',') if item.strip()}

claude_frontmatters = {}

yaml_text_for_model = (root/'docs/harness/harness.yaml').read_text(encoding='utf-8')
model_match = re.search(r'^  codex_agent_model:\s*(\S+)\s*$', yaml_text_for_model, flags=re.M)
expected_model = os.environ.get('HARNESS_EXPECTED_CODEX_MODEL') or (model_match.group(1) if model_match else 'gpt-5.5')
runtime_match = re.search(
    r'^runtime:\n(?P<body>(?:  [A-Za-z0-9_]+: .+\n?)+)',
    yaml_text_for_model,
    flags=re.M,
)
check(runtime_match, 'missing runtime manifest')
runtime_refs = {}
for line in runtime_match.group('body').splitlines():
    key, value = line.strip().split(': ', 1)
    runtime_refs[key] = value.strip()
required_runtime_refs = {
    'codex_agent_model': model_match.group(1) if model_match else '',
    'codex_model_override_env': 'HARNESS_EXPECTED_CODEX_MODEL',
    'supported_os': 'macos_linux_windows',
    'shell_entrypoints': 'bash_make_powershell',
    'unsupported_windows_native': 'false',
    'required_tools': 'bash make python3 git',
    'powershell_entrypoints': 'scripts/doctor.ps1 scripts/verify-harness-structure.ps1',
    'powershell_required_tool': 'pwsh_or_windows_powershell',
    'posix_utilities': 'find cp rm mkdir chmod rmdir sed env uname head cat dirname pwd',
    'toml_parser': 'tomllib_or_tomli',
    'note': '조직 표준 적용 시 모델명은 scripts/set-codex-agent-model.sh로 일괄 변경한다.',
}
missing_runtime_keys = set(required_runtime_refs) - set(runtime_refs)
check(not missing_runtime_keys, f'missing runtime manifest keys: {sorted(missing_runtime_keys)}')
for key, expected in required_runtime_refs.items():
    check(runtime_refs.get(key) == expected, f'runtime.{key} must be {expected}: {runtime_refs.get(key)}')
check(runtime_refs['codex_agent_model'], 'runtime.codex_agent_model must not be empty')
check(runtime_refs['codex_model_override_env'] == 'HARNESS_EXPECTED_CODEX_MODEL', 'runtime override env mismatch')
set_model_script = root/'scripts/set-codex-agent-model.sh'
check(set_model_script.exists(), 'missing runtime model management script')
set_model_text = set_model_script.read_text(encoding='utf-8')
check("sync_runtime_model(root/'MANIFEST.md')" in set_model_text, 'set-model script must update MANIFEST.md runtime model')
for key, expected in required_runtime_refs.items():
    if key == 'codex_agent_model':
        continue
    check(f'  {key}: {expected}' in set_model_text, f'set-model fallback missing runtime field: {key}')
for token in ['Darwin|Linux', 'CYGWIN*|MINGW*|MSYS*', 'prefer WSL for CI parity', 'unsupported OS']:
    check(token in make_text, f'Makefile doctor missing OS support token: {token}')
for tool in runtime_refs['required_tools'].split():
    check(f'command -v {tool}' in make_text, f'Makefile doctor missing required tool check: {tool}')
posix_make_match = re.search(r'^HARNESS_POSIX_UTILITIES \?= (.+)$', make_text, flags=re.M)
check(posix_make_match, 'Makefile missing HARNESS_POSIX_UTILITIES ?= assignment')
check(posix_make_match.group(1).strip() == runtime_refs['posix_utilities'], (
    f'Makefile/runtime posix utility list mismatch: {posix_make_match.group(1).strip()} != {runtime_refs["posix_utilities"]}'
))
for tool in runtime_refs['posix_utilities'].split():
    check(tool in make_text, f'Makefile doctor missing POSIX utility from readiness list: {tool}')
check('command -v "$$tool"' in make_text, 'Makefile doctor must validate every configured POSIX utility')
check(runtime_refs['toml_parser'] == 'tomllib_or_tomli', 'runtime TOML parser contract mismatch')
for token in ['find_spec("tomllib")', 'find_spec("tomli")', 'Python TOML parser']:
    check(token in make_text, f'Makefile doctor missing Python TOML parser check token: {token}')
readme_text_for_runtime = (root/'docs/harness/README.md').read_text(encoding='utf-8')
for token in ['macOS, Linux/WSL', 'Git Bash/MSYS/Cygwin/PowerShell', 'Windows native PowerShell', 'scripts/doctor.ps1', 'scripts/verify-harness-structure.ps1', 'bash', 'python3', 'make', 'git', 'POSIX 유틸리티', 'find', 'cp', 'rm', 'mkdir', 'chmod', 'rmdir', 'sed', 'env', 'uname', 'head', 'cat', 'dirname', 'pwd', 'tomllib', 'tomli', 'Python TOML 파서']:
    check(token in readme_text_for_runtime, f'README runtime section missing token: {token}')
for ps_script in ['scripts/doctor.ps1', 'scripts/verify-harness-structure.ps1']:
    ps_text = (root/ps_script).read_text(encoding='utf-8')
    check('Set-StrictMode -Version Latest' in ps_text, f'{ps_script} must enable strict mode')
    check('$ErrorActionPreference = "Stop"' in ps_text, f'{ps_script} must stop on errors')
check('bash is required for the current structure verifier' in (root/'scripts/verify-harness-structure.ps1').read_text(encoding='utf-8'), 'PowerShell verifier must state bash requirement')
for token in ['Codex agent TOML', 'skills = [...]', 'skill preload metadata']:
    check(token in readme_text_for_runtime, f'README compatibility section missing token: {token}')

allowed_reasoning_efforts = {'none', 'minimal', 'low', 'medium', 'high', 'xhigh'}
allowed_sandbox_modes = {'read-only', 'workspace-write', 'danger-full-access'}

for p in agents:
    data = tomllib.loads(p.read_text(encoding='utf-8'))
    for key in ['name', 'description', 'model', 'model_reasoning_effort', 'sandbox_mode', 'developer_instructions']:
        check(isinstance(data.get(key), str) and data.get(key).strip(), f'Codex agent {key} must be a non-empty string: {p}')
    check(data.get('model_reasoning_effort') in allowed_reasoning_efforts, f'Codex agent model_reasoning_effort has unsupported value: {p}')
    check(data.get('sandbox_mode') in allowed_sandbox_modes, f'Codex agent sandbox_mode has unsupported value: {p}')
    check(data.get('name'), f'missing name: {p}')
    check(data.get('model') == expected_model, f'model must be {expected_model}: {p}')
    check('developer_instructions' in data, f'missing developer_instructions: {p}')
    claude_path = root/'.claude/agents'/f'{p.stem}.md'
    frontmatter, claude_body = parse_claude_agent(claude_path)
    claude_frontmatters[p.stem] = frontmatter
    raw_codex_skills = data.get('skills')
    check(isinstance(raw_codex_skills, list), f'Codex agent skills must be a list: {p}')
    check(all(isinstance(skill, str) and skill.strip() for skill in raw_codex_skills), f'Codex agent skills must be non-empty strings: {p}')
    codex_skills = set(raw_codex_skills)
    claude_skills = parse_frontmatter_list(frontmatter.get('skills', ''))
    check(frontmatter.get('name') == data.get('name'), f'agent name mismatch: {p} vs {claude_path}')
    check(frontmatter.get('description') == data.get('description'), f'agent description mismatch: {p} vs {claude_path}')
    check(codex_skills, f'missing Codex agent skills preload: {p}')
    check(codex_skills == claude_skills, f'agent skills preload drift: {p} vs {claude_path}')
    codex_body = data.get('developer_instructions', '').strip()
    codex_body = re.sub(r'\n{3,}', '\n\n', codex_body)
    check(codex_body == claude_body, f'agent body mirror drift: {p} vs {claude_path}')
    if p.stem.endswith('reviewer'):
        check(data.get('sandbox_mode') == 'read-only', f'reviewer must be read-only sandbox: {p}')
        check('읽기 전용 안전 계약' in data.get('developer_instructions', ''), f'missing read-only contract: {p}')
    else:
        check(data.get('sandbox_mode') != 'read-only', f'implementer should not be read-only: {p}')

# Claude reviewer safety contract validation.
for p in sorted((root/'.claude/agents').glob('*reviewer.md')):
    text = p.read_text(encoding='utf-8')
    check('읽기 전용 안전 계약' in text, f'missing read-only contract: {p}')

# Claude subagent tool/skill frontmatter validation.
for name, frontmatter in sorted(claude_frontmatters.items()):
    tools = parse_frontmatter_list(frontmatter.get('tools', ''))
    skills = parse_frontmatter_list(frontmatter.get('skills', ''))
    check(tools, f'missing Claude agent tools allowlist: .claude/agents/{name}.md')
    check(skills, f'missing Claude agent skills preload: .claude/agents/{name}.md')
    if name.endswith('reviewer'):
        unsafe = {'Write', 'Edit', 'MultiEdit', 'Bash'}
        check(not (tools & unsafe), f'reviewer has unsafe tools {sorted(tools & unsafe)}: .claude/agents/{name}.md')
        check(tools <= {'Read', 'Grep', 'Glob'}, f'reviewer tools must stay read-only: .claude/agents/{name}.md -> {sorted(tools)}')
    else:
        check({'Read', 'Grep', 'Glob'} <= tools, f'implementer missing base read tools: .claude/agents/{name}.md')

print('[OK] codex agent TOML valid')
print(f'[OK] codex agents: {len(agents)}')
print(f'[OK] claude agents: {len(claude_agents)}')

# OpenAI/Codex repo skills are the source of truth; Claude skills are generated native mirrors.
codex_skill_dirs = {p.parent.name: p.parent for p in (root/'.agents/skills').glob('*/SKILL.md')}
claude_skill_dirs = {p.parent.name: p.parent for p in (root/'.claude/skills').glob('*/SKILL.md')}
check(codex_skill_dirs, 'missing repo skills')
check(codex_skill_dirs.keys() == claude_skill_dirs.keys(), (
    f'repo/claude skill set mismatch: '
    f'codex_only={sorted(codex_skill_dirs.keys()-claude_skill_dirs.keys())}, '
    f'claude_only={sorted(claude_skill_dirs.keys()-codex_skill_dirs.keys())}'
))

ignored_names = {'.DS_Store'}
def file_bytes(path: Path) -> bytes:
    return path.read_bytes()

for name, codex_dir in sorted(codex_skill_dirs.items()):
    claude_dir = claude_skill_dirs[name]
    codex_files = {p.relative_to(codex_dir) for p in codex_dir.rglob('*') if p.is_file() and p.name not in ignored_names and not p.name.startswith('._')}
    claude_files = {p.relative_to(claude_dir) for p in claude_dir.rglob('*') if p.is_file() and p.name not in ignored_names and not p.name.startswith('._')}
    check(codex_files == claude_files, f'skill mirror file set drift: {name}: codex_only={sorted(map(str, codex_files-claude_files))}, claude_only={sorted(map(str, claude_files-codex_files))}')
    for rel in sorted(codex_files):
        check(file_bytes(codex_dir/rel) == file_bytes(claude_dir/rel), f'skill mirror content drift: {name}/{rel}')

# Skill frontmatter descriptions should be trigger-oriented, not generic.
for name, skill_dir in sorted(codex_skill_dirs.items()):
    skill_text = (skill_dir/'SKILL.md').read_text(encoding='utf-8')
    m = re.search(r'^description:\s*(.+)$', skill_text, flags=re.M)
    check(m, f'missing skill description: {skill_dir}/SKILL.md')
    desc = m.group(1).strip()
    check('기준을 적용한다' not in desc, f'skill description too generic: {skill_dir}/SKILL.md')
    check(len(desc) >= 50, f'skill description should include trigger words: {skill_dir}/SKILL.md')

# Claude agent preloaded skills should exist in source skill set.
all_skill_names = set(codex_skill_dirs)
for name, frontmatter in sorted(claude_frontmatters.items()):
    declared = parse_frontmatter_list(frontmatter.get('skills', ''))
    missing = declared - all_skill_names
    check(not missing, f'Claude agent declares missing skills {sorted(missing)}: .claude/agents/{name}.md')

codex_agent_skill_usage = set()
for p in agents:
    data = tomllib.loads(p.read_text(encoding='utf-8'))
    declared = set(data.get('skills') or [])
    missing = declared - all_skill_names
    check(not missing, f'Codex agent declares missing skills {sorted(missing)}: {p}')
    codex_agent_skill_usage.update(declared)
unpreloaded_skills = sorted(all_skill_names - codex_agent_skill_usage)
check(not unpreloaded_skills, f'local skills are not preloaded by any Codex agent: {unpreloaded_skills}')

sync_script = root/'scripts/sync-skills.sh'
check(os.access(sync_script, os.X_OK), 'scripts/sync-skills.sh must be executable')
project_gate_script = root/'scripts/verify-project-gates.sh'
check(os.access(project_gate_script, os.X_OK), 'scripts/verify-project-gates.sh must be executable')
for script_name in ['check-profile-readiness.sh', 'self-test-harness-gates.sh', 'collect-eval-metrics.sh', 'check-completed-plan-quality.sh', 'set-codex-agent-model.sh']:
    script_path = root/'scripts'/script_name
    check(os.access(script_path, os.X_OK), f'scripts/{script_name} must be executable')

self_test_text = (root/'scripts/self-test-harness-gates.sh').read_text(encoding='utf-8')
for token in ['expect_pass', 'expect_fail', 'check-profile-readiness.sh', 'check-completed-plan-quality.sh', 'verify-harness-structure.sh', 'verify-project-gates.sh', 'HARNESS_VERIFY_MODE=invalid', 'HARNESS_REQUIRE_FILLED_PROFILE=1', 'completed plan quality accepts empty directory', 'completed plan quality accepts required evidence markers', 'completed plan quality rejects missing evidence markers', 'sensitive artifact rejects local env file', 'sensitive artifact rejects token config file', 'sensitive artifact rejects secret properties file', 'token policy markdown remains allowed', 'template rejects tracked active plan', 'template rejects tracked completed plan', 'project allows tracked completed plan', 'source_of_truth rejects missing required entry', 'source_of_truth rejects missing required state', 'manifest parity rejects missing policy line', 'gitignore rejects missing active plan ignore', 'gitignore rejects missing completed plan ignore', 'gitignore rejects missing secret config ignore', 'project profile rejects missing frontend test command', 'clean removes nested macOS metadata', 'plan template rejects lifecycle Status', 'makefile rejects hardcoded bash path', 'source_of_truth rejects missing backend rubric', 'skill routing rejects missing agent mapping', 'skill routing rejects unknown agent mapping', 'organization manifest rejects missing governance', 'review_gates reject missing agent', 'owned API manifest rejects missing router skill', 'runtime manifest rejects missing override env', 'runtime rejects missing OS support manifest', 'runtime rejects missing git required tool', 'runtime rejects missing POSIX utility manifest', 'runtime rejects missing Python TOML parser manifest', 'agent metadata rejects missing Codex skills preload', 'agent metadata rejects invalid sandbox mode', 'agent metadata rejects invalid reasoning effort', 'agent metadata rejects non-list skills preload', 'agent preload rejects missing local skill coverage', 'project gate manifest rejects missing preferred script', 'workflow manifest rejects missing integrity target', 'parallel manifest rejects overlapping file edits', 'rules manifest rejects unrelated refactor removal', 'agent orchestration rejects missing single integrator', 'context rules reject full scan default removal', 'project gate rejects symlink script', 'project gate rejects parent symlink script path', 'project gate rejects non-allowlisted repo script', 'project gate accepts allowlisted executable script', 'legacy command blocks without explicit opt-in', 'legacy command accepts explicit opt-in', 'HARNESS_REQUIRE_PROJECT_CHECKS=1', 'HARNESS_BACKEND_TEST_CMD']:
    check(token in self_test_text, f'self-test gate script missing token: {token}')

completed_quality_text = (root/'scripts/check-completed-plan-quality.sh').read_text(encoding='utf-8')
for token in ['HARNESS_COMPLETED_PLAN_DIR', 'nullglob', 'completed plan quality: no completed plans']:
    check(token in completed_quality_text, f'completed plan quality script missing token: {token}')

print(f'[OK] repo skills: {len(codex_skill_dirs)}')
print(f'[OK] claude skills: {len(claude_skill_dirs)}')
print('[OK] repo/claude skill mirrors verified')

# Claude command set validation.
expected_commands = {'start', 'plan', 'red', 'green', 'refactor', 'verify', 'review', 'complete'}
actual_commands = {p.stem for p in (root/'.claude/commands').glob('*.md')}
check(actual_commands == expected_commands, f'claude command mismatch: expected={sorted(expected_commands)}, actual={sorted(actual_commands)}')

# No root generated 전체 스캔.
check(not (root/'PROJECT_CONTEXT_SCAN.md').exists(), 'PROJECT_CONTEXT_SCAN.md must not be stored at root')
if mode == 'template':
    tracked_plan_markdown = subprocess.run(
        ['git', 'ls-files', 'docs/harness/plans/active/*.md', 'docs/harness/plans/completed/*.md'],
        cwd=root,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    if tracked_plan_markdown.returncode == 0:
        tracked_plans = [line for line in tracked_plan_markdown.stdout.splitlines() if line.strip()]
        check(not tracked_plans, (
            'tracked active/completed plan markdown must not be distributed: '
            f'{tracked_plans}'
        ))

manifest_text = (root/'MANIFEST.md').read_text(encoding='utf-8')
manifest_policy_text = manifest_text.split('\n## ', 1)[0].rstrip() + '\n'

def canonical_manifest_policy(text: str) -> str:
    lines = [line.rstrip() for line in text.splitlines()]
    normalized = []
    previous_blank = False
    for line in lines:
        blank = not line.strip()
        if blank and previous_blank:
            continue
        normalized.append(line)
        previous_blank = blank
    return '\n'.join(normalized).rstrip() + '\n'

check(
    canonical_manifest_policy(manifest_policy_text) == canonical_manifest_policy(yaml_text_for_model),
    'MANIFEST.md policy block must match docs/harness/harness.yaml'
)
manifest_model_match = re.search(r'^  codex_agent_model:\s*(\S+)\s*$', manifest_text, flags=re.M)
check(manifest_model_match, 'MANIFEST.md missing runtime codex_agent_model')
check(manifest_model_match.group(1) == runtime_refs['codex_agent_model'], (
    f'MANIFEST.md runtime model must match harness.yaml: {manifest_model_match.group(1)} != {runtime_refs["codex_agent_model"]}'
))
for token in [
    'CLAUDE.md',
    'docs/harness/ORG_ROLLOUT.md',
    'docs/harness/rubrics/backend.md',
    'optional_project_gates: true',
    'project_gates:',
    'agent_orchestration:',
    'orchestration:',
    'organization:',
    'owned_api_contract_impact:',
    'supported_os: macos_linux_windows',
    'shell_entrypoints: bash_make_powershell',
    'powershell_entrypoints: scripts/doctor.ps1 scripts/verify-harness-structure.ps1',
    'required_tools: bash make python3 git',
    'posix_utilities: find cp rm mkdir chmod rmdir sed env uname head cat dirname pwd',
    'toml_parser: tomllib_or_tomli',
]:
    check(token in manifest_text, f'MANIFEST.md missing current manifest token: {token}')

root_readme_text = (root/'README.md').read_text(encoding='utf-8')
for token in ['배포 전 체크리스트', 'make doctor', 'make verify', 'make check-sync', 'make integrity', 'make eval', 'make verify-org']:
    check(token in root_readme_text, f'root README release checklist missing token: {token}')
harness_readme_text = (root/'docs/harness/README.md').read_text(encoding='utf-8')
for doc_name, doc_text in [('README.md', root_readme_text), ('docs/harness/README.md', harness_readme_text)]:
    missing_doc_targets = [target for target in public_make_targets if f'make {target}' not in doc_text]
    check(not missing_doc_targets, f'{doc_name} missing public Makefile target docs: {missing_doc_targets}')
check('| `make integrity` |' in root_readme_text, 'root README Makefile command table must document make integrity')
for token in [
    'docs/harness/plans/active/*.md',
    'docs/harness/plans/completed/*.md',
    '.env*', '*.pem', '*.p12', '*.key', '*.keystore', 'token-policy.md',
    '*secret*.json', '*secret*.yml', '*secret*.yaml', '*secret*.txt',
    '*secret*.conf', '*secret*.config', '*secret*.ini', '*secret*.properties', '*secret*.toml',
    '*token*.json', '*token*.yml', '*token*.yaml', '*token*.txt',
    '*token*.conf', '*token*.config', '*token*.ini', '*token*.properties', '*token*.toml',
]:
    check(token in root_readme_text, f'root README distribution exclusion missing sensitive token: {token}')
gitignore_text = (root/'.gitignore').read_text(encoding='utf-8')
for token in [
    'docs/harness/plans/active/*.md',
    'docs/harness/plans/completed/*.md',
    '.codex/skills/',
    '__tmp-*.sh',
    '**/__tmp-*.sh',
    '.env*', '*.pem', '*.p12', '*.key', '*.keystore',
    '*secret*.json', '*secret*.yml', '*secret*.yaml', '*secret*.txt',
    '*secret*.conf', '*secret*.config', '*secret*.ini', '*secret*.properties', '*secret*.toml',
    '*token*.json', '*token*.yml', '*token*.yaml', '*token*.txt',
    '*token*.conf', '*token*.config', '*token*.ini', '*token*.properties', '*token*.toml',
]:
    check(token in gitignore_text, f'.gitignore missing distribution exclusion token: {token}')

profile_text = (root/'docs/harness/profiles/project-profile.md').read_text(encoding='utf-8')
baseline_text = (root/'docs/harness/context/BASELINE.md').read_text(encoding='utf-8')
testing_text = (root/'docs/harness/05_TESTING.md').read_text(encoding='utf-8')
default_command_placeholders = [
    '<backend-test-command>',
    '<backend-build-command>',
    '<primary-frontend-test-command>',
    '<primary-frontend-build-command>',
    '<secondary-app-test-command>',
    '<secondary-app-build-command>',
]
extended_command_placeholders = [
    '<backend-targeted-test-command>',
    '<backend-runtime-command>',
    '<primary-frontend-targeted-test-command>',
    '<primary-frontend-style-command>',
    '<secondary-app-runtime-command>',
]
for token in default_command_placeholders:
    check(token in baseline_text, f'BASELINE.md missing default validation command placeholder: {token}')
for token in default_command_placeholders + extended_command_placeholders:
    check(token in testing_text, f'05_TESTING.md missing validation command placeholder: {token}')
    check(token in profile_text, f'project-profile.md missing validation command placeholder: {token}')
check('사용하지 않는 영역은 `N/A`' in profile_text, 'project-profile.md must document N/A for unused validation areas')

# PROJECT_CONTEXT_SCAN references must call it 생성 산출물 or basic context exclusion.
for p in root.rglob('*'):
    if p.is_file() and p.suffix in text_file_suffixes:
        text = p.read_text(encoding='utf-8', errors='ignore')
        if 'PROJECT_CONTEXT_SCAN.md' in text and '생성 산출물' not in text and 'generated/PROJECT_CONTEXT_SCAN.generated.md' not in text and '기본 컨텍스트' not in text:
            fail(f'unexpected PROJECT_CONTEXT_SCAN.md reference: {p}')

# Generic harness files must not leak one target project's actor, stack, API prefix,
# package root, or design-token values.
#
# mode=template:
#   distribution/template package. core, context, profiles, agents, skills should remain generic.
# mode=project:
#   installed project package. core/agents/skills must remain generic, but context/profiles may contain project values.
leak_scan_roots = [
    root/'AGENTS.md',
    root/'CLAUDE.md',
    root/'docs/harness',
    root/'.codex/agents',
    root/'.agents/skills',
    root/'.claude/skills',
    root/'.claude/agents',
    root/'.claude/commands',
]
leak_excluded = [
    root/'docs/harness/plans/active',
    root/'docs/harness/plans/completed',
    root/'docs/harness/plans/examples',
    root/'docs/harness/profiles/examples',
]
if mode == 'project':
    leak_excluded.extend([
        root/'docs/harness/context',
        root/'docs/harness/profiles',
    ])
project_leak_patterns = [
    ('target-project marker', r'대상 프로젝트'),
    ('domain actor term', r'직' + r'원|알' + r'바|em' + r'ployee|Em' + r'ployee|OW' + r'NER|EM' + r'PLOYEE'),
    ('domain resource term', r'사업' + r'장|selected store|store selection|store scope|store-scoped|storeId|/stores\b'),
    ('domain API prefix', r'/api/app|/api/alba'),
    ('project package/name', r'il' + r'log|com/' + r'il' + r'log|eal' + r'ry|bzhs1992'),
    ('project design token', r'--il' + r'log|#0955ab|Project' + r' Editorial|No' + r'tion'),
    ('hardcoded backend stack', r'\bJa' + r'va 21\b|\bSpring' + r' Boot\b|\bGra' + r'dle\b|\bPostgre' + r'SQL\b|\bFly' + r'way\b|\bRe' + r'dis\b'),
    ('hardcoded frontend stack', r'\bVu' + r'e\b|\bVi' + r'te\b|\bCap' + r'acitor\b'),
    ('old auth wording', r'auth/store|owner/management|em' + r'ployee-facing|VITE_' + r'EMPLOYEE'),
    ('source-project surface naming', r'front' + r'end-ad' + r'min|US' + r'ER_APP|us' + r'er[_-]app|us' + r'er-hybrid|보조 사용자' + r' 앱|사용자' + r' 앱|관리' + r'자'),
]

def is_under(path: Path, base: Path) -> bool:
    try:
        path.relative_to(base)
        return True
    except ValueError:
        return False

leaks = []
for scan_root in leak_scan_roots:
    candidates = [scan_root] if scan_root.is_file() else scan_root.rglob('*')
    for p in candidates:
        if not p.is_file() or p.suffix not in text_file_suffixes:
            continue
        if p == root/'scripts/verify-harness-structure.sh':
            continue
        if any(is_under(p, excluded) for excluded in leak_excluded):
            continue
        text = p.read_text(encoding='utf-8', errors='ignore')
        for label, pattern in project_leak_patterns:
            match = re.search(pattern, text)
            if match:
                leaks.append(f'{p}: {label}: {match.group(0)!r}')
                break
check(not leaks, f'프로젝트별 leakage in generic harness files (mode={mode}):\n' + '\n'.join(leaks))

# Placeholder must not be used as an agent/skill file name.
# Path placeholders like cd <secondary-app-dir> are allowed, but placeholder-derived agent names are not.
bad_placeholder_ref = re.compile(r'<(?:backend|primary-frontend|secondary-app)-dir>-[A-Za-z0-9_-]+')
for p in root.rglob('*'):
    if p == Path('scripts/verify-harness-structure.sh'):
        continue
    if p.is_file() and p.suffix in text_file_suffixes:
        text = p.read_text(encoding='utf-8', errors='ignore')
        match = bad_placeholder_ref.search(text)
        if match:
            fail(f'unresolved placeholder-derived name {match.group(0)!r}: {p}')

# Referenced Codex agents/skills in routing docs should exist.
agent_names = {p.stem for p in (root/'.codex/agents').glob('*.toml')}
skill_names = {p.parent.name for p in (root/'.agents/skills').glob('*/SKILL.md')}
for doc in [root/'AGENTS.md', root/'docs/harness/skill-routing.md', root/'docs/harness/harness.yaml']:
    text = doc.read_text(encoding='utf-8')
    for ref in re.findall(r'`?\.codex/agents/([A-Za-z0-9_-]+)\.toml`?', text):
        check(ref in agent_names, f'missing referenced codex agent {ref}: {doc}')
    for ref in re.findall(r'`?\.agents/skills/([A-Za-z0-9_-]+)/SKILL\.md`?', text):
        check(ref in skill_names, f'missing referenced repo skill {ref}: {doc}')
    for ref in re.findall(r'`?\.claude/skills/([A-Za-z0-9_-]+)/SKILL\.md`?', text):
        check(ref in claude_skill_dirs, f'missing referenced claude skill {ref}: {doc}')

skill_routing_text = (root/'docs/harness/skill-routing.md').read_text(encoding='utf-8')
unrouted_skills = sorted(skill for skill in skill_names if skill not in skill_routing_text)
check(not unrouted_skills, f'skill-routing.md missing local skills: {unrouted_skills}')
unrouted_agents = sorted(agent for agent in agent_names if agent not in skill_routing_text)
check(not unrouted_agents, f'skill-routing.md missing local agents: {unrouted_agents}')
routing_agent_refs = {
    ref
    for ref in re.findall(r'`([A-Za-z0-9_-]+)`', skill_routing_text)
    if ref == 'task-orchestrator' or ref.endswith(('-implementer', '-reviewer', '-modeler'))
}
missing_routing_agent_refs = sorted(ref for ref in routing_agent_refs if ref not in agent_names)
check(not missing_routing_agent_refs, f'skill-routing.md references missing local agent: {missing_routing_agent_refs}')
for required in ['review-rubric', 'delivery-rubric', '판정', '잔여 위험']:
    check(required in skill_routing_text, f'skill-routing.md missing review/delivery routing token: {required}')

yaml_text = (root/'docs/harness/harness.yaml').read_text(encoding='utf-8')

def check_agent_ref(ref: str, source: str) -> None:
    check(ref in agent_names, f'harness.yaml {source} references missing agent: {ref}')
    check(ref in claude_names, f'harness.yaml {source} references missing Claude agent mirror: {ref}')

review_gates_match = re.search(r'^review_gates:\n(?P<body>.*?)(?:\n\nagent_orchestration:)', yaml_text, flags=re.S | re.M)
check(review_gates_match, 'missing review_gates manifest')
review_gate_refs = []
review_gate_keys = set()
current_review_gate = None
for raw_line in review_gates_match.group('body').splitlines():
    if re.match(r'^  [A-Za-z0-9_]+:\s*$', raw_line):
        current_review_gate = raw_line.strip()[:-1]
        review_gate_keys.add(current_review_gate)
        continue
    if raw_line.startswith('    - '):
        check(current_review_gate, f'review_gates list item without gate: {raw_line}')
        review_gate_refs.append((current_review_gate, raw_line.strip()[2:].strip()))
        continue
    check(not raw_line.strip(), f'unexpected review_gates manifest line: {raw_line}')
required_review_gates = {
    'backend_auth_or_security',
    'api_contract',
    'primary_frontend_ui',
    'secondary_app',
    'orchestration',
    'backend_domain_persistence_split',
    'final_quality',
}
check(review_gate_keys == required_review_gates, (
    f'review_gates keys mismatch: expected={sorted(required_review_gates)}, actual={sorted(review_gate_keys)}'
))
for gate, ref in review_gate_refs:
    check_agent_ref(ref, f'review_gates.{gate}')

agent_orchestration_match = re.search(r'^agent_orchestration:\n(?P<body>.*?)(?:\n\nparallel_agents:)', yaml_text, flags=re.S | re.M)
check(agent_orchestration_match, 'missing agent_orchestration manifest')
agent_orchestration_refs = {}
agent_orchestration_modes = []
backend_layer_order = []
in_modes = False
in_backend_layer_order = False
for raw_line in agent_orchestration_match.group('body').splitlines():
    stripped = raw_line.strip()
    if not stripped:
        continue
    if raw_line == '  modes:':
        in_modes = True
        in_backend_layer_order = False
        continue
    if raw_line == '  backend_layer_order:':
        in_modes = False
        in_backend_layer_order = True
        continue
    if in_modes and raw_line.startswith('    - '):
        agent_orchestration_modes.append(stripped[2:].strip())
        continue
    if in_backend_layer_order and raw_line.startswith('    - '):
        backend_layer_order.append(stripped[2:].strip())
        continue
    if (in_modes or in_backend_layer_order) and stripped and not raw_line.startswith('    '):
        in_modes = False
        in_backend_layer_order = False
    if raw_line.startswith('  ') and ': ' in stripped:
        key, value = stripped.split(': ', 1)
        agent_orchestration_refs[key] = value.strip()
required_agent_orchestration_refs = {
    'default_mode': 'SINGLE_AGENT',
    'orchestrator_agent': 'task-orchestrator',
    'orchestration_skill': 'orchestration-planning',
    'allow_single_agent_for_small_changes': 'true',
    'require_active_plan_for_split_delegation': 'true',
    'require_common_decisions_when_split': 'true',
    'require_single_integrator': 'true',
}
for key, expected in required_agent_orchestration_refs.items():
    actual = agent_orchestration_refs.get(key)
    check(actual == expected, f'agent_orchestration.{key} must be {expected}: {actual}')
check_agent_ref(agent_orchestration_refs['orchestrator_agent'], 'agent_orchestration.orchestrator_agent')
check(agent_orchestration_refs['orchestration_skill'] in skill_names, (
    f'agent_orchestration.orchestration_skill references missing skill: {agent_orchestration_refs["orchestration_skill"]}'
))
check(agent_orchestration_refs['orchestration_skill'] in claude_skill_dirs, (
    f'agent_orchestration.orchestration_skill references missing Claude skill mirror: {agent_orchestration_refs["orchestration_skill"]}'
))
expected_agent_orchestration_modes = [
    'SINGLE_AGENT',
    'SINGLE_AGENT_WITH_REVIEW',
    'SEQUENTIAL_LAYERED',
    'PARALLEL_INVESTIGATION',
    'PARALLEL_REVIEW',
    'PARALLEL_IMPLEMENT',
]
check(agent_orchestration_modes == expected_agent_orchestration_modes, (
    f'agent_orchestration.modes mismatch: expected={expected_agent_orchestration_modes}, actual={agent_orchestration_modes}'
))
check(backend_layer_order, 'missing agent_orchestration.backend_layer_order')
for ref in backend_layer_order:
    check_agent_ref(ref, 'agent_orchestration.backend_layer_order')

parallel_agents_match = re.search(r'^parallel_agents:\n(?P<body>.*?)(?:\n\norganization:)', yaml_text, flags=re.S | re.M)
check(parallel_agents_match, 'missing parallel_agents manifest')
parallel_agent_refs = {}
for raw_line in parallel_agents_match.group('body').splitlines():
    stripped = raw_line.strip()
    if not stripped:
        continue
    key, value = stripped.split(': ', 1)
    parallel_agent_refs[key] = value.strip()
required_parallel_agent_refs = {
    'default_mode': 'SEQUENTIAL',
    'prefer_parallel_review': 'true',
    'allow_parallel_implementation': 'conditional',
    'require_parallelization_check': 'true',
    'require_single_integration_coordinator': 'true',
    'forbid_overlapping_file_edits': 'true',
    'forbid_shared_transaction_boundary_edits': 'true',
    'forbid_shared_migration_schema_edits': 'true',
    'require_verify_after_fan_in': 'true',
    'allow_backend_domain_persistence_parallelism': 'conditional',
}
missing_parallel_keys = set(required_parallel_agent_refs) - set(parallel_agent_refs)
check(not missing_parallel_keys, f'missing parallel_agents keys: {sorted(missing_parallel_keys)}')
for key, expected in required_parallel_agent_refs.items():
    check(parallel_agent_refs.get(key) == expected, f'parallel_agents.{key} must be {expected}: {parallel_agent_refs.get(key)}')
parallel_gate_text = (root/'docs/harness/11_PARALLEL_AGENT_GATE.md').read_text(encoding='utf-8')
for required in ['기본값은 순차 실행', '같은 파일', '트랜잭션 경계', '마이그레이션/스키마', '단일 통합자', 'VERIFY']:
    check(required in parallel_gate_text, f'parallel gate doc missing safety token: {required}')
plan_template_text_for_parallel = (root/'docs/harness/plans/TEMPLATE.md').read_text(encoding='utf-8')
for required in ['## 병렬화 점검', '겹치는 파일 여부', '통합 담당자', '### 병렬 에이전트 디스패치', '### 수렴 결과']:
    check(required in plan_template_text_for_parallel, f'plan template missing parallel field: {required}')
evidence_gate_text = (root/'docs/harness/09_EVIDENCE_GATE.md').read_text(encoding='utf-8')
plans_readme_text = (root/'docs/harness/plans/README.md').read_text(encoding='utf-8')
check('- Plan State: `draft`' in plan_template_text_for_parallel, 'plan template must use Plan State for lifecycle status')
check('- Status: `draft`' not in plan_template_text_for_parallel, 'plan template must not use Status for lifecycle status')
for doc_name, doc_text in [
    ('docs/harness/09_EVIDENCE_GATE.md', evidence_gate_text),
    ('docs/harness/plans/README.md', plans_readme_text),
]:
    check('Metadata > Plan State' in doc_text, f'{doc_name} must use Plan State for plan lifecycle')
    check('Metadata > Status' not in doc_text, f'{doc_name} must not use Status for plan lifecycle')
    check('DONE_WITH_CONCERNS' in doc_text, f'{doc_name} must distinguish agent Status enum from plan lifecycle')

# harness.yaml source_of_truth.entry must not contain duplicate lines.
entry_match = re.search(r'source_of_truth:\n  entry:\n(?P<body>(?:    - .+\n)+)', yaml_text)
check(entry_match, 'missing source_of_truth.entry')
entries = [line.strip()[2:].strip() for line in entry_match.group('body').splitlines() if line.strip().startswith('- ')]
check(len(entries) == len(set(entries)), f'duplicate source_of_truth.entry: {entries}')
for ref in entries:
    check((root/ref).exists(), f'missing source_of_truth.entry path: {ref}')
required_entries = {
    'AGENTS.md',
    'CLAUDE.md',
    'docs/harness/context/BASELINE.md',
    'docs/harness/context/INDEX.md',
    'docs/harness/README.md',
    'docs/harness/QUICKSTART_5_MIN.md',
}
missing_entries = required_entries - set(entries)
check(not missing_entries, f'missing required source_of_truth.entry refs: {sorted(missing_entries)}')

harness_match = re.search(r'  harness:\n(?P<body>(?:    - .+\n)+)', yaml_text)
check(harness_match, 'missing source_of_truth.harness')
harness_refs = [line.strip()[2:].strip() for line in harness_match.group('body').splitlines() if line.strip().startswith('- ')]
check(len(harness_refs) == len(set(harness_refs)), f'duplicate source_of_truth.harness: {harness_refs}')
for ref in harness_refs:
    check((root/ref).exists(), f'missing source_of_truth.harness path: {ref}')
required_harness_refs = {
    'docs/harness/00_AGENT_BRIEF.md',
    'docs/harness/01_BACKEND.md',
    'docs/harness/02_PRIMARY_FRONTEND.md',
    'docs/harness/03_SECONDARY_APP.md',
    'docs/harness/04_INTEGRATION.md',
    'docs/harness/05_TESTING.md',
    'docs/harness/07_DESIGN_SYSTEM.md',
    'docs/harness/08_HARNESS_AUDIT.md',
    'docs/harness/09_EVIDENCE_GATE.md',
    'docs/harness/10_BACKEND_QUALITY_GATE.md',
    'docs/harness/11_PARALLEL_AGENT_GATE.md',
    'docs/harness/12_FIELD_VALIDATION.md',
    'docs/harness/13_AGENT_ORCHESTRATION.md',
    'docs/harness/ORG_ROLLOUT.md',
    'docs/harness/CI_EXAMPLES.md',
    'docs/harness/GOVERNANCE.md',
    'docs/harness/SECURITY_POLICY.md',
    'docs/harness/ADOPTION_SCORECARD.md',
    'docs/harness/rubrics/backend.md',
    'docs/harness/rubrics/frontend.md',
    'docs/harness/rubrics/integration.md',
    'docs/harness/rubrics/secondary-app.md',
    'docs/harness/profiles/project-profile.md',
    'docs/harness/profiles/design-system-profile.md',
}
missing_harness_refs = required_harness_refs - set(harness_refs)
check(not missing_harness_refs, f'missing required source_of_truth.harness refs: {sorted(missing_harness_refs)}')
required_rubric_tokens = {
    'backend.md': ['백엔드 리뷰 기준', 'DDD', '트랜잭션', '권한'],
    'frontend.md': ['주요 프론트엔드 리뷰 기준', 'i18n', '인라인 스타일', '반응형'],
    'integration.md': ['통합 리뷰 기준', '요청/응답', '인증', '페이지네이션'],
    'secondary-app.md': ['보조 앱 리뷰 기준', 'API 계약', 'UX와 접근성', '런타임'],
}
for filename, required_tokens in required_rubric_tokens.items():
    rubric_path = root/'docs/harness/rubrics'/filename
    check(str(rubric_path.relative_to(root)) in harness_refs, f'missing rubric source_of_truth ref: {rubric_path}')
    rubric_text = rubric_path.read_text(encoding='utf-8')
    for required in required_tokens:
        check(required in rubric_text, f'rubric {filename} missing review token: {required}')

workflow_match = re.search(r'^workflow:\n(?P<body>.*?)(?:\n\nrules:)', yaml_text, flags=re.S | re.M)
check(workflow_match, 'missing workflow manifest')
workflow_body = workflow_match.group('body')
workflow_steps = []
workflow_scalars = {}
in_default_steps = False
for raw_line in workflow_body.splitlines():
    stripped = raw_line.strip()
    if not stripped:
        continue
    if raw_line == '  default:':
        in_default_steps = True
        continue
    if in_default_steps and raw_line.startswith('    - '):
        workflow_steps.append(stripped[2:].strip())
        continue
    if in_default_steps and stripped and not raw_line.startswith('    '):
        in_default_steps = False
    if stripped.endswith(':'):
        continue
    key, value = stripped.split(': ', 1)
    workflow_scalars[key] = value.strip()
expected_workflow_steps = ['triage', 'plan', 'spec', 'red', 'green', 'refactor', 'verify', 'review', 'complete']
check(workflow_steps == expected_workflow_steps, (
    f'workflow.default mismatch: expected={expected_workflow_steps}, actual={workflow_steps}'
))
expected_workflow_scalars = {
    'trivial_allowed_without_plan': 'true',
    'non_trivial_requires_active_plan': 'true',
    'optional_project_gates': 'true',
    'project_readiness_gate': 'scripts/check-profile-readiness.sh',
    'final_integrity_target': 'make integrity',
    'gate_self_test': 'scripts/self-test-harness-gates.sh',
    'orchestration_default_mode': 'SINGLE_AGENT',
    'orchestration_requires_active_plan_when_split': 'true',
}
for key, expected in expected_workflow_scalars.items():
    check(workflow_scalars.get(key) == expected, f'workflow.{key} must be {expected}: {workflow_scalars.get(key)}')
for script_key in ['project_readiness_gate', 'gate_self_test']:
    script_ref = workflow_scalars[script_key]
    check((root/script_ref).exists(), f'missing workflow script path: {script_key} -> {script_ref}')
    check(os.access(root/script_ref, os.X_OK), f'workflow script must be executable: {script_key} -> {script_ref}')
final_target = workflow_scalars['final_integrity_target']
check(final_target.startswith('make '), f'workflow.final_integrity_target must be a make target: {final_target}')
final_target_name = final_target.split(' ', 1)[1]
check(re.search(rf'^{re.escape(final_target_name)}:', make_text, re.M), (
    f'workflow.final_integrity_target references missing Makefile target: {final_target}'
))

rules_match = re.search(r'^rules:\n(?P<body>.*?)(?:\n\nreview_gates:)', yaml_text, flags=re.S | re.M)
check(rules_match, 'missing rules manifest')
rules_body = rules_match.group('body')
rules_sections = {}
current_rule_section = None
expected_rules = {
    'tdd': {
        'require_red_before_product_edit': 'true',
        'require_green_before_refactor': 'true',
        'require_verify_before_done': 'true',
        'exception_requires_rationale': 'true',
    },
    'scope': {
        'edit_only_requested_files_or_direct_dependencies': 'true',
        'avoid_unrelated_refactor': 'true',
        'avoid_unrequested_library': 'true',
    },
    'frontend': {
        'require_i18n_for_visible_copy': 'true',
        'forbid_inline_style': 'true',
        'prefer_existing_style_tokens': 'true',
        'forbid_external_ui_library_without_approval': 'true',
    },
    'backend': {
        'keep_layer_boundary': 'true',
        'validate_resource_scoped_auth': 'true',
        'avoid_sensitive_response_leak': 'true',
        'require_ddd_boundary_review': 'true',
        'require_transaction_boundary_review': 'true',
        'require_oop_solid_review': 'true',
        'split_domain_and_persistence_agents': 'true',
    },
    'integration': {
        'review_api_auth_resource_pagination_changes': 'true',
    },
    'commits': {
        'require_explicit_user_request': 'true',
    },
}
for raw_line in rules_body.splitlines():
    stripped = raw_line.strip()
    if not stripped:
        continue
    if raw_line.startswith('  ') and not raw_line.startswith('    ') and stripped.endswith(':'):
        current_rule_section = stripped[:-1]
        if current_rule_section in expected_rules:
            rules_sections[current_rule_section] = {}
        continue
    if raw_line.startswith('    ') and current_rule_section in expected_rules and ': ' in stripped:
        key, value = stripped.split(': ', 1)
        rules_sections[current_rule_section][key] = value.strip()
for section, expected_values in expected_rules.items():
    check(section in rules_sections, f'missing rules.{section}')
    for key, expected in expected_values.items():
        actual = rules_sections[section].get(key)
        check(actual == expected, f'rules.{section}.{key} must be {expected}: {actual}')

context_rules_match = re.search(
    r'  context:\n(?P<body>(?:    [A-Za-z0-9_]+: .+\n?)+)',
    rules_body,
)
check(context_rules_match, 'missing rules.context manifest')
context_rules = {}
for line in context_rules_match.group('body').splitlines():
    key, value = line.strip().split(': ', 1)
    context_rules[key] = value.strip()
expected_context_rules = {
    'default_load_full_scan': 'false',
    'full_scan_is_generated_artifact': 'true',
    'prefer_baseline_and_recent_completed_plan': 'true',
    'generated_scan_dir': 'docs/harness/context/generated',
    'baseline': 'docs/harness/context/BASELINE.md',
    'decisions': 'docs/harness/context/DECISIONS.md',
}
missing_context_rule_keys = set(expected_context_rules) - set(context_rules)
check(not missing_context_rule_keys, (
    f'missing rules.context manifest keys: {sorted(missing_context_rule_keys)}'
))
for key, expected in expected_context_rules.items():
    actual = context_rules.get(key)
    check(actual == expected, f'rules.context.{key} must be {expected}: {actual}')
for key in ['generated_scan_dir', 'baseline', 'decisions']:
    ref = context_rules[key]
    check((root/ref).exists(), f'missing rules.context path: {key} -> {ref}')

context_index_text = (root/'docs/harness/context/INDEX.md').read_text(encoding='utf-8')
for required in ['전체 스캔', '기본 컨텍스트', 'generated/']:
    check(required in context_index_text, f'context INDEX missing context policy token: {required}')
context_readme_text = (root/'docs/harness/context/README.md').read_text(encoding='utf-8')
for required in ['전체 스캔', '기본 컨텍스트', 'generated/PROJECT_CONTEXT_SCAN.generated.md']:
    check(required in context_readme_text, f'context README missing context policy token: {required}')

testing_text = (root/'docs/harness/05_TESTING.md').read_text(encoding='utf-8')
for required in ['RED -> GREEN -> REFACTOR -> VERIFY', 'RED', 'GREEN', 'VERIFY', '예외 사유']:
    check(required in testing_text, f'testing doc missing rules token: {required}')
agent_brief_text = (root/'docs/harness/00_AGENT_BRIEF.md').read_text(encoding='utf-8')
for required in ['프로젝트별', '관련 없는', '컨텍스트', '검증']:
    check(required in agent_brief_text, f'agent brief missing rules token: {required}')
backend_text = (root/'docs/harness/01_BACKEND.md').read_text(encoding='utf-8')
for required in ['레이어', '권한', '트랜잭션', 'DDD']:
    check(required in backend_text, f'backend doc missing rules token: {required}')
frontend_text = (root/'docs/harness/02_PRIMARY_FRONTEND.md').read_text(encoding='utf-8')
for required in ['i18n', '인라인 스타일', '디자인', '접근성']:
    check(required in frontend_text, f'primary frontend doc missing rules token: {required}')

skill_policy = re.search(r'  skills:\n(?P<body>(?:    .+\n)+)', yaml_text)
check(skill_policy, 'missing source_of_truth.skills')
check('repo_source: .agents/skills' in skill_policy.group('body'), 'missing repo skill source policy')
check('claude_mirror: .claude/skills' in skill_policy.group('body'), 'missing claude skill mirror policy')
check('sync_script: scripts/sync-skills.sh' in skill_policy.group('body'), 'missing skill sync script policy')

state_match = re.search(r'  state:\n(?P<body>(?:    [A-Za-z0-9_]+: .+\n)+)', yaml_text)
check(state_match, 'missing source_of_truth.state')
state_refs = {}
for line in state_match.group('body').splitlines():
    key, value = line.strip().split(': ', 1)
    state_refs[key] = value.strip()
required_state_refs = {
    'active_plans': 'docs/harness/plans/active',
    'completed_plans': 'docs/harness/plans/completed',
    'current_context': 'docs/harness/context',
    'baseline': 'docs/harness/context/BASELINE.md',
    'decisions': 'docs/harness/context/DECISIONS.md',
    'context_index': 'docs/harness/context/INDEX.md',
    'generated_context': 'docs/harness/context/generated',
}
missing_state_keys = set(required_state_refs) - set(state_refs)
check(not missing_state_keys, f'missing source_of_truth.state keys: {sorted(missing_state_keys)}')
for key, ref in required_state_refs.items():
    check(state_refs.get(key) == ref, f'source_of_truth.state.{key} must be {ref}: {state_refs.get(key)}')
    check((root/ref).exists(), f'missing source_of_truth.state path: {key} -> {ref}')

project_gate_match = re.search(r'  project_gates:\n(?P<body>.*?)(?:\n\n  context:)', yaml_text, flags=re.S)
check(project_gate_match, 'missing project gate manifest')
project_gate_body = project_gate_match.group('body')
project_gate_scalars = {}
preferred_scripts = {}
legacy_commands = {}
current_project_gate_section = None
for raw_line in project_gate_body.splitlines():
    stripped = raw_line.strip()
    if not stripped:
        continue
    if raw_line.startswith('    ') and not raw_line.startswith('      ') and stripped.endswith(':'):
        current_project_gate_section = stripped[:-1]
        continue
    if raw_line.startswith('      ') and current_project_gate_section in {'preferred_scripts', 'legacy_commands'}:
        key, value = stripped.split(': ', 1)
        if current_project_gate_section == 'preferred_scripts':
            preferred_scripts[key] = value.strip()
        else:
            legacy_commands[key] = value.strip()
        continue
    current_project_gate_section = None
    key, value = stripped.split(': ', 1)
    project_gate_scalars[key] = value.strip()

expected_preferred_scripts = {
    'backend': 'HARNESS_BACKEND_TEST_SCRIPT',
    'primary_frontend': 'HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT',
    'secondary_app': 'HARNESS_SECONDARY_APP_TEST_SCRIPT',
    'integration': 'HARNESS_INTEGRATION_TEST_SCRIPT',
    'security': 'HARNESS_SECURITY_SCAN_SCRIPT',
    'accessibility': 'HARNESS_A11Y_CHECK_SCRIPT',
}
expected_legacy_commands = {
    'backend': 'HARNESS_BACKEND_TEST_CMD',
    'primary_frontend': 'HARNESS_PRIMARY_FRONTEND_TEST_CMD',
    'secondary_app': 'HARNESS_SECONDARY_APP_TEST_CMD',
    'integration': 'HARNESS_INTEGRATION_TEST_CMD',
    'security': 'HARNESS_SECURITY_SCAN_CMD',
    'accessibility': 'HARNESS_A11Y_CHECK_CMD',
}
expected_project_gate_scalars = {
    'enabled_by_env': 'HARNESS_RUN_PROJECT_CHECKS',
    'profile_readiness_enabled_by_env': 'HARNESS_REQUIRE_FILLED_PROFILE',
    'profile_readiness_script': 'scripts/check-profile-readiness.sh',
    'script': 'scripts/verify-project-gates.sh',
    'org_standard_requires_ack': 'HARNESS_ACK_TRUSTED_PROJECT_CMDS',
    'legacy_bash_lc_opt_in': 'HARNESS_ALLOW_LEGACY_BASH_LC',
}
for key, expected in expected_project_gate_scalars.items():
    check(project_gate_scalars.get(key) == expected, (
        f'rules.project_gates.{key} must be {expected}: {project_gate_scalars.get(key)}'
    ))
    if key.endswith('script'):
        check((root/expected).exists(), f'missing rules.project_gates script path: {expected}')
check(preferred_scripts == expected_preferred_scripts, (
    f'rules.project_gates.preferred_scripts mismatch: expected={expected_preferred_scripts}, actual={preferred_scripts}'
))
check(legacy_commands == expected_legacy_commands, (
    f'rules.project_gates.legacy_commands mismatch: expected={expected_legacy_commands}, actual={legacy_commands}'
))
project_gate_text_for_manifest = (root/project_gate_scalars['script']).read_text(encoding='utf-8')
actual_run_gates = {
    name: (script_var, cmd_var)
    for name, script_var, cmd_var in re.findall(
        r'run_gate "([^"]+)" "\$\{([A-Z0-9_]+):-\}" "\$\{([A-Z0-9_]+):-\}"',
        project_gate_text_for_manifest,
    )
}
expected_run_gates = {
    'backend': ('HARNESS_BACKEND_TEST_SCRIPT', 'HARNESS_BACKEND_TEST_CMD'),
    'primary-frontend': ('HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT', 'HARNESS_PRIMARY_FRONTEND_TEST_CMD'),
    'secondary-app': ('HARNESS_SECONDARY_APP_TEST_SCRIPT', 'HARNESS_SECONDARY_APP_TEST_CMD'),
    'integration': ('HARNESS_INTEGRATION_TEST_SCRIPT', 'HARNESS_INTEGRATION_TEST_CMD'),
    'security': ('HARNESS_SECURITY_SCAN_SCRIPT', 'HARNESS_SECURITY_SCAN_CMD'),
    'accessibility': ('HARNESS_A11Y_CHECK_SCRIPT', 'HARNESS_A11Y_CHECK_CMD'),
}
check(actual_run_gates == expected_run_gates, (
    f'project gate run_gate matrix mismatch: expected={expected_run_gates}, actual={actual_run_gates}'
))

print('[OK] reviewer safety verified')
print('[OK] codex/claude agent mirrors verified')
print('[OK] claude commands verified')
print(f'[OK] leakage scope verified: {mode}')
print('[OK] placeholder references verified')
print('[OK] routing references verified')
print('[OK] source_of_truth entries verified')
# Agent orchestration policy validation.
orchestration_doc = root/'docs/harness/13_AGENT_ORCHESTRATION.md'
check(orchestration_doc.exists(), 'missing docs/harness/13_AGENT_ORCHESTRATION.md')
orchestration_text = orchestration_doc.read_text(encoding='utf-8')
for required in ['SINGLE_AGENT', 'SINGLE_AGENT_WITH_REVIEW', 'SEQUENTIAL_LAYERED', 'PARALLEL_REVIEW', '단일 통합자', '레이어별 에이전트는', 'task-orchestrator', 'fan-in', '큰 작업 감지 신호']:
    check(required in orchestration_text, f'missing orchestration keyword: {required}')
check('task-orchestrator' in agent_names, 'missing task-orchestrator codex agent')
check((root/'.claude/agents/task-orchestrator.md').exists(), 'missing task-orchestrator claude agent')
for required_skill in ['orchestration-planning', 'backend-domain', 'backend-api', 'backend-db-migration']:
    check(required_skill in skill_names, f'missing required skill: {required_skill}')
    check(required_skill in claude_skill_dirs, f'missing required Claude skill mirror: {required_skill}')

plan_template_text = (root/'docs/harness/plans/TEMPLATE.md').read_text(encoding='utf-8')
check('## 에이전트 오케스트레이션' in plan_template_text, 'plan template must include agent orchestration block')
for required in ['Orchestration', 'task-orchestrator', '수정 범위 이탈 확인']:
    check(required in plan_template_text, f'plan template missing orchestration field: {required}')

plan_cmd_text = (root/'.claude/commands/plan.md').read_text(encoding='utf-8')
for required in ['오케스트레이션 모드', 'task-orchestrator', '레이어 영향도', '통합 담당자']:
    check(required in plan_cmd_text, f'/plan command missing orchestration requirement: {required}')

executor_text = (root/'.agents/skills/executor/SKILL.md').read_text(encoding='utf-8')
for required in ['13_AGENT_ORCHESTRATION.md', 'task-orchestrator', '에이전트 오케스트레이션']:
    check(required in executor_text, f'executor skill missing orchestration requirement: {required}')

check('agent_orchestration:' in yaml_text, 'harness.yaml missing agent_orchestration section')
for required in ['orchestrator_agent: task-orchestrator', 'orchestration_skill: orchestration-planning']:
    check(required in yaml_text, f'harness.yaml missing orchestration policy: {required}')
check('13_AGENT_ORCHESTRATION.md' in (root/'AGENTS.md').read_text(encoding='utf-8'), 'AGENTS.md must route orchestration decisions')
check('task-orchestrator' in (root/'AGENTS.md').read_text(encoding='utf-8'), 'AGENTS.md must name task-orchestrator')
check('13_AGENT_ORCHESTRATION.md' in (root/'CLAUDE.md').read_text(encoding='utf-8'), 'CLAUDE.md must route orchestration decisions')
check('task-orchestrator' in (root/'CLAUDE.md').read_text(encoding='utf-8'), 'CLAUDE.md must name task-orchestrator')

# Owned API contract impact policy validation.
integration_text = (root/'docs/harness/04_INTEGRATION.md').read_text(encoding='utf-8')
for required in ['Owned API Contract Impact Rule', '프론트엔드에서 API DTO', '백엔드에서 API 요청/응답', '프론트 호출부 검색어']:
    check(required in integration_text or required in (root/'docs/harness/plans/TEMPLATE.md').read_text(encoding='utf-8'), f'missing owned API contract impact rule: {required}')

integration_skill_text = (root/'.agents/skills/integration-contract/SKILL.md').read_text(encoding='utf-8')
for required in ['Owned API Contract Impact Rule', 'endpoint path', 'query key', 'hook/composable']:
    check(required in integration_skill_text, f'integration-contract skill missing owned API check: {required}')

plan_text = (root/'docs/harness/plans/TEMPLATE.md').read_text(encoding='utf-8')
for required in ['## API 계약 영향도', '우리 백엔드 API 여부', '확인한 backend 파일/문서', '확인한 frontend 파일/검색 범위', '프론트 호출부 검색어']:
    check(required in plan_text, f'plan template missing API impact field: {required}')

for doc in ['docs/harness/01_BACKEND.md', 'docs/harness/02_PRIMARY_FRONTEND.md', 'docs/harness/03_SECONDARY_APP.md', 'docs/harness/13_AGENT_ORCHESTRATION.md', 'docs/harness/skill-routing.md']:
    text = (root/doc).read_text(encoding='utf-8')
    check('Owned API' in text or 'API 계약 영향도' in text, f'{doc} missing owned API contract impact routing')

owned_api_match = re.search(
    r'^owned_api_contract_impact:\n(?P<body>(?:  [A-Za-z0-9_]+: .+\n?)+)',
    yaml_text,
    flags=re.M,
)
check(owned_api_match, 'missing owned_api_contract_impact manifest')
owned_api_refs = {}
for line in owned_api_match.group('body').splitlines():
    key, value = line.strip().split(': ', 1)
    owned_api_refs[key] = value.strip()
required_owned_api_refs = {
    'policy_doc': 'docs/harness/04_INTEGRATION.md',
    'required_plan_block': 'API 계약 영향도',
    'router_agent': 'task-orchestrator',
    'router_skill': 'integration-contract',
    'frontend_to_backend_check': 'true',
    'backend_to_frontend_search': 'true',
}
missing_owned_api_keys = set(required_owned_api_refs) - set(owned_api_refs)
check(not missing_owned_api_keys, f'missing owned_api_contract_impact keys: {sorted(missing_owned_api_keys)}')
for key, expected in required_owned_api_refs.items():
    check(owned_api_refs.get(key) == expected, (
        f'owned_api_contract_impact.{key} must be {expected}: {owned_api_refs.get(key)}'
    ))
policy_doc = root/owned_api_refs['policy_doc']
check(policy_doc.exists(), f'missing owned_api_contract_impact policy_doc: {owned_api_refs["policy_doc"]}')
check(f'## {owned_api_refs["required_plan_block"]}' in plan_text, (
    f'plan template missing owned API block: {owned_api_refs["required_plan_block"]}'
))
check_agent_ref(owned_api_refs['router_agent'], 'owned_api_contract_impact.router_agent')
check(owned_api_refs['router_skill'] in skill_names, (
    f'owned_api_contract_impact.router_skill references missing skill: {owned_api_refs["router_skill"]}'
))
check(owned_api_refs['router_skill'] in claude_skill_dirs, (
    f'owned_api_contract_impact.router_skill references missing Claude skill mirror: {owned_api_refs["router_skill"]}'
))

print('[OK] agent orchestration policy verified')
print('[OK] owned API contract impact policy verified')

# Organization standard polish validation.
organization_match = re.search(
    r'^organization:\n(?P<body>.*?)(?:\n\nruntime:)',
    yaml_text,
    flags=re.S | re.M,
)
check(organization_match, 'missing organization manifest')
organization_body = organization_match.group('body')
organization_refs = {}
organization_eval_scripts = []
current_list = None
for raw_line in organization_body.splitlines():
    stripped = raw_line.strip()
    if not stripped:
        continue
    if stripped.endswith(':') and not stripped.startswith('- '):
        current_list = stripped[:-1]
        organization_refs[current_list] = []
        continue
    if stripped.startswith('- '):
        check(current_list == 'eval_scripts', f'unexpected organization list item: {stripped}')
        organization_eval_scripts.append(stripped[2:].strip())
        continue
    current_list = None
    key, value = stripped.split(': ', 1)
    organization_refs[key] = value.strip()

required_organization_refs = {
    'rollout_guide': 'docs/harness/ORG_ROLLOUT.md',
    'ci_examples': 'docs/harness/CI_EXAMPLES.md',
    'governance': 'docs/harness/GOVERNANCE.md',
    'security_policy': 'docs/harness/SECURITY_POLICY.md',
    'adoption_scorecard': 'docs/harness/ADOPTION_SCORECARD.md',
}
for key, ref in required_organization_refs.items():
    check(organization_refs.get(key) == ref, f'organization.{key} must be {ref}: {organization_refs.get(key)}')
    check((root/ref).exists(), f'missing organization manifest path: {key} -> {ref}')
check(organization_refs.get('org_standard_flag') == 'HARNESS_ORG_STANDARD', (
    f"organization.org_standard_flag must be HARNESS_ORG_STANDARD: {organization_refs.get('org_standard_flag')}"
))
required_eval_scripts = {
    'scripts/collect-eval-metrics.sh',
    'scripts/check-completed-plan-quality.sh',
}
check(set(organization_eval_scripts) == required_eval_scripts, (
    f'organization.eval_scripts mismatch: expected={sorted(required_eval_scripts)}, actual={sorted(organization_eval_scripts)}'
))
for ref in organization_eval_scripts:
    script_path = root/ref
    check(script_path.exists(), f'missing organization eval script: {ref}')
    check(os.access(script_path, os.X_OK), f'organization eval script must be executable: {ref}')

ci_example_path = root/'docs/harness/examples/github-actions/harness-verify.yml'
check(ci_example_path.exists(), f'missing GitHub Actions example: {ci_example_path}')
ci_example = ci_example_path.read_text(encoding='utf-8')
check('HARNESS_VERIFY_MODE=project \\' in ci_example, 'CI example should use readable multiline env assignment')
org_text = (root/'docs/harness/ORG_ROLLOUT.md').read_text(encoding='utf-8')
for required in ['Project gate 명령 실행 정책', '신뢰된 CI', 'HARNESS_*_CMD', 'symlink']:
    check(required in org_text, f'ORG_ROLLOUT missing project gate trust policy: {required}')
vpg_text = (root/'scripts/verify-project-gates.sh').read_text(encoding='utf-8')
for required in ['SECURITY POLICY', 'HARNESS_ACK_TRUSTED_PROJECT_CMDS', 'bash -lc', 'no symlink escapes']:
    check(required in vpg_text, f'verify-project-gates missing trust policy: {required}')
for required in ['orchestration mode별 성공률', 'reviewer FAIL 사유 TOP 5', 'project gate 실패율']:
    check(required in (root/'docs/harness/evals/metrics.md').read_text(encoding='utf-8'), f'eval metrics missing: {required}')
for example in ['spring-boot-rest.md', 'node-nestjs.md']:
    check((root/'docs/harness/profiles/examples'/example).exists(), f'missing backend profile example: {example}')
for example in ['react-next.md', 'vue-vite.md', 'frontend-testing.md']:
    check((root/'docs/harness/profiles/examples'/example).exists(), f'missing frontend profile example: {example}')

react_next_text = (root/'docs/harness/profiles/examples/react-next.md').read_text(encoding='utf-8')
for token in ['Next.js Server / Client Component 기준', 'TanStack Query / React Query 기준', 'Storybook', 'Playwright', 'Owned API']:
    check(token in react_next_text, f'react-next profile missing framework-specific guidance: {token}')

vue_vite_text = (root/'docs/harness/profiles/examples/vue-vite.md').read_text(encoding='utf-8')
for token in ['Composition API 기준', 'Pinia / Store 기준', 'Router / Auth / Resource Scope 기준', 'Storybook/Histoire', 'Owned API']:
    check(token in vue_vite_text, f'vue-vite profile missing framework-specific guidance: {token}')

frontend_testing_text = (root/'docs/harness/profiles/examples/frontend-testing.md').read_text(encoding='utf-8')
for token in ['Test Pyramid 기준', 'Playwright 기준', 'Storybook / Visual Regression 기준', 'Testing Library / Component Test 기준', 'owned API fixture/mock 변경']:
    check(token in frontend_testing_text, f'frontend-testing profile missing specific test guidance: {token}')

for doc in [root/'AGENTS.md', root/'CLAUDE.md']:
    doc_text = doc.read_text(encoding='utf-8')
    check('HARNESS_*_SCRIPT' in doc_text, f'{doc} must prefer script-based project gates')
    check('HARNESS_ALLOW_LEGACY_BASH_LC' in doc_text, f'{doc} must document legacy command opt-in')
    forbidden = [
        'HARNESS_*_CMD 환경변수를 설정해',
        'HARNESS_*_CMD 환경변수로 project gate를 실행한다',
    ]
    for phrase in forbidden:
        check(phrase not in doc_text, f'{doc} still presents legacy command gate as primary: {phrase}')

# Organization governance and safer project gate policy validation.
org_docs = [root/'docs/harness/GOVERNANCE.md', root/'docs/harness/SECURITY_POLICY.md', root/'docs/harness/ADOPTION_SCORECARD.md']
for doc in org_docs:
    text = doc.read_text(encoding='utf-8')
    check('HARNESS_ACK_TRUSTED_PROJECT_CMDS' in text or doc.name == 'ADOPTION_SCORECARD.md', f'missing org ACK policy: {doc}')
    check('HARNESS_*_SCRIPT' in text or doc.name == 'ADOPTION_SCORECARD.md', f'missing script gate policy: {doc}')
governance_text = (root/'docs/harness/GOVERNANCE.md').read_text(encoding='utf-8')
scorecard_text = (root/'docs/harness/ADOPTION_SCORECARD.md').read_text(encoding='utf-8')
plans_readme_text = (root/'docs/harness/plans/README.md').read_text(encoding='utf-8')
for token in ['make integrity', 'make project-ready', 'HARNESS_ORG_STANDARD=1']:
    check(token in governance_text, f'GOVERNANCE missing integrity rollout token: {token}')
for token in ['make integrity', 'make project-ready', '최종 무결성']:
    check(token in scorecard_text, f'ADOPTION_SCORECARD missing integrity score token: {token}')
for token in ['make integrity', '범용 template package', '완료 기록을 누적']:
    check(token in plans_readme_text, f'plans README missing lifecycle integrity token: {token}')
check('project mode' in plans_readme_text, 'plans README must distinguish project mode completed plan accumulation')
verifier_text = (root/'scripts/verify-harness-structure.sh').read_text(encoding='utf-8')
check("if mode == 'template':\n    tracked_plan_markdown = subprocess.run" in verifier_text, 'tracked plan markdown guard must be template-mode only')

project_gate_text = (root/'scripts/verify-project-gates.sh').read_text(encoding='utf-8')
check('HARNESS_*_SCRIPT' in project_gate_text, 'project gate must support script-based gates')
check('HARNESS_ALLOW_LEGACY_BASH_LC' in project_gate_text, 'legacy bash -lc must require explicit opt-in')
check('HARNESS_*_CMD is legacy; prefer HARNESS_*_SCRIPT or set HARNESS_ALLOW_LEGACY_BASH_LC=1' in project_gate_text, 'legacy bash -lc opt-in must apply outside organization mode too')
check('HARNESS_ALLOW_ANY_REPO_SCRIPT' not in project_gate_text, 'project gate must not expose hidden allow-any repo script bypass')
check('resolve_repo_script' in project_gate_text, 'project gate must validate repository script path')
check('RESOLVED_SCRIPT' in project_gate_text, 'project gate must avoid unsafe command-substitution resolution')
check('reject()' in project_gate_text, 'project gate must return explicit validation failures')
check('reject_symlink_components' in project_gate_text, 'project gate must reject symlink path components')
check('script gate path component must not be a symlink' in project_gate_text, 'project gate must explain symlink path component rejection')
check('bash -lc "$cmd"' in project_gate_text, 'legacy command path should be explicit and auditable')

# Negative policy tests: invalid script gates must return non-zero so CI can enforce policy.
invalid_gate_cases = [
    ('/tmp/nope.sh', 'absolute path'),
    ('../hack.sh', 'parent traversal'),
    ('foo;bar.sh', 'shell metacharacter'),
    ('scripts/ci/nope.sh', 'missing script'),
]
for bad_value, label in invalid_gate_cases:
    env = os.environ.copy()
    env.update({
        'HARNESS_ORG_STANDARD': '1',
        'HARNESS_ACK_TRUSTED_PROJECT_CMDS': '1',
        'HARNESS_BACKEND_TEST_SCRIPT': bad_value,
    })
    result = subprocess.run(
        ['bash', 'scripts/verify-project-gates.sh'],
        cwd=root,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    check(result.returncode != 0, f'invalid project gate should fail ({label}): {bad_value}')

ci_text = ci_example_path.read_text(encoding='utf-8')
check('make integrity' in ci_text, 'CI example must run make integrity before organization gates')
check('HARNESS_ACK_TRUSTED_PROJECT_CMDS=1' in ci_text, 'CI example must include trusted gate ACK')
check('HARNESS_BACKEND_TEST_SCRIPT' in ci_text, 'CI example must prefer script-based backend gate')
check('HARNESS_BACKEND_TEST_CMD' not in ci_text, 'CI example should not use legacy command gate')

ci_examples_text = (root/'docs/harness/CI_EXAMPLES.md').read_text(encoding='utf-8')
for token in ['make integrity', 'HARNESS_*_SCRIPT', 'HARNESS_ALLOW_LEGACY_BASH_LC', 'HARNESS_ACK_TRUSTED_PROJECT_CMDS=1']:
    check(token in ci_examples_text, f'CI examples missing {token}')
for doc in [root/'README.md', root/'docs/harness/SECURITY_POLICY.md', root/'docs/harness/CI_EXAMPLES.md']:
    check('symlink' in doc.read_text(encoding='utf-8'), f'{doc} missing project gate symlink policy')

metrics_text = (root/'docs/harness/evals/metrics.md').read_text(encoding='utf-8')
for token in ['작업 유형별 성공률', 'agent별 재작업률', 'reviewer별 또는 사유별 FAIL TOP N', 'project gate 실패율 추이', 'fan-in 충돌 발생률', 'regression case 반영률', 'orchestration mode별 성공률/실패율/평균 소요 시간']:
    check(token in metrics_text, f'eval metrics missing {token}')

collect_eval_text = (root/'scripts/collect-eval-metrics.sh').read_text(encoding='utf-8')
for token in ['HARNESS_COMPLETED_PLAN_DIR', 'Task type success rate', 'Agent rework rate', 'Reviewer FAIL reasons TOP 10', 'Project gate failure trend', 'Fan-in conflict rate', 'Regression case capture rate', 'Orchestration mode success/failure/duration']:
    check(token in collect_eval_text, f'eval collector missing {token}')

print('[OK] governance and project gate policy verified')

print('[OK] organization standard polish verified')

PY

if [[ "${HARNESS_REQUIRE_FILLED_PROFILE:-0}" == "1" ]]; then
  if [[ "$VERIFY_MODE" != "project" ]]; then
    echo "[FAIL] HARNESS_REQUIRE_FILLED_PROFILE=1 requires HARNESS_VERIFY_MODE=project" >&2
    exit 1
  fi
  bash scripts/check-profile-readiness.sh
fi

echo "[OK] harness structure verified ($VERIFY_MODE)"


if [[ "${HARNESS_ORG_STANDARD:-0}" == "1" ]]; then
  export HARNESS_RUN_PROJECT_CHECKS=1
  export HARNESS_REQUIRE_PROJECT_CHECKS=1
  bash scripts/verify-project-gates.sh
  echo "[OK] project gates checked"
  bash scripts/check-completed-plan-quality.sh
  echo "[OK] completed plan quality checked"
elif [[ "${HARNESS_RUN_PROJECT_CHECKS:-0}" == "1" ]]; then
  bash scripts/verify-project-gates.sh
  echo "[OK] project gates checked"
fi
