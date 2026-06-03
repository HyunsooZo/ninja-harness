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
  rm -f scripts/ci/.harness-self-test-ok.py
  rm -f scripts/ci/.harness-self-test-org.sh
  rm -f scripts/ci/.harness-self-test-link.sh
  rm -f scripts/ci/.harness-self-test-link-dir
  rm -f .env.harness-self-test
  rm -f session-token.json
  rm -f api-secret.properties
  rm -f .DS_Store
  rm -f .claude/settings.local.json
  rm -f docs/harness/context/generated/token-policy.md
  rm -f scripts/.harness-self-test-outside.sh
  rm -f docs/harness/plans/active/.harness-self-test-tracked.md
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
  local backup="$tmp_dir/file-without-line.backup"
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

with_file_replacing_line() {
  local path="$1"
  local needle="$2"
  local replacement="$3"
  shift 3
  local backup="$tmp_dir/file-replacing-line.backup"
  cp "$path" "$backup"
  python3 - "$path" "$needle" "$replacement" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
needle = sys.argv[2]
replacement = sys.argv[3]
lines = path.read_text(encoding='utf-8').splitlines()
changed = False
for index, line in enumerate(lines):
    if line.strip() == needle:
        lines[index] = replacement
        changed = True
        break
if not changed:
    raise SystemExit(f'missing test needle in {path}: {needle}')
path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
PY
  local status=0
  set +e
  "$@"
  status=$?
  set -e
  cp "$backup" "$path"
  return "$status"
}

make_mutation_fixture() {
  local fixture="$tmp_dir/mutation-fixture-$pass_count"
  mkdir -p "$fixture"
  (
    cd "$ROOT"
    git ls-files -z | while IFS= read -r -d '' rel_path; do
      if [[ ! -e "$rel_path" && ! -L "$rel_path" ]]; then
        continue
      fi
      mkdir -p "$fixture/$(dirname "$rel_path")"
      cp -P "$rel_path" "$fixture/$rel_path"
    done
  )
  (
    cd "$fixture"
    git init --quiet
    git add -A
  )
  printf '%s\n' "$fixture"
}

with_fixture_file_without_line() {
  local path="$1"
  local needle="$2"
  shift 2
  local fixture
  fixture="$(make_mutation_fixture)"
  (
    cd "$fixture"
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
    "$@"
  )
}

with_fixture_file_replacing_line() {
  local path="$1"
  local needle="$2"
  local replacement="$3"
  shift 3
  local fixture
  fixture="$(make_mutation_fixture)"
  (
    cd "$fixture"
    python3 - "$path" "$needle" "$replacement" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
needle = sys.argv[2]
replacement = sys.argv[3]
lines = path.read_text(encoding='utf-8').splitlines()
changed = False
for index, line in enumerate(lines):
    if line.strip() == needle:
        lines[index] = replacement
        changed = True
        break
if not changed:
    raise SystemExit(f'missing test needle in {path}: {needle}')
path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
PY
    "$@"
  )
}

with_fixture_duplicate_skill_boilerplate() {
  local fixture
  fixture="$(make_mutation_fixture)"
  (
    cd "$fixture"
    python3 - <<'PY'
from pathlib import Path

block = """\n## 증거 게이트\n\n- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.\n- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.\n- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.\n"""
for path in [
    Path('.agents/skills/content-i18n-ux/SKILL.md'),
    Path('.claude/skills/content-i18n-ux/SKILL.md'),
]:
    path.write_text(path.read_text(encoding='utf-8').rstrip() + block, encoding='utf-8')
PY
    "$@"
  )
}

good_profile="$tmp_dir/good-profile.md"
bad_profile="$tmp_dir/bad-profile.md"
printf 'project: N/A\nruntime: N/A\n' > "$good_profile"
printf 'project: <fill-project>\n' > "$bad_profile"

expect_pass "profile readiness accepts filled profile" \
  bash scripts/check-profile-readiness.sh "$good_profile"

expect_fail "profile readiness rejects placeholder" \
  bash scripts/check-profile-readiness.sh "$bad_profile"

completed_quality_dir="$tmp_dir/completed-plans"
mkdir -p "$completed_quality_dir"

