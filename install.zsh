echo Welcome to libbeagan.
if [[ ! -v LIBBEAGAN_HOME ]]; then
    echo '-> Nothing done.'
    echo '-> Please set the LIBBEAGAN_HOME environment variable.'
    echo '-> This can be done by adding (export LIBBEAGAN_HOME="$HOME/libbeagan") to your ~/.zshrc file'
    echo
else
    ###########################################################
    # Configurations
    # Personal settings that modify the environment
    source "$LIBBEAGAN_HOME/configs/config-zsh.zsh"
    source "$LIBBEAGAN_HOME/configs/config-omzsh.zsh"
    source "$LIBBEAGAN_HOME/configs/config-golang.zsh"
    source "$LIBBEAGAN_HOME/configs/config-android.zsh"

    ###########################################################
    # Personal scripts
    export PATH=$PATH:$LIBBEAGAN_HOME/scripts/android
    export PATH=$PATH:$LIBBEAGAN_HOME/scripts/dev
    export PATH=$PATH:$LIBBEAGAN_HOME/scripts/documentation
    export PATH=$PATH:$LIBBEAGAN_HOME/scripts/file_management
    export PATH=$PATH:$LIBBEAGAN_HOME/scripts/image_manipulation
    export PATH=$PATH:$LIBBEAGAN_HOME/scripts/math
    export PATH=$PATH:$LIBBEAGAN_HOME/scripts/sysadmin
    export PATH=$PATH:$LIBBEAGAN_HOME/scripts/util
    export PATH=$PATH:$LIBBEAGAN_HOME/scripts/vcs

    ###########################################################
    # Aliases

    function source_libbeagan() { source "$LIBBEAGAN_HOME/$1"; }
    function source_alias() { source_libbeagan "aliases/$1"; }

    # this is in another file
    # so that it can get sourced multiple times per session.
    source "$LIBBEAGAN_HOME/alias"

    ###########################################################
    # Dependencies
    source "$LIBBEAGAN_HOME/dependencies.sh"
fi
