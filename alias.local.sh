: <<'END'
# add this to the .zshrc file to install. 

export ZSH="$HOME/.oh-my-zsh"
export LIBBEAGAN_HOME="$HOME/libbeagan"
source ~/libbeagan/install.zsh
source $ZSH/oh-my-zsh.sh
END


if [ "$CURRENT_COMPUTER" = "framework" ]; then

    echo '      ___            __      ___  __              ___       __   __       '
    echo '|__| |__  |    |    /  \    |__  |__)  /\   |\/| |__  |  | /  \ |__) |__/ '
    echo '|  | |___ |___ |___ \__/    |    |  \ /~~\  |  | |___ |/\| \__/ |  \ |  \ '
    echo

    cal
    echo 
    restic_backup() { restic -r sftp:restic@nas:/home/restic-repo --verbose backup ~; }  
    alias monorepo='/home/patrick/repo/incubator/__monorepo/tools/monorepo'
    alias m='monorepo'
    source "/home/patrick/.local/share/swiftly/env.sh"
    intake() { echo "\n$@" >>~/repo/internal/Notes/Zettel/Intake.md; }

    declare -A holidays=(
        ["2023-12-25"]="Xmas 2023"
        ["2024-02-14"]="Valentine's"
        ["2024-03-17"]="St. Patrick's Day 🍀"
        ["2024-08-04"]="The Day"
        ["2024-12-25"]="Xmas 2024"
        ["2025-02-15"]="Moving day"
    )
    for date in ${(k)holidays}; do                                                                                                                                                  
         days_until.py "$date" "${holidays[$date]}" 2>/dev/null
    done

    export PATH=$PATH:/home/patrick/.local/share/JetBrains/Toolbox/scripts
    export DENO_INSTALL="/home/patrick/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    export GEM_HOME=$HOME/.gem
fi

################################################################################

if [ "$CURRENT_COMPUTER" = "mac_2017" ]; then
    echo '  __  __              ____   ___  _ _____  '
    echo ' |  \/  | __ _  ___  |___ \ / _ \/ |___  | '
    echo ' | |\/| |/ _` |/ __|   __) | | | | |  / /  '
    echo ' | |  | | (_| | (__   / __/| |_| | | / /   '
    echo ' |_|  |_|\__,_|\___| |_____|\___/|_|/_/    '
    echo

    intake() { echo "\n$@" >>~/repo/internal/Notes/Zettel/Intake.md; }
    alias consolevision='java -jar ~/Downloads/app-0.7.0-all.jar'
    alias cv=consolevision
fi

################################################################################

if [ "$CURRENT_COMPUTER" = "mac_2022" ]; then
    echo '  __  __              ____   ___ ____  ____   '
    echo ' |  \/  | __ _  ___  |___ \ / _ \___ \|___ \  '
    echo ' | |\/| |/ _` |/ __|   __) | | | |__) | __) | '
    echo ' | |  | | (_| | (__   / __/| |_| / __/ / __/  '
    echo ' |_|  |_|\__,_|\___| |_____|\___/_____|_____| '
    echo
    echo "Current release: \033[31;1;4m$(cd $RELEASE_DIR && getCurrentRelease)\033[0m"

    javaSet17
fi
