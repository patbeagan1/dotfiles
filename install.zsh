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
export PATH=$PATH:$LIBBEAGAN/scripts/android
export PATH=$PATH:$LIBBEAGAN/scripts/dev
export PATH=$PATH:$LIBBEAGAN/scripts/documentation
export PATH=$PATH:$LIBBEAGAN/scripts/file_management
export PATH=$PATH:$LIBBEAGAN/scripts/image_manipulation
export PATH=$PATH:$LIBBEAGAN/scripts/math
export PATH=$PATH:$LIBBEAGAN/scripts/sysadmin
export PATH=$PATH:$LIBBEAGAN/scripts/util
export PATH=$PATH:$LIBBEAGAN/scripts/vcs

###########################################################
# Aliases

# this is in another file
# so that it cen get sourced multiple times per session.

function source_alias() { source "$LIBBEAGAN/aliases/$1"; }
source "$LIBBEAGAN/alias"

###########################################################
# Dependencies
source "$LIBBEAGAN/dependencies.sh"
