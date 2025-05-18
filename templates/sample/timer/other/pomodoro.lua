-- games/pomodoro.lua
local PomodoroEvents = {}

function PomodoroEvents.get_events()
    local events = {}
    local work_duration = 25 * 60 -- 25 minutes
    local short_break = 5 * 60 -- 5 minutes
    local long_break = 15 * 60 -- 15 minutes
    local total_cycles = 4

    local current_time = 0
    for cycle = 1, total_cycles do
        -- Add work period
        table.insert(events, {current_time, "Start working! Focus for 25 minutes."})
        current_time = current_time + work_duration

        -- Add break
        if cycle < total_cycles then
            table.insert(events, {current_time, "Take a 5-minute break. Relax!"})
            current_time = current_time + short_break
        else
            table.insert(events, {current_time, "Take a 15-minute break. Great job!"})
            current_time = current_time + long_break
        end
    end

    return events
end

return PomodoroEvents
