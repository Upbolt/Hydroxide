local methods = {}

local function secureCall(closure, ...)
    local env = getfenv(1)
    
    setfenv(1, setmetatable({script=script}, {
        __index = getrenv()
    }))

    closure(...)
    
    setfenv(1, env)
end

methods.secureCall = secureCall
return methods