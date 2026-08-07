#!/usr/bin/env python3
"""Fan category YAML command maps into per-command YAML includes.

Each command (about/help/run/…) becomes scripts/<category>/<name>.yaml.
Category files retain only `about` + `commands: { name: { include: … } }`.

When `run` currently includes a non-YAML script file, the body is restored into
an inlined `exec.argv` (bash -lc / zsh -c / …) so the tree stays YAML-only.

Usage:
  .venv/bin/python fanout_command_yaml.py files.yaml
  .venv/bin/python fanout_command_yaml.py --all
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap, CommentedSeq
from ruamel.yaml.scalarstring import LiteralScalarString

ROOT = Path(__file__).resolve().parent


def make_yaml() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.width = 1000
    y.indent(mapping=2, sequence=4, offset=2)
    return y


def flag_for_argv(argv: list[str] | None) -> tuple[str, str]:
    """Return (prog, -c-style flag) for restoring an inlined body."""
    if not argv:
        return "bash", "-lc"
    prog = str(argv[0])
    base = Path(prog).name
    if base == "zsh":
        return prog, "-c"
    if base.startswith("python"):
        return prog, "-c"
    if base in ("node", "nodejs"):
        return prog, "-e"
    if base == "deno":
        # historical form was `deno eval`
        return "deno", "eval"
    if base == "lua":
        return prog, "-e"
    if base == "elixir":
        return prog, "-e"
    if base == "sbcl":
        return prog, "--script"
    return prog, "-lc"


def strip_shebang(body: str) -> str:
    lines = body.splitlines(keepends=True)
    if lines and lines[0].startswith("#!"):
        lines = lines[1:]
    text = "".join(lines)
    if not text.endswith("\n"):
        text += "\n"
    return text


def restore_run_from_script(run: dict, scripts_root: Path) -> dict:
    """If run.include points at a non-YAML script, fold body into exec.argv."""
    if not isinstance(run, dict) or "include" not in run:
        return run
    inc = run["include"]
    if not isinstance(inc, dict):
        return run
    rel = str(inc.get("path") or "").strip()
    if not rel or rel.endswith(".yaml") or rel.endswith(".yml"):
        return run

    script_path = scripts_root / rel
    if not script_path.is_file():
        # try relative to ROOT
        script_path = ROOT / rel
    if not script_path.is_file():
        raise FileNotFoundError(f"missing script for include: {rel}")

    body = strip_shebang(script_path.read_text())
    argv_prefix = list(inc.get("argv") or [])
    prog, flag = flag_for_argv(argv_prefix)
    passthrough = bool(inc.get("passthrough"))

    new_run = CommentedMap()
    for k, v in run.items():
        if k == "include":
            continue
        new_run[k] = v
    exec_map = CommentedMap()
    seq = CommentedSeq([prog, flag, LiteralScalarString(body)])
    exec_map["argv"] = seq
    if passthrough:
        exec_map["passthrough"] = True
    # copy optional sha256 from include if any
    if inc.get("sha256"):
        # not applicable on argv-only exec; ignore
        pass
    new_run["exec"] = exec_map
    return new_run


def fanout_category(cat_file: Path, dry_run: bool = False) -> tuple[int, list[str]]:
    yaml = make_yaml()
    with cat_file.open() as f:
        data = yaml.load(f)
    if not data or "commands" not in data:
        return 0, [f"skip {cat_file}"]

    cat = cat_file.stem
    out_dir = ROOT / "scripts" / cat
    notes: list[str] = []
    count = 0

    new_commands = CommentedMap()
    for name, node in list(data["commands"].items()):
        if not isinstance(node, dict):
            new_commands[name] = node
            continue

        # Already a pure include of another YAML command file — keep
        if "include" in node and "commands" not in node and "exec" not in node:
            inc = node["include"]
            path = inc if isinstance(inc, str) else (inc or {}).get("path")
            if path and str(path).endswith((".yaml", ".yml")):
                new_commands[name] = node
                notes.append(f"{cat}/{name}: already yaml include")
                continue

        # Build command document: full node with run restored if needed
        cmd_doc = CommentedMap()
        for k, v in node.items():
            cmd_doc[k] = v

        cmds = cmd_doc.get("commands")
        if isinstance(cmds, dict) and "run" in cmds:
            cmds["run"] = restore_run_from_script(cmds["run"], ROOT)

        rel = f"scripts/{cat}/{name}.yaml"
        out_path = out_dir / f"{name}.yaml"

        if dry_run:
            notes.append(f"would write {rel}")
        else:
            out_dir.mkdir(parents=True, exist_ok=True)
            with out_path.open("w") as f:
                yaml.dump(cmd_doc, f)

            wrap = CommentedMap()
            wrap["include"] = rel
            new_commands[name] = wrap
            notes.append(f"wrote {rel}")
        count += 1

    if count and not dry_run:
        new_root = CommentedMap()
        # preserve about and other top-level keys except commands
        for k, v in data.items():
            if k == "commands":
                continue
            new_root[k] = v
        new_root["commands"] = new_commands
        header = (
            f"# Personal utilities tree for jan (canonical under dotfiles/jan).\n"
            f"# Each command is a YAML include under scripts/{cat}/.\n"
        )
        with cat_file.open("w") as f:
            f.write(header)
            yaml.dump(new_root, f)

    return count, notes


def cleanup_non_yaml_scripts(dry_run: bool = False) -> list[str]:
    removed = []
    scripts = ROOT / "scripts"
    if not scripts.is_dir():
        return removed
    for p in scripts.rglob("*"):
        if not p.is_file():
            continue
        if p.suffix.lower() in (".yaml", ".yml"):
            continue
        if dry_run:
            removed.append(f"would remove {p.relative_to(ROOT)}")
        else:
            p.unlink()
            removed.append(f"removed {p.relative_to(ROOT)}")
    return removed


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="*")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--cleanup", action="store_true", help="Delete non-YAML files under scripts/")
    args = ap.parse_args()

    if args.all:
        files = sorted(
            p
            for p in ROOT.glob("*.yaml")
            if p.name not in ("scripts.yaml", "scripts.spec.yaml")
        )
    else:
        files = [Path(f) if Path(f).is_absolute() else ROOT / f for f in args.files]

    if not files and not args.cleanup:
        ap.error("pass category YAML files, --all, and/or --cleanup")

    total = 0
    for f in files:
        n, notes = fanout_category(f, dry_run=args.dry_run)
        total += n
        print(f"== {f.name}: {n} commands ==")
        for line in notes[:5]:
            print(f"  {line}")
        if len(notes) > 5:
            print(f"  … {len(notes) - 5} more")
    print(f"total command YAML files: {total}")

    if args.cleanup:
        removed = cleanup_non_yaml_scripts(dry_run=args.dry_run)
        print(f"cleanup: {len(removed)} non-YAML script files")
        for line in removed[:8]:
            print(f"  {line}")
        if len(removed) > 8:
            print(f"  … {len(removed) - 8} more")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
