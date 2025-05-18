-- games/valorant.lua
local ValorantEvents = {}

function ValorantEvents.get_events()
    return {
        {0, "Welcome to Valorant! Prepare for the match."},
        {15, "15 seconds until buy phase ends. Position yourself!"},
        {90, "Round time is halfway through. Keep an eye on spike locations."},
        {100, "30 seconds remaining. Be ready to plant or defuse the spike!"}
    }
end

return ValorantEvents
