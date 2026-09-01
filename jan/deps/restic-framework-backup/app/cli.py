"""Command-line interface for restic-framework-backup."""

import argparse
import getpass
import secrets
import sys
from pathlib import Path
from typing import Any

import yaml

from app.config import get_profile, load_config, validate_profile
from app.crypto import decrypt_password, encrypt_password
from app.ignore import build_exclude_args, get_ignore_patterns
from app.restic import (
    format_bytes,
    init_repository,
    run_backup,
    run_forget,
)


def _print_estimate(summary: dict[str, Any], patterns: list[str]) -> None:
    """Print dry-run estimation results."""
    files_new = summary.get("files_new", 0)
    files_changed = summary.get("files_changed", 0)
    files_unmodified = summary.get("files_unmodified", 0)
    total_files = summary.get("total_files_processed", files_new + files_changed + files_unmodified)
    data_added = summary.get("data_added", 0)
    total_bytes = summary.get("total_bytes_processed", 0)

    print("\n--- Backup Estimate (dry-run) ---")
    print(f"Files to transfer (new):     {files_new:,}")
    print(f"Files to transfer (changed): {files_changed:,}")
    print(f"Files unchanged:             {files_unmodified:,}")
    print(f"Total files scanned:         {total_files:,}")
    print(f"Data to transfer:            {format_bytes(data_added)}")
    print(f"Total data scanned:          {format_bytes(total_bytes)}")
    print(f"\nExcluded patterns ({len(patterns)}):")
    for pattern in patterns:
        print(f"  - {pattern}")
    print("--------------------------------\n")


def _handle_encrypt() -> None:
    passwd = getpass.getpass("Enter the Restic repository password to encrypt: ")
    if not passwd:
        print("Password cannot be empty.", file=sys.stderr)
        sys.exit(1)

    confirm_passwd = getpass.getpass("Confirm password: ")
    if passwd != confirm_passwd:
        print("Passwords do not match.", file=sys.stderr)
        sys.exit(1)

    encrypted_str = encrypt_password(passwd)
    print("\n--- ENCRYPTED PASSWORD COPIED BELOW ---")
    print(encrypted_str)
    print("---------------------------------------\n")
    print("Copy the string above into your config.yaml file.")


def _setup_config_from_example(config_path: Path, example_path: Path) -> None:
    """Create config.yaml from example with a generated encrypted password."""
    with example_path.open() as f:
        config = yaml.safe_load(f)

    password = secrets.token_urlsafe(24)
    encrypted = encrypt_password(password)
    config["hourly_backup"]["encrypted_password"] = encrypted
    if "monthly_backup" in config:
        config["monthly_backup"]["encrypted_password"] = encrypted

    with config_path.open("w") as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)

    print(f"Created {config_path} with a generated repository password.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Encrypted wrapper script for Restic backups."
    )
    parser.add_argument(
        "--config", required=False, help="Path to the yaml configuration file."
    )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--target",
        choices=["hourly", "monthly"],
        help="Which backup profile to execute.",
    )
    group.add_argument(
        "--encrypt",
        action="store_true",
        help="Interactively prompt for a password to encrypt for your config file.",
    )
    group.add_argument(
        "--setup",
        action="store_true",
        help="Create config.yaml from config.yaml.example with a generated password.",
    )

    parser.add_argument(
        "--estimate",
        action="store_true",
        help="Dry-run backup and report file/size counts without transferring data.",
    )
    parser.add_argument(
        "--init",
        action="store_true",
        help="Initialize the restic repository for the selected profile.",
    )

    args = parser.parse_args()

    if args.encrypt:
        _handle_encrypt()
        return

    if args.setup:
        config_path = Path(args.config or "config.yaml")
        example_path = Path("config.yaml.example")
        if not example_path.exists():
            print(f"Error: {example_path} not found.", file=sys.stderr)
            sys.exit(1)
        if config_path.exists():
            print(f"Error: {config_path} already exists.", file=sys.stderr)
            sys.exit(1)
        _setup_config_from_example(config_path, example_path)
        return

    if not args.config:
        parser.error("--config is required when running a backup target.")

    config = load_config(args.config)
    global_config = config.get("global", {})
    restic_path = global_config.get("restic_path", "restic")

    profile = get_profile(config, args.target)
    repo, encrypted_password, source = validate_profile(profile)
    password = decrypt_password(encrypted_password)
    exclude_args = build_exclude_args(config)
    patterns = get_ignore_patterns(config)

    if args.init:
        print(f"--- Initializing repository at {repo} ---")
        init_repository(restic_path, repo, password)
        print("--- Repository initialized successfully ---")
        return

    if args.estimate:
        print(f"--- Estimating {args.target} backup for {source} ---")
        summary = run_backup(
            restic_path, repo, password, source, exclude_args, dry_run=True
        )
        if summary:
            _print_estimate(summary, patterns)
        else:
            print("Dry-run completed but no JSON summary was returned.", file=sys.stderr)
            sys.exit(1)
        return

    print(f"--- Starting {args.target} backup job ---")
    summary = run_backup(restic_path, repo, password, source, exclude_args)
    if summary:
        files_new = summary.get("files_new", 0)
        data_added = summary.get("data_added", 0)
        print(f"Backed up {files_new:,} new files ({format_bytes(data_added)})")

    forget_policy = profile.get("forget_policy", {})
    if forget_policy:
        print("\n--- Applying retention policy ---")
        run_forget(restic_path, repo, password, forget_policy)

    print(f"\n--- {args.target} backup job finished successfully ---")


if __name__ == "__main__":
    main()
