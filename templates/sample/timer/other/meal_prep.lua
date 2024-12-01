-- games/meal_prep.lua
local MealPrepEvents = {}

function MealPrepEvents.get_events()
    local events = {}
    local prep_duration = 20 * 60 -- 20 minutes
    local cooking_duration = 40 * 60 -- 40 minutes
    local packing_duration = 15 * 60 -- 15 minutes

    local current_time = 0
    table.insert(events, {current_time, "Begin meal prep! Chop vegetables, marinate, etc."})
    current_time = current_time + prep_duration

    table.insert(events, {current_time, "Start cooking! Ensure all dishes are in progress."})
    current_time = current_time + cooking_duration

    table.insert(events, {current_time, "Pack meals and clean up. You're almost done!"})
    current_time = current_time + packing_duration

    table.insert(events, {current_time, "Meal prep complete. Enjoy your well-organized week!"})
    return events
end

return MealPrepEvents
