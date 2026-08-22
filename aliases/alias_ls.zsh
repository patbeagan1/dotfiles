# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
alias l.='ls -d .* --color=auto'
# `l`, `la`, `ll` are declared in jan/files.yaml and emitted by `jan alias`.
# Moved to jan scripts/files/lk.yaml (`jan scripts files lk run`).
unalias lk 2>/dev/null
lk() { local d; d="$(jan --no-log scripts files lk run "$@")" && [[ -n "$d" ]] && cd "$d"; }
