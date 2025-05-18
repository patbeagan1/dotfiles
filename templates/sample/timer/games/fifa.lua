-- games/fifa.lua
local FIFAEvents = {}

function FIFAEvents.get_events()
    return {
        {0, "Welcome to FIFA! Match is about to start."},
        {45, "45-minute mark. First half is ending soon."},
        {90, "90-minute mark. Full time is approaching. Push for a goal!"},
        {105, "105-minute mark. First half of extra time is ending."},
        {120, "120-minute mark. Penalties may start soon. Be ready!"}
    }
end

return FIFAEvents
