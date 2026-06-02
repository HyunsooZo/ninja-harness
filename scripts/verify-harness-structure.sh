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
  "scripts/verify-harness-structure.py"
  ".codex/agents"
  ".agents/skills"
  ".claude/skills"
  ".claude/agents"
  ".claude/commands"
  "scripts/sync-skills.sh"
  "scripts/sync-skills.py"
  "scripts/sync-skills.ps1"
  "scripts/check-profile-readiness.sh"
  "scripts/self-test-harness-gates.sh"
  "scripts/verify-project-gates.sh"
  "scripts/verify-project-gates.py"
  "scripts/verify-project-gates.ps1"
  "scripts/check-completed-plan-quality.sh"
  "scripts/check-completed-plan-quality.py"
  "scripts/check-completed-plan-quality.ps1"
  "scripts/collect-eval-metrics.sh"
)

for path in "${required[@]}"; do
  [[ -e "$path" ]] || { echo "[FAIL] missing: $path"; exit 1; }
done

VERIFY_MODE="$VERIFY_MODE" python3 scripts/verify-harness-structure.py
