#!/usr/bin/env python3
"""
List GitHub PRs merged in the last N months for a given author.
Uses the GitHub CLI (gh); username and repos are configurable via flags.
Supports --since/--until for explicit dates and --all for multiple local repo dirs.
No Python dependencies beyond the standard library.
"""

import argparse
import os
import subprocess
import sys
from datetime import date, datetime
from pathlib import Path


GH_AUTHOR_FILE = Path.home() / ".gh_prs_author"
DEFAULT_MONTHS = 6
DATE_FMT = "%Y-%m-%d"


def get_username_from_flag_or_file(username_flag: str | None) -> str:
    """Resolve author: flag overrides, else ~/.gh_prs_author, else exit."""
    if username_flag and username_flag.strip():
        return username_flag.strip()
    if GH_AUTHOR_FILE.exists():
        try:
            content = GH_AUTHOR_FILE.read_text().strip()
            if content:
                return content
        except OSError:
            pass
    print("Error: GitHub username is required.", file=sys.stderr)
    print("Use -u/--username or set it in ~/.gh_prs_author", file=sys.stderr)
    sys.exit(1)


def remember_username(username: str) -> None:
    """Write username to ~/.gh_prs_author for next time."""
    try:
        GH_AUTHOR_FILE.write_text(username + "\n")
    except OSError:
        pass


def detect_base_branch(cwd: Path | None) -> str:
    """Detect default base branch via git (develop, main, master, else current branch)."""
    cmd_prefix = ["git"]
    run_kw: dict = {}
    if cwd is not None:
        run_kw["cwd"] = str(cwd)
    for branch in ("develop", "main", "master"):
        r = subprocess.run(
            ["git", "show-ref", "--verify", "--quiet", f"refs/remotes/origin/{branch}"],
            **run_kw,
            capture_output=True,
        )
        if r.returncode == 0:
            return branch
    r = subprocess.run(
        ["git", "symbolic-ref", "--short", "HEAD"],
        **run_kw,
        capture_output=True,
        text=True,
    )
    if r.returncode == 0 and r.stdout.strip():
        return r.stdout.strip()
    return "main"


def date_range(months: int) -> tuple[str, str]:
    """Return (since_date, until_date) in YYYY-MM-DD (portable, no shell date)."""
    until = date.today()
    y, m, d = until.year, until.month, until.day
    m -= months
    while m <= 0:
        m += 12
        y -= 1
    since = date(y, m, d)
    return since.isoformat(), until.isoformat()


def run_gh_pr_list(
    author: str,
    since: str,
    until: str,
    base: str,
    repo: str | None,
    base_filter: str,
    cwd: Path | None = None,
) -> int:
    """
    Run `gh pr list` with the given search.
    base_filter is either "base:BRANCH" or "-base:BRANCH".
    If cwd is set, run from that directory (gh uses local repo); else use --repo if set.
    """
    search = (
        f"is:pr is:closed merged:{since}..{until} {base_filter} author:{author} sort:updated-desc"
    )
    cmd = ["gh", "pr", "list", "--limit", "1000", "--search", search]
    if repo:
        cmd.extend(["--repo", repo])
    run_kw: dict = {"capture_output": False}
    if cwd is not None:
        run_kw["cwd"] = str(cwd)
    r = subprocess.run(cmd, **run_kw)
    return r.returncode


