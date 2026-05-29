SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

HARNESS_VERIFY ?= scripts/verify-harness-structure.sh
HARNESS_PROJECT_GATES ?= scripts/verify-project-gates.sh
HARNESS_SYNC_SKILLS ?= scripts/sync-skills.sh
HARNESS_CHECK_PROFILE ?= scripts/check-profile-readiness.sh
HARNESS_EVAL ?= scripts/collect-eval-metrics.sh
HARNESS_CHECK_PLANS ?= scripts/check-completed-plan-quality.sh
HARNESS_SET_MODEL ?= scripts/set-codex-agent-model.sh

ORG_GATE_SCRIPT_VARS := \
  HARNESS_BACKEND_TEST_SCRIPT \
  HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT \
  HARNESS_SECONDARY_APP_TEST_SCRIPT \
  HARNESS_INTEGRATION_TEST_SCRIPT \
  HARNESS_SECURITY_SCAN_SCRIPT \
  HARNESS_A11Y_CHECK_SCRIPT

.PHONY: \
  help doctor verify verify-template verify-project verify-org \
  project-ready check-profile project-gates project-gates-required sync-skills check-sync \
  eval check-plans set-model clean

help:
	@echo "Harness commands:"
	@echo "  make help                    Show this help"
	@echo "  make doctor                  Check local harness tooling and script executability"
	@echo "  make verify                  Run template and project harness verification"
	@echo "  make verify-template         Run template-mode harness verification"
	@echo "  make verify-project          Run project-mode harness verification"
	@echo "  make project-ready           Verify project mode and fail on unfilled profile placeholders"
	@echo "  make check-profile           Check project profile/context placeholders only"
	@echo "  make verify-org              Run organization-standard verification with real project gates"
	@echo "  make project-gates           Run configured project gates only; skips if none configured"
	@echo "  make project-gates-required  Run project gates only and fail when no gate is configured"
	@echo "  make sync-skills             Sync .agents/skills to .claude/skills"
	@echo "  make check-sync              Verify skill mirrors after sync"
	@echo "  make eval                    Collect completed-plan eval metrics"
	@echo "  make check-plans             Check completed plan quality"
	@echo "  make set-model MODEL=<model> Update Codex agent model in all TOML files"
	@echo "  make clean                   Remove OS/editor metadata files"
	@echo ""
	@echo "Organization mode requires at least one repository script gate. Supported variables:"
	@for var in $(ORG_GATE_SCRIPT_VARS); do echo "  $$var"; done
	@echo ""
	@echo "Example:"
	@echo "  HARNESS_INTEGRATION_TEST_SCRIPT=scripts/ci/integration-test.sh make verify-org"

# Local sanity check that does not run project build/test commands.
doctor:
	@test -f AGENTS.md || { echo "[FAIL] missing AGENTS.md"; exit 1; }
	@test -f CLAUDE.md || { echo "[FAIL] missing CLAUDE.md"; exit 1; }
	@test -f Makefile || { echo "[FAIL] missing Makefile"; exit 1; }
	@for script in \
		"$(HARNESS_VERIFY)" \
		"$(HARNESS_PROJECT_GATES)" \
		"$(HARNESS_SYNC_SKILLS)" \
		"$(HARNESS_CHECK_PROFILE)" \
		"$(HARNESS_EVAL)" \
		"$(HARNESS_CHECK_PLANS)" \
		"$(HARNESS_SET_MODEL)"; do \
		if [ ! -f "$$script" ]; then echo "[FAIL] missing script: $$script"; exit 1; fi; \
		if [ ! -x "$$script" ]; then echo "[FAIL] script must be executable: $$script"; exit 1; fi; \
		done
	@command -v bash >/dev/null || { echo "[FAIL] bash is required"; exit 1; }
	@command -v python3 >/dev/null || { echo "[FAIL] python3 is required"; exit 1; }
	@command -v make >/dev/null || { echo "[FAIL] make is required"; exit 1; }
	@os="$$(uname -s 2>/dev/null || echo unknown)"; \
	case "$$os" in \
		Darwin|Linux) echo "[OK] supported OS: $$os" ;; \
		CYGWIN*|MINGW*|MSYS*) echo "[WARN] $$os is supported only through a POSIX-compatible shell; prefer WSL for CI parity" ;; \
		*) echo "[FAIL] unsupported OS for harness scripts: $$os"; exit 1 ;; \
	esac
	@bash --version | head -n 1
	@python3 --version
	@make --version | head -n 1
	@bash -n scripts/*.sh
	@echo "[OK] harness local tooling looks ready"

verify: verify-template verify-project

verify-template:
	HARNESS_VERIFY_MODE=template bash "$(HARNESS_VERIFY)"

verify-project:
	HARNESS_VERIFY_MODE=project bash "$(HARNESS_VERIFY)"

project-ready:
	HARNESS_VERIFY_MODE=project \
	HARNESS_REQUIRE_FILLED_PROFILE=1 \
	bash "$(HARNESS_VERIFY)"

check-profile:
	bash "$(HARNESS_CHECK_PROFILE)"

# Organization-standard verification intentionally requires script gates, not
# legacy HARNESS_*_CMD strings.  The gate scripts must live under the allowlisted
# repository paths enforced by scripts/verify-project-gates.sh.
verify-org:
	@found=0; \
	for var in $(ORG_GATE_SCRIPT_VARS); do \
		if [ -n "$${!var:-}" ]; then found=1; fi; \
	done; \
	if [ "$$found" -eq 0 ]; then \
		echo "[FAIL] set at least one HARNESS_*_SCRIPT before make verify-org"; \
		echo "       supported variables:"; \
		for var in $(ORG_GATE_SCRIPT_VARS); do echo "       - $$var"; done; \
		echo "       example: HARNESS_INTEGRATION_TEST_SCRIPT=scripts/ci/integration-test.sh make verify-org"; \
		exit 1; \
	fi
	HARNESS_VERIFY_MODE=project \
	HARNESS_ORG_STANDARD=1 \
	HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 \
	bash "$(HARNESS_VERIFY)"

project-gates:
	HARNESS_RUN_PROJECT_CHECKS=1 bash "$(HARNESS_PROJECT_GATES)"

project-gates-required:
	HARNESS_RUN_PROJECT_CHECKS=1 \
	HARNESS_REQUIRE_PROJECT_CHECKS=1 \
	HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 \
	bash "$(HARNESS_PROJECT_GATES)"

sync-skills:
	bash "$(HARNESS_SYNC_SKILLS)"

check-sync:
	bash "$(HARNESS_SYNC_SKILLS)"
	HARNESS_VERIFY_MODE=template bash "$(HARNESS_VERIFY)"

eval:
	bash "$(HARNESS_EVAL)"

check-plans:
	bash "$(HARNESS_CHECK_PLANS)"

set-model:
	@if [ -z "$${MODEL:-}" ]; then \
		echo "[FAIL] set MODEL=<model> before make set-model"; \
		echo "       example: make set-model MODEL=gpt-5.5"; \
		exit 1; \
	fi
	bash "$(HARNESS_SET_MODEL)" "$${MODEL}"

clean:
	find . -name ".DS_Store" -delete
	find . -name "._*" -delete
	rm -rf __MACOSX
	find . -name "__tmp-*.sh" -delete
