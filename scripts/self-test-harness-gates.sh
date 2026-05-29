#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

tmp_dir="$(python3 - <<'PY'
import tempfile
print(tempfile.mkdtemp(prefix='harness-gate-self-test-'))
PY
)"
trap 'rm -rf "$tmp_dir"' EXIT
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

expect_fail "project gate rejects absolute script path" \
  env HARNESS_ORG_STANDARD=1 \
      HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 \
      HARNESS_BACKEND_TEST_SCRIPT=/tmp/not-allowed.sh \
      bash scripts/verify-project-gates.sh

echo "[OK] harness gate self-tests passed: $pass_count"
