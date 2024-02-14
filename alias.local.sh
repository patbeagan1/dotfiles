if [ "$CURRENT_COMPUTER" = "framework" ]; then

    echo '      ___            __      ___  __              ___       __   __       '
    echo '|__| |__  |    |    /  \    |__  |__)  /\   |\/| |__  |  | /  \ |__) |__/ '
    echo '|  | |___ |___ |___ \__/    |    |  \ /~~\  |  | |___ |/\| \__/ |  \ |  \ '
    echo

    cal
    restic_backup() { restic -r sftp:restic@nas:/home/restic-repo --verbose backup ~; }  
    intake() { echo "\n$@" >>~/repo/internal/Notes/Zettel/Intake.md; }
    days_until.py 2023-12-25 'Xmas 2023' 2> /dev/null
    days_until.py 2024-02-14 "Valentine's" 2> /dev/null
    days_until.py 2024-03-17 "St. Patrick's Day" 2> /dev/null
    days_until.py 2024-08-04 "The Day" 2> /dev/null
    days_until.py 2024-12-25 "Xmas 2024" 2> /dev/null
    days_until.py 2025-02-15 "Moving day" 2> /dev/null

fi

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

if [ "$CURRENT_COMPUTER" = "mac_2022" ]; then
    echo '  __  __              ____   ___ ____  ____   '
    echo ' |  \/  | __ _  ___  |___ \ / _ \___ \|___ \  '
    echo ' | |\/| |/ _` |/ __|   __) | | | |__) | __) | '
    echo ' | |  | | (_| | (__   / __/| |_| / __/ / __/  '
    echo ' |_|  |_|\__,_|\___| |_____|\___/_____|_____| '
    echo
    echo "Current release: \033[31;1;4m$(cd $RELEASE_DIR && getCurrentRelease)\033[0m"
fi
