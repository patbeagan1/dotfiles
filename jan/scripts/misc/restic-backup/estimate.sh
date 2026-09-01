#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

target="${1:-hourly}"
config="$(restic_backup_config)"

if ! restic_backup_check_target "$target"; then
  echo "restic-backup: skipping $target estimate (drive unavailable)" >&2
  exit 0
fi

exec restic-framework-backup --config "$config" --target "$target" --estimate
