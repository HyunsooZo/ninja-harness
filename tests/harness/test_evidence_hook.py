from pathlib import Path
import importlib.util
import os
import subprocess
import sys
import tempfile
import unittest


def load_hook_module():
    path = Path(__file__).resolve().parents[2] / 'scripts/check-evidence-gate-hook.py'
    scripts_dir = str(path.parent)
    if scripts_dir not in sys.path:
        sys.path.insert(0, scripts_dir)
    spec = importlib.util.spec_from_file_location('check_evidence_gate_hook', path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


HOOK_PATH = Path(__file__).resolve().parents[2] / 'scripts/check-evidence-gate-hook.py'


class EvidenceHookScopeTest(unittest.TestCase):
    def setUp(self) -> None:
        self.hook = load_hook_module()
        self.original_active_dir = self.hook.ACTIVE_PLAN_DIR
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        self.hook.ACTIVE_PLAN_DIR = root / 'docs/harness/plans/active'
        self.hook.ACTIVE_PLAN_DIR.mkdir(parents=True)

    def tearDown(self) -> None:
        self.hook.ACTIVE_PLAN_DIR = self.original_active_dir
        self.tmp.cleanup()

    def write_plan(self, text: str) -> None:
        (self.hook.ACTIVE_PLAN_DIR / 'plan.md').write_text(text, encoding='utf-8')

    def test_state_only_red_is_not_evidence(self) -> None:
        self.write_plan('# Plan\n\n- Plan State: `red`\n')
        self.assertFalse(self.hook.evidence_ready_for_target('src/app.py'))

    def test_unrelated_scope_does_not_allow_target(self) -> None:
        self.write_plan('# Plan\n\n## RED Evidence\n\n- 예외 사유: fixture\n\n## Scope\n\n- `docs/**`\n')
        self.assertFalse(self.hook.evidence_ready_for_target('src/app.py'))

    def test_matching_scope_allows_target(self) -> None:
        self.write_plan('# Plan\n\n## RED Evidence\n\n- 예외 사유: fixture\n- 대체 검증: fixture\n\n## Scope\n\n- `src/**`\n')
        self.assertTrue(self.hook.evidence_ready_for_target('src/app.py'))

    def test_parent_traversal_scope_does_not_allow_target(self) -> None:
        self.write_plan('# Plan\n\n## RED Evidence\n\n- 예외 사유: fixture\n- 대체 검증: fixture\n\n## Scope\n\n- `../src/**`\n')
        self.assertFalse(self.hook.evidence_ready_for_target('src/app.py'))

    def test_absolute_target_does_not_match_broad_scope(self) -> None:
        self.write_plan('# Plan\n\n## RED Evidence\n\n- 예외 사유: fixture\n- 대체 검증: fixture\n\n## Scope\n\n- `*`\n')
        self.assertFalse(self.hook.evidence_ready_for_target('/tmp/outside.py'))

    def test_paths_outside_explicit_scope_do_not_allow_target(self) -> None:
        self.write_plan(
            '# Plan\n\n'
            'Notes mention `src/**` as historical context only.\n\n'
            '## RED Evidence\n\n'
            '- 예외 사유: fixture\n\n'
            '## Scope\n\n'
            '- `docs/**`\n'
        )
        self.assertFalse(self.hook.evidence_ready_for_target('src/app.py'))

    def test_files_section_does_not_allow_target(self) -> None:
        self.write_plan('# Plan\n\n## RED Evidence\n\n- 예외 사유: fixture\n- 대체 검증: fixture\n\n## Files\n\n- `src/**`\n')
        self.assertFalse(self.hook.evidence_ready_for_target('src/app.py'))

    def test_risk_left_only_is_not_red_evidence(self) -> None:
        self.write_plan('# Plan\n\n## RED Evidence\n\n- Risk left: fixture\n\n## Scope\n\n- `src/**`\n')
        self.assertFalse(self.hook.evidence_ready_for_target('src/app.py'))

    def test_narrative_failure_word_only_is_not_red_evidence(self) -> None:
        self.write_plan('# Plan\n\n## RED Evidence\n\n실패를 재현했다.\n\n## Scope\n\n- `src/**`\n')
        self.assertFalse(self.hook.evidence_ready_for_target('src/app.py'))

    def test_root_bare_filename_in_scope_allows_target(self) -> None:
        self.write_plan('# Plan\n\n## RED Evidence\n\n- 예외 사유: fixture\n- 대체 검증: fixture\n\n## Scope\n\n- `MANIFEST.md`\n')
        self.assertTrue(self.hook.evidence_ready_for_target('MANIFEST.md'))

    def test_extensionless_root_file_in_scope_allows_target(self) -> None:
        root = Path(self.tmp.name)
        (root / 'VERSION').write_text('0.0.0\n', encoding='utf-8')
        patterns = self.hook.scoped_patterns('- `VERSION`\n', root=root)
        self.assertIn('VERSION', patterns)

    def test_whitespace_backtick_is_not_a_scope_pattern(self) -> None:
        patterns = self.hook.scoped_patterns('- `bash scripts/run.sh`\n')
        self.assertNotIn('bash scripts/run.sh', patterns)

    def test_bypass_mode_requires_audit_reason(self) -> None:
        env = os.environ.copy()
        env['CLAUDE_PROJECT_DIR'] = str(Path(self.tmp.name))
        env['HARNESS_EVIDENCE_HOOK_MODE'] = 'off'
        env.pop('HARNESS_EVIDENCE_HOOK_BYPASS_REASON', None)
        result = subprocess.run(
            [sys.executable, str(HOOK_PATH)],
            input='{"tool_name":"Edit","tool_input":{"file_path":"src/app.py"}}',
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            check=False,
        )
        self.assertEqual(result.returncode, 2)
        self.assertIn('bypass without audit reason', result.stderr)

    def test_bypass_mode_accepts_audit_reason(self) -> None:
        env = os.environ.copy()
        env['CLAUDE_PROJECT_DIR'] = str(Path(self.tmp.name))
        env['HARNESS_EVIDENCE_HOOK_MODE'] = 'off'
        env['HARNESS_EVIDENCE_HOOK_BYPASS_REASON'] = 'approved emergency fixture'
        result = subprocess.run(
            [sys.executable, str(HOOK_PATH)],
            input='{"tool_name":"Edit","tool_input":{"file_path":"src/app.py"}}',
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            check=False,
        )
        self.assertEqual(result.returncode, 0)
        self.assertIn('approved emergency fixture', result.stderr)


if __name__ == '__main__':
    unittest.main()
