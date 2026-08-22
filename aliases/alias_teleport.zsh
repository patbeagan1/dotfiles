# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# Moved to jan scripts/misc/waypoint_go.yaml (`jan scripts misc waypoint_go run`).
unalias waypoint_go 2>/dev/null
waypoint_go() { local d; d="$(jan --no-log scripts misc waypoint_go run "$@")" && [[ -n "$d" ]] && cd "$d"; }
# Moved to jan scripts/misc/z-cd.yaml (`jan scripts misc z-cd run`).
# `jan alias` also emits `tp` for scripts/misc/tp.yaml (PS1 helper); unalias so this cd wrapper wins.
unalias tp 2>/dev/null
tp() { local d; d="$(jan --no-log scripts misc z-cd run "$@")" && [[ -n "$d" ]] && cd "$d"; }
