local aux = {}

local getGc = getgc
local getInfo = debug.getinfo or getinfo

assert(getGc and getInfo, "Your exploit is not supported")

local function findClosure(name)
    for i,v in pairs(getGc()) do
        if type(v) == "function" and getInfo(v).name == name then
            return v
        end
    end
end

aux.findClosure = findClosure

return aux