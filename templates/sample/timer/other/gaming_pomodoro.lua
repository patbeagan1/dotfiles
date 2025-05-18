-- games/gaming_pomodoro.lua
local GamingPomodoroEvents = {}

function GamingPomodoroEvents.get_events()
    local events = {}
    local practice_duration = 20 * 60 -- 20 minutes
    local short_break = 10 * 60 -- 10 minutes
    local long_break = 20 * 60 -- 20 minutes
    local total_cycles = 3 -- Number of practice sessions

    local current_time = 0
    for cycle = 1, total_cycles do
        -- Add practice period
        table.insert(events, {current_time, "Start focused practice! 20 minutes of skill improvement."})
        current_time = current_time + practice_duration

        -- Add break
        if cycle < total_cycles then
            table.insert(events, {current_time, "Take a 10-minute break. Recharge for the next session."})
            current_time = current_time + short_break
        else
            table.insert(events, {current_time, "Take a 20-minute break. Great practice session!"})
            current_time = current_time + long_break
        end
    end

    return events
end

return GamingPomodoroEvents
