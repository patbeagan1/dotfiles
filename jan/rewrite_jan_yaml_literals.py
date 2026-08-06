#!/usr/bin/env python3
"""Rewrite jan YAML trees so multiline strings use literal block style (|).

PyYAML's default dumper emits long inlined runners as double-quoted strings
full of `\\n` escapes. It also refuses literal style when a string contains
tabs. This script loads each jan YAML file and re-emits it with a small
custom writer that always uses `|` for multiline scalars (tabs preserved).

Usage:
  python3 rewrite_jan_yaml_literals.py [/path/to/dotfiles/jan]
  python3 rewrite_jan_yaml_literals.py --check [/path/to/dotfiles/jan]
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

import yaml

CATEGORY_HEADER = (
    "# Personal utilities tree for jan (canonical under dotfiles/jan).\n"
    "# Each category file inlines script `help` + `run` bodies.\n"
    "# Multiline exec bodies use YAML literal block style (|).\n"
)

SPEC_HEADER = (
    "# Personal utilities tree for jan (canonical under dotfiles/jan).\n"
    "# Multiline exec bodies use YAML literal block style (|).\n"
)

CATEGORY_FILES = [
    "git.yaml",
    "android.yaml",
    "docker.yaml",
    "network.yaml",
    "media.yaml",
    "files.yaml",
    "text.yaml",
    "tmux.yaml",
    "time.yaml",
    "system.yaml",
    "misc.yaml",
]

INDEX_FILES = [
    "scripts.yaml",
    "scripts.spec.yaml",
]


def load_yaml(path: Path) -> dict:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise SystemExit(f"{path}: expected a mapping at the root")
    return data


def deep_equal(a, b) -> bool:
    if isinstance(a, dict) and isinstance(b, dict):
        if set(a) != set(b):
            return False
        return all(deep_equal(a[k], b[k]) for k in a)
    if isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            return False
        return all(deep_equal(x, y) for x, y in zip(a, b))
    if isinstance(a, str) and isinstance(b, str):
        return a.rstrip("\n") == b.rstrip("\n")
    return a == b


def needs_literal(value: str) -> bool:
    return ("\n" in value) or (len(value) > 120)


_PLAIN_OK = re.compile(r"^[A-Za-z0-9_./:+@%?-][A-Za-z0-9_./:+@%? -]*$")


def emit_scalar(value: str, indent: int) -> str:
    """Emit a YAML scalar at the given indent (spaces before content lines)."""
    pad = " " * indent
    if needs_literal(value):
        text = value if value.endswith("\n") else value + "\n"
        lines = text.splitlines(keepends=True)
        out = ["|\n"]
        for line in lines:
            if line == "\n":
                # Completely empty line is valid inside a literal block.
                out.append("\n")
            elif line.endswith("\n"):
                out.append(f"{pad}{line}")
            else:
                out.append(f"{pad}{line}\n")
        return "".join(out)

    # Prefer plain scalars when safe; otherwise single-quote.
    if value == "" or value.lower() in {"true", "false", "null", "~"} or value[:1] in "-?:,{}[]&*!|>'\"%@`":
        return "'" + value.replace("'", "''") + "'\n"
    if "\n" in value or "#" in value or ": " in value or value.strip() != value:
        return "'" + value.replace("'", "''") + "'\n"
    if _PLAIN_OK.match(value) and not value.endswith(":"):
        return value + "\n"
    return "'" + value.replace("'", "''") + "'\n"


def emit(obj, indent: int = 0, *, after_key: bool = False) -> str:
    """Serialize obj to YAML. `after_key` means we already wrote `key: `."""
    if isinstance(obj, dict):
        if not obj:
            return "{}\n" if after_key else (" " * indent) + "{}\n"
        parts: list[str] = []
        first = True
        for key, value in obj.items():
            key_s = str(key)
            if not re.match(r"^[A-Za-z0-9_.-]+$", key_s):
                key_s = "'" + key_s.replace("'", "''") + "'"
            prefix = "" if (after_key and first) else (" " * indent)
            first = False
            if isinstance(value, (dict, list)):
                if not value:
                    empty = "{}" if isinstance(value, dict) else "[]"
                    parts.append(f"{prefix}{key_s}: {empty}\n")
                else:
                    parts.append(f"{prefix}{key_s}:\n")
                    parts.append(emit(value, indent + 2, after_key=False))
            else:
                # scalar on same line as key
                parts.append(f"{prefix}{key_s}: ")
                parts.append(emit(value, indent + 2, after_key=True))
        return "".join(parts)

    if isinstance(obj, list):
        if not obj:
            return "[]\n" if after_key else (" " * indent) + "[]\n"
        parts = []
        first = True
        for item in obj:
            prefix = "" if (after_key and first) else (" " * indent)
            first = False
            if isinstance(item, (dict, list)):
                if not item:
                    empty = "{}" if isinstance(item, dict) else "[]"
                    parts.append(f"{prefix}- {empty}\n")
                else:
                    parts.append(f"{prefix}-\n")
                    parts.append(emit(item, indent + 2, after_key=False))
            else:
                parts.append(f"{prefix}- ")
                parts.append(emit(item, indent + 2, after_key=True))
        return "".join(parts)

    if obj is None:
        return "null\n"
    if isinstance(obj, bool):
        return ("true" if obj else "false") + "\n"
    if isinstance(obj, int) and not isinstance(obj, bool):
        return f"{obj}\n"
    if isinstance(obj, float):
        return f"{obj}\n"
    if isinstance(obj, str):
        return emit_scalar(obj, indent)
    raise TypeError(f"unsupported YAML type: {type(obj)!r}")


def render_file(path: Path, data: dict) -> str:
    body = emit(data, 0)
    if path.name == "scripts.spec.yaml":
        return SPEC_HEADER + body
    return CATEGORY_HEADER + body


def looks_escaped(text: str) -> bool:
    """True when the file still has PyYAML double-quoted runner blobs."""
    return bool(
        re.search(r'"set -euo pipefail\\n', text)
        or re.search(r'\\ntmpdir=\\"', text)
    )


def count_scripts(jan_dir: Path) -> int:
    total = 0
    for name in CATEGORY_FILES:
        path = jan_dir / name
        if not path.is_file():
            continue
        cmds = load_yaml(path).get("commands") or {}
        if isinstance(cmds, dict):
            total += len(cmds)
    return total


def write_manifest(jan_dir: Path) -> None:
    files: dict[str, str] = {}
    for name in CATEGORY_FILES + ["scripts.yaml"]:
        path = jan_dir / name
        if path.is_file():
            files[name] = hashlib.sha256(path.read_bytes()).hexdigest()
    manifest = {
        "generator_version": "3-literal",
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "script_count": count_scripts(jan_dir),
        "canonical": "dotfiles/jan",
        "style": "yaml-literal",
        "categories": [n for n in CATEGORY_FILES if (jan_dir / n).is_file()],
        "files": files,
    }
    (jan_dir / "manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n",
        encoding="utf-8",
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "jan_dir",
        nargs="?",
        default=str(Path(__file__).resolve().parent),
        help="Path to a flat jan tree (default: directory containing this script)",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Verify literal style / round-trip without writing",
    )
    args = parser.parse_args(argv)
    jan_dir = Path(args.jan_dir).expanduser().resolve()
    if not jan_dir.is_dir():
        print(f"error: not a directory: {jan_dir}", file=sys.stderr)
        return 2

    targets = [
        jan_dir / name
        for name in CATEGORY_FILES + INDEX_FILES
        if (jan_dir / name).is_file()
    ]
    if not targets:
        print(f"error: no jan YAML files found under {jan_dir}", file=sys.stderr)
        return 2

    failures = 0
    for path in targets:
        original = load_yaml(path)
        text = render_file(path, original)
        try:
            reparsed = yaml.safe_load(text)
        except Exception as e:
            print(f"error: {path}: rewritten YAML failed to parse: {e}", file=sys.stderr)
            failures += 1
            continue
        if not deep_equal(original, reparsed):
            print(f"error: {path}: round-trip mismatch", file=sys.stderr)
            failures += 1
            continue

        if args.check:
            current = path.read_text(encoding="utf-8")
            if looks_escaped(current):
                print(f"fail: {path}: still has escaped multiline strings")
                failures += 1
            else:
                print(f"ok: {path}")
            continue

        path.write_text(text, encoding="utf-8")
        print(f"rewrote: {path}")

    if failures:
        return 1

    if not args.check:
        write_manifest(jan_dir)
        print(f"updated: {jan_dir / 'manifest.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
