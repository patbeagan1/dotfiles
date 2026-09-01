"""Ignore pattern handling for Restic exclude arguments."""

from typing import Any

DEFAULT_IGNORE_PATTERNS: list[str] = [
    "node_modules",
    ".git",
    "__pycache__",
    ".venv",
    "venv",
    "site-packages",
    "build",
    "dist",
    "target",
    ".gradle",
    ".mypy_cache",
    ".pytest_cache",
    ".tox",
    ".eggs",
    ".next",
    ".nuxt",
    ".parcel-cache",
    "coverage",
    ".turbo",
    ".cache",
    "vendor",
    "bower_components",
    ".idea",
    ".terraform",
    "*.pyc",
    "*.pyo",
    "*.class",
    "*.jar",
    "*.o",
    "*.a",
    ".DS_Store",
    ".rs.bk",
]


def get_ignore_patterns(config: dict[str, Any]) -> list[str]:
    """Merge default and config ignore patterns, deduplicated."""
    ignore_section = config.get("ignore", {})
    use_defaults = ignore_section.get("use_defaults", True)
    config_patterns = ignore_section.get("patterns", [])

    if use_defaults:
        patterns = list(DEFAULT_IGNORE_PATTERNS)
        for pattern in config_patterns:
            if pattern not in patterns:
                patterns.append(pattern)
    else:
        patterns = list(config_patterns)

    return patterns


def build_exclude_args(config: dict[str, Any]) -> list[str]:
    """Build restic --exclude and --exclude-caches arguments from config."""
    args: list[str] = ["--exclude-caches"]
    for pattern in get_ignore_patterns(config):
        args.extend(["--exclude", pattern])
    return args
