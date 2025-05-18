-- games/laundry.lua
local LaundryEvents = {}

function LaundryEvents.get_events()
    local events = {}
    local current_time = 0

    -- Step 1: Start washing machine (45 minutes)
    table.insert(events, {current_time, "Start the washing machine. Load clothes, add detergent, and set the cycle. 45 minutes."})
    current_time = current_time + 45 * 60

    -- Step 2: Transfer to dryer (5 minutes)
    table.insert(events, {current_time, "Washing is done! Transfer clothes to the dryer. 5 minutes."})
    current_time = current_time + 5 * 60

    -- Step 3: Drying cycle (60 minutes)
    table.insert(events, {current_time, "Start the dryer. Drying will take about 60 minutes."})
    current_time = current_time + 60 * 60

    -- Step 4: Folding clothes (20 minutes)
    table.insert(events, {current_time, "Drying is complete! Take out the clothes and start folding. 20 minutes."})
    current_time = current_time + 20 * 60

    table.insert(events, {current_time, "Laundry is done! Put away the folded clothes and enjoy your tidy wardrobe."})

    return events
end

return LaundryEvents
