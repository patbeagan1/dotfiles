# Mac 2025 specific configuration
if [ "$CURRENT_COMPUTER" = "mac2025" ]; then

# ASCII art banner
echo '    __  ___              ___   ____ ___   ______'
echo '   /  |/  /___ ______   |__ \ / __ \__ \ / ____/'
echo '  / /|_/ / __ `/ ___/   __/ // / / /_/ //___ \  '
echo ' / /  / / /_/ / /__    / __// /_/ / __/____/ /  '
echo '/_/  /_/\__,_/\___/   /____/\____/____/_____/   '
echo '                                                '

# Show current release
echo "Current release: \033[31;1;4m$(cd $RELEASE_DIR && getCurrentRelease)\033[0m"

# Set Java 17
javaSet17

fi
