# Shared span + timeline helpers for jan multi-agent flows (CLI-only Unifier).
# Source from an agent bash leaf:
#   . "$(jq -r '.jan_dir' "${JAN_CONFIG_DIR:-$HOME/.config/jan-cli}/config.json")/scripts/lib/flow_obs.sh"
#
# Usage:
#   flow_span_start gift-curator -f wakeup=…
#   flow_span_note "curated ada-lovelace"
#   flow_timeline_append gifts "curator signal=72 forwarded ada-lovelace"
#   flow_span_end
#   flow_status_touch gifts "3 upcoming · 1 planned"

FLOW_SPAN="${FLOW_SPAN:-}"
FLOW_TIMELINE_CAP="${FLOW_TIMELINE_CAP:-200}"

flow_span_start() {
  local name="$1"
  shift || true
  FLOW_SPAN="$(unifier log start "$name" "$@" 2>/dev/null || true)"
}

flow_span_note() {
  [ -n "${FLOW_SPAN:-}" ] || return 0
  unifier log event "$FLOW_SPAN" "$1" >/dev/null 2>&1 || true
}

flow_span_end() {
  [ -n "${FLOW_SPAN:-}" ] || return 0
  unifier log end "$FLOW_SPAN" >/dev/null 2>&1 || true
  FLOW_SPAN=""
}

flow_timeline_append() {
  local prefix="$1"
  local line="$2"
  local key="${prefix}/status/timeline"
  local ts
  ts="$(date -Is 2>/dev/null || date)"
  local entry="${ts}  ${line}"
  local prev
  prev="$(unifier get "$key" 2>/dev/null || true)"
  local next
  if [ -n "$prev" ]; then
    next="$(printf '%s\n%s\n' "$prev" "$entry")"
  else
    next="$entry"
  fi
  # Cap to last N lines
  next="$(printf '%s\n' "$next" | tail -n "$FLOW_TIMELINE_CAP")"
  unifier put "$key" "$next" >/dev/null 2>&1 || true
  unifier put "${prefix}/status/updated_at" "$ts" >/dev/null 2>&1 || true
}

flow_status_touch() {
  local prefix="$1"
  local summary="$2"
  local ts
  ts="$(date -Is 2>/dev/null || date)"
  unifier put "${prefix}/status/summary" "$summary" >/dev/null 2>&1 || true
  unifier put "${prefix}/status/updated_at" "$ts" >/dev/null 2>&1 || true
}

# Resolve and source this file from inline bash (no-op if already sourced).
flow_obs_source() {
  if declare -F flow_timeline_append >/dev/null 2>&1; then
    return 0
  fi
  local cfg="${JAN_CONFIG_DIR:-${HOME}/.config/jan-cli}/config.json"
  local root=""
  if [ -f "$cfg" ] && command -v jq >/dev/null 2>&1; then
    root="$(jq -r '.jan_dir // empty' "$cfg" 2>/dev/null || true)"
  fi
  local cand
  for cand in \
    ${root:+"${root}/scripts/lib/flow_obs.sh"} \
    "${HOME}/Documents/Github/dotfiles/jan/scripts/lib/flow_obs.sh"; do
    if [ -n "$cand" ] && [ -f "$cand" ]; then
      # shellcheck disable=SC1090
      . "$cand"
      return 0
    fi
  done
  return 1
}
