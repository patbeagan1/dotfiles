###########################################################
# Lightweight re5et-style prompt (no Oh My Zsh)
###########################################################

autoload -U colors && colors
setopt prompt_subst

# Minimal git branch + dirty/clean for the prompt (sync; fine for typical repos).
_libbeagan_git_prompt_info() {
  local git_dir ref dirty
  git_dir="$(git rev-parse --git-dir 2>/dev/null)" || return 0
  ref="$(git symbolic-ref --short HEAD 2>/dev/null)" \
    || ref="$(git describe --tags --exact-match HEAD 2>/dev/null)" \
    || ref="$(git rev-parse --short HEAD 2>/dev/null)" \
    || return 0
  if [[ -n "$(git status --porcelain --ignore-submodules=dirty 2>/dev/null | head -1)" ]]; then
    dirty="%{$fg_bold[red]%} ±"
  else
    dirty="%{$fg_bold[red]%} ♥"
  fi
  echo "%{$fg_bold[magenta]%}^%{$reset_color%}%{$fg_bold[yellow]%}${ref//\%/%%}${dirty}%{$reset_color%}"
}

if [[ "$USERNAME" = "root" ]]; then
  typeset -g _LIBBEAGAN_CARETCOLOR="red"
else
  typeset -g _LIBBEAGAN_CARETCOLOR="magenta"
fi

PROMPT='
%{$fg_bold[cyan]%}%n%{$reset_color%}%{$fg[yellow]%}@%{$reset_color%}%{$fg_bold[blue]%}%m%{$reset_color%}:%{${fg_bold[green]}%}%~%{$reset_color%}$(_libbeagan_git_prompt_info)
%{${fg[$_LIBBEAGAN_CARETCOLOR]}%}%# %{${reset_color}%}'

RPS1='%(?..%{$fg_bold[red]%}:( %?%{$reset_color%}) %D - %*'
