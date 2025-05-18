-- games/house_cleaning.lua
local HouseCleaningEvents = {}

function HouseCleaningEvents.get_events()
    local events = {}
    local task_duration = 15 * 60 -- 15 minutes
    local break_duration = 10 * 60 -- 10 minutes
    local cycles = 8 -- Total tasks

    local current_time = 0
    for cycle = 1, cycles do
        table.insert(events, {current_time, "Clean a specific area for 15 minutes (e.g., living room, kitchen)."})

        current_time = current_time + task_duration
        if cycle % 4 == 0 then
            table.insert(events, {current_time, "Take a 10-minute break. Stay hydrated!"})
            current_time = current_time + break_duration
        end
    end

    table.insert(events, {current_time, "All cleaning tasks are done! Time to relax."})
    return events
end

return HouseCleaningEvents
