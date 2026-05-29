# Plan: harness 10/10 review cleanup

## Metadata

- Owner: Codex
- Date: 2026-05-22
- Scope: harness docs, Codex/Claude agent mirror validation, structure verification
- Risk level: medium
- Preferred executor: `executor`
- Plan State: `completed`
- Related context: `AGENTS.md`, `docs/harness/context/BASELINE.md`, `docs/harness/context/INDEX.md`, `docs/harness/README.md`

## Repo rules summary

- [x] Read `AGENTS.md`
- [x] Read `docs/harness/context/BASELINE.md`
- [x] Read `docs/harness/context/INDEX.md`
- [x] Read `docs/harness/README.md`
- [x] Read relevant layer/gate docs
- [x] Read relevant `docs/harness/context/*`

## Spec

### Goal

Bring the harness to a stricter review-ready state by fixing the latest review concerns:

- Remove duplicate/non-essential numbered core docs from the source of truth.
- Ensure Codex and Claude agent mirrors stay synchronized as pairs.
- Make structure verification fail on local artifact leaks and mirror drift.
- Keep the plan-implement-verify loop and backend quality gates intact.

### Current State

- `scripts/verify-harness-structure.sh` passes while `.DS_Store` files exist.
- Codex/Claude agent names and descriptions match, but exact body drift is not verified.
- `docs/harness/06_PROJECT_BASELINE.md` duplicates `context/BASELINE.md`, `profiles/**`, and `harness.yaml`.
- `docs/harness/12_CONTEXT_LOADING_RULE.md` duplicates `context/INDEX.md`, `context/README.md`, and `CLAUDE.md`.

### Target State

- Structure verification fails for `.DS_Store`, missing agent mirror pairs, frontmatter drift, and body drift.
- `06_PROJECT_BASELINE.md` and `12_CONTEXT_LOADING_RULE.md` are removed from core source of truth and references.
- Runtime docs point to `context/BASELINE.md`, `profiles/**`, `context/INDEX.md`, and `context/README.md` for those concerns.
- Codex/Claude mirror bodies are normalized and equal, except Claude runtime memo.

### Non-goals

- No product code changes.
- No backend/frontend implementation changes.
- No commit or push.

### Assumptions / Questions

- This is a harness maintenance task; automated product tests are not applicable.
- Removing redundant core docs is acceptable because the same facts remain in `context/**`, `profiles/**`, and `harness.yaml`.

## Requirement Traceability

| Requirement | Acceptance Criteria | Test / Verification | Implementation | Evidence |
|---|---|---|---|---|
| Fix review concerns until 10/10 | Prior findings are either fixed or intentionally documented | `bash scripts/verify-harness-structure.sh`; `rg` checks | Harness docs and verification script | Verify Report |
| Check Codex/Claude agents together | 21:21 pair set, matching names/descriptions, matching normalized body, reviewer safety | enhanced structure script | `scripts/verify-harness-structure.sh` | Verify Report |
| Decide necessity of numbered core files | Redundant `06` and `12` removed from core; `00` retained as expanded brief | `bash scripts/verify-harness-structure.sh`; source reference review | README/yaml/routing/script updates | Verify Report |

## Approach

### Candidate Approaches

- A: Keep all files and document which are optional.
- B: Remove redundant `06` and `12`, strengthen validation, and update all references.

### Decision

Use B. Keeping redundant files preserves a review concern; removing them makes source-of-truth boundaries clearer.

## Parallelization Check

- Mode: `SEQUENTIAL`
- Decision: `sequential`
- Reason: Same harness docs and validation script references are intertwined.
- Shared contracts fixed?: `yes`
- Overlapping files?: `yes`
- Transaction / domain conflict risk?: `n/a`
- Integration owner: Codex

### Parallel Agent Dispatch

| Agent | Role | Scope | Editable Files | Read-only Files | Verification | Status |
|---|---|---|---|---|---|---|
| n/a | n/a | Sequential harness maintenance | n/a | n/a | n/a | n/a |

### Fan-in Result

- Conflicts: n/a
- Duplicates: n/a
- Missing work: n/a
- Final integration decision: Sequential edit and verify.

## Tasks

- [x] Remove redundant numbered core docs and update references
  - Owner: Codex
  - Files: `docs/harness/README.md`, `docs/harness/harness.yaml`, `docs/harness/skill-routing.md`, `docs/harness/08_HARNESS_AUDIT.md`, deleted docs
  - Acceptance: no source-of-truth dependency on `06_PROJECT_BASELINE.md` or `12_CONTEXT_LOADING_RULE.md`
  - Verification: `bash scripts/verify-harness-structure.sh` and source reference review

- [x] Strengthen structure validation
  - Owner: Codex
  - Files: `scripts/verify-harness-structure.sh`
  - Acceptance: validates `.DS_Store`, pair sets, frontmatter, reviewer safety, normalized mirror body, command set
  - Verification: `bash scripts/verify-harness-structure.sh`

- [x] Sync mirror body drift
  - Owner: Codex
  - Files: `.codex/agents/backend-domain-modeler.toml`, `.codex/agents/backend-persistence-implementer.toml`
  - Acceptance: normalized Codex developer instructions match Claude mirror bodies
  - Verification: `bash scripts/verify-harness-structure.sh`

## Test Plan