expect_pass "completed plan quality accepts empty directory" \
  env HARNESS_COMPLETED_PLAN_DIR="$completed_quality_dir" \
      bash scripts/check-completed-plan-quality.sh

printf '# Good completed plan\n\nRED GREEN REFACTOR VERIFY\n잔여 위험: none\n' > "$completed_quality_dir/good.md"
expect_pass "completed plan quality accepts required evidence markers" \
  env HARNESS_COMPLETED_PLAN_DIR="$completed_quality_dir" \
      bash scripts/check-completed-plan-quality.sh

printf '# Bad completed plan\n\nVERIFY only\n' > "$completed_quality_dir/bad.md"
expect_fail "completed plan quality rejects missing evidence markers" \
  env HARNESS_COMPLETED_PLAN_DIR="$completed_quality_dir" \
      bash scripts/check-completed-plan-quality.sh

printf '# Pending completed plan\n\nRED\n- 명령: pending\nGREEN\n- 확인: pending\nREFACTOR\nVERIFY\nRisk left: pending\n' > "$completed_quality_dir/pending.md"
expect_fail "completed plan quality rejects pending evidence placeholders" \
  env HARNESS_COMPLETED_PLAN_DIR="$completed_quality_dir" \
      bash scripts/check-completed-plan-quality.sh

expect_pass "completed plan quality tracked source ignores local fixture files" \
  env HARNESS_COMPLETED_PLAN_DIR="$completed_quality_dir" \
      HARNESS_COMPLETED_PLAN_SOURCE=tracked \
      bash scripts/check-completed-plan-quality.sh
rm -f "$completed_quality_dir/bad.md" "$completed_quality_dir/pending.md"

evidence_hook_root="$tmp_dir/evidence-hook-root"
mkdir -p "$evidence_hook_root/docs/harness/plans/active" "$evidence_hook_root/scripts"
cp scripts/check-evidence-gate-hook.py "$evidence_hook_root/scripts/check-evidence-gate-hook.py"
cp scripts/check-evidence-gate-hook.sh "$evidence_hook_root/scripts/check-evidence-gate-hook.sh"
mkdir -p "$evidence_hook_root/scripts/harness_lib"
cp scripts/harness_lib/stdio.py "$evidence_hook_root/scripts/harness_lib/stdio.py"
cp scripts/harness_lib/__init__.py "$evidence_hook_root/scripts/harness_lib/__init__.py"
chmod +x "$evidence_hook_root/scripts/check-evidence-gate-hook.py" "$evidence_hook_root/scripts/check-evidence-gate-hook.sh"
printf '{"tool_name":"Edit","tool_input":{"file_path":"docs/harness/plans/active/hook-test.md"}}\n' > "$tmp_dir/hook-plan-edit.json"
printf '{"tool_name":"Edit","tool_input":{"file_path":"src/app.py"}}\n' > "$tmp_dir/hook-src-edit.json"

expect_pass "evidence hook allows active plan edit" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-plan-edit.json"

settings_hook_command="$(
  python3 - <<'PY'
import json
from pathlib import Path

settings = json.loads(Path('.claude/settings.json').read_text(encoding='utf-8'))
print(settings['hooks']['PreToolUse'][0]['hooks'][0]['command'])
PY
)"

expect_pass "evidence hook settings command works outside repo cwd" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      bash -c 'cd /tmp && eval "$1" < "$2"' _ "$settings_hook_command" "$tmp_dir/hook-plan-edit.json"

expect_fail "evidence hook blocks edit without RED" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-src-edit.json"

if env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
  bash -c 'cd /tmp; eval "$1" < "$2"; code=$?; test "$code" -eq 2' _ "$settings_hook_command" "$tmp_dir/hook-src-edit.json"; then
  pass "evidence hook settings command preserves block exit code"
else
  sed -n '1,80p' "$output_file" >&2
  fail "evidence hook settings command should preserve exit code 2"
fi

cat > "$evidence_hook_root/docs/harness/plans/active/stale.md" <<'EOF'
# Stale plan

## RED Evidence

- 예외 사유: stale unrelated scope
- 대체 검증: fixture
- Risk left: none

## Scope

- `docs/only/**`
EOF

