-- games/apex.lua
local ApexEvents = {}

function ApexEvents.get_events()
    return {
        {0, "Welcome to Apex Legends! Prepare to drop."},
        {20, "20 seconds elapsed. Decide your drop location."},
        {120, "2-minute mark. First ring is closing soon."},
        {180, "3-minute mark. The first ring is shrinking. Move to safety!"},
        {600, "10-minute mark. Mid-game fights are common. Stay alert."},
        {1200, "20-minute mark. Final ring is approaching. Prepare for endgame!"},
        {1500, "25-minute mark. The match is nearing its end. Secure the victory!"}
    }
end

return ApexEvents
