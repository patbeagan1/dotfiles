#!/usr/bin/env python3
"""Rewrite jan YAML run wrappers: drop mktemp+heredoc antipattern.

Replaces bash -lc wrappers that write a temp script and exec it with a direct
interpreter invocation whose argv body is the script itself.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

EXEC_RE = re.compile(r'^(\s*)exec "\$tmpdir/([^"]+)" "\$@"\s*$')
MKTEMP_RE = re.compile(r'tmpdir="\$\(mktemp -d\)"')
CAT_RE = re.compile(r'^(\s*)cat >"\$tmpdir/([^"]+)" <<\'([^\']+)\'\s*$')


def dedent_lines(lines: list[str]) -> list[str]:
    indents = [len(l) - len(l.lstrip(" ")) for l in lines if l.strip()]
    if not indents:
        return lines
    mid = min(indents)
    return [l[mid:] if len(l) >= mid else l for l in lines]


def interpret_env_prog(prog: str) -> list[str]:
    if prog == "bash":
        return ["bash", "-lc"]
    if prog == "sh":
        return ["sh", "-c"]
    if prog == "zsh":
        return ["zsh", "-c"]
    if prog.startswith("python"):
        return ["python3", "-c"]
    if prog == "node":
        return ["node", "-e"]
    if prog == "lua":
        return ["lua", "-e"]
    if prog == "elixir":
        return ["elixir", "-e"]
    if prog == "deno":
        return ["deno", "eval", "--ext=ts"]
    return ["bash", "-lc"]


def parse_shebang(body_lines: list[str]) -> tuple[list[str], list[str]]:
    """Return (argv_prefix without code, body_lines without shebang)."""
    lines = list(body_lines)
    while lines and not lines[0].strip():
        lines.pop(0)
    if not lines or not lines[0].startswith("#!"):
        return ["bash", "-lc"], lines

    shebang = lines[0][2:].strip()
    rest = lines[1:]
    while rest and not rest[0].strip():
        rest.pop(0)

    if shebang.startswith("/usr/bin/env -S "):
        parts = shebang[len("/usr/bin/env -S ") :].split()
        if parts and parts[0] == "deno":
            flags = [p for p in parts[1:] if p.startswith("-")]
            return ["deno", "eval", "--ext=ts", *flags], rest
        return parts, rest
    if shebang.startswith("/usr/bin/env "):
        parts = shebang[len("/usr/bin/env ") :].split()
        prog = parts[0] if parts else "bash"
        return interpret_env_prog(prog), rest
    if "zsh" in shebang:
        return ["zsh", "-c"], rest
    if "bash" in shebang:
        return ["bash", "-lc"], rest
    if shebang.startswith("/bin/sh") or shebang.endswith("/sh"):
        return ["sh", "-c"], rest
    if "python" in shebang:
        return ["python3", "-c"], rest
    if "node" in shebang:
        return ["node", "-e"], rest
    if "lua" in shebang:
        return ["lua", "-e"], rest
    if "elixir" in shebang:
        return ["elixir", "-e"], rest
    if "sbcl" in shebang:
        wrapped = (
            ["set -euo pipefail", "sbcl --script /dev/stdin <<'JAN_SBCL_EOF'"]
            + rest
            + ["JAN_SBCL_EOF"]
        )
        return ["bash", "-lc"], wrapped
    return ["bash", "-lc"], rest


def yaml_quote(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def render_argv_block(
    indent: str, argv_head: list[str], code: str, passthrough: bool
) -> list[str]:
    item = indent + "  - "
    code_indent = indent + "    "
    out = [f"{indent}argv:"]
    for part in argv_head:
        out.append(f"{item}{yaml_quote(part)}")
    out.append(f"{item}|")
    for cl in code.splitlines():
        if cl.strip():
            out.append(code_indent + cl)
        else:
            out.append("")
    # Do not inject a fake $0: with `passthrough: true`, jan appends user args after
    # the -c/-lc string, matching classic `bash -lc '…' -- args` ($0=--, $@=args).
    return out


def extract_heredoc(lines: list[str], start_idx: int, tag: str) -> list[str]:
    body: list[str] = []
    j = start_idx + 1
    while j < len(lines):
        if lines[j].strip() == tag:
            return body
        body.append(lines[j])
        j += 1
    raise ValueError(f"unclosed heredoc {tag}")


def find_wrapper_start(lines: list[str], exec_idx: int) -> int | None:
    for j in range(exec_idx, max(-1, exec_idx - 5000), -1):
        if MKTEMP_RE.search(lines[j]):
            start = j
            if start > 0 and "set -euo pipefail" in lines[start - 1]:
                start -= 1
            return start
        # don't cross into a previous script's run block blindly forever —
        # but heredocs can be long; 5000 lines is enough for this tree.
    return None


def rewrite_file(path: Path, dry_run: bool = False) -> int:
    lines = path.read_text().splitlines()
    replacements: list[tuple[int, int, list[str]]] = []
    i = 0
    count = 0
    while i < len(lines):
        m = EXEC_RE.match(lines[i])
        if not m:
            i += 1
            continue
        exe_name = m.group(2)
        start = find_wrapper_start(lines, i)
        if start is None:
            print(f"WARN {path}: exec without mktemp at line {i+1}", file=sys.stderr)
            i += 1
            continue

        cat_idx = tag = None
        for j in range(start, i):
            cm = CAT_RE.match(lines[j])
            if cm and cm.group(2) == exe_name:
                cat_idx, tag = j, cm.group(3)
                break
        if cat_idx is None:
            print(f"WARN {path}: no heredoc for {exe_name} at line {i+1}", file=sys.stderr)
            i += 1
            continue

        body = dedent_lines(extract_heredoc(lines, cat_idx, tag))
        argv_head, body = parse_shebang(body)
        code = "\n".join(body).rstrip() + "\n"

        passthrough = False
        for j in range(i + 1, min(len(lines), i + 8)):
            if re.match(r"^\s*passthrough:\s*true\s*$", lines[j]):
                passthrough = True
                break
            stripped = lines[j].strip()
            if stripped and not stripped.startswith("#") and "passthrough" not in stripped:
                if not lines[j].startswith(" ") and not lines[j].startswith("\t"):
                    break

        argv_line = None
        for j in range(start, max(-1, start - 20), -1):
            if re.match(r"^\s*argv:\s*$", lines[j]):
                argv_line = j
                break
        if argv_line is None:
            print(f"WARN {path}: no argv: above wrapper at {i+1}", file=sys.stderr)
            i += 1
            continue

        argv_indent = re.match(r"^(\s*)", lines[argv_line]).group(1)
        base_indent = len(argv_indent)
        k = argv_line + 1
        true_end = argv_line + 1
        while k < len(lines):
            if not lines[k].strip():
                k += 1
                continue
            ind = len(lines[k]) - len(lines[k].lstrip(" "))
            stripped = lines[k].lstrip()
            if ind <= base_indent and not stripped.startswith("-"):
                true_end = k
                break
            true_end = k + 1
            k += 1
        else:
            true_end = len(lines)

        new_argv = render_argv_block(argv_indent, argv_head, code, passthrough)
        replacements.append((argv_line, true_end, new_argv))
        count += 1
        i = true_end

    if not replacements:
        return 0

    for start, end, new_lines in sorted(replacements, key=lambda t: t[0], reverse=True):
        lines[start:end] = new_lines

    if not dry_run:
        path.write_text("\n".join(lines) + "\n")
    return count


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "root",
        nargs="?",
        default=str(Path(__file__).resolve().parent),
    )
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    root = Path(args.root)
    total = 0
    for path in sorted(root.glob("*.yaml")):
        if path.name in {"scripts.yaml", "scripts.spec.yaml"}:
            continue
        n = rewrite_file(path, dry_run=args.dry_run)
        if n:
            print(f"{path.name}: rewrote {n} run wrapper(s)")
            total += n
    print(f"total: {total}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
