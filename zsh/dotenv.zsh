###########################################################
# Auto-load .env on cd (allow/deny lists; no Oh My Zsh)
###########################################################

: ${ZSH_DOTENV_FILE:=.env}
: ${ZSH_DOTENV_PROMPT:=true}
: ${ZSH_DOTENV_ALLOWED_LIST:="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/dotenv-allowed.list"}
: ${ZSH_DOTENV_DISALLOWED_LIST:="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/dotenv-disallowed.list"}

_libbeagan_dotenv_ensure_lists() {
  local dir="${ZSH_DOTENV_ALLOWED_LIST:h}"
  [[ -d "$dir" ]] || mkdir -p "$dir"
  dir="${ZSH_DOTENV_DISALLOWED_LIST:h}"
  [[ -d "$dir" ]] || mkdir -p "$dir"
  touch "$ZSH_DOTENV_ALLOWED_LIST" "$ZSH_DOTENV_DISALLOWED_LIST"
}

source_env() {
  [[ -f "$ZSH_DOTENV_FILE" ]] || return 0

  if [[ "$ZSH_DOTENV_PROMPT" != false ]]; then
    local confirmation dirpath="${PWD:A}"
    _libbeagan_dotenv_ensure_lists

    if command grep -Fx -q "$dirpath" "$ZSH_DOTENV_DISALLOWED_LIST" &>/dev/null; then
      return 0
    fi

    if ! command grep -Fx -q "$dirpath" "$ZSH_DOTENV_ALLOWED_LIST" &>/dev/null; then
      local column
      echo -ne "\e[6n" > /dev/tty
      read -t 1 -s -d R column < /dev/tty
      column="${column##*\[*;}"
      [[ $column -eq 1 ]] || echo

      echo -n "dotenv: found '$ZSH_DOTENV_FILE' file. Source it? ([y]es/[N]o/[a]lways/n[e]ver) "
      read -k 1 confirmation
      [[ "$confirmation" = $'\n' ]] || echo

      case "$confirmation" in
        [yY]) ;;
        [aA]) echo "$dirpath" >> "$ZSH_DOTENV_ALLOWED_LIST" ;;
        [eE]) echo "$dirpath" >> "$ZSH_DOTENV_DISALLOWED_LIST"; return 0 ;;
        *) return 0 ;;
      esac
    fi
  fi

  # Syntax-check then export KEY=VALUE lines (no command substitution).
  if ! zsh -fn -- "$ZSH_DOTENV_FILE" 2>/dev/null; then
    print -u2 "dotenv: error when checking '$ZSH_DOTENV_FILE'"
    return 1
  fi

  setopt localoptions allexport
  # shellcheck disable=SC1090
  source "$ZSH_DOTENV_FILE"
}

autoload -U add-zsh-hook
add-zsh-hook chpwd source_env
source_env