expect_fail "evidence hook rejects unrelated stale plan scope" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-src-edit.json"

cat > "$evidence_hook_root/docs/harness/plans/active/notes-only.md" <<'EOF'
# Notes only scope

Notes mention `src/**` as historical context only.

## RED Evidence

- 예외 사유: notes-only fixture
- 대체 검증: fixture
- Risk left: none

## Scope

- `docs/only/**`
EOF

expect_fail "evidence hook ignores paths outside explicit scope section" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-src-edit.json"

printf '{"tool_name":"Edit","tool_input":{"file_path":"docs/harness/plans/completed/old.md"}}\n' > "$tmp_dir/hook-completed-edit.json"
expect_fail "evidence hook blocks completed plan direct edit without scope" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-completed-edit.json"

cat > "$evidence_hook_root/docs/harness/plans/active/state-only.md" <<'EOF'
# State only

- Plan State: `red`
EOF

expect_fail "evidence hook rejects state-only RED" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-src-edit.json"

cat > "$evidence_hook_root/docs/harness/plans/active/files-heading.md" <<'EOF'
# Files heading is not editable scope

## RED Evidence

- 예외 사유: files heading fixture
- 대체 검증: fixture

## Files

- `src/**`
EOF

expect_fail "evidence hook rejects generic Files section as scope" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-src-edit.json"

cat > "$evidence_hook_root/docs/harness/plans/active/risk-only.md" <<'EOF'
# Risk only

## RED Evidence

- Risk left: fixture

## Scope

- `src/**`
EOF

expect_fail "evidence hook rejects risk-left-only RED evidence" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-src-edit.json"

cat > "$evidence_hook_root/docs/harness/plans/active/narrative-only.md" <<'EOF'
# Narrative only

## RED Evidence

실패를 재현했다.

## Scope

- `src/**`
EOF

expect_fail "evidence hook rejects narrative-only RED evidence" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-src-edit.json"

cat > "$evidence_hook_root/docs/harness/plans/active/hook-test.md" <<'EOF'
# Hook test

## RED Evidence

- 예외 사유: hook self-test
- 대체 검증: fixture
- Risk left: none

## Scope

- `src/**`
EOF

expect_pass "evidence hook accepts documented RED exception" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-src-edit.json"

expect_pass "evidence hook wrapper works outside repo cwd" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      bash -c 'cd /tmp && "$2/scripts/check-evidence-gate-hook.sh" < "$1"' _ "$tmp_dir/hook-src-edit.json" "$PWD"

expect_fail "evidence hook bypass mode requires audit reason" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      HARNESS_EVIDENCE_HOOK_MODE=off \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-src-edit.json"

expect_pass "evidence hook bypass mode accepts audit reason" \
  env CLAUDE_PROJECT_DIR="$evidence_hook_root" \
      HARNESS_EVIDENCE_HOOK_MODE=off \
      HARNESS_EVIDENCE_HOOK_BYPASS_REASON="approved emergency self-test" \
      python3 scripts/check-evidence-gate-hook.py < "$tmp_dir/hook-src-edit.json"

eval_fixture_dir="$tmp_dir/eval-completed-plans"
mkdir -p "$eval_fixture_dir"
cat > "$eval_fixture_dir/narrative-failure-pass.md" <<'EOF'
# Eval fixture

- 날짜: 2026-05-31
- 작업 유형: docs
- 기본 실행자: executor
- 모드: SINGLE_AGENT
- Verdict: PASS

## Notes

- RED Evidence mentions an expected 자동 검증 실패 before the fix.
EOF
cat > "$eval_fixture_dir/backtick-status-done.md" <<'EOF'
# Eval fixture

- 날짜: 2026-05-31
- 작업 유형: docs
- 기본 실행자: executor
- 모드: SINGLE_AGENT
- Status: `DONE`

## Notes

- 회귀 검증이라는 일반 설명은 regression capture 지표 분모가 아니다.
EOF
expect_pass "eval ignores narrative failure and regression wording" \
  env HARNESS_COMPLETED_PLAN_DIR="$eval_fixture_dir" \
      bash scripts/collect-eval-metrics.sh
