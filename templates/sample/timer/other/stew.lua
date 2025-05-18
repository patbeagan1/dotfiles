 -- games/stew.lua
local StewEvents = {}

function StewEvents.get_events()
    local events = {}
    local current_time = 0

    -- Step 1: Prep ingredients (15 minutes)
    table.insert(events, {current_time, "Prep time: Chop vegetables, cube the meat, and measure spices. 15 minutes."})
    current_time = current_time + 15 * 60

    -- Step 2: Brown meat (10 minutes)
    table.insert(events, {current_time, "Brown the meat: Heat oil in a pot and sear the meat. 10 minutes."})
    current_time = current_time + 10 * 60

    -- Step 3: Add vegetables and spices (5 minutes)
    table.insert(events, {current_time, "Add vegetables and spices: Toss in the chopped vegetables and spices. 5 minutes."})
    current_time = current_time + 5 * 60

    -- Step 4: Add broth and bring to boil (5 minutes)
    table.insert(events, {current_time, "Add broth and bring to a boil. Stir occasionally. 5 minutes."})
    current_time = current_time + 5 * 60

    -- Step 5: Simmer stew (90 minutes)
    table.insert(events, {current_time, "Reduce to a simmer and cover the pot. Let the stew cook for 90 minutes."})
    current_time = current_time + 90 * 60

    -- Step 6: Taste and adjust seasoning (5 minutes)
    table.insert(events, {current_time, "Taste the stew and adjust seasoning (salt, pepper, etc.). 5 minutes."})
    current_time = current_time + 5 * 60

    -- Step 7: Serve (5 minutes)
    table.insert(events, {current_time, "Stew is ready! Serve hot and enjoy. 5 minutes."})
    current_time = current_time + 5 * 60

    table.insert(events, {current_time, "Cooking is complete. Enjoy your delicious stew!"})

    return events
end

return StewEvents
