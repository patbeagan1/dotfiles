
export LIBBEAGAN="$HOME/libbeagan"

export GOPATH="$HOME/go"

# adding the script directories to the path
export PATH=$PATH:$LIBBEAGAN/bin

export PATH=$PATH:$LIBBEAGAN/scripts
export PATH=$PATH:$LIBBEAGAN/scripts/util
export PATH=$PATH:$LIBBEAGAN/scripts/image_manipulation
export PATH=$PATH:$LIBBEAGAN/scripts/file_management
export PATH=$PATH:$LIBBEAGAN/scripts/math
export PATH=$PATH:$LIBBEAGAN/scripts/sysadmin
export PATH=$PATH:$LIBBEAGAN/scripts/vcs
export PATH=$PATH:$LIBBEAGAN/scripts/android
export PATH=$PATH:$LIBBEAGAN/scripts/dev

source $LIBBEAGAN/zsh/source-pbeagan.zsh

# shell agnostic files
source $LIBBEAGAN/shared/source-git-config.sh
source $LIBBEAGAN/shared/source-alias-shared.sh

# When testing out new code please do it in the playground!
source $LIBBEAGAN/playground-source.sh
