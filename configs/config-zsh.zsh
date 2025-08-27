###########################################################
# Zsh configuration

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=9999
SAVEHIST=9999
setopt AUTO_CD
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt NO_AUTO_MENU
setopt NO_CASE_GLOB
setopt NO_MENU_COMPLETE
setopt SHARE_HISTORY
setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Use modern completion system
autoload -Uz compinit
compinit

# Add script completions to fpath if available
if [[ -n "$LIBBEAGAN_HOME" ]] && [[ -d "$LIBBEAGAN_HOME/scripts/completions" ]]; then
    fpath=("$LIBBEAGAN_HOME/scripts/completions" $fpath)
    # Re-initialize completions with new fpath
    autoload -Uz compinit && compinit
fi

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
if isLinux.sh; then 
  eval "$(dircolors -b)"
fi
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
