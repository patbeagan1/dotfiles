-- games/pubg.lua
local PUBGEvents = {}

function PUBGEvents.get_events()
    return {
        {0, "Welcome to PUBG! Prepare to parachute."},
        {30, "30 seconds elapsed. Finalize your landing spot."},
        {120, "2-minute mark. First blue zone is closing soon."},
        {300, "5-minute mark. Red zones are more frequent. Stay alert."},
        {600, "10-minute mark. Mid-game engagements. Focus on positioning."},
        {1200, "20-minute mark. Final circles are approaching. Prepare for combat!"},
        {1500, "25-minute mark. Victory is near. Secure the chicken dinner!"}
    }
end

return PUBGEvents
