local kstd = {}

function kstd:of(valueIn)
    o = {}
    o.value = valueIn
    setmetatable(o, self)
    kstd.__index = self
    return o
end

local function createContext(value)
    local context = {}
    if value then
        for k, v in pairs(value) do
            context[k] = v
        end
    end
    for k, v in pairs(_G) do
        context[k] = v
    end
    return context
end

-- region std
function kstd:let(block)
    setfenv(block, createContext({
        it = self.value
    }))
    return kstd:of(block(self.value))
end

function kstd:also(block)
    setfenv(block, createContext({
        it = self.value
    }))
    block(self.value)
    return self
end

function kstd:run(block)
    setfenv(block, createContext(self.value))
    return kstd.of(block())
end

function kstd:apply(block)
    error("Not implemented. This goes against the _ENV hierarchy. Use let to build the object instead.")
end
-- endregion 

function kstd:takeIf(block)
    setfenv(block, createContext({
        it = self.value
    }))
    if block(self.value) then
        self.value = nil
    end
    return self
end

function kstd:takeUnless(block)
    setfenv(block, createContext({
        it = self.value
    }))
    if not block(self.value) then
        self.value = nil
    end
    return self
end

function kstd:toString()
    local result = {}
    for k, v in pairs(self) do
        table.insert(result, tostring(k) .. ": " .. tostring(v))
    end
    return "{" .. table.concat(result, ", ") .. "}"
end

function kstd.shell(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result
end

setfenv = setfenv or function(f, t)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name
    local up = 0
    repeat
        up = up + 1
        name = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    if name then
        debug.upvaluejoin(f, up, function()
            return name
        end, 1) -- use unique upvalue
        debug.setupvalue(f, up, t)
    end
end

getfenv = getfenv or function(f)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name, val
    local up = 0
    repeat
        up = up + 1
        name, val = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    return val
end

function printEnv()
    print("---\nenv\n---")
    table.sort(_ENV)
    for k, v in pairs(_ENV) do
        print(k .. " :: " .. tostring(v))
    end
    print()
end

function kstd.with(value, block)
    return block(value)
end

return kstd
