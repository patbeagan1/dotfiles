lll () 
{ 
    if [ $(uname) = "Darwin" ]; then
        ls --color=auto -lT;
    else
        ls --color=auto -l --full-time;
    fi
}
