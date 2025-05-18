-- games/csgo.lua
local CSGoEvents = {}

function CSGoEvents.get_events()
    return {
        {0, "Welcome to Counter-Strike: Global Offensive! Get ready for the match."},
        {15, "15 seconds until freeze time ends. Prepare for the round."},
        {90, "1 minute 30 seconds elapsed. Secure bomb sites!"},
        {105, "35 seconds left in the round. Bomb plant or defuse decisions!"}
    }
end

return CSGoEvents