env HARNESS_COMPLETED_PLAN_DIR="$eval_fixture_dir" bash scripts/collect-eval-metrics.sh > "$output_file"
grep -q '^fail_markers=0$' "$output_file" || fail "eval should not count narrative failure wording as fail marker"
grep -q '^regression_markers=0$' "$output_file" || fail "eval should not count narrative regression wording as regression marker"
grep -q '^completed_plan_source=local$' "$output_file" || fail "eval should report local completed plan source"
grep -q $'docs\t2/2\t100.0%' "$output_file" || fail "eval should count PASS verdict and backtick DONE status as successful docs tasks"
pass "eval fixture metrics verified"

env HARNESS_COMPLETED_PLAN_DIR="$eval_fixture_dir" HARNESS_COMPLETED_PLAN_SOURCE=tracked bash scripts/collect-eval-metrics.sh > "$output_file"
grep -q '^completed_plans=0$' "$output_file" || fail "tracked eval source should ignore local fixture files"
grep -q '^completed_plan_source=tracked$' "$output_file" || fail "eval should report tracked completed plan source"
pass "eval tracked source ignores local fixture files"

expect_pass "harness upgrade checker accepts current metadata" \
  python3 scripts/check-harness-upgrade.py

expect_pass "harness upgrade checker accepts changelog delta from previous version" \
  python3 scripts/check-harness-upgrade.py --from-version 0.1.0

expect_fail "harness upgrade checker rejects newer from-version" \
  python3 scripts/check-harness-upgrade.py --from-version 999.0.0

expect_fail "harness upgrade checker rejects ownership placeholders when required" \
  env HARNESS_REQUIRE_FILLED_OWNERSHIP=1 python3 scripts/check-harness-upgrade.py

expect_fail "harness upgrade checker rejects ownership placeholders in org standard" \
  env HARNESS_ORG_STANDARD=1 python3 scripts/check-harness-upgrade.py

upgrade_downstream="$tmp_dir/upgrade-downstream"
mkdir -p "$upgrade_downstream/scripts" "$upgrade_downstream/docs/harness/context"
printf 'downstream local edit\n' > "$upgrade_downstream/scripts/check-harness-upgrade.py"
printf 'scripts/check-harness-upgrade.py\n' > "$tmp_dir/changed-harness-paths.txt"
expect_fail "harness upgrade checker rejects dirty downstream changed path" \
  python3 scripts/check-harness-upgrade.py \
    --downstream-root "$upgrade_downstream" \
    --changed-paths-file "$tmp_dir/changed-harness-paths.txt" \
    --require-downstream-audit \
    --require-clean-downstream

printf 'docs/harness/context/BASELINE.md\n' > "$tmp_dir/changed-project-owned-paths.txt"
expect_fail "harness upgrade checker rejects project-owned downstream overwrite" \
  python3 scripts/check-harness-upgrade.py \
    --downstream-root "$upgrade_downstream" \
    --changed-paths-file "$tmp_dir/changed-project-owned-paths.txt" \
    --require-downstream-audit \
    --require-clean-downstream

mkdir -p "$tmp_dir/upgrade-template/scripts"
cp -R VERSION MANIFEST.md LICENSE .github docs scripts "$tmp_dir/upgrade-template/"
printf 'new upstream file\n' > "$tmp_dir/upgrade-template/scripts/new-upstream-tool.py"
printf 'scripts/new-upstream-tool.py\n' > "$tmp_dir/changed-new-managed-paths.txt"
expect_fail "harness upgrade checker rejects missing downstream managed file" \
  python3 scripts/check-harness-upgrade.py \
    --root "$tmp_dir/upgrade-template" \
    --downstream-root "$upgrade_downstream" \
    --changed-paths-file "$tmp_dir/changed-new-managed-paths.txt" \
    --require-downstream-audit \
    --require-clean-downstream

printf 'stale downstream file\n' > "$upgrade_downstream/scripts/deleted-upstream-tool.py"
printf 'scripts/deleted-upstream-tool.py\n' > "$tmp_dir/changed-deleted-managed-paths.txt"
expect_fail "harness upgrade checker rejects deleted upstream managed file left downstream" \
  python3 scripts/check-harness-upgrade.py \
    --downstream-root "$upgrade_downstream" \
    --changed-paths-file "$tmp_dir/changed-deleted-managed-paths.txt" \
    --require-downstream-audit \
    --require-clean-downstream

