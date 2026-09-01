"""Restic subprocess wrapper."""

import json
import os
import subprocess
import sys
from typing import Any


def _build_env(repo: str, password: str) -> dict[str, str]:
    env = os.environ.copy()
    env["RESTIC_REPOSITORY"] = repo
    env["RESTIC_PASSWORD"] = password
    return env


def run_restic_cmd(
    restic_path: str,
    repo: str,
    password: str,
    args: list[str],
    *,
    capture_output: bool = False,
) -> subprocess.CompletedProcess[str]:
    """Run a restic command and return the completed process."""
    env = _build_env(repo, password)
    cmd = [restic_path] + args

    display_args = [a for a in args if not a.startswith("/") or " " in a]
    print(f"Running Restic: {restic_path} {' '.join(display_args)}")

    try:
        return subprocess.run(
            cmd,
            env=env,
            check=True,
            text=True,
            capture_output=capture_output,
        )
    except subprocess.CalledProcessError as e:
        print(f"Restic command failed with exit code {e.returncode}", file=sys.stderr)
        if e.stderr:
            print(e.stderr, file=sys.stderr)
        raise


def init_repository(restic_path: str, repo: str, password: str) -> None:
    """Initialize a new restic repository."""
    os.makedirs(repo, exist_ok=True)
    run_restic_cmd(restic_path, repo, password, ["init"])


def run_backup(
    restic_path: str,
    repo: str,
    password: str,
    source: str,
    exclude_args: list[str],
    *,
    dry_run: bool = False,
) -> dict[str, Any] | None:
    """Run a backup (or dry-run) and return parsed JSON summary if available."""
    backup_args = ["backup", "--one-file-system", "--json"]
    if dry_run:
        backup_args.append("--dry-run")
    backup_args.extend(exclude_args)
    backup_args.append(source)

    result = run_restic_cmd(
        restic_path, repo, password, backup_args, capture_output=True
    )

    if not result.stdout:
        return None

    for line in reversed(result.stdout.strip().split("\n")):
        line = line.strip()
        if line.startswith("{"):
            try:
                return json.loads(line)
            except json.JSONDecodeError:
                continue
    return None


def run_forget(
    restic_path: str,
    repo: str,
    password: str,
    forget_policy: dict[str, Any],
) -> None:
    """Apply retention policy with forget --prune."""
    forget_args = ["forget", "--prune"]
    for key, value in forget_policy.items():
        forget_args.extend([f"--{key}", str(value)])
    run_restic_cmd(restic_path, repo, password, forget_args)


def format_bytes(num_bytes: int) -> str:
    """Format bytes as a human-readable string."""
    value = float(num_bytes)
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if value < 1024:
            return f"{value:.1f} {unit}"
        value /= 1024
    return f"{value:.1f} PB"
