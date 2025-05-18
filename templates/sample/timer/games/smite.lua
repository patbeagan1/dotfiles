-- games/smite.lua
local SmiteEvents = {}

function SmiteEvents.get_events()
    return {
        {0, "Welcome to the Battleground of the Gods! Prepare for the match."},
        {30, "30 seconds to minion spawn. Position yourself!"},
        {60, "Minions have spawned! Secure your lane."},
        {180, "3-minute mark. Buff camps have respawned!"},
        {300, "5-minute mark. Gold Fury is available. Secure objectives!"},
        {480, "8-minute mark. Pyromancer is available."},
        {600, "10-minute mark. Fire Giant is available! Be ready to contest."},
        {1200, "20-minute mark. Enhanced Fire Giant is available. Prepare for late-game fights!"}
    }
end

return SmiteEvents
