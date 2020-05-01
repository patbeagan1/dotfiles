lsdaemons () 
{ 
    ps -eo 'tty,pid,comm' | grep --color=auto ^?
}
