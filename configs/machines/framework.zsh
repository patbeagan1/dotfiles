# Framework laptop specific configuration
if [ "$CURRENT_COMPUTER" = "framework" ]; then

# ASCII art banner
echo '      ___            __      ___  __              ___       __   __       '
echo '|__| |__  |    |    /  \    |__  |__)  /\   |\/| |__  |  | /  \ |__) |__/ '
echo '|  | |___ |___ |___ \__/    |    |  \ /~~\  |  | |___ |/\| \__/ |  \ |  \ '
echo

# Show calendar
cal
echo 

# Framework-specific functions
restic_backup() { 
    restic -r sftp:restic@nas:/home/restic-repo --verbose backup ~
}

# Common functions
intake() { 
    echo "\n$@" >>~/repo/internal/Notes/Zettel/Intake.md
}

# Framework-specific aliases
alias monorepo='/home/patrick/repo/incubator/__monorepo/tools/monorepo'
alias m='monorepo'

# Swift environment
source "/home/patrick/.local/share/swiftly/env.sh"

# Holiday tracking
typeset -A holidays=(
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

# Framework-specific PATH additions
export PATH=$PATH:/home/patrick/.local/share/JetBrains/Toolbox/scripts
export DENO_INSTALL="/home/patrick/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Homebrew setup
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export GEM_HOME=$HOME/.gem

fi
