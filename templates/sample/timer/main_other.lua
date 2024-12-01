-- main.lua
local Timer = require("timer")
local util = require("util")

-- Supported games and timers
local timers = {
    pomodoro = "other.pomodoro",
    gaming_pomodoro = "other.gaming_pomodoro",
    programmer_balance = "other.programmer_balance",
    deep_work = "other.deep_work",
    desk_exercise = "other.desk_exercise",
    creative_sprint = "other.creative_sprint",
    house_cleaning = "other.house_cleaning",
    study_marathon = "other.study_marathon",
    meal_prep = "other.meal_prep",
    stew = "other.stew",
    laundry = "other.laundry",
    stir_fry = "other.stir_fry"
}

-- Get the selected game or timer from command-line arguments
local timer_name = arg[1] or "pomodoro"

-- Load the appropriate module
local each_module = timers[timer_name]
if not each_module then
    print("Unsupported timer:", timer_name)
    local timer_list = util.keys(timers)
    print("Supported timers are: " .. table.concat(timer_list, ", "))
    os.exit(1)
end

-- Load events and start the timer
local events = require(each_module).get_events()
Timer.start(events)
