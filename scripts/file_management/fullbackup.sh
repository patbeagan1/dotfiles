#!/bin/bash 

trackusage.sh "$0"

if [ $# -eq 0 ] || [ $1 == "help" ]; then 
cat <<END

This script is an rsync wrapper. 
fullbackup {options} {destination}

It pulls:           | It excludes:
------------------------------------
/home               | ~/.steam
/etc                | ~/.cache
installed_commands  | ~/.config

If no flags are passed, -aPz will be used.

END
exit
fi

echo $(ls /usr/*bin) $(ls /usr/local/*bin) > /tmp/installed_commands
if [ $# -eq 2 ]; then
	options=$1
	shift
fi
if [ ! -e $1 ]; then mkdir $1; fi
if [ -z $options ]; then options="-aPz"; fi

echo 0$0 1$1 2$2
echo $options
echo

rsync $options --info=progress2 --info=name0 --exclude ~/.steam --exclude ~/.cache --exclude ~/.config /home /etc /tmp/installed_commands $1 2>fullbackup_errors.log

cat fullbackup_errors.log