printf '../scripts/check-harness-upgrade.py\n' > "$tmp_dir/changed-unsafe-paths.txt"
expect_fail "harness upgrade checker rejects unsafe changed path traversal" \
  python3 scripts/check-harness-upgrade.py \
    --downstream-root "$upgrade_downstream" \
    --changed-paths-file "$tmp_dir/changed-unsafe-paths.txt" \
    --require-downstream-audit

expect_fail "verify rejects invalid mode" \
  env HARNESS_VERIFY_MODE=invalid bash scripts/verify-harness-structure.sh

expect_fail "filled-profile gate requires project mode" \
  env HARNESS_REQUIRE_FILLED_PROFILE=1 HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

printf 'PLACEHOLDER_ONLY=1\n' > .env.harness-self-test
expect_pass "verify ignores ignored untracked env file" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh
rm -f .env.harness-self-test

printf '{"placeholder": true}\n' > session-token.json
expect_pass "verify ignores ignored untracked token config file" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh
rm -f session-token.json

printf 'placeholder=true\n' > api-secret.properties
expect_pass "verify ignores ignored untracked secret properties file" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh
rm -f api-secret.properties

printf 'metadata\n' > .DS_Store
mkdir -p .claude
printf '{"local": true}\n' > .claude/settings.local.json
expect_pass "verify ignores ignored untracked local artifacts" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh
rm -f .DS_Store .claude/settings.local.json

printf 'PLACEHOLDER_ONLY=1\n' > .env.harness-self-test
GIT_INDEX_FILE="$tmp_dir/git-index-sensitive" git read-tree HEAD
sensitive_blob="$(git hash-object -w .env.harness-self-test)"
GIT_INDEX_FILE="$tmp_dir/git-index-sensitive" git update-index --add --cacheinfo 100644 "$sensitive_blob" .env.harness-self-test
expect_fail "tracked sensitive env file is rejected" \
  env GIT_INDEX_FILE="$tmp_dir/git-index-sensitive" HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh
rm -f .env.harness-self-test

mkdir -p docs/harness/context/generated
printf '# Token policy placeholder\n' > docs/harness/context/generated/token-policy.md
expect_pass "token policy markdown remains allowed" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh
rm -f docs/harness/context/generated/token-policy.md

printf '# Harness self-test tracked active plan\n\nRED GREEN REFACTOR VERIFY\n잔여 위험: self-test only\n' > docs/harness/plans/active/.harness-self-test-tracked.md
GIT_INDEX_FILE="$tmp_dir/git-index" git read-tree HEAD
GIT_INDEX_FILE="$tmp_dir/git-index" git update-index --add docs/harness/plans/active/.harness-self-test-tracked.md

expect_fail "template rejects tracked active plan" \
  env GIT_INDEX_FILE="$tmp_dir/git-index" HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

rm -f docs/harness/plans/active/.harness-self-test-tracked.md

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

expect_fail "manifest parity rejects missing policy line" \
  with_file_without_line "MANIFEST.md" \
    "allow_parallel_implementation: conditional" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "gitignore rejects missing completed plan ignore" \
  with_file_without_line ".gitignore" \
    "docs/harness/plans/completed/*.md" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "gitignore rejects missing active plan ignore" \
  with_file_without_line ".gitignore" \
    "docs/harness/plans/active/*.md" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "gitignore rejects missing secret config ignore" \
  with_file_without_line ".gitignore" \
    "*secret*.json" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "project profile rejects missing frontend test command" \
  with_file_without_line "docs/harness/profiles/project-profile.md" \
    '| 주요 프론트엔드 테스트 | `<primary-frontend-test-command>` |' \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

mkdir -p docs/harness/context/generated/.harness-clean-test/__MACOSX
expect_pass "clean removes nested macOS metadata" \
  make clean
if [[ -d docs/harness/context/generated/.harness-clean-test/__MACOSX ]]; then
  fail "nested __MACOSX should be removed by make clean"
fi
rm -rf docs/harness/context/generated/.harness-clean-test

