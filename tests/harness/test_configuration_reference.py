import tempfile
import unittest
from pathlib import Path

from scripts.harness_lib.config_reference import (
    env_vars_in_text,
    reality_env_vars,
    reference_drift,
)

REPO_ROOT = Path(__file__).resolve().parents[2]


class ConfigurationReferenceTest(unittest.TestCase):
    def test_repo_reference_is_in_sync(self) -> None:
        undocumented, ghost = reference_drift(REPO_ROOT)
        self.assertEqual(undocumented, [])
        self.assertEqual(ghost, [])

    def test_path_name_is_not_treated_as_env_var(self) -> None:
        # 08_HARNESS_AUDIT.md must not yield a HARNESS_AUDIT env var.
        self.assertNotIn('HARNESS_AUDIT', env_vars_in_text('see docs/harness/08_HARNESS_AUDIT.md'))
        self.assertIn('HARNESS_ORG_STANDARD', env_vars_in_text('set `HARNESS_ORG_STANDARD` to 1'))

    def _scaffold(self, tmp: Path, script_body: str, doc_body: str) -> None:
        (tmp / 'scripts' / 'harness_lib').mkdir(parents=True)
        (tmp / 'docs' / 'harness').mkdir(parents=True)
        (tmp / 'Makefile').write_text(script_body, encoding='utf-8')
        (tmp / 'docs' / 'harness' / 'harness.yaml').write_text('project:\n  name: t\n', encoding='utf-8')
        (tmp / 'docs' / 'harness' / 'CONFIGURATION.md').write_text(doc_body, encoding='utf-8')

    def test_detects_undocumented_var(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            tmp = Path(raw)
            self._scaffold(tmp, 'HARNESS_NEW_FLAG ?= 1\n', '# config\n(no vars)\n')
            self.assertIn('HARNESS_NEW_FLAG', reality_env_vars(tmp))
            undocumented, ghost = reference_drift(tmp)
            self.assertIn('HARNESS_NEW_FLAG', undocumented)
            self.assertEqual(ghost, [])

    def test_detects_ghost_var(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            tmp = Path(raw)
            self._scaffold(tmp, 'all:\n\techo ok\n', '| `HARNESS_GHOST_ONLY` | doc-only |\n')
            undocumented, ghost = reference_drift(tmp)
            self.assertEqual(undocumented, [])
            self.assertIn('HARNESS_GHOST_ONLY', ghost)

    def test_python_constants_are_not_env_vars(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            tmp = Path(raw)
            self._scaffold(tmp, 'all:\n\techo ok\n', '# config\n(no vars)\n')
            script = tmp / 'scripts' / 'example.py'
            script.write_text('HARNESS_NOT_ENV = {"fixture"}\n', encoding='utf-8')
            self.assertNotIn('HARNESS_NOT_ENV', reality_env_vars(tmp))


if __name__ == '__main__':
    unittest.main()
