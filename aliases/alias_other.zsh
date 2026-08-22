# Moved to jan scripts/misc/envsec.yaml (`jan scripts misc envsec run`).
unalias envsec 2>/dev/null
envsec() {
  if [[ "$1" == load ]]; then
    eval "$(jan --no-log scripts misc envsec run "$@")"
  else
    jan --no-log scripts misc envsec run "$@"
  fi
}
