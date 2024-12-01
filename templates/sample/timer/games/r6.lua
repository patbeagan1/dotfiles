-- games/r6.lua
local R6Events = {}

function R6Events.get_events()
    return {
        {0, "Welcome to Rainbow Six Siege! Match preparation begins."},
        {15, "15 seconds until prep phase ends. Reinforce and place gadgets!"},
        {45, "45 seconds elapsed. Attackers should breach objectives."},
        {120, "2-minute mark. Secure the area or eliminate remaining enemies."}
    }
end

return R6Events
