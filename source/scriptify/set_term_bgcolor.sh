set_term_bgcolor () 
{ 
    local R=$1;
    local G=$2;
    local B=$3;
    /usr/bin/osascript  <<EOF
tell application "iTerm"
  tell the current window
    tell the current session
      set background color to {$(($R*65535/255)), $(($G*65535/255)), $(($B*65535/255))}
    end tell
  end tell
end tell
EOF

}
if [[ $0 != "-bash" ]]; then set_term_bgcolor "$@"; fi
