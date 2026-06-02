#!/usr/bin/env python3
from pathlib import Path
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


def run_checks(
    root: Path,
    from_version: str | None = None,
    require_filled_ownership: bool = False,
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
        default=os.environ.get('HARNESS_REQUIRE_FILLED_OWNERSHIP', '').strip().lower() in {'1', 'true', 'yes'},
        help='Fail when ownership, license, security, or CODEOWNERS files still contain template placeholders.',
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    errors = run_checks(root, args.from_version, args.require_filled_ownership)
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
