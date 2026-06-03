"""Cross-check helpers for the HARNESS_* configuration reference.

CONFIGURATION.md must document every HARNESS_* env var the harness actually
consumes (scripts) or declares (harness.yaml), and must not list ghost vars.
"""
from __future__ import annotations

import re
from pathlib import Path


# Precise consumption patterns: real env reads, not mere string mentions.
_PYTHON_READ_PATTERNS = [
    r"environ\.get\(\s*['\"](HARNESS_[A-Z0-9_]+)",
    r"environ\[\s*['\"](HARNESS_[A-Z0-9_]+)",
    r"getenv\(\s*['\"](HARNESS_[A-Z0-9_]+)",
    r"float_env\(\s*['\"](HARNESS_[A-Z0-9_]+)",
]

_SHELL_READ_PATTERNS = [
    r"\$\{(HARNESS_[A-Z0-9_]+)",
    r"\$\((HARNESS_[A-Z0-9_]+)\)",
    r"(?m)^[ \t]*(HARNESS_[A-Z0-9_]+)\s*[:?]?=",
    r"\benv\s+(HARNESS_[A-Z0-9_]+)=",
    r"(?<![A-Za-z0-9_])(HARNESS_[A-Z0-9_]+)=",
]

# Boundary-guarded token match (drops path-name false hits like 08_HARNESS_AUDIT.md).
_TOKEN_PATTERN = r"(?<![A-Za-z0-9_])HARNESS_[A-Z0-9_]+"


def _clean(names) -> set[str]:
    return {name for name in names if not name.endswith('_')}


def env_vars_in_text(text: str) -> set[str]:
    """HARNESS_* tokens mentioned in arbitrary text (e.g. CONFIGURATION.md)."""
    return _clean(re.findall(_TOKEN_PATTERN, text))


def env_vars_consumed_in_scripts(root: Path) -> set[str]:
    found: set[str] = set()

    makefile = root / 'Makefile'
    shell_sources = [makefile] if makefile.exists() else []
    shell_sources += sorted((root / 'scripts').glob('*.sh'))
    for src in shell_sources:
        text = src.read_text(encoding='utf-8')
        for pattern in _SHELL_READ_PATTERNS:
            found |= _clean(re.findall(pattern, text))

    python_sources = sorted((root / 'scripts').glob('*.py'))
    python_sources += sorted((root / 'scripts' / 'harness_lib').glob('*.py'))
    for src in python_sources:
        if not src.exists():
            continue
        text = src.read_text(encoding='utf-8')
        for pattern in _PYTHON_READ_PATTERNS:
            found |= _clean(re.findall(pattern, text))
    return found


def env_vars_declared_in_yaml(root: Path) -> set[str]:
    yaml_path = root / 'docs/harness/harness.yaml'
    if not yaml_path.exists():
        return set()
    return env_vars_in_text(yaml_path.read_text(encoding='utf-8'))


def reality_env_vars(root: Path) -> set[str]:
    return env_vars_consumed_in_scripts(root) | env_vars_declared_in_yaml(root)


def documented_env_vars(root: Path) -> set[str]:
    doc_path = root / 'docs/harness/CONFIGURATION.md'
    if not doc_path.exists():
        return set()
    return env_vars_in_text(doc_path.read_text(encoding='utf-8'))


def reference_drift(root: Path) -> tuple[list[str], list[str]]:
    """Return (undocumented, ghost) env var lists. Empty lists mean in sync."""
    documented = documented_env_vars(root)
    reality = reality_env_vars(root)
    undocumented = sorted(reality - documented)
    ghost = sorted(documented - reality)
    return undocumented, ghost
