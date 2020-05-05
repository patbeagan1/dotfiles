
export LIBBEAGAN="$HOME/libbeagan"
git diff origin/master

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
. $LIBBEAGAN/bash/lib/source-internal-libraries.sh
. $LIBBEAGAN/bash/lib/sourcelib-cache.sh
. $LIBBEAGAN/bash/lib/sourcelib-machine-types.sh
. $LIBBEAGAN/bash/lib/sourcelib-random.sh
. $LIBBEAGAN/bash/source-alias.sh
. $LIBBEAGAN/bash/source-functions.sh
. $LIBBEAGAN/bash/source-git-completion.bash
. $LIBBEAGAN/bash/source-settings.sh

# setting up terminal prompt
. $LIBBEAGAN/bash/prompts/source-prompt-1.sh

# setting up external resources and shell agnostic config files
. $LIBBEAGAN/shared/external-resources.sh
. $LIBBEAGAN/shared/source-git-config.sh

# When testing out new code please do it in the playground!
. $LIBBEAGAN/playground-source.sh