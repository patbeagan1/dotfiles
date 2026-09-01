#!/usr/bin/env bash
set -euo pipefail

restic_backup_jan_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd
}

restic_backup_config() {
  local jan_root
  jan_root="$(restic_backup_jan_root)"
  printf '%s\n' "${RESTIC_BACKUP_CONFIG:-$jan_root/deps/restic-framework-backup/config.yaml}"
}

restic_backup_profile_repo() {
  local target="$1"
  local config
  config="$(restic_backup_config)"
  python3 - <<PY
from app.config import load_config, get_profile
config = load_config("${config}")
print(get_profile(config, "${target}")["repository"])
PY
}

restic_backup_check_repo() {
  local repo="$1"
  local label="${2:-$repo}"
  local mount_point avail_kb

  if [[ ! -d "$repo" ]]; then
    echo "restic-backup: $label not found (repo parent missing): $repo" >&2
    return 1
  fi

  mount_point="$(df -P "$repo" 2>/dev/null | awk 'NR==2 {print $6}')"
  if [[ -n "$mount_point" && "$mount_point" != / ]]; then
    if ! mountpoint -q "$mount_point" 2>/dev/null; then
      echo "restic-backup: $label drive does not appear mounted ($mount_point)" >&2
      return 1
    fi
    avail_kb="$(df -P "$mount_point" | awk 'NR==2 {print $4}')"
    if [[ -n "${avail_kb:-}" && "$avail_kb" -lt 1048576 ]]; then
      echo "restic-backup: warning: less than 1 GiB free on $label ($mount_point)" >&2
    fi
  fi
  return 0
}

restic_backup_check_target() {
  local target="$1"
  local repo
  repo="$(restic_backup_profile_repo "$target")"
  restic_backup_check_repo "$repo" "$target"
}
