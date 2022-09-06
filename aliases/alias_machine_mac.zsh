alias mac_showFinderLocation='defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES && killall Finder'
alias mac_hideFinderLocation='defaults write com.apple.finder _FXShowPosixPathInTitle -bool NO && killall Finder'
alias mac_showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias mac_hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

alias readOutLoud='say -v Moira -i -f'
alias read_out_loud=readOutLoud

alias javaSet7="export JAVA_HOME=$(/usr/libexec/java_home -v 1.7); java -version"
alias javaSet8="export JAVA_HOME=$(/usr/libexec/java_home -v 1.8); java -version"
alias javaSet9="export JAVA_HOME=$(/usr/libexec/java_home -v 9); java -version"
alias javaSet10="export JAVA_HOME=$(/usr/libexec/java_home -v 10); java -version"
alias javaSet11="export JAVA_HOME=$(/usr/libexec/java_home -v 11); java -version"
alias javaSet12="export JAVA_HOME=$(/usr/libexec/java_home -v 12); java -version"
alias javaSet13="export JAVA_HOME=$(/usr/libexec/java_home -v 13); java -version"
alias javaSet14="export JAVA_HOME=$(/usr/libexec/java_home -v 14); java -version"
alias javaSet15="export JAVA_HOME=$(/usr/libexec/java_home -v 15); java -version"
alias javaSet16="export JAVA_HOME=$(/usr/libexec/java_home -v 16); java -version"
alias javaSet17="export JAVA_HOME=$(/usr/libexec/java_home -v 17); java -version"

alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum > /dev/null || alias sha1sum="shasum"
