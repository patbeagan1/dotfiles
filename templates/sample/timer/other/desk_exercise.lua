-- games/desk_exercise.lua
local DeskExerciseEvents = {}

function DeskExerciseEvents.get_events()
    local events = {}
    local work_duration = 30 * 60 -- 30 minutes
    local cardio_duration = 120 * 60 -- 2 hours
    local total_time = 8 * 60 * 60 -- 8 hours

    local current_time = 0
    while current_time < total_time do
        current_time = current_time + work_duration
        table.insert(events, {current_time, "Take a 1-minute stretch break. Loosen your muscles!"})

        if current_time % cardio_duration == 0 then
            table.insert(events, {current_time, "Take a 5-minute cardio break. Jumping jacks or a quick walk!"})
        end
    end

    table.insert(events, {total_time, "Workday complete. Take a longer walk or workout session!"})
    return events
end

return DeskExerciseEvents
