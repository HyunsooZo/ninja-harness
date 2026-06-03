#!/usr/bin/env python3
from pathlib import Path, PurePosixPath
import argparse
import os
import re
import sys

from harness_lib.stdio import configure_utf8_stdio


configure_utf8_stdio()

SEMVER_RE = re.compile(r'^\d+\.\d+\.\d+$')
REQUIRED_UPGRADE_PATHS = [
    'VERSION',
    'docs/harness/harness.yaml',
    'MANIFEST.md',
    'docs/harness/CHANGELOG.md',
    'docs/harness/UPGRADE.md',
    'docs/harness/OWNERSHIP.md',
    'docs/harness/SECURITY_POLICY.md',
    '.github/CODEOWNERS',
    'LICENSE',
    'scripts/check-harness-upgrade.py',
    'scripts/check-harness-upgrade.ps1',
]
REQUIRED_UPGRADE_TOKENS = [
    'make harness-upgrade',
    'VERSION',
    'harness_version',
    'make integrity',
    'make project-ready',
    'completed plan',
]
OWNERSHIP_PLACEHOLDER_PATHS = [
    'LICENSE',
    '.github/CODEOWNERS',
    'docs/harness/OWNERSHIP.md',
    'docs/harness/SECURITY_POLICY.md',
]
PROJECT_OWNED_PREFIXES = (
    'docs/harness/context/',
    'docs/harness/profiles/',
    'docs/harness/plans/',
)
HARNESS_MANAGED_PREFIXES = (
    '.agents/',
    '.claude/',
    '.codex/',
    '.github/workflows/',
    'docs/harness/',
    'scripts/',
    'tests/harness/',
)
HARNESS_MANAGED_FILES = {
    'AGENTS.md',
    'CLAUDE.md',
    'LICENSE',
    'MANIFEST.md',
    'Makefile',
    'VERSION',
    '.github/CODEOWNERS',
}


def fail(message: str) -> None:
    print(f'[FAIL] {message}', file=sys.stderr)


def read_text(path: Path) -> str:
    return path.read_text(encoding='utf-8', errors='ignore')


def version_tuple(value: str) -> tuple[int, int, int]:
    if not SEMVER_RE.fullmatch(value):
        raise ValueError(f'invalid semver: {value}')
    major, minor, patch = value.split('.')
    return int(major), int(minor), int(patch)


def find_top_level_value(text: str, key: str) -> str:
    match = re.search(rf'^{re.escape(key)}:\s*(\S+)\s*$', text, flags=re.M)
    return match.group(1) if match else ''


def changelog_versions(text: str) -> list[str]:
    return re.findall(r'^##\s+(\d+\.\d+\.\d+)\s*$', text, flags=re.M)


def has_placeholder(text: str) -> bool:
    return bool(re.search(r'<[^>\n]+>|@your-org/', text))


def ownership_placeholder_errors(root: Path) -> list[str]:
    errors: list[str] = []
    for rel_path in OWNERSHIP_PLACEHOLDER_PATHS:
        if has_placeholder(read_text(root / rel_path)):
            errors.append(f'ownership placeholder must be replaced before organization release: {rel_path}')
    return errors


def path_list_from_file(path: Path) -> list[str]:
    items: list[str] = []
    for line in read_text(path).splitlines():
        value = line.strip()
        if not value or value.startswith('#'):
            continue
        normalized = value.replace('\\', '/')
        while normalized.startswith('./'):
            normalized = normalized[2:]
        parsed = PurePosixPath(normalized)
        if parsed.is_absolute() or any(part == '..' for part in parsed.parts):
            raise ValueError(f'changed path must be repository-relative without parent traversal: {value}')
        items.append(parsed.as_posix())
    return sorted(set(items))


