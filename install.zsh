# todo make this less fragile
export LIBBEAGAN="$HOME/libbeagan"

###########################################################
# Configurations
# Personal settings that modify the environment
source "$LIBBEAGAN/configs/config-zsh.zsh"
source "$LIBBEAGAN/configs/config-omzsh.zsh"
source "$LIBBEAGAN/configs/config-golang.zsh"
source "$LIBBEAGAN/configs/config-android.zsh"

###########################################################
# Personal scripts
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
# Aliases

source "$LIBBEAGAN/alias"

###########################################################
# Dependencies

libbeagan_dependencies() {
    if isMac.sh; then
        if ! which ag &>/dev/null; then echo "brew install the_silver_searcher"; fi
        if ! which wget &>/dev/null; then echo 'brew install wget'; fi
        if ! which dot &>/dev/null; then echo 'brew install graphviz'; fi
        if ! which tree &>/dev/null; then echo 'brew install tree'; fi
        if ! which qrencode &>/dev/null; then echo 'brew install qrencode'; fi
        if ! which java &>/dev/null; then echo 'brew install java'; fi
        if ! which fzf &>/dev/null; then echo 'brew install fzf'; fi
    fi
}
libbeagan_dependencies