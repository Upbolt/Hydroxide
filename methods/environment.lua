local methods = {}

local function secureCall(closure, ...)
    local env = getfenv(1)
    local renv = getrenv()
    local results
    
    setfenv(1, setmetatable({script=script}, {
        __index = renv
    }))

    results = { closure(...) }
    
    setfenv(1, env)

    return unpack(results)
end

methods.secureCall = secureCall
return methods