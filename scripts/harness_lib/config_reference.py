"""Cross-check helpers for the HARNESS_* configuration reference.

CONFIGURATION.md must document every HARNESS_* env var the harness actually
consumes (scripts/workflows) or declares (harness.yaml), and must not list
ghost vars.
"""
from __future__ import annotations

import ast
import re
from pathlib import Path


_SHELL_READ_PATTERNS = [
    r"\$\{(HARNESS_[A-Z0-9_]+)",
    r"\$\((HARNESS_[A-Z0-9_]+)\)",
    r"(?m)^[ \t]*(HARNESS_[A-Z0-9_]+)\s*[:?]?=",
    r"\benv\s+(HARNESS_[A-Z0-9_]+)=",
    r"(?<![A-Za-z0-9_])(HARNESS_[A-Z0-9_]+)=",
]

_WORKFLOW_READ_PATTERNS = [
    r"(?m)^[ \t]*(HARNESS_[A-Z0-9_]+)\s*:",
    r"(?i:\$env:)(HARNESS_[A-Z0-9_]+)\b",
]

# Boundary-guarded token match (drops path-name false hits like 08_HARNESS_AUDIT.md).
_TOKEN_PATTERN = r"(?<![A-Za-z0-9_])HARNESS_[A-Z0-9_]+"


def _clean(names) -> set[str]:
    return {name for name in names if not name.endswith('_')}


def _strip_hash_comments(text: str) -> str:
    lines: list[str] = []
    for line in text.splitlines():
        in_single = False
        in_double = False
        escaped = False
        kept: list[str] = []
        for char in line:
            if escaped:
                kept.append(char)
                escaped = False
                continue
            if char == '\\' and not in_single:
                kept.append(char)
                escaped = True
                continue
            if char == "'" and not in_double:
                in_single = not in_single
                kept.append(char)
                continue
            if char == '"' and not in_single:
                in_double = not in_double
                kept.append(char)
                continue
            if char == '#' and not in_single and not in_double:
                break
            kept.append(char)
        lines.append(''.join(kept))
    return '\n'.join(lines)


def env_vars_in_text(text: str) -> set[str]:
    """HARNESS_* tokens mentioned in arbitrary text (e.g. CONFIGURATION.md)."""
    return _clean(re.findall(_TOKEN_PATTERN, text))


def _constant_harness_name(node: ast.AST) -> str | None:
    if isinstance(node, ast.Constant) and isinstance(node.value, str):
        value = node.value
        if re.fullmatch(r"HARNESS_[A-Z0-9_]+", value):
            return value
    return None


def _python_env_aliases(tree: ast.AST) -> tuple[set[str], set[str], set[str]]:
    os_aliases = {'os'}
    environ_aliases = {'environ'}
    getenv_aliases = {'getenv'}
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                if alias.name == 'os':
                    os_aliases.add(alias.asname or alias.name)
        if isinstance(node, ast.ImportFrom) and node.module == 'os':
            for alias in node.names:
                target = alias.asname or alias.name
                if alias.name == 'environ':
                    environ_aliases.add(target)
                if alias.name == 'getenv':
                    getenv_aliases.add(target)
    return os_aliases, environ_aliases, getenv_aliases


def _is_environ_ref(node: ast.AST, os_aliases: set[str], environ_aliases: set[str]) -> bool:
    if isinstance(node, ast.Name):
        return node.id in environ_aliases
    if isinstance(node, ast.Attribute):
        return (
            node.attr == 'environ'
            and isinstance(node.value, ast.Name)
            and node.value.id in os_aliases
        )
    return False


def env_vars_consumed_in_python_text(text: str) -> set[str]:
    try:
        tree = ast.parse(text)
    except SyntaxError:
        return set()

    os_aliases, environ_aliases, getenv_aliases = _python_env_aliases(tree)
    found: set[str] = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Call) and node.args:
            func = node.func
            if (
                isinstance(func, ast.Attribute)
                and func.attr == 'get'
                and _is_environ_ref(func.value, os_aliases, environ_aliases)
            ):
                name = _constant_harness_name(node.args[0])
                if name:
                    found.add(name)
            if (
                (isinstance(func, ast.Name) and func.id in (getenv_aliases | {'float_env'}))
                or (
                    isinstance(func, ast.Attribute)
                    and func.attr == 'getenv'
                    and isinstance(func.value, ast.Name)
                    and func.value.id in os_aliases
                )
            ):
                name = _constant_harness_name(node.args[0])
                if name:
                    found.add(name)
        if isinstance(node, ast.Subscript) and _is_environ_ref(node.value, os_aliases, environ_aliases):
            name = _constant_harness_name(node.slice)
            if name:
                found.add(name)
    return found


def env_vars_consumed_in_scripts(root: Path) -> set[str]:
    found: set[str] = set()

    makefile = root / 'Makefile'
    shell_sources = [makefile] if makefile.exists() else []
    shell_sources += sorted((root / 'scripts').glob('*.sh'))
    for src in shell_sources:
        text = _strip_hash_comments(src.read_text(encoding='utf-8'))
        for pattern in _SHELL_READ_PATTERNS:
            found |= _clean(re.findall(pattern, text))

    powershell_sources = sorted((root / 'scripts').glob('*.ps1'))
    for src in powershell_sources:
        text = _strip_hash_comments(src.read_text(encoding='utf-8'))
        for pattern in _WORKFLOW_READ_PATTERNS:
            found |= _clean(re.findall(pattern, text))

    python_sources = sorted((root / 'scripts').glob('*.py'))
    python_sources += sorted((root / 'scripts' / 'harness_lib').glob('*.py'))
    for src in python_sources:
        if not src.exists():
            continue
        found |= env_vars_consumed_in_python_text(src.read_text(encoding='utf-8'))
    return found


def env_vars_consumed_in_workflows(root: Path) -> set[str]:
    found: set[str] = set()
    workflow_dir = root / '.github' / 'workflows'
    workflow_sources = sorted(workflow_dir.glob('*.yml')) + sorted(workflow_dir.glob('*.yaml'))
    for src in workflow_sources:
        text = _strip_hash_comments(src.read_text(encoding='utf-8'))
        for pattern in _WORKFLOW_READ_PATTERNS + _SHELL_READ_PATTERNS:
            found |= _clean(re.findall(pattern, text))
    return found


def env_vars_declared_in_yaml(root: Path) -> set[str]:
    yaml_path = root / 'docs/harness/harness.yaml'
    if not yaml_path.exists():
        return set()
    return env_vars_in_text(yaml_path.read_text(encoding='utf-8'))


def reality_env_vars(root: Path) -> set[str]:
    return (
        env_vars_consumed_in_scripts(root)
        | env_vars_consumed_in_workflows(root)
        | env_vars_declared_in_yaml(root)
    )


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
