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

    def test_python_comments_and_strings_are_not_env_vars(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            tmp = Path(raw)
            self._scaffold(tmp, 'all:\n\techo ok\n', '# config\n(no vars)\n')
            script = tmp / 'scripts' / 'example.py'
            script.write_text(
                '# os.environ.get("HARNESS_PY_COMMENT")\n'
                'doc = """os.environ.get("HARNESS_PY_DOCSTRING")"""\n',
                encoding='utf-8',
            )

            reality = reality_env_vars(tmp)
            self.assertNotIn('HARNESS_PY_COMMENT', reality)
            self.assertNotIn('HARNESS_PY_DOCSTRING', reality)

    def test_python_env_import_aliases_are_tracked(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            tmp = Path(raw)
            self._scaffold(tmp, 'all:\n\techo ok\n', '# config\n(no vars)\n')
            script = tmp / 'scripts' / 'example.py'
            script.write_text(
                'import os as operating_system\n'
                'from os import getenv as read_env\n'
                'from os import environ as env_map\n'
                'operating_system.getenv("HARNESS_OS_ALIAS")\n'
                'read_env("HARNESS_GETENV_ALIAS")\n'
                'env_map.get("HARNESS_ENVIRON_ALIAS")\n',
                encoding='utf-8',
            )

            reality = reality_env_vars(tmp)
            self.assertIn('HARNESS_OS_ALIAS', reality)
            self.assertIn('HARNESS_GETENV_ALIAS', reality)
            self.assertIn('HARNESS_ENVIRON_ALIAS', reality)

    def test_python_non_env_objects_are_not_env_vars(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            tmp = Path(raw)
            self._scaffold(tmp, 'all:\n\techo ok\n', '# config\n(no vars)\n')
            script = tmp / 'scripts' / 'example.py'
            script.write_text(
                'class Config:\n'
                '    environ = {}\n'
                '    def getenv(self, name):\n'
                '        return None\n'
                'config = Config()\n'
                'config.getenv("HARNESS_CONFIG_GETENV")\n'
                'config.environ.get("HARNESS_CONFIG_ENVIRON")\n',
                encoding='utf-8',
            )

            reality = reality_env_vars(tmp)
            self.assertNotIn('HARNESS_CONFIG_GETENV', reality)
            self.assertNotIn('HARNESS_CONFIG_ENVIRON', reality)

    def test_detects_workflow_env_vars(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            tmp = Path(raw)
            self._scaffold(tmp, 'all:\n\techo ok\n', '# config\n(no vars)\n')
            workflow_dir = tmp / '.github' / 'workflows'
            workflow_dir.mkdir(parents=True)
            (workflow_dir / 'verify.yml').write_text(
                'jobs:\n'
                '  verify:\n'
                '    env:\n'
                '      HARNESS_WORKFLOW_FLAG: "1"\n'
                '    steps:\n'
                '      - shell: pwsh\n'
                '        run: |\n'
                '          $env:HARNESS_WORKFLOW_PS_FLAG = "1"\n',
                encoding='utf-8',
            )

            reality = reality_env_vars(tmp)
            self.assertIn('HARNESS_WORKFLOW_FLAG', reality)
            self.assertIn('HARNESS_WORKFLOW_PS_FLAG', reality)

    def test_detects_powershell_script_env_vars(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            tmp = Path(raw)
            self._scaffold(tmp, 'all:\n\techo ok\n', '# config\n(no vars)\n')
            script = tmp / 'scripts' / 'example.ps1'
            script.write_text(
                '$env:HARNESS_PS_SCRIPT_FLAG = "1"\n'
                'Write-Host $env:HARNESS_PS_SCRIPT_READ_FLAG\n',
                encoding='utf-8',
            )

            reality = reality_env_vars(tmp)
            self.assertIn('HARNESS_PS_SCRIPT_FLAG', reality)
            self.assertIn('HARNESS_PS_SCRIPT_READ_FLAG', reality)

    def test_detects_powershell_env_provider_case_insensitively(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            tmp = Path(raw)
            self._scaffold(tmp, 'all:\n\techo ok\n', '# config\n(no vars)\n')
            script = tmp / 'scripts' / 'example.ps1'
            script.write_text('$Env:HARNESS_PS_CASE_FLAG = "1"\n', encoding='utf-8')

            reality = reality_env_vars(tmp)
            self.assertIn('HARNESS_PS_CASE_FLAG', reality)

    def test_comments_are_not_env_vars(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            tmp = Path(raw)
            self._scaffold(tmp, '# HARNESS_SCRIPT_COMMENT=1\n', '# config\n(no vars)\n')
            workflow_dir = tmp / '.github' / 'workflows'
            workflow_dir.mkdir(parents=True)
            (workflow_dir / 'verify.yml').write_text(
                '# HARNESS_WORKFLOW_COMMENT=1\n'
                'jobs:\n'
                '  verify:\n'
                '    steps:\n'
                '      - run: echo ok # HARNESS_WORKFLOW_INLINE_COMMENT=1\n',
                encoding='utf-8',
            )

            reality = reality_env_vars(tmp)
            self.assertNotIn('HARNESS_SCRIPT_COMMENT', reality)
            self.assertNotIn('HARNESS_WORKFLOW_COMMENT', reality)
            self.assertNotIn('HARNESS_WORKFLOW_INLINE_COMMENT', reality)


if __name__ == '__main__':
    unittest.main()
