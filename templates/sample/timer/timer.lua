-- timer.lua
local socket = require("socket")

-- Timer module
local Timer = {}

-- Native sleep function
local function sleep(n)
    socket.sleep(n)
end

-- Cross-platform text-to-speech function
local function text_to_speech(message)
    print(message) -- Always print the message
    local os_name = io.popen("uname"):read("*l") or "Windows"
    if os_name:find("Darwin") then
        os.execute('say "' .. message .. '"')
    elseif os_name:find("Linux") then
        os.execute('spd-say "' .. message .. '"')
    elseif os_name:find("MINGW") or os_name:find("CYGWIN") or os_name:find("Windows") then
        os.execute('powershell -Command "Add-Type -AssemblyName System.speech; $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; $speak.Speak(\'' .. message .. '\')"')
    else
        print("Text-to-speech not supported on this OS.")
    end
end

-- Asynchronous event scheduler
local function schedule_event(delay, message)
    coroutine.wrap(function()
        sleep(delay)
        text_to_speech(message)
    end)()
end

-- Ensure no conflicts in event scheduling
local function resolve_conflicts(events)
    local scheduled_times = {}
    for _, event in ipairs(events) do
        local delay, message = event[1], event[2]

        -- Push event back by 5 seconds if conflict detected
        while scheduled_times[delay] do
            delay = delay + 5
        end

        -- Record the resolved time
        event[1] = delay
        scheduled_times[delay] = true
    end
end

-- Main function to start the game timer
function Timer.start(events)
    print("Starting game timer...")

    -- Resolve conflicts in event scheduling
    resolve_conflicts(events)

    -- Schedule all events
    for _, event in ipairs(events) do
        local delay, message = event[1], event[2]
        schedule_event(delay, message)
    end

    print("Timer started! All events have been scheduled.")
end

return Timer
