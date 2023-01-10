alias waypoint='echo `pwd` >> ~/waypoint.txt; cat ~/waypoint.txt | sort | uniq >> /tmp/waypoint.txt; mv /tmp/waypoint.txt ~/waypoint.txt'
waypoint_go () { cd $(cat ~/waypoint.txt | fzf -1 -q "$1") ; }
alias teleport=waypoint_go
alias tp-manual=teleport
function tp () { cd $(z -l | cut -d'/' -f2-100 | sed 's:^:/:g' | fzf -1); }
