# Mac 2022 specific configuration
if [ "$CURRENT_COMPUTER" = "mac_2022" ]; then

# ASCII art banner
echo '  __  __              ____   ___ ____  ____   '
echo ' |  \/  | __ _  ___  |___ \ / _ \___ \|___ \  '
echo ' | |\/| |/ _` |/ __|   __) | | | |__) | __) | '
echo ' | |  | | (_| | (__   / __/| |_| / __/ / __/  '
echo ' |_|  |_|\__,_|\___| |_____|\___/_____|_____| '
echo

# Show current release
echo "Current release: \033[31;1;4m$(cd $RELEASE_DIR && getCurrentRelease)\033[0m"

# Set Java 17
javaSet17

fi
