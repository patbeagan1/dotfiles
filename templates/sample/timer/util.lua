local util = {}

function util.keys(tbl)
    local list = {}
    local n = 1
    for k, v in pairs(tbl) do
        list[n] = k
        n = n + 1
    end
    return list
end

return util
