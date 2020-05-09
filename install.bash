
export LIBBEAGAN="$HOME/libbeagan"

# adding the script directories to the path
export PATH=$PATH:$LIBBEAGAN/scripts
export PATH=$PATH:$LIBBEAGAN/scripts/util
export PATH=$PATH:$LIBBEAGAN/scripts/image_manipulation
export PATH=$PATH:$LIBBEAGAN/scripts/file_management
export PATH=$PATH:$LIBBEAGAN/scripts/math
export PATH=$PATH:$LIBBEAGAN/scripts/sysadmin
export PATH=$PATH:$LIBBEAGAN/scripts/vcs
export PATH=$PATH:$LIBBEAGAN/scripts/android
export PATH=$PATH:$LIBBEAGAN/scripts/dev

# sourcing bash libraries
source $LIBBEAGAN/bash/lib/sourcelib-cache.sh
source $LIBBEAGAN/bash/lib/sourcelib-machine-types.sh
source $LIBBEAGAN/bash/lib/sourcelib-random.sh
source $LIBBEAGAN/bash/source-alias.sh
source $LIBBEAGAN/bash/source-functions.sh
source $LIBBEAGAN/bash/source-git-completion.bash
source $LIBBEAGAN/bash/source-settings.sh

# setting up terminal prompt
source $LIBBEAGAN/bash/prompts/source-prompt-1.sh

# setting up external resources
$LIBBEAGAN/bash/external-resources.sh

# shell agnostic files
source $LIBBEAGAN/shared/source-git-config.sh
source $LIBBEAGAN/shared/source-alias-shared.sh

# When testing out new code please do it in the playground!
source $LIBBEAGAN/playground-source.sh