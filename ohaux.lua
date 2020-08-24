local aux = {}

local getGc = getgc
local getInfo = debug.getinfo or getinfo
local getConstants = debug.getconstants or getconstants or getconsts

assert(getGc and getInfo and getConstants, "Your exploit is not supported")

local function matchConstants(closure, list)
    if not list then
        return true
    end
    
    for index in pairs(getConstants(closure)) do
        if not list[index] then
            return false
        end
    end
    
    return true
end

local function searchClosure(script, name, constants)
    for _i, v in pairs(getGc()) do
        if type(v) == "function" and (not script or (script and rawget(getfenv(v), "script") == script)) then
            if ((name and name ~= "Unnamed function") and getInfo(v).name == name) and matchConstants(v, constants) then
                return v
            elseif (not name or name == "Unnamed function") and matchConstants(v, constants) then
                return v
            end
        end
    end
end

aux.searchClosure = searchClosure

return aux