def path_list_from_git(root: Path, from_ref: str) -> tuple[list[str], str]:
    import subprocess

    result = subprocess.run(
        ['git', 'diff', '--name-only', '--diff-filter=ACDMRT', f'{from_ref}..HEAD'],
        cwd=root,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        return [], result.stderr.strip() or f'git diff failed for ref: {from_ref}'
    items = [line.strip().replace('\\', '/') for line in result.stdout.splitlines() if line.strip()]
    return sorted(set(items)), ''


def is_project_owned_path(path: str) -> bool:
    return any(path.startswith(prefix) for prefix in PROJECT_OWNED_PREFIXES)


def is_harness_managed_path(path: str) -> bool:
    return path in HARNESS_MANAGED_FILES or any(path.startswith(prefix) for prefix in HARNESS_MANAGED_PREFIXES)


def downstream_audit_errors(
    root: Path,
    downstream_root: Path,
    changed_paths: list[str],
    require_clean_downstream: bool,
) -> list[str]:
    errors: list[str] = []
    if not downstream_root.exists():
        return [f'downstream root does not exist: {downstream_root}']

    manual_review: list[str] = []
    for rel_path in changed_paths:
        if not is_harness_managed_path(rel_path):
            continue
        if is_project_owned_path(rel_path):
            manual_review.append(f'{rel_path} (project-owned path)')
            continue
        template_path = root / rel_path
        downstream_path = downstream_root / rel_path
        if not template_path.exists():
            if downstream_path.exists():
                manual_review.append(f'{rel_path} (deleted upstream file remains downstream)')
        elif template_path.is_file():
            if not downstream_path.exists():
                manual_review.append(f'{rel_path} (missing downstream file)')
            elif not downstream_path.is_file():
                manual_review.append(f'{rel_path} (downstream path is not a file)')
            elif read_text(template_path) != read_text(downstream_path):
                manual_review.append(rel_path)

    if require_clean_downstream and manual_review:
        errors.append('downstream manual merge required for changed harness paths: ' + ', '.join(manual_review))
    return errors


def run_checks(
    root: Path,
    from_version: str | None = None,
    require_filled_ownership: bool = False,
    downstream_root: Path | None = None,
    changed_paths_file: Path | None = None,
    from_ref: str | None = None,
    require_downstream_audit: bool = False,
    require_clean_downstream: bool = False,
) -> list[str]:
    errors: list[str] = []

    for rel_path in REQUIRED_UPGRADE_PATHS:
        if not (root / rel_path).exists():
            errors.append(f'missing required upgrade path: {rel_path}')

    if errors:
        return errors

    version = read_text(root / 'VERSION').strip()
    if not SEMVER_RE.fullmatch(version):
        errors.append(f'VERSION must be semver MAJOR.MINOR.PATCH: {version}')

    harness_yaml = read_text(root / 'docs/harness/harness.yaml')
    manifest = read_text(root / 'MANIFEST.md')
    yaml_version = find_top_level_value(harness_yaml, 'harness_version')
    manifest_version = find_top_level_value(manifest, 'harness_version')
    yaml_schema = find_top_level_value(harness_yaml, 'schema_version')
    manifest_schema = find_top_level_value(manifest, 'schema_version')

    if yaml_version != version:
        errors.append(f'harness.yaml harness_version must match VERSION: {yaml_version} != {version}')
    if manifest_version != version:
        errors.append(f'MANIFEST.md harness_version must match VERSION: {manifest_version} != {version}')
    if not yaml_schema:
        errors.append('harness.yaml missing schema_version')
    if not manifest_schema:
        errors.append('MANIFEST.md missing schema_version')

    changelog = read_text(root / 'docs/harness/CHANGELOG.md')
    upgrade = read_text(root / 'docs/harness/UPGRADE.md')
    if f'## {version}' not in changelog:
        errors.append(f'CHANGELOG.md missing current version entry: {version}')
    for token in REQUIRED_UPGRADE_TOKENS:
        if token not in upgrade:
            errors.append(f'UPGRADE.md missing upgrade token: {token}')

    parsed_changelog_versions = changelog_versions(changelog)
    if version not in parsed_changelog_versions:
        errors.append(f'CHANGELOG.md missing parseable current version heading: {version}')

    if from_version:
        try:
            current_tuple = version_tuple(version)
            previous_tuple = version_tuple(from_version)
        except ValueError as exc:
            errors.append(str(exc))
        else:
            if previous_tuple > current_tuple:
                errors.append(f'from-version must not be newer than VERSION: {from_version} > {version}')
            if previous_tuple < current_tuple:
                delta_versions = [
                    item for item in parsed_changelog_versions
                    if previous_tuple < version_tuple(item) <= current_tuple
                ]
                if not delta_versions:
                    errors.append(f'CHANGELOG.md missing upgrade delta entries from {from_version} to {version}')

    if require_filled_ownership:
        errors.extend(ownership_placeholder_errors(root))

    changed_paths: list[str] = []
    if changed_paths_file:
        if not changed_paths_file.exists():
            errors.append(f'changed paths file does not exist: {changed_paths_file}')
        else:
            try:
                changed_paths.extend(path_list_from_file(changed_paths_file))
            except ValueError as exc:
                errors.append(str(exc))
    if from_ref:
        git_paths, git_error = path_list_from_git(root, from_ref)
        if git_error:
            errors.append(git_error)
        changed_paths.extend(git_paths)
    changed_paths = sorted(set(changed_paths))

    if require_downstream_audit and not downstream_root:
        errors.append('downstream audit requires --downstream-root')
    if downstream_root and require_downstream_audit and not changed_paths:
        errors.append('downstream audit requires --changed-paths-file or --from-ref with at least one changed path')
    if downstream_root and changed_paths:
        errors.extend(downstream_audit_errors(root, downstream_root, changed_paths, require_clean_downstream))

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description='Check harness upgrade readiness metadata.')
    parser.add_argument('--root', default='.', help='Repository root to check.')
    parser.add_argument(
        '--from-version',
        default=None,
        help='Optional downstream version before upgrade; must be semver and not newer than VERSION.',
    )
    parser.add_argument(
        '--require-filled-ownership',
        action='store_true',
        default=(
            os.environ.get('HARNESS_REQUIRE_FILLED_OWNERSHIP', '').strip().lower() in {'1', 'true', 'yes'}
            or os.environ.get('HARNESS_ORG_STANDARD', '').strip().lower() in {'1', 'true', 'yes'}
        ),
        help='Fail when ownership, license, security, or CODEOWNERS files still contain template placeholders.',
    )
    parser.add_argument('--downstream-root', default=None, help='Optional downstream repository root for upgrade conflict audit.')
    parser.add_argument('--changed-paths-file', default=None, help='File containing upstream changed paths, one path per line.')
    parser.add_argument('--from-ref', default=None, help='Optional git ref used to compute upstream changed harness paths.')
    parser.add_argument(
        '--require-downstream-audit',
        action='store_true',
        default=os.environ.get('HARNESS_REQUIRE_DOWNSTREAM_AUDIT', '').strip().lower() in {'1', 'true', 'yes'},
        help='Require downstream-root and changed path input before accepting upgrade readiness.',
    )
    parser.add_argument(
        '--require-clean-downstream',
        action='store_true',
        default=os.environ.get('HARNESS_REQUIRE_CLEAN_DOWNSTREAM', '').strip().lower() in {'1', 'true', 'yes'},
        help='Fail when changed harness-owned paths differ in the downstream repository and need manual merge.',
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    downstream_root = Path(args.downstream_root).resolve() if args.downstream_root else None
    changed_paths_file = Path(args.changed_paths_file).resolve() if args.changed_paths_file else None
    errors = run_checks(
        root,
        args.from_version,
        args.require_filled_ownership,
        downstream_root,
        changed_paths_file,
        args.from_ref,
        args.require_downstream_audit,
        args.require_clean_downstream,
    )
    if errors:
        for error in errors:
            fail(error)
        return 1

    version = read_text(root / 'VERSION').strip()
    if args.from_version and args.from_version != version:
        print(f'[OK] harness upgrade metadata ready: {args.from_version} -> {version}')
    else:
        print(f'[OK] harness upgrade metadata ready: {version}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
