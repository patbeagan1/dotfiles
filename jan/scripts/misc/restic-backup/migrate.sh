#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

old_repo="${RESTIC_MIGRATE_FROM:-/run/media/patrick/1TB/restic-documents}"
new_repo="${RESTIC_MIGRATE_TO:-$(restic_backup_profile_repo monthly)}"
script_dir="$(dirname "${BASH_SOURCE[0]}")"

if [[ ! -f "$old_repo/config" ]]; then
  echo "restic-backup migrate: source repo not found: $old_repo" >&2
  exit 1
fi

if [[ ! -d "$(dirname "$new_repo")" ]]; then
  echo "restic-backup migrate: destination drive not found for: $new_repo" >&2
  exit 1
fi

restic_backup_check_repo "$new_repo" "destination" || exit 1

password="$("$script_dir/password.sh")"
export RESTIC_PASSWORD="$password"
export RESTIC_FROM_REPOSITORY="$old_repo"
export RESTIC_REPOSITORY="$new_repo"

echo "restic-backup migrate: copying snapshots" >&2
echo "  from: $old_repo" >&2
echo "  to:   $new_repo" >&2

old_count="$(restic -r "$old_repo" snapshots --json | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))')"
if [[ "$old_count" -eq 0 ]]; then
  echo "restic-backup migrate: no snapshots in source repository" >&2
  exit 0
fi

restic copy --from-repo "$old_repo" --repo "$new_repo" -v
restic -r "$new_repo" snapshots
