#!/usr/bin/env bash
set -euo pipefail

restic_backup_export_env() {
  local target="$1"
  local script_dir password

  if ! restic_backup_check_target "$target"; then
    echo "restic-repo: $target repo unavailable (is the drive mounted?)" >&2
    exit 1
  fi

  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  export RESTIC_REPOSITORY="$(restic_backup_profile_repo "$target")"
  password="$("$script_dir/password.sh")"
  export RESTIC_PASSWORD="$password"
}
