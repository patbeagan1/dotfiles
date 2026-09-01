#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh source=env.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

target="${1:?target profile required (hourly or monthly)}"
shift

restic_backup_export_env "$target"

if [[ $# -eq 0 ]]; then
  exec restic snapshots
fi

exec restic "$@"
