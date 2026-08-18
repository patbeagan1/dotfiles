# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
#alias ls='ls -Fh --color=auto'
# alias ll='ls -l'
alias l.='ls -d .* --color=auto'
# `l`, `la`, `ll` are declared in jan/files.yaml and emitted by `jan alias`.
# alias l='ls -F'
# alias la='ls -A'
# alias ll="ls -lhA"
# alias lla='ls -la'
# alias lr='ls -ralt'
# alias lsd='ls --group-directories-first'
# alias lsg='ls | grep -i '
# alias lsl="ls -lhFA | less"
# alias lt='ls | rev | sort | rev'
# alias ldu='du -sh * | sort -h'
# alias sl="ls"
# alias ralt='ls -ralt'
# alias dirs="ls -al | grep '^d'"
# alias peek="peek.sh"
# alias lss='ls -harsS'
function lk {
  cd "$(walk "$@")"
}
