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

# this is in another file 
# so that it cen get sourced multiple times per session.
source "$LIBBEAGAN/alias"

###########################################################
# Dependencies

libbeagan_dependencies() {
    if isMac.sh; then
        local util=()
        add_util() {
            if [ ! -z "$2" ]; then
                if ! which "$1" &>/dev/null; then util+="$1($2)"; fi
            else
                if ! which "$1" &>/dev/null; then util+="$1"; fi
            fi
        }
        print_clear() {
            if [ ! ${#util[@]} -eq 0 ]; then
                echo "Missing $1 tools:\n$util"
            fi
            util=()
        }

        # required for full use of scripts
        add_util 'ag' 'the_silver_searcher'
        add_util 'deno'
        add_util 'dot' 'graphviz'
        add_util 'fzf'
        add_util 'gpg'
        add_util 'gpg' 'gnupg'
        add_util 'java'
        add_util 'magick' 'imagemagick'
        add_util 'npm'
        add_util 'parallel'
        add_util 'python3' 'python'
        add_util 'qrencode'
        add_util 'tree'
        add_util 'wget'
        print_clear 'required'

        # general purpose
        add_util 'dart'
        add_util 'docker'
        add_util 'exiftool'
        add_util 'ffmpeg'
        add_util 'go'
        add_util 'lua'
        add_util 'nmap'
        add_util 'recode'
        add_util 'rename'
        add_util 'sqlite3'
        add_util 'sshfs'
        add_util 'yarn'
        print_clear 'general purpose'

        # optional / could be replaced
        add_util 'gitup'
        add_util 'ktlint'
        add_util 'mednafen'
        add_util 'nu' 'nushell'
        add_util 'fish'
        add_util 'pngcrush'
        add_util 'rbenv'
        add_util 'restic'
        add_util 'tiddlywiki'
        add_util 'timewarrior'
        add_util 'gimp'
        print_clear 'optional'
    fi
}
libbeagan_dependencies
