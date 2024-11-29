local kontext = {}
function kontext:of(valueIn)
    o = {}
    o.value = valueIn
    setmetatable(o, self)
    kontext.__index = self
    return o
end

-- region std
function kontext:let(block)
    return kontext:of(block(self.value))
end

function kontext:run(block)
    setfenv(block, self.value)
    return kontext.of(block())
end

function kontext:also(block)
    block(self.value)
    return self
end

function kontext:apply(block)
    setfenv(block, self.value)
    block()
    return self
end
-- endregion 

function kontext:takeIf(predicate)
    if predicate(self.value) then
        return self
    else
        return nil
    end
end

function kontext:takeUnless(predicate)
    if not predicate(self.value) then
        return self
    else
        return nil
    end
end

function kontext:toString()
    local result = {}
    for k, v in pairs(self) do
        table.insert(result, tostring(k) .. ": " .. tostring(v))
    end
    return "{" .. table.concat(result, ", ") .. "}"
end

function kontext.shell(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result
end

function kontext.with(value, block)
    return block(value)
end

return kontext
