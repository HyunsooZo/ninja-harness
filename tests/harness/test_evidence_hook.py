from pathlib import Path
import importlib.util
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


if __name__ == '__main__':
    unittest.main()
