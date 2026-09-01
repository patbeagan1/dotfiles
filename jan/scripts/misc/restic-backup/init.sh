#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

target="${1:-hourly}"
config="$(restic_backup_config)"
repo="$(restic_backup_profile_repo "$target")"

restic_backup_check_target "$target"
mkdir -p "$repo"
exec restic-framework-backup --config "$config" --target "$target" --init
