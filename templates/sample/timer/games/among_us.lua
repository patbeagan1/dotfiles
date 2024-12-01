-- games/among_us.lua
local AmongUsEvents = {}

function AmongUsEvents.get_events()
    return {
        {0, "Welcome to Among Us! Crewmates complete tasks; impostors sabotage."},
        {30, "30 seconds elapsed. Discuss your strategy with your team."},
        {120, "2-minute mark. Check for suspicious activity!"},
        {300, "5-minute mark. Tasks should be nearly complete. Stay alert!"}
    }
end

return AmongUsEvents
