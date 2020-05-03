
# adding the script directories to the path
export PATH=$PATH:~/libbeagan/scripts
export PATH=$PATH:~/libbeagan/scripts/util
export PATH=$PATH:~/libbeagan/scripts/image_manipulation
export PATH=$PATH:~/libbeagan/scripts/file_management
export PATH=$PATH:~/libbeagan/scripts/math
export PATH=$PATH:~/libbeagan/scripts/sysadmin
export PATH=$PATH:~/libbeagan/scripts/vcs
export PATH=$PATH:~/libbeagan/scripts/android
export PATH=$PATH:~/libbeagan/scripts/dev

# sourcing bash libraries
. ./bash/lib/source-internal-libraries.sh
. ./bash/lib/sourcelib-cache.sh
. ./bash/lib/sourcelib-machine-types.sh
. ./bash/lib/sourcelib-random.sh
. ./bash/source-alias.sh
. ./bash/source-functions.sh
. ./bash/source-git-completion.bash
. ./bash/source-settings.sh

# setting up terminal prompt
. ./bash/prompts/source-prompt-1.sh

# setting up external resources and shell agnostic config files
. ./external-resources.sh
. ./source-git-config.sh

# When testing out new code please do it in the playground!
. ./playground-source.sh