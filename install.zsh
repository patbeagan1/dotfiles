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
        # required for full use of scripts
        if ! which ag &>/dev/null; then echo 'brew install the_silver_searcher'; fi
        if ! which wget &>/dev/null; then echo 'brew install wget'; fi
        if ! which dot &>/dev/null; then echo 'brew install graphviz'; fi
        if ! which tree &>/dev/null; then echo 'brew install tree'; fi
        if ! which qrencode &>/dev/null; then echo 'brew install qrencode'; fi
        if ! which java &>/dev/null; then echo 'brew install java'; fi
        if ! which fzf &>/dev/null; then echo 'brew install fzf'; fi
        if ! which gpg &>/dev/null; then echo 'brew install gpg'; fi
        if ! which magick &>/dev/null; then echo 'brew install imagemagick'; fi
        if ! which deno &>/dev/null; then echo 'brew install deno'; fi
        if ! which python3 &>/dev/null; then echo 'brew install python'; fi
        if ! which npm &>/dev/null; then echo 'brew install npm'; fi
        if ! which parallel &>/dev/null; then echo 'brew install parallel'; fi

        # general purpose
        if ! which dart &>/dev/null; then echo 'brew install dart'; fi
        if ! which docker &>/dev/null; then echo 'brew install docker'; fi
        if ! which ffmpeg &>/dev/null; then echo 'brew install ffmpeg'; fi
        if ! which nmap &>/dev/null; then echo 'brew install nmap'; fi
        if ! which rvm &>/dev/null; then echo 'brew install rvm'; fi

        # optional / could be replaced
        local optional=()
        if ! which gitup &>/dev/null; then optional+='gitup'; fi
        if ! which ktlint &>/dev/null; then optional+='ktlint'; fi
        if ! which mednafen &>/dev/null; then optional+='mednafen'; fi
        if ! which nushell &>/dev/null; then optional+='nushell'; fi
        if ! which restic &>/dev/null; then optional+='restic'; fi
        if ! which tiddlywiki &>/dev/null; then optional+='tiddlywiki'; fi
        if ! which timewarrior &>/dev/null; then optional+='timewarrior'; fi
        echo "Missing optional tools: $optional"
    fi
}
libbeagan_dependencies
