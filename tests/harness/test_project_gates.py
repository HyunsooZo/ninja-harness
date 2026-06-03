from pathlib import Path
from contextlib import redirect_stderr
import io
import tempfile
import unittest

from scripts.harness_lib import project_gates


class ProjectGateValidationTest(unittest.TestCase):
    def setUp(self) -> None:
        self.original_root = project_gates.ROOT
        self.tmp = tempfile.TemporaryDirectory()
        project_gates.ROOT = Path(self.tmp.name)

    def tearDown(self) -> None:
        project_gates.ROOT = self.original_root
        self.tmp.cleanup()

    def test_rejects_parent_traversal(self) -> None:
        with redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            project_gates.validate_repo_script('../hack.sh')

    def test_rejects_non_allowlisted_path(self) -> None:
        script = project_gates.ROOT / 'tools/test.sh'
        script.parent.mkdir(parents=True)
        script.write_text('#!/usr/bin/env bash\n', encoding='utf-8')
        with redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            project_gates.validate_repo_script('tools/test.sh')

    def test_accepts_allowlisted_script(self) -> None:
        script = project_gates.ROOT / 'scripts/ci/test.py'
        script.parent.mkdir(parents=True)
        script.write_text('print("ok")\n', encoding='utf-8')
        self.assertEqual(project_gates.validate_repo_script('scripts/ci/test.py'), script)

    def test_powershell_script_gate_disables_profile(self) -> None:
        script = project_gates.ROOT / 'scripts/ci/test.ps1'
        script.parent.mkdir(parents=True)
        script.write_text('exit 0\n', encoding='utf-8')
        original = project_gates.powershell_executable
        project_gates.powershell_executable = lambda: 'pwsh'
        try:
            self.assertEqual(
                project_gates.command_for_script(script),
                ['pwsh', '-NoProfile', '-NonInteractive', '-File', str(script)],
            )
        finally:
            project_gates.powershell_executable = original


if __name__ == '__main__':
    unittest.main()
