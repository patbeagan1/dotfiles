###########################################################
# Colored man pages via LESS_TERMCAP (no Oh My Zsh)
###########################################################

autoload -U colors && colors

typeset -AHg less_termcap
less_termcap[mb]="${fg_bold[red]}"
less_termcap[md]="${fg_bold[red]}"
less_termcap[me]="${reset_color}"
less_termcap[so]="${fg_bold[yellow]}${bg[blue]}"
less_termcap[se]="${reset_color}"
less_termcap[us]="${fg_bold[green]}"
less_termcap[ue]="${reset_color}"

_libbeagan_colored() {
  local -a environment
  local k v
  for k v in "${(@kv)less_termcap}"; do
    environment+=( "LESS_TERMCAP_${k}=${v}" )
  done
  environment+=( PAGER="${commands[less]:-$PAGER}" )
  environment+=( GROFF_NO_SGR=1 )
  command env "${environment[@]}" "$@"
}

function man {
  _libbeagan_colored man "$@"
}
