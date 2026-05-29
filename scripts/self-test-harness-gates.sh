#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

tmp_dir="$(python3 - <<'PY'
import tempfile
print(tempfile.mkdtemp(prefix='harness-gate-self-test-'))
PY
)"
created_ci_dir=0
harness_yaml_backup=""
cleanup() {
  if [[ -n "$harness_yaml_backup" && -f "$harness_yaml_backup" ]]; then
    cp "$harness_yaml_backup" docs/harness/harness.yaml
  fi
  rm -rf "$tmp_dir"
  rm -f scripts/ci/.harness-self-test-ok.sh
  rm -f .env.harness-self-test
  rm -f session-token.json
  rm -f api-secret.properties
  rm -f docs/harness/context/generated/token-policy.md
  rm -f scripts/.harness-self-test-outside.sh
  rm -f docs/harness/plans/completed/.harness-self-test-tracked.md
  if [[ "$created_ci_dir" == "1" ]]; then
    rmdir scripts/ci 2>/dev/null || true
  fi
}
trap cleanup EXIT
output_file="$tmp_dir/output.log"

pass_count=0

pass() {
  echo "[OK] $*"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

expect_pass() {
  local name="$1"
  shift
  if "$@" >"$output_file" 2>&1; then
    pass "$name"
  else
    sed -n '1,80p' "$output_file" >&2
    fail "$name should pass"
  fi
}

expect_fail() {
  local name="$1"
  shift
  if "$@" >"$output_file" 2>&1; then
    sed -n '1,80p' "$output_file" >&2
    fail "$name should fail"
  fi
  pass "$name"
}

with_harness_yaml_without_line() {
  local needle="$1"
  shift
  harness_yaml_backup="$tmp_dir/harness.yaml.backup"
  cp docs/harness/harness.yaml "$harness_yaml_backup"
  python3 - "$needle" <<'PY'
from pathlib import Path
import sys

needle = sys.argv[1]
path = Path('docs/harness/harness.yaml')
lines = path.read_text(encoding='utf-8').splitlines()
filtered = [line for line in lines if line.strip() != needle]
if len(filtered) == len(lines):
    raise SystemExit(f'missing test needle in harness.yaml: {needle}')
path.write_text('\n'.join(filtered) + '\n', encoding='utf-8')
PY
  local status=0
  set +e
  "$@"
  status=$?
  set -e
  cp "$harness_yaml_backup" docs/harness/harness.yaml
  harness_yaml_backup=""
  return "$status"
}

with_harness_yaml_insert_after_line() {
  local needle="$1"
  local insertion="$2"
  shift 2
  harness_yaml_backup="$tmp_dir/harness.yaml.backup"
  cp docs/harness/harness.yaml "$harness_yaml_backup"
  python3 - "$needle" "$insertion" <<'PY'
from pathlib import Path
import sys

needle = sys.argv[1]
insertion = sys.argv[2]
path = Path('docs/harness/harness.yaml')
lines = path.read_text(encoding='utf-8').splitlines()
for index, line in enumerate(lines):
    if line == needle:
        lines.insert(index + 1, insertion)
        path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
        break
else:
    raise SystemExit(f'missing test needle in harness.yaml: {needle}')
PY
  local status=0
  set +e
  "$@"
  status=$?
  set -e
  cp "$harness_yaml_backup" docs/harness/harness.yaml
  harness_yaml_backup=""
  return "$status"
}

with_file_without_line() {
  local path="$1"
  local needle="$2"
  shift 2
  local backup="$tmp_dir/$(basename "$path").backup"
  cp "$path" "$backup"
  python3 - "$path" "$needle" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
needle = sys.argv[2]
lines = path.read_text(encoding='utf-8').splitlines()
filtered = [line for line in lines if line.strip() != needle]
if len(filtered) == len(lines):
    raise SystemExit(f'missing test needle in {path}: {needle}')
path.write_text('\n'.join(filtered) + '\n', encoding='utf-8')
PY
  local status=0
  set +e
  "$@"
  status=$?
  set -e
  cp "$backup" "$path"
  return "$status"
}

good_profile="$tmp_dir/good-profile.md"
bad_profile="$tmp_dir/bad-profile.md"
printf 'project: N/A\nruntime: N/A\n' > "$good_profile"
printf 'project: <fill-project>\n' > "$bad_profile"

expect_pass "profile readiness accepts filled profile" \
  bash scripts/check-profile-readiness.sh "$good_profile"

expect_fail "profile readiness rejects placeholder" \
  bash scripts/check-profile-readiness.sh "$bad_profile"

expect_fail "verify rejects invalid mode" \
  env HARNESS_VERIFY_MODE=invalid bash scripts/verify-harness-structure.sh

expect_fail "filled-profile gate requires project mode" \
  env HARNESS_REQUIRE_FILLED_PROFILE=1 HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

printf 'PLACEHOLDER_ONLY=1\n' > .env.harness-self-test
expect_fail "sensitive artifact rejects local env file" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh
rm -f .env.harness-self-test

printf '{"placeholder": true}\n' > session-token.json
expect_fail "sensitive artifact rejects token config file" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh
rm -f session-token.json

printf 'placeholder=true\n' > api-secret.properties
expect_fail "sensitive artifact rejects secret properties file" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh
rm -f api-secret.properties

mkdir -p docs/harness/context/generated
printf '# Token policy placeholder\n' > docs/harness/context/generated/token-policy.md
expect_pass "token policy markdown remains allowed" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh
rm -f docs/harness/context/generated/token-policy.md

printf '# Harness self-test tracked completed plan\n\nRED GREEN REFACTOR VERIFY\n잔여 위험: self-test only\n' > docs/harness/plans/completed/.harness-self-test-tracked.md
GIT_INDEX_FILE="$tmp_dir/git-index" git read-tree HEAD
GIT_INDEX_FILE="$tmp_dir/git-index" git update-index --add docs/harness/plans/completed/.harness-self-test-tracked.md

expect_fail "template rejects tracked completed plan" \
  env GIT_INDEX_FILE="$tmp_dir/git-index" HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_pass "project allows tracked completed plan" \
  env GIT_INDEX_FILE="$tmp_dir/git-index" HARNESS_VERIFY_MODE=project bash scripts/verify-harness-structure.sh

rm -f docs/harness/plans/completed/.harness-self-test-tracked.md

expect_fail "source_of_truth rejects missing required entry" \
  with_harness_yaml_without_line "- CLAUDE.md" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "source_of_truth rejects missing required state" \
  with_harness_yaml_without_line "decisions: docs/harness/context/DECISIONS.md" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "source_of_truth rejects missing backend rubric" \
  with_harness_yaml_without_line "- docs/harness/rubrics/backend.md" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "organization manifest rejects missing governance" \
  with_harness_yaml_without_line "governance: docs/harness/GOVERNANCE.md" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "review_gates reject missing agent" \
  with_harness_yaml_insert_after_line "  final_quality:" "    - missing-reviewer" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "owned API manifest rejects missing router skill" \
  with_harness_yaml_without_line "router_skill: integration-contract" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime manifest rejects missing override env" \
  with_harness_yaml_without_line "codex_model_override_env: HARNESS_EXPECTED_CODEX_MODEL" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing OS support manifest" \
  with_harness_yaml_without_line "supported_os: macos_linux_wsl_posix_shell" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing git required tool" \
  with_harness_yaml_without_line "required_tools: bash make python3 git" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing POSIX utility manifest" \
  with_harness_yaml_without_line "posix_utilities: find cp rm mkdir chmod rmdir sed env uname head" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing Python TOML parser manifest" \
  with_harness_yaml_without_line "toml_parser: tomllib_or_tomli" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "agent metadata rejects missing Codex skills preload" \
  with_file_without_line ".codex/agents/backend-api-implementer.toml" \
    'skills = ["backend-api", "backend-application", "integration-contract", "testing-strategy"]' \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "project gate manifest rejects missing preferred script" \
  with_harness_yaml_without_line "backend: HARNESS_BACKEND_TEST_SCRIPT" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "workflow manifest rejects missing integrity target" \
  with_harness_yaml_without_line "final_integrity_target: make integrity" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "parallel manifest rejects overlapping file edits" \
  with_harness_yaml_without_line "forbid_overlapping_file_edits: true" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "rules manifest rejects unrelated refactor removal" \
  with_harness_yaml_without_line "avoid_unrelated_refactor: true" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "agent orchestration rejects missing single integrator" \
  with_harness_yaml_without_line "require_single_integrator: true" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "context rules reject full scan default removal" \
  with_harness_yaml_without_line "default_load_full_scan: false" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "project gate rejects absolute script path" \
  env HARNESS_ORG_STANDARD=1 \
      HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 \
      HARNESS_BACKEND_TEST_SCRIPT=/tmp/not-allowed.sh \
      bash scripts/verify-project-gates.sh

printf '#!/usr/bin/env bash\nset -euo pipefail\necho "[OK] outside project gate"\n' > scripts/.harness-self-test-outside.sh
chmod +x scripts/.harness-self-test-outside.sh

expect_fail "project gate rejects non-allowlisted repo script" \
  env HARNESS_BACKEND_TEST_SCRIPT=scripts/.harness-self-test-outside.sh \
      bash scripts/verify-project-gates.sh

rm -f scripts/.harness-self-test-outside.sh

if [[ ! -d scripts/ci ]]; then
  mkdir -p scripts/ci
  created_ci_dir=1
fi
printf '#!/usr/bin/env bash\nset -euo pipefail\necho "[OK] self-test project gate"\n' > scripts/ci/.harness-self-test-ok.sh
chmod +x scripts/ci/.harness-self-test-ok.sh

expect_pass "project gate accepts allowlisted executable script" \
  env HARNESS_RUN_PROJECT_CHECKS=1 \
      HARNESS_BACKEND_TEST_SCRIPT=scripts/ci/.harness-self-test-ok.sh \
      bash scripts/verify-project-gates.sh

expect_fail "required project gates reject empty configuration" \
  env HARNESS_RUN_PROJECT_CHECKS=1 \
      HARNESS_REQUIRE_PROJECT_CHECKS=1 \
      bash scripts/verify-project-gates.sh

expect_fail "organization mode blocks legacy command without explicit opt-in" \
  env HARNESS_ORG_STANDARD=1 \
      HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 \
      HARNESS_BACKEND_TEST_CMD='echo legacy' \
      bash scripts/verify-project-gates.sh

echo "[OK] harness gate self-tests passed: $pass_count"
