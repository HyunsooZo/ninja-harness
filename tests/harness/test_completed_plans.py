import unittest
from pathlib import Path
import tempfile

from scripts.harness_lib.completed_plans import completed_plan_files, plan_missing_markers


class CompletedPlanQualityTest(unittest.TestCase):
    def test_accepts_required_evidence_markers(self) -> None:
        text = 'RED\nGREEN\nREFACTOR\nVERIFY\n잔여 위험: none\n'
        self.assertEqual(plan_missing_markers(text), [])

    def test_rejects_missing_residual_risk(self) -> None:
        text = 'RED\nGREEN\nREFACTOR\nVERIFY\n'
        self.assertIn('residual risk', plan_missing_markers(text))

    def test_layered_plan_requires_fan_in_evidence(self) -> None:
        missing = plan_missing_markers('SEQUENTIAL_LAYERED\nRED GREEN REFACTOR VERIFY\n잔여 위험: none\n')
        self.assertIn('integration owner', missing)
        self.assertIn('contract consistency check', missing)

    def test_local_source_reads_untracked_directory_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            completed_dir = Path(tmp)
            plan = completed_dir / 'local.md'
            plan.write_text('RED GREEN REFACTOR VERIFY\n잔여 위험: none\n', encoding='utf-8')
            self.assertEqual(completed_plan_files(completed_dir, 'local'), [plan])

    def test_tracked_source_ignores_external_local_directory(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            completed_dir = Path(tmp)
            (completed_dir / 'local.md').write_text('RED GREEN REFACTOR VERIFY\n잔여 위험: none\n', encoding='utf-8')
            self.assertEqual(completed_plan_files(completed_dir, 'tracked'), [])


if __name__ == '__main__':
    unittest.main()
