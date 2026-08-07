#!/usr/bin/env python3
"""Extract inlined jan `run` exec bodies into scripts/<category>/<name>.* and
replace them with include links (local, unhashed).

Uses ruamel.yaml to preserve comments/formatting where possible.

Usage:
  .venv/bin/python extract_script_includes.py files.yaml git.yaml ...
  .venv/bin/python extract_script_includes.py --all
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from ruamel.yaml import YAML
from ruamel.yaml.scalarstring import LiteralScalarString

ROOT = Path(__file__).resolve().parent

INLINE_FLAGS = {"-c", "-lc", "-e"}


def make_yaml() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.width = 1000
    y.indent(mapping=2, sequence=4, offset=2)
    return y


def ext_for(prog: str) -> str:
    base = Path(prog).name
    if base == "zsh":
        return ".zsh"
    if base in ("bash", "sh", "dash", "ksh"):
        return ".sh"
    if base.startswith("python"):
        return ".py"
    if base in ("node", "nodejs"):
        return ".js"
    if base == "deno":
        return ".ts"
    if base == "lua":
        return ".lua"
    if base == "elixir":
        return ".exs"
    if base in ("sbcl", "lisp", "clisp"):
        return ".lisp"
    return ".txt"


def argv_prefix(prog: str, flag: str) -> list[str]:
    base = Path(prog).name
    if base == "deno" and flag == "eval":
        return ["deno", "run", "--quiet"]
    if base == "sbcl":
        return ["sbcl", "--script"]
    return [prog]


def is_inline_script(argv) -> bool:
    if argv is None or len(argv) < 3:
        return False
    prog = str(argv[0])
    flag = str(argv[1])
    body = argv[2]
    if not isinstance(body, str):
        return False
    base = Path(prog).name
    if flag in INLINE_FLAGS:
        return True
    if base == "deno" and flag == "eval":
        return True
    if base == "sbcl" and flag == "--script":
        return "\n" in body or body.strip().startswith("(")
    return False


def strip_body(body: str) -> str:
    if not body.endswith("\n"):
        body = body + "\n"
    return body


def shebang_for(prog: str) -> str:
    base = Path(prog).name
    if base == "zsh":
        return "#!/usr/bin/env zsh\n"
    if base in ("bash", "sh", "dash", "ksh"):
        return "#!/usr/bin/env bash\n"
    if base.startswith("python"):
        return "#!/usr/bin/env python3\n"
    if base in ("node", "nodejs"):
        return "#!/usr/bin/env node\n"
    if base == "lua":
        return "#!/usr/bin/env lua\n"
    if base == "elixir":
        return "#!/usr/bin/env elixir\n"
    return ""


def extract_category(cat_file: Path, dry_run: bool = False) -> tuple[int, list[str]]:
    yaml = make_yaml()
    with cat_file.open() as f:
        data = yaml.load(f)
    if data is None or "commands" not in data:
        return 0, [f"skip {cat_file}: no commands"]

    cat = cat_file.stem
    scripts_dir = ROOT / "scripts" / cat
    extracted = 0
    notes: list[str] = []

    commands = data["commands"]
    for name, node in list(commands.items()):
        if not isinstance(node, dict):
            continue
        cmds = node.get("commands")
        if cmds is None or "run" not in cmds:
            continue
        run = cmds["run"]
        if not isinstance(run, dict):
            continue
        if "include" in run:
            notes.append(f"{cat}/{name}: already include")
            continue
        ex = run.get("exec")
        if not isinstance(ex, dict):
            continue
        argv = ex.get("argv")
        if not is_inline_script(argv):
            continue

        prog = str(argv[0])
        flag = str(argv[1])
        body = strip_body(str(argv[2]))
        passthrough = bool(ex.get("passthrough"))
        about = run.get("about")

        ext = ext_for(prog)
        out_path = scripts_dir / f"{name}{ext}"
        rel = f"scripts/{cat}/{name}{ext}"

        content = body
        sb = shebang_for(prog)
        if sb and not content.lstrip().startswith("#!"):
            content = sb + content

        prefix = argv_prefix(prog, flag)

        # Build replacement run mapping (ruamel CommentedMap-friendly via plain dict)
        from ruamel.yaml.comments import CommentedMap

        new_run = CommentedMap()
        if about is not None:
            new_run["about"] = about
        for k in ("requires", "env", "inputs", "cron", "dependencies", "path", "os"):
            if k in run:
                new_run[k] = run[k]
        inc = CommentedMap()
        inc["path"] = rel
        if prefix:
            from ruamel.yaml.comments import CommentedSeq

            seq = CommentedSeq(prefix)
            inc["argv"] = seq
        if passthrough:
            inc["passthrough"] = True
        new_run["include"] = inc

        if dry_run:
            notes.append(f"would extract {rel} ({len(body)} bytes)")
        else:
            scripts_dir.mkdir(parents=True, exist_ok=True)
            out_path.write_text(content)
            mode = out_path.stat().st_mode
            out_path.chmod(mode | 0o111)
            cmds["run"] = new_run
            notes.append(f"extracted {rel}")
        extracted += 1

    if extracted and not dry_run:
        # Ensure help bodies stay literal where they were
        with cat_file.open("w") as f:
            yaml.dump(data, f)

    return extracted, notes


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="*", help="Category YAML files")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    if args.all:
        files = sorted(
            p
            for p in ROOT.glob("*.yaml")
            if p.name not in ("scripts.yaml", "scripts.spec.yaml")
        )
    else:
        files = [Path(f) if Path(f).is_absolute() else ROOT / f for f in args.files]

    if not files:
        ap.error("pass category YAML files or --all")

    total = 0
    for f in files:
        if not f.exists():
            print(f"missing: {f}", file=sys.stderr)
            return 1
        n, notes = extract_category(f, dry_run=args.dry_run)
        total += n
        print(f"== {f.name}: {n} scripts ==")
        for line in notes:
            print(f"  {line}")
    print(f"total extracted: {total}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
