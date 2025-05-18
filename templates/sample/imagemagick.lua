-- Enhanced ImageMagick DSL Class
ImageMagick = {}

-- Global Configuration
ImageMagick.config = {
    tool = "convert", -- Default tool (can be "convert" or "magick")
    log_file = nil,   -- Set to a file path to enable logging
    debug = false,    -- Debug mode (true to print commands without running)
}

-- Constructor
function ImageMagick:new(input)
    local obj = { input = {}, commands = {}, output_file = nil }
    if type(input) == "string" then
        table.insert(obj.input, input)
    elseif type(input) == "table" then
        obj.input = input
    else
        error("Input must be a string or table of file paths.")
    end
    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- Add a command
function ImageMagick:addCommand(command)
    assert(type(command) == "string" and command ~= "", "Command must be a non-empty string.")
    table.insert(self.commands, command)
    return self
end

-- DSL Methods
function ImageMagick:resize(size)
    assert(type(size) == "string" and size:match("%d+x%d+"), "Invalid size format. Use 'WIDTHxHEIGHT'.")
    return self:addCommand("-resize " .. size)
end

function ImageMagick:crop(dimensions)
    assert(type(dimensions) == "string" and dimensions:match("%d+x%d+[%+%-]%d+[%+%-]%d+"),
           "Invalid crop format. Use 'WIDTHxHEIGHT+X_OFFSET+Y_OFFSET'.")
    return self:addCommand("-crop " .. dimensions)
end

function ImageMagick:rotate(angle)
    assert(type(angle) == "number", "Angle must be a number.")
    return self:addCommand("-rotate " .. angle)
end

function ImageMagick:blur(amount)
    assert(type(amount) == "number" or (type(amount) == "string" and amount:match("%d+")), 
           "Blur amount must be a number or valid string.")
    return self:addCommand("-blur " .. amount)
end

function ImageMagick:colorspace(mode)
    assert(type(mode) == "string" and mode ~= "", "Colorspace mode must be a non-empty string.")
    return self:addCommand("-colorspace " .. mode)
end

function ImageMagick:format(fmt)
    assert(type(fmt) == "string" and fmt ~= "", "Format must be a non-empty string.")
    return self:addCommand("-format " .. fmt)
end

function ImageMagick:brightnessContrast(value)
    assert(type(value) == "string" and value:match("[+-]?%d+x[+-]?%d+"),
           "Brightness/Contrast must be in the format '+BRIGHTNESSx+CONTRAST'.")
    return self:addCommand("-brightness-contrast " .. value)
end

function ImageMagick:annotate(text, options)
    assert(type(text) == "string" and text ~= "", "Text must be a non-empty string.")
    options = options or ""
    return self:addCommand(string.format("-annotate %s '%s'", options, text))
end

function ImageMagick:flip()
    return self:addCommand("-flip")
end

function ImageMagick:flop()
    return self:addCommand("-flop")
end

-- Set output file
function ImageMagick:output(filename)
    assert(type(filename) == "string" and filename ~= "", "Output file must be a non-empty string.")
    self.output_file = filename
    return self
end

-- Add raw/custom ImageMagick commands
function ImageMagick:custom(cmd)
    assert(type(cmd) == "string" and cmd ~= "", "Custom command must be a non-empty string.")
    return self:addCommand(cmd)
end

-- Execute the command
function ImageMagick:run()
    assert(#self.input > 0, "Input file(s) must be specified.")
    assert(self.output_file, "Output file must be specified using :output().")

    -- Build the command
    local tool = ImageMagick.config.tool or "convert"
    local command = tool .. " " .. table.concat(self.input, " ")
    for _, cmd in ipairs(self.commands) do
        command = command .. " " .. cmd
    end
    command = command .. " " .. self.output_file

    -- Debug or execute
    if ImageMagick.config.debug then
        print("[DEBUG] Command:", command)
    else
        print("Executing:", command)
        local success, _, exit_code = os.execute(command)
        if not success then
            error("ImageMagick command failed with exit code: " .. (exit_code or "unknown"))
        end
    end

    -- Logging
    if ImageMagick.config.log_file then
        local log = io.open(ImageMagick.config.log_file, "a")
        log:write(command .. "\n")
        log:close()
    end

    return command
end

-- Factory function
function imagemagick(input)
    return ImageMagick:new(input)
end

-- Configuration method
function ImageMagick.configure(options)
    for k, v in pairs(options) do
        ImageMagick.config[k] = v
    end
end
