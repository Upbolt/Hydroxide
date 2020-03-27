local upvalue = {}

local update = function(upvalue)
    
end

upvalue.new = function(closure, index)
    local object = {}

    object.update = update

    return object
end

return upvalue