expect_fail "plan template rejects lifecycle Status" \
  with_file_replacing_line "docs/harness/plans/TEMPLATE.md" \
    '- Plan State: `draft`' \
    '- Status: `draft`' \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "makefile rejects hardcoded bash path" \
  with_file_replacing_line "Makefile" \
    "SHELL := bash" \
    "SHELL := /bin/bash" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "root README rejects missing integrity table row" \
  with_file_without_line "README.md" \
    '| `make integrity` | 최종 로컬 하네스 무결성 검증을 실행합니다. |' \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "source_of_truth rejects missing backend rubric" \
  with_harness_yaml_without_line "- docs/harness/rubrics/backend.md" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "skill routing rejects missing agent mapping" \
  with_file_without_line "docs/harness/skill-routing.md" \
    '| 데이터 시각화 리뷰 | `data-viz-reviewer` |' \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "skill routing rejects unknown agent mapping" \
  with_file_replacing_line "docs/harness/skill-routing.md" \
    '| 주요 프론트엔드 화면, 스타일, i18n | `primary-frontend-view-implementer` |' \
    '| 주요 프론트엔드 화면, 스타일, i18n | `missing-frontend-implementer` |' \
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
  with_harness_yaml_without_line "supported_os: macos_linux_windows" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing PowerShell entrypoint manifest" \
  with_harness_yaml_without_line "powershell_entrypoints: scripts/doctor.ps1 scripts/verify-harness-structure.ps1 scripts/verify-project-gates.ps1 scripts/check-completed-plan-quality.ps1 scripts/sync-skills.ps1 scripts/check-profile-readiness.ps1 scripts/collect-eval-metrics.ps1 scripts/set-codex-agent-model.ps1 scripts/check-evidence-gate-hook.ps1 scripts/check-harness-upgrade.ps1" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing Python verifier manifest" \
  with_harness_yaml_without_line "python_verifier: scripts/verify-harness-structure.py" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing git required tool" \
  with_harness_yaml_without_line "required_tools: python3 git" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing POSIX required tools" \
  with_harness_yaml_without_line "posix_required_tools: bash make" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing PowerShell structure verification policy" \
  with_harness_yaml_without_line "powershell_structure_verification: true" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing project gate runner policy" \
  with_harness_yaml_without_line "project_gate_runner: python_cross_platform" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing POSIX utility manifest" \
  with_harness_yaml_without_line "posix_utilities: find cp rm mkdir chmod rmdir sed env uname head cat dirname pwd" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "runtime rejects missing Python TOML parser manifest" \
  with_harness_yaml_without_line "toml_parser: tomllib_or_tomli" \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "agent metadata rejects missing Codex skills preload" \
  with_fixture_file_without_line ".codex/agents/backend-api-implementer.toml" \
    'skills = ["backend-api", "backend-application", "integration-contract", "testing-strategy"]' \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "agent metadata rejects invalid sandbox mode" \
  with_fixture_file_replacing_line ".codex/agents/backend-api-implementer.toml" \
    'sandbox_mode = "workspace-write"' \
    'sandbox_mode = "full-access"' \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "agent metadata rejects invalid reasoning effort" \
  with_fixture_file_replacing_line ".codex/agents/backend-api-implementer.toml" \
    'model_reasoning_effort = "high"' \
    'model_reasoning_effort = "extreme"' \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "agent metadata rejects non-list skills preload" \
  with_fixture_file_replacing_line ".codex/agents/backend-api-implementer.toml" \
    'skills = ["backend-api", "backend-application", "integration-contract", "testing-strategy"]' \
    'skills = "backend-api"' \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "agent preload rejects missing local skill coverage" \
  with_fixture_file_replacing_line ".codex/agents/task-orchestrator.toml" \
    'skills = ["orchestration-planning", "executor", "review-rubric", "testing-strategy", "harness-maintenance"]' \
    'skills = ["orchestration-planning", "executor", "review-rubric", "testing-strategy"]' \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "skill boilerplate rejects duplicated common block" \
  with_fixture_duplicate_skill_boilerplate \
  env HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh

