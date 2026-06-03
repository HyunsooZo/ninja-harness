from pathlib import Path
import importlib.util
import sys
import tempfile
import unittest
import subprocess


def load_upgrade_module():
    path = Path(__file__).resolve().parents[2] / 'scripts/check-harness-upgrade.py'
    scripts_dir = str(path.parent)
    if scripts_dir not in sys.path:
        sys.path.insert(0, scripts_dir)
    spec = importlib.util.spec_from_file_location('check_harness_upgrade', path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class UpgradeCheckerTest(unittest.TestCase):
    def setUp(self) -> None:
        self.mod = load_upgrade_module()
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name) / 'template'
        self.downstream = Path(self.tmp.name) / 'downstream'
        self.root.mkdir()
        self.downstream.mkdir()
        self.write_required_template()

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def write(self, root: Path, rel_path: str, text: str) -> None:
        path = root / rel_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding='utf-8')

    def write_required_template(self) -> None:
        for rel_path in self.mod.REQUIRED_UPGRADE_PATHS:
            self.write(self.root, rel_path, 'ok\n')
        self.write(self.root, 'VERSION', '1.2.3\n')
        self.write(self.root, 'docs/harness/harness.yaml', 'schema_version: 1\nharness_version: 1.2.3\n')
        self.write(self.root, 'MANIFEST.md', 'schema_version: 1\nharness_version: 1.2.3\n')
        self.write(self.root, 'docs/harness/CHANGELOG.md', '# Changelog\n\n## 1.2.3\n\n- fixture\n')
        self.write(
            self.root,
            'docs/harness/UPGRADE.md',
            'make harness-upgrade\nVERSION\nharness_version\nmake integrity\nmake project-ready\ncompleted plan\n',
        )

    def test_org_standard_requires_filled_ownership(self) -> None:
        self.write(self.root, 'LICENSE', 'owner <organization-or-owner>\n')
        errors = self.mod.run_checks(self.root, require_filled_ownership=True)
        self.assertIn('ownership placeholder must be replaced before organization release: LICENSE', errors)

    def test_required_downstream_audit_requires_inputs(self) -> None:
        errors = self.mod.run_checks(self.root, require_downstream_audit=True)
        self.assertIn('downstream audit requires --downstream-root', errors)

    def test_changed_paths_reject_parent_traversal(self) -> None:
        changed_paths = Path(self.tmp.name) / 'changed-paths.txt'
        changed_paths.write_text('../scripts/check-harness-upgrade.py\n', encoding='utf-8')
        errors = self.mod.run_checks(
            self.root,
            downstream_root=self.downstream,
            changed_paths_file=changed_paths,
            require_downstream_audit=True,
        )
        self.assertIn('changed path must be repository-relative without parent traversal: ../scripts/check-harness-upgrade.py', errors)

    def test_changed_paths_reject_absolute_path(self) -> None:
        changed_paths = Path(self.tmp.name) / 'changed-paths.txt'
        changed_paths.write_text('/tmp/scripts/check-harness-upgrade.py\n', encoding='utf-8')
        errors = self.mod.run_checks(
            self.root,
            downstream_root=self.downstream,
            changed_paths_file=changed_paths,
            require_downstream_audit=True,
        )
        self.assertIn('changed path must be repository-relative without parent traversal: /tmp/scripts/check-harness-upgrade.py', errors)

    def test_clean_downstream_audit_detects_changed_harness_file(self) -> None:
        changed_paths = Path(self.tmp.name) / 'changed-paths.txt'
        changed_paths.write_text('scripts/check-harness-upgrade.py\n', encoding='utf-8')
        self.write(self.downstream, 'scripts/check-harness-upgrade.py', 'downstream local edit\n')
        errors = self.mod.run_checks(
            self.root,
            downstream_root=self.downstream,
            changed_paths_file=changed_paths,
            require_downstream_audit=True,
            require_clean_downstream=True,
        )
        self.assertEqual(
            errors,
            ['downstream manual merge required for changed harness paths: scripts/check-harness-upgrade.py'],
        )

    def test_downstream_audit_flags_project_owned_path_for_manual_review(self) -> None:
        changed_paths = Path(self.tmp.name) / 'changed-paths.txt'
        changed_paths.write_text('docs/harness/context/BASELINE.md\n', encoding='utf-8')
        errors = self.mod.run_checks(
            self.root,
            downstream_root=self.downstream,
            changed_paths_file=changed_paths,
            require_downstream_audit=True,
            require_clean_downstream=True,
        )
        self.assertEqual(
            errors,
            ['downstream manual merge required for changed harness paths: docs/harness/context/BASELINE.md (project-owned path)'],
        )

    def test_clean_downstream_audit_detects_missing_new_managed_file(self) -> None:
        changed_paths = Path(self.tmp.name) / 'changed-paths.txt'
        changed_paths.write_text('scripts/new-upstream-tool.py\n', encoding='utf-8')
        self.write(self.root, 'scripts/new-upstream-tool.py', 'new upstream file\n')
        errors = self.mod.run_checks(
            self.root,
            downstream_root=self.downstream,
            changed_paths_file=changed_paths,
            require_downstream_audit=True,
            require_clean_downstream=True,
        )
        self.assertEqual(
            errors,
            ['downstream manual merge required for changed harness paths: scripts/new-upstream-tool.py (missing downstream file)'],
        )

    def test_clean_downstream_audit_detects_deleted_upstream_managed_file(self) -> None:
        changed_paths = Path(self.tmp.name) / 'changed-paths.txt'
        changed_paths.write_text('scripts/old-upstream-tool.py\n', encoding='utf-8')
        self.write(self.downstream, 'scripts/old-upstream-tool.py', 'stale downstream file\n')
        errors = self.mod.run_checks(
            self.root,
            downstream_root=self.downstream,
            changed_paths_file=changed_paths,
            require_downstream_audit=True,
            require_clean_downstream=True,
        )
        self.assertEqual(
            errors,
            ['downstream manual merge required for changed harness paths: scripts/old-upstream-tool.py (deleted upstream file remains downstream)'],
        )

    def test_git_changed_paths_include_deleted_managed_file(self) -> None:
        repo = Path(self.tmp.name) / 'git-template'
        repo.mkdir()
        self.write(repo, 'scripts/old-upstream-tool.py', 'old upstream file\n')
        subprocess.run(['git', 'init', '--quiet'], cwd=repo, check=True)
        subprocess.run(['git', 'add', 'scripts/old-upstream-tool.py'], cwd=repo, check=True)
        subprocess.run(
            ['git', '-c', 'user.name=Test User', '-c', 'user.email=test@example.com', 'commit', '--quiet', '-m', 'initial'],
            cwd=repo,
            check=True,
        )
        (repo / 'scripts/old-upstream-tool.py').unlink()
        subprocess.run(['git', 'add', '-u'], cwd=repo, check=True)
        subprocess.run(
            ['git', '-c', 'user.name=Test User', '-c', 'user.email=test@example.com', 'commit', '--quiet', '-m', 'delete old tool'],
            cwd=repo,
            check=True,
        )
        paths, error = self.mod.path_list_from_git(repo, 'HEAD~1')
        self.assertEqual(error, '')
        self.assertIn('scripts/old-upstream-tool.py', paths)


if __name__ == '__main__':
    unittest.main()
