local Closure = {}
local Upvalue = import("objects/Upvalue")
local Constant = import("objects/Constant")

local closureCache = {}

function Closure.new(data)
    if closureCache[data] then
        return closureCache[data]
    end

    local closure = {}
    local name = getInfo(data).name
    
    closure.Name = (name ~= "" and name) or "Unnamed function"
    closure.Data = data
    closure.Environment = getfenv(data)

    closure.Upvalues = {}
    closure.Constants = {}

    return closure
end

return Closure