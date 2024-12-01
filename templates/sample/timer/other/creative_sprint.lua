-- games/creative_sprint.lua
local CreativeSprintEvents = {}

function CreativeSprintEvents.get_events()
    local events = {}
    local creative_duration = 25 * 60 -- 25 minutes
    local reflection_duration = 10 * 60 -- 10 minutes
    local cycles = 5 -- Number of creative cycles

    local current_time = 0
    for cycle = 1, cycles do
        table.insert(events, {current_time, "Begin a 25-minute creative sprint. Focus on output!"})
        current_time = current_time + creative_duration
        table.insert(events, {current_time, "Take 10 minutes to reflect, review, and plan your next steps."})
        current_time = current_time + reflection_duration
    end

    table.insert(events, {current_time, "All creative sprints complete. Well done!"})
    return events
end

return CreativeSprintEvents
