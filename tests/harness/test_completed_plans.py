import unittest
from pathlib import Path
import tempfile

from scripts.harness_lib.completed_plans import completed_plan_files, quality_failures, plan_missing_markers


class CompletedPlanQualityTest(unittest.TestCase):
    def test_accepts_required_evidence_markers(self) -> None:
        text = (
            '## RED Evidence\n- 명령: failed test\n'
            '## GREEN Evidence\n- 확인: passed test\n'
            '## REFACTOR Decision\n- 결정: none\n'
            '## VERIFY Evidence\n- 결과: pass\n'
            '## Residual Risk\n- none\n'
        )
        self.assertEqual(plan_missing_markers(text), [])

    def test_rejects_missing_residual_risk(self) -> None:
        text = (
            '## RED Evidence\n- 명령: failed test\n'
            '## GREEN Evidence\n- 확인: passed test\n'
            '## REFACTOR Decision\n- 결정: none\n'
            '## VERIFY Evidence\n- 결과: pass\n'
        )
        self.assertIn('residual risk', plan_missing_markers(text))

    def test_rejects_marker_words_without_evidence_sections(self) -> None:
        text = 'No RED evidence yet. No GREEN evidence yet. No REFACTOR decision yet. No VERIFY evidence yet. No Risk left yet.\n'
        missing = plan_missing_markers(text)
        self.assertIn('RED evidence', missing)
        self.assertIn('GREEN evidence', missing)
        self.assertIn('REFACTOR decision', missing)
        self.assertIn('VERIFY evidence', missing)
        self.assertIn('residual risk', missing)

    def test_rejects_slim_audit_completed_candidate_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            plan = Path(tmp) / 'slim-audit.md'
            plan.write_text(
                '# Slim audit\n\n'
                '## Findings\n\n'
                '- Verdict: PASS\n',
                encoding='utf-8',
            )
            failures = quality_failures([plan])
            self.assertEqual(failures[0][0], plan)
            self.assertIn('RED evidence', failures[0][1])
            self.assertIn('GREEN evidence', failures[0][1])
            self.assertIn('REFACTOR decision', failures[0][1])
            self.assertIn('VERIFY evidence', failures[0][1])
            self.assertIn('residual risk', failures[0][1])

    def test_rejects_empty_evidence_sections(self) -> None:
        text = '## RED Evidence\n\n## GREEN Evidence\n\n## REFACTOR Decision\n\n## VERIFY Evidence\n\n## Residual Risk\n\n'
        missing = plan_missing_markers(text)
        self.assertIn('RED evidence', missing)
        self.assertIn('GREEN evidence', missing)
        self.assertIn('REFACTOR decision', missing)
        self.assertIn('VERIFY evidence', missing)
        self.assertIn('residual risk', missing)

    def test_rejects_pending_evidence_placeholders(self) -> None:
        text = (
            'RED Evidence\n'
            '- 명령: pending\n'
            '- 실패 이유: pending\n'
            'GREEN Evidence\n'
            '- 통과 테스트 / 확인: pending\n'
            'REFACTOR\n'
            '- 변경: pending\n'
            'VERIFY\n'
            '- 결과: pending\n'
            'Risk left: pending\n'
        )
        self.assertIn('pending evidence placeholders', plan_missing_markers(text))

    def test_rejects_pending_label_evidence_placeholders(self) -> None:
        text = (
            'RED Evidence\n'
            '- Pending: add regression test\n'
            'GREEN Evidence\n'
            '- 확인: PASS\n'
            'REFACTOR\n'
            '- 결정: none\n'
            'VERIFY\n'
            '- 결과: PASS\n'
            'Risk left: none\n'
        )
        self.assertIn('pending evidence placeholders', plan_missing_markers(text))

    def test_accepts_documented_temporary_command_placeholders(self) -> None:
        text = (
            '## RED Evidence\n'
            '- 명령: `HARNESS_COMPLETED_PLAN_DIR=<tmp> bash scripts/check-completed-plan-quality.sh`\n'
            '## GREEN Evidence\n- 확인: PASS\n'
            '## REFACTOR Decision\n- 결정: none\n'
            '## VERIFY Evidence\n- 결과: PASS\n'
            '## Residual Risk\n- none\n'
        )
        self.assertEqual(plan_missing_markers(text), [])

    def test_layered_plan_requires_fan_in_evidence(self) -> None:
        missing = plan_missing_markers(
            'SEQUENTIAL_LAYERED\n'
            '## RED Evidence\n- 명령: failed test\n'
            '## GREEN Evidence\n- 확인: passed test\n'
            '## REFACTOR Decision\n- 결정: none\n'
            '## VERIFY Evidence\n- 결과: pass\n'
            '## Residual Risk\n- none\n'
        )
        self.assertIn('integration owner', missing)
        self.assertIn('contract consistency check', missing)

    def test_local_source_reads_untracked_directory_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            completed_dir = Path(tmp)
            plan = completed_dir / 'local.md'
            plan.write_text(
                '## RED Evidence\n- 명령: failed test\n'
                '## GREEN Evidence\n- 확인: passed test\n'
                '## REFACTOR Decision\n- 결정: none\n'
                '## VERIFY Evidence\n- 결과: pass\n'
                '## Residual Risk\n- none\n',
                encoding='utf-8',
            )
            self.assertEqual(completed_plan_files(completed_dir, 'local'), [plan])

    def test_tracked_source_ignores_external_local_directory(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            completed_dir = Path(tmp)
            (completed_dir / 'local.md').write_text(
                '## RED Evidence\n- 명령: failed test\n'
                '## GREEN Evidence\n- 확인: passed test\n'
                '## REFACTOR Decision\n- 결정: none\n'
                '## VERIFY Evidence\n- 결과: pass\n'
                '## Residual Risk\n- none\n',
                encoding='utf-8',
            )
            self.assertEqual(completed_plan_files(completed_dir, 'tracked'), [])


if __name__ == '__main__':
    unittest.main()
