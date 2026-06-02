import unittest

from scripts.harness_lib.completed_plans import plan_missing_markers


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


if __name__ == '__main__':
    unittest.main()
