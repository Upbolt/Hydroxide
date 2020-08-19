local Closure = {}
local closureCache = {}

function Closure.new(data)
    if closureCache[data] then
        return closureCache[data]
    end

    local closure = {}
    local name = getInfo(data).name or ''
    
    closure.Name = (name ~= '' and name) or "Unnamed function"
    closure.Data = data
    closure.Environment = getfenv(data)

    closure.Upvalues = {}
    closure.Constants = {}

    closure.TemporaryUpvalues = {}
    closure.TemporaryConstants = {}

    return closure
end

return Closure