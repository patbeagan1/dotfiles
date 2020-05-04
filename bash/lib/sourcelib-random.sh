
random () {
    # $1 is an integer
    echo $((1 + RANDOM % $1))
}

temp_file () {
    echo "/tmp/$(date +%s)_$(random 1000)"
}

alias d2="random 2"
alias d4="random 4"
alias d6="random 6"
alias d8="random 8"
alias d10="random 10"
alias d12="random 12"
alias d20="random 20"