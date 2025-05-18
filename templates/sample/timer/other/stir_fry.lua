-- games/stir_fry.lua
local StirFryEvents = {}

function StirFryEvents.get_events()
    local events = {}
    local current_time = 0

    -- Step 1: Prep ingredients (10 minutes)
    table.insert(events, {current_time, "Prep time: Chop vegetables, cut protein, and measure sauces. 10 minutes."})
    current_time = current_time + 10 * 60

    -- Step 2: Heat the pan (2 minutes)
    table.insert(events, {current_time, "Heat the pan: Add oil and heat on medium-high. 2 minutes."})
    current_time = current_time + 2 * 60

    -- Step 3: Cook protein (5 minutes)
    table.insert(events, {current_time, "Cook the protein: Add meat or tofu to the pan. Stir frequently for 5 minutes."})
    current_time = current_time + 5 * 60

    -- Step 4: Cook vegetables (3 minutes)
    table.insert(events, {current_time, "Add vegetables: Toss the chopped veggies into the pan. Cook for 3 minutes, stirring constantly."})
    current_time = current_time + 3 * 60

    -- Step 5: Add sauce (2 minutes)
    table.insert(events, {current_time, "Add sauce: Pour in the pre-measured sauce and mix well. 2 minutes."})
    current_time = current_time + 2 * 60

    -- Step 6: Simmer and combine (3 minutes)
    table.insert(events, {current_time, "Simmer and combine: Let everything cook together for 3 minutes to blend flavors."})
    current_time = current_time + 3 * 60

    -- Step 7: Serve (5 minutes)
    table.insert(events, {current_time, "Serve: Plate your stir-fry over rice or noodles. Clean up as you go! 5 minutes."})
    current_time = current_time + 5 * 60

    table.insert(events, {current_time, "Stir-fry is ready! Enjoy your delicious meal!"})

    return events
end

return StirFryEvents
