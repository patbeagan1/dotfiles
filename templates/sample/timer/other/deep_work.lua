-- games/deep_work.lua
local DeepWorkEvents = {}

function DeepWorkEvents.get_events()
    local events = {}
    local work_duration = 90 * 60 -- 90 minutes
    local break_duration = 15 * 60 -- 15 minutes
    local cycles = 3 -- Number of deep work cycles

    local current_time = 0
    for cycle = 1, cycles do
        table.insert(events, {current_time, "Start a deep work session! 90 minutes of focused effort."})
        current_time = current_time + work_duration
        if cycle < cycles then
            table.insert(events, {current_time, "Take a 15-minute recharge break. Step away from your desk!"})
            current_time = current_time + break_duration
        end
    end

    table.insert(events, {current_time, "You've completed all deep work cycles. Great job for the day!"})
    return events
end

return DeepWorkEvents
