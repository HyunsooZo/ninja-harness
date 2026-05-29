#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# SECURITY POLICY
# Organization mode prefers HARNESS_*_SCRIPT variables that point to executable
# repository scripts. HARNESS_*_CMD is legacy and executes through `bash -lc`;
# it is blocked in organization mode unless explicitly acknowledged and allowed.
# Never connect PR/issue/user-provided text to either gate variable.
#
# Script gates are intentionally script-first and allowlist-based:
# - allowed relative roots: scripts/ci/**, .github/scripts/**, ci/**
# - no absolute paths
# - no parent traversal
# - no shell metacharacters
# - no symlink escapes
# - target must exist and be executable

ran_any=0
RESOLVED_SCRIPT=""

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

reject() {
  echo "[FAIL] $*" >&2
  return 2
}

is_blank() {
  [[ -z "${1// }" ]]
}

resolve_repo_script() {
  local value="$1"
  RESOLVED_SCRIPT=""

  if is_blank "$value"; then
    return 1
  fi

  [[ "$value" != /* ]] || reject "absolute script paths are not allowed: $value" || return $?
  [[ "$value" != *".."* ]] || reject "parent directory traversal is not allowed in script path: $value" || return $?

  case "$value" in
    *\;*|*\&*|*\|*|*\`*|*'$('*|*'${'*) reject "script path contains shell metacharacters: $value" || return $? ;;
  esac

  local script="$ROOT/$value"
  [[ -f "$script" ]] || reject "script gate not found: $value" || return $?
  [[ ! -L "$script" ]] || reject "script gate must not be a symlink: $value" || return $?
  [[ -x "$script" ]] || reject "script gate must be executable: $value" || return $?

  case "$value" in
    scripts/ci/*|.github/scripts/*|ci/*) ;;
    *)
      reject "script gate must live under scripts/ci/, .github/scripts/, or ci/: $value" || return $?
      ;;
  esac

  RESOLVED_SCRIPT="$script"
  return 0
}

run_script_gate() {
  local name="$1"
  local script_value="$2"
  local rc=0

  resolve_repo_script "$script_value" || rc=$?
  if [[ "$rc" == "1" ]]; then
    return 1
  fi
  if [[ "$rc" != "0" ]]; then
    exit "$rc"
  fi

  echo "[RUN] $name script: $script_value"
  if ! "$RESOLVED_SCRIPT"; then
    fail "$name script failed: $script_value"
  fi
  echo "[OK] $name"
  ran_any=1
  return 0
}

run_legacy_cmd_gate() {
  local name="$1"
  local cmd="$2"

  if is_blank "$cmd"; then
    return 1
  fi

  if [[ "${HARNESS_ORG_STANDARD:-0}" == "1" ]]; then
    [[ "${HARNESS_ACK_TRUSTED_PROJECT_CMDS:-0}" == "1" ]] || fail "HARNESS_*_CMD in organization mode requires HARNESS_ACK_TRUSTED_PROJECT_CMDS=1"
    [[ "${HARNESS_ALLOW_LEGACY_BASH_LC:-0}" == "1" ]] || fail "HARNESS_*_CMD is legacy in organization mode; prefer HARNESS_*_SCRIPT or set HARNESS_ALLOW_LEGACY_BASH_LC=1"
  else
    echo "[WARN] $name uses legacy HARNESS_*_CMD through bash -lc; prefer HARNESS_*_SCRIPT"
  fi

  echo "[RUN] $name legacy command: $cmd"
  if ! bash -lc "$cmd"; then
    fail "$name legacy command failed"
  fi
  echo "[OK] $name"
  ran_any=1
  return 0
}

run_gate() {
  local name="$1"
  local script_value="$2"
  local cmd_value="$3"

  if run_script_gate "$name" "$script_value"; then
    return 0
  fi
  if run_legacy_cmd_gate "$name" "$cmd_value"; then
    return 0
  fi

  echo "[SKIP] $name: script/command not configured"
}

if [[ "${HARNESS_ORG_STANDARD:-0}" == "1" && "${HARNESS_ACK_TRUSTED_PROJECT_CMDS:-0}" != "1" ]]; then
  echo "[FAIL] organization mode requires HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 to acknowledge trusted gate configuration" >&2
  exit 1
fi

run_gate "backend" "${HARNESS_BACKEND_TEST_SCRIPT:-}" "${HARNESS_BACKEND_TEST_CMD:-}"
run_gate "primary-frontend" "${HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT:-}" "${HARNESS_PRIMARY_FRONTEND_TEST_CMD:-}"
run_gate "secondary-app" "${HARNESS_SECONDARY_APP_TEST_SCRIPT:-}" "${HARNESS_SECONDARY_APP_TEST_CMD:-}"
run_gate "integration" "${HARNESS_INTEGRATION_TEST_SCRIPT:-}" "${HARNESS_INTEGRATION_TEST_CMD:-}"
run_gate "security" "${HARNESS_SECURITY_SCAN_SCRIPT:-}" "${HARNESS_SECURITY_SCAN_CMD:-}"
run_gate "accessibility" "${HARNESS_A11Y_CHECK_SCRIPT:-}" "${HARNESS_A11Y_CHECK_CMD:-}"

if [[ "$ran_any" == "0" ]]; then
  echo "[WARN] no project gate script/command configured"
  echo "[WARN] set HARNESS_*_SCRIPT variables, or legacy HARNESS_*_CMD with explicit opt-in"
  if [[ "${HARNESS_REQUIRE_PROJECT_CHECKS:-0}" == "1" ]]; then
    echo "[FAIL] HARNESS_REQUIRE_PROJECT_CHECKS=1 requires at least one project gate" >&2
    exit 1
  fi
fi
