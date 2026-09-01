#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

config="$(restic_backup_config)"
exec python3 - <<PY
from app.config import load_config, get_profile, validate_profile
from app.crypto import decrypt_password

config = load_config("${config}")
_, enc, _ = validate_profile(get_profile(config, "hourly"))
print(decrypt_password(enc))
PY
