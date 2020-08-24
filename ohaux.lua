local aux = {}

local getGc = getgc
local getInfo = debug.getinfo or getinfo

assert(getGc and getInfo, "Your exploit is not supported")

local function matchConstants(closure, list)
    if not list then
        return false
    end
    
    for i,v in pairs(debug.getconstants(closure)) do
        if not list[i] then
            return false
        end
    end
    
    return true
end

local function searchClosure(script, name, constants)
    for _i, v in pairs(getgc()) do
        if type(v) == "function" and ((script and rawget(getfenv(v), "script") == script) or true) then
            if ((name and name ~= '') and debug.getinfo(v).name == name) or matchConstants(v, constants) then
                return v
            end
        end
    end
end

aux.searchClosure = searchClosure

return aux