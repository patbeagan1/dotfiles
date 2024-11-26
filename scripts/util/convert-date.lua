local DateConverter = {}

-- Month map for converting month names to numeric format
DateConverter.month_map = {
    January = "01",
    February = "02",
    March = "03",
    April = "04",
    May = "05",
    June = "06",
    July = "07",
    August = "08",
    September = "09",
    October = "10",
    November = "11",
    December = "12"
}

-- Function to convert the date
function DateConverter.convert_date(date_string)
    -- Split the input into components
    local month, day, year = date_string:match("(%a+)%s(%d+),%s(%d+)")
    if month and day and year then
        local month_number = DateConverter.month_map[month]
        if month_number then
            -- Format the date as YYYY-MM-DD
            return string.format("%s-%s-%02d", year, month_number, tonumber(day))
        else
            return nil, "Invalid month name: " .. month
        end
    else
        return nil, "Invalid date format. Expected format: 'Month Day, Year' (e.g., 'October 20, 1999')."
    end
end

-- CLI handling
local function main()
    -- Get the input date from the command-line arguments
    local args = {...}
    if #args == 1 then
        local input_date = args[1]
        local converted_date, err = DateConverter.convert_date(input_date)
        if converted_date then
            print("Converted date: " .. converted_date)
        else
            io.stderr:write("Error: " .. err .. "\n")
        end
    else
        io.stderr:write("Usage: lua convert_date.lua \"Month Day, Year\"\n")
    end
end

-- Run the script
main