def main() -> None:
    parser = argparse.ArgumentParser(
        description="List GitHub PRs merged in the last N months (uses gh CLI)."
    )
    parser.add_argument(
        "-u", "--username",
        metavar="USER",
        help="GitHub username (author). Default: read from ~/.gh_prs_author",
    )
    parser.add_argument(
        "-r", "--repo",
        metavar="OWNER/REPO",
        action="append",
        default=[],
        dest="repos",
        help="Repository in owner/repo form. Can be repeated. Default: use current directory's repo.",
    )
    parser.add_argument(
        "-b", "--base",
        metavar="BRANCH",
        help="Base branch (e.g. main, develop). Default: auto-detect from git when no -r; else main.",
    )
    parser.add_argument(
        "-m", "--months",
        type=int,
        default=DEFAULT_MONTHS,
        metavar="N",
        help=f"Look back N months when --since is not set (default: {DEFAULT_MONTHS})",
    )
    parser.add_argument(
        "-s", "--since",
        metavar="YYYY-MM-DD",
        help="Start date for merged PRs (overrides --months). Format: YYYY-MM-DD.",
    )
    parser.add_argument(
        "-e", "--until",
        metavar="YYYY-MM-DD",
        help="End date for merged PRs. Default: today. Format: YYYY-MM-DD.",
    )
    parser.add_argument(
        "-a", "--all",
        metavar="DIR",
        action="append",
        default=[],
        dest="repos_dirs",
        help="Local repo directory (e.g. ~/Documents/Github/my-repo). Can be repeated. Like gh-prs-last-6-months-all.",
    )
    args = parser.parse_args()

    author = get_username_from_flag_or_file(args.username)
    remember_username(author)

    # Resolve since/until: explicit flags override months-based range
    until_date = date.today()
    if args.until:
        try:
            until_date = datetime.strptime(args.until, DATE_FMT).date()
        except ValueError:
            print(f"Error: --until must be YYYY-MM-DD, got {args.until!r}", file=sys.stderr)
            sys.exit(1)
    if args.since:
        try:
            since_date = datetime.strptime(args.since, DATE_FMT).date()
        except ValueError:
            print(f"Error: --since must be YYYY-MM-DD, got {args.since!r}", file=sys.stderr)
            sys.exit(1)
    else:
        since_date, _ = date_range(args.months)
        since_date = datetime.strptime(since_date, DATE_FMT).date()
    since = since_date.isoformat()
    until = until_date.isoformat()
    if since_date > until_date:
        print("Error: --since must be on or before --until.", file=sys.stderr)
        sys.exit(1)

    date_label = f"{since}..{until}"

    if args.repos_dirs:
        # --all: run from each local repo directory (gh-prs-last-6-months-all behavior)
        for raw_dir in args.repos_dirs:
            path = Path(raw_dir).expanduser().resolve()
            if not (path / ".git").exists():
                print(f"Directory {path} is not a git repository.", file=sys.stderr)
                continue
            print()
            print("==================================================================")
            print(f"Repository: {path}")
            print("==================================================================")
            print()
            base_branch = args.base if args.base is not None else detect_base_branch(path)
            rc = run_gh_pr_list(
                author, since, until, base_branch, None,
                base_filter=f"base:{base_branch}",
                cwd=path,
            )
            if rc != 0:
                sys.exit(rc)
            print()
            print("###########################################################")
            print(f"#   GitHub PRs merged into branches other than {base_branch} (by {author})")
            print("###########################################################")
            rc = run_gh_pr_list(
                author, since, until, base_branch, None,
                base_filter=f"-base:{base_branch}",
                cwd=path,
            )
            if rc != 0:
                sys.exit(rc)
            print()
        sys.exit(0)

    # Single-repo mode: -r owner/repo or current directory
    if args.base is not None:
        base_branch = args.base
    elif args.repos:
        base_branch = "main"
    else:
        base_branch = detect_base_branch(Path.cwd())

    repos: list[str | None] = [None] if not args.repos else args.repos

    for repo in repos:
        if repo:
            print()
            print("==================================================================")
            print(f"Repository: {repo}")
            print("==================================================================")
            print()

        print("###########################################################")
        print(f"#   GitHub PRs merged {date_label} (by {author})")
        print("###########################################################")
        rc = run_gh_pr_list(
            author, since, until, base_branch, repo,
            base_filter=f"base:{base_branch}",
        )
        if rc != 0:
            sys.exit(rc)

        print()
        print("###########################################################")
        print(f"#   GitHub PRs merged into branches other than {base_branch} (by {author})")
        print("###########################################################")
        rc = run_gh_pr_list(
            author, since, until, base_branch, repo,
            base_filter=f"-base:{base_branch}",
        )
        if rc != 0:
            sys.exit(rc)
        if repo:
            print()

    sys.exit(0)


if __name__ == "__main__":
    main()
