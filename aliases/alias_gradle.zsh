alias destroy_gradle='rm -rf ~/.gradle/caches && rm -rf .gradle && ./gradlew clean'
alias findgradle='\ps aux | grep Gradle | grep -v grep | awk '\''{print $2}'\'''
alias killgradle='findgradle | xargs kill -9'
alias gradlekill='pkill -f gradle-launcher'