| Phase | Command / Check | Expected Result | Notes |
|---|---|---|---|
| RED | `find . -name .DS_Store -print`; `bash scripts/verify-harness-structure.sh` | `.DS_Store` exists while structure script still passes | Captures current validation gap |
| GREEN | `bash scripts/verify-harness-structure.sh` | pass after cleanup and stronger checks | Harness structure |
| REFACTOR | source reference review | deleted docs only appear in retirement notes, not source-of-truth lists | Source-of-truth cleanup |
| VERIFY | `find . -name .DS_Store -print`; `bash scripts/verify-harness-structure.sh`; `rg` checks | no artifacts, script pass, no stale references | Final |

## Evidence

### RED Evidence

- Command: `find . -name .DS_Store -print`
- Failing test / check: output includes `./.DS_Store` and `./docs/.DS_Store`
- Failure reason: local generated files remain in package.
- Why this failure is expected: previous review noted `.DS_Store` leakage.
- Command: `bash scripts/verify-harness-structure.sh`
- Failing test / check: script passes despite `.DS_Store` leakage.
- Failure reason: structure verification does not enforce the audit rule.
- Why this failure is expected: previous review identified the script gap.
- Exception rationale, if RED is not applicable: documentation/harness maintenance uses structural checks instead of product tests.

### GREEN Evidence

- Command: `bash scripts/verify-harness-structure.sh`
- Passing test / check: structure verification passed with strengthened checks for `.DS_Store`, retired docs, Codex/Claude pair sets, frontmatter, normalized body mirrors, Claude command set, routing references, and source-of-truth paths.
- Changed files:
  - `.codex/agents/backend-domain-modeler.toml`
  - `.codex/agents/backend-persistence-implementer.toml`
  - `.claude/commands/start.md`
  - `ADAPTATION_NOTES.md`
  - `MANIFEST.md`
  - `docs/harness/00_AGENT_BRIEF.md`
  - `docs/harness/README.md`
  - `docs/harness/08_HARNESS_AUDIT.md`
  - `docs/harness/harness.yaml`
  - `docs/harness/plans/TEMPLATE.md`
  - `docs/harness/profiles/README.md`
  - `docs/harness/skill-routing.md`
  - `scripts/verify-harness-structure.sh`
  - removed `docs/harness/06_PROJECT_BASELINE.md`
  - removed `docs/harness/12_CONTEXT_LOADING_RULE.md`
  - removed `.DS_Store` and `docs/.DS_Store`
- Why implementation is minimal: changes are limited to the reviewed harness structure, mirror sync, validation, and related references.

### Refactor Note

- Changes: removed duplicate `Gate status` field from the plan template and replaced broad `01~11` loading language with `layer/gate docs`; added Clean Code to the backend quality gate template section.
- Behavior impact: no product behavior; harness workflow is clearer and less ambiguous.
- Rerun command: `bash scripts/verify-harness-structure.sh`

### Verify Report

| Check | Command / Method | Result |
|---|---|---|
| Test | `bash scripts/verify-harness-structure.sh` | PASS |
| Typecheck / Build | N/A | Harness docs/scripts only |
| Lint / Static check | `find . -name .DS_Store -print`; `test ! -f docs/harness/06_PROJECT_BASELINE.md && test ! -f docs/harness/12_CONTEXT_LOADING_RULE.md`; source-of-truth validation script | PASS |
| UI / A11y / Manual | N/A | No UI changes |
| Backend safety | N/A | Harness docs only |

### Skipped Checks

| Check | Reason | Risk Left |
|---|---|---|
| Product test/build | No product code exists in this harness package | Low; structure checks cover requested scope |

## Backend Architecture Quality Gate

N/A. This task changes harness docs/scripts only, not backend code.

## Review Report

| Review | Reviewer / Method | Verdict | Notes |
|---|---|---|---|
| Spec | Self-review | PASS | Scope is explicit |
| Integration | N/A | N/A | No product API changes |
| Security | N/A | N/A | No secrets or auth changes |
| A11y / responsive | N/A | N/A | No UI changes |
| Final quality | Self-review | PASS | Previous findings addressed: artifact leakage, weak mirror validation, duplicate docs, status field ambiguity |

## Review gates

- [x] Spec review needed?
- [x] Integration review needed? N/A
- [x] Security review needed? N/A
- [x] A11y/responsive review needed? N/A
- [x] Final quality review passed?

## Execution progress

- RED captured.
- GREEN implemented and structure verification passed.
- REFACTOR cleanup applied and verification rerun.
- VERIFY passed.

## Completion Report

- Summary: tightened the harness to resolve the latest review findings and make future drift harder.
- Requirements covered:
  - Codex/Claude agents are verified as synchronized pairs.
  - `00_AGENT_BRIEF.md` is retained as the expanded operating brief.
  - redundant `06_PROJECT_BASELINE.md` and `12_CONTEXT_LOADING_RULE.md` are removed from core source of truth.
  - `.DS_Store` leakage is removed and now fails verification.
  - plan status ambiguity is removed from the template.
- Tests added / changed: strengthened `scripts/verify-harness-structure.sh`.
- Implementation: docs, script, and two Codex agent mirror bodies updated; redundant docs and local artifacts removed.
- Verification:
  - `bash scripts/verify-harness-structure.sh` PASS
  - `find . -name .DS_Store -print` produced no output
  - retired docs absent
  - 21 Codex/Claude mirror bodies synced
  - source-of-truth refs valid
- Review verdict: PASS
- Risk left: low; no product code changes.
- Context docs updated: not needed; this changes harness policy/docs, not target project facts.
- `docs/harness/context/BASELINE.md` / `DECISIONS.md` / 세부 context update needed: no.
