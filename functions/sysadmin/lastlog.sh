lastlog () 
{ 
    cd /var/log;
    less $(ls -1t | head -1)
}
