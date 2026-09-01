#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

config="$(restic_backup_config)"
cd "$(dirname "$config")"
exec restic-framework-backup --setup --config "$(basename "$config")"
