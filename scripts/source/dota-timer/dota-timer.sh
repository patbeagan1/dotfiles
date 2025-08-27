#!/bin/bash

# Function to handle text-to-speech based on the operating system
text_to_speech() {
    local message=$1
    echo "$message"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        say "$message"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        spd-say "$message"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        powershell -Command "Add-Type -AssemblyName System.speech; \$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$speak.Speak('$message')"
    else
        echo "Text-to-speech not supported on this OS."
    fi
}

# Function to announce an event after a delay
announce_event() {
    local delay=$1
    local message=$2
    sleep $delay
    text_to_speech "$message"
}

# Main function to start the timer
start_dota_timer() {
    echo "Starting Dota timer..."

    # Day/Night cycle events (every 5 minutes)
    for i in {1..12}; do
        local time=$((i * 300 + 5))
        if ((i % 2 == 1)); then
            announce_event $time "Daytime. $((i / 2 + 1)) minutes remaining until night." &
        else
            announce_event $time "Nighttime. $((i / 2)) minutes remaining until day." &
        fi
    done

    # Neutral creep spawn times (every minute starting at 1:00)
    for i in {1..60}; do
        announce_event $((i * 60 + 2)) "Neutral creeps have spawned." &
    done

    # Other important events
    announce_event 0 "Welcome to Dota 2!" &
    announce_event 10 "10 seconds have passed." &
    announce_event 60 "1 minute mark. Check runes!" &
    announce_event 240 "4 minute mark. Power runes will spawn soon." &
    announce_event 300 "5 minute mark. Siege creeps will spawn soon. Bounty runes are available!" &
    announce_event 480 "8 minute mark. Check Roshan soon for potential respawn." &
    announce_event 600 "10 minute mark. Outposts are available!" &
    announce_event 720 "12 minute mark. Power runes will spawn soon." &
    announce_event 900 "15 minute mark. Siege creeps will spawn soon. Check runes!" &
    
    # Wait for all events to complete
    wait
    echo "Dota timer finished."
}

# Start the timer
start_dota_timer