expect_fail "configuration reference rejects undocumented env var" \
  with_file_without_line "docs/harness/CONFIGURATION.md" \
    '| `HARNESS_A11Y_CHECK_CMD` | 접근성 검사 legacy 명령. |' \
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
printf 'print("[OK] self-test python project gate")\n' > scripts/ci/.harness-self-test-ok.py

python3 - <<'PY'
from pathlib import Path

target = Path('scripts/ci/.harness-self-test-ok.sh').resolve()
link = Path('scripts/ci/.harness-self-test-link.sh')
if link.exists() or link.is_symlink():
    link.unlink()
link.symlink_to(target)
PY

expect_fail "project gate rejects symlink script" \
  env HARNESS_RUN_PROJECT_CHECKS=1 \
      HARNESS_BACKEND_TEST_SCRIPT=scripts/ci/.harness-self-test-link.sh \
      bash scripts/verify-project-gates.sh

mkdir -p "$tmp_dir/project-gate-target"
printf '#!/usr/bin/env bash\nset -euo pipefail\necho "[OK] parent symlink project gate"\n' > "$tmp_dir/project-gate-target/ok.sh"
chmod +x "$tmp_dir/project-gate-target/ok.sh"
python3 - "$tmp_dir/project-gate-target" <<'PY'
from pathlib import Path
import sys

target = Path(sys.argv[1]).resolve()
link = Path('scripts/ci/.harness-self-test-link-dir')
if link.exists() or link.is_symlink():
    link.unlink()
link.symlink_to(target, target_is_directory=True)
PY

expect_fail "project gate rejects parent symlink script path" \
  env HARNESS_RUN_PROJECT_CHECKS=1 \
      HARNESS_BACKEND_TEST_SCRIPT=scripts/ci/.harness-self-test-link-dir/ok.sh \
      bash scripts/verify-project-gates.sh

expect_pass "project gate accepts allowlisted executable script" \
  env HARNESS_RUN_PROJECT_CHECKS=1 \
      HARNESS_BACKEND_TEST_SCRIPT=scripts/ci/.harness-self-test-ok.sh \
      bash scripts/verify-project-gates.sh

expect_pass "project gate accepts allowlisted python script" \
  env HARNESS_RUN_PROJECT_CHECKS=1 \
      HARNESS_BACKEND_TEST_SCRIPT=scripts/ci/.harness-self-test-ok.py \
      python3 scripts/verify-project-gates.py

expect_fail "required project gates reject empty configuration" \
  env HARNESS_RUN_PROJECT_CHECKS=1 \
      HARNESS_REQUIRE_PROJECT_CHECKS=1 \
      bash scripts/verify-project-gates.sh

expect_fail "organization mode blocks legacy command without explicit opt-in" \
  env HARNESS_ORG_STANDARD=1 \
      HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 \
      HARNESS_BACKEND_TEST_CMD='echo legacy' \
      bash scripts/verify-project-gates.sh

expect_fail "organization structure rejects ownership placeholders" \
  env HARNESS_ORG_STANDARD=1 \
      bash scripts/verify-harness-structure.sh

if [[ ! -d scripts/ci ]]; then
  mkdir -p scripts/ci
  created_ci_dir=1
fi
printf '#!/usr/bin/env bash\nexit 0\n' > scripts/ci/.harness-self-test-org.sh
chmod +x scripts/ci/.harness-self-test-org.sh
expect_fail "verify-org rejects ownership placeholders" \
  env HARNESS_BACKEND_TEST_SCRIPT=scripts/ci/.harness-self-test-org.sh \
      make verify-org

expect_fail "legacy command blocks without explicit opt-in" \
  env HARNESS_REQUIRE_PROJECT_CHECKS=1 \
      HARNESS_BACKEND_TEST_CMD='echo legacy' \
      bash scripts/verify-project-gates.sh

expect_pass "legacy command accepts explicit opt-in" \
  env HARNESS_REQUIRE_PROJECT_CHECKS=1 \
      HARNESS_ALLOW_LEGACY_BASH_LC=1 \
      HARNESS_BACKEND_TEST_CMD='echo legacy' \
      bash scripts/verify-project-gates.sh

echo "[OK] harness gate self-tests passed: $pass_count"
