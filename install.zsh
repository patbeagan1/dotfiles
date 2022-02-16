export LIBBEAGAN="$HOME/libbeagan"

###########################################################
# Framework home directories
###########################################################

# Golang
export GOPATH="$HOME/go"

# Android
export ANDROID_SDK=$HOME/Library/Android/sdk
export PATH=$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$PATH
export PATH=$ANDROID_SDK/platform-tools:$PATH
export PATH=$PATH:/Users/pbeagan/repo/flutter/bin
export PATH=$PATH:~/.local/bin

###########################################################
# Setting the PATH
###########################################################

export PATH=$PATH:$LIBBEAGAN/bin
export PATH=$PATH:$LIBBEAGAN/scripts
export PATH=$PATH:$LIBBEAGAN/scripts/util
export PATH=$PATH:$LIBBEAGAN/scripts/image_manipulation
export PATH=$PATH:$LIBBEAGAN/scripts/file_management
export PATH=$PATH:$LIBBEAGAN/scripts/documentation
export PATH=$PATH:$LIBBEAGAN/scripts/math
export PATH=$PATH:$LIBBEAGAN/scripts/sysadmin
export PATH=$PATH:$LIBBEAGAN/scripts/vcs
export PATH=$PATH:$LIBBEAGAN/scripts/android
export PATH=$PATH:$LIBBEAGAN/scripts/dev

###########################################################
# Zsh configuration
###########################################################

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=2000
SAVEHIST=5000
setopt AUTO_CD
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt NO_AUTO_MENU
setopt NO_CASE_GLOB
setopt NO_MENU_COMPLETE
setopt SHARE_HISTORY

# Fixes autocomplete to choose the case sensitive one first, if it exists.
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###########################################################
# Git Configuration
###########################################################

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
git config --global alias.mergetest '!f(){ git merge --no-commit --no-ff "$1"; git merge --abort; echo "Merge aborted"; };f'
git config --global alias.work 'log --pretty=format:"%h%x09%an%x09%ad%x09%s"'

###########################################################
# OMZSH Configuration
###########################################################

# prompt_ps_padding() {
#     prompt_parse_git_branch() {
#         git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
#         git rev-list --count HEAD 2>/dev/null
#     }
#     echo " $(date +"%H:%M:%S")$(prompt_parse_git_branch)" | tr "\n" " "
# }
# export PROMPT="%F{cyan}%n%F{white}@%F{green}$(ipconfig getifaddr en0):%F{yellow}%~%F{green}$(prompt_ps_padding)%F{white}%% "
# export PROMPT='%{$fg_bold[cyan]%}%n%{$reset_color%}%{$fg[yellow]%}@%{$reset_color%}%{$fg_bold[blue]%}%m%{$reset_color%}:%{${fg_bold[green]}%}%~%{$reset_color%}$(git_prompt_info) %{${fg[$CARETCOLOR]}%}%# %{${reset_color}%}'
# PROMPT='%F{green}%n%f@%F{magenta}%m%f %F{blue}%B%~%b%f %# '

# ZSH_THEME="pygmalion"
# ZSH_THEME="lukerandall"
ZSH_THEME="re5et"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# DISABLE_AUTO_UPDATE="true"
# DISABLE_UPDATE_PROMPT="true"
# export UPDATE_ZSH_DAYS=13

CASE_SENSITIVE="true"
# COMPLETION_WAITING_DOTS="true"
plugins=(
    git
    adb
)

###########################################################
# Aliases
###########################################################

source "$LIBBEAGAN/alias"
source "$LIBBEAGAN/aliases/alias_api.zsh"
source "$LIBBEAGAN/aliases/alias_git.zsh"
source "$LIBBEAGAN/aliases/alias_gradle.zsh"
source "$LIBBEAGAN/aliases/alias_imagemagick.zsh"
source "$LIBBEAGAN/aliases/alias_ls.zsh"
source "$LIBBEAGAN/aliases/alias_network.zsh"
source "$LIBBEAGAN/aliases/alias_other.zsh"
source "$LIBBEAGAN/aliases/alias_python.zsh"
source "$LIBBEAGAN/aliases/alias_unix.zsh"

darwin=false
case "`uname`" in
  Darwin* )
    darwin=true
    ;;
esac

if [ "$cygwin" = "false" ]; then
    source "$LIBBEAGAN/aliases/alias_mac.zsh"
fi
