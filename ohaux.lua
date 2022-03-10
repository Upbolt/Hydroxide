local aux = {}

local getGc = getgc
local getInfo = debug.getinfo or getinfo
local getUpvalue = debug.getupvalue or getupvalue or getupval
local getConstants = debug.getconstants or getconstants or getconsts
local isXClosure = is_synapse_function or issentinelclosure or is_protosmasher_closure or is_sirhurt_closure or istempleclosure or checkclosure
local isLClosure = islclosure or is_l_closure or (iscclosure and function(f) return not iscclosure(f) end)

assert(getGc and getInfo and getConstants and isXClosure, "Your exploit is not supported")

local placeholderUserdataConstant = newproxy(false)

local function matchConstants(closure, list)
    if not list then
        return true
    end
    
    local constants = getConstants(closure)
    
    for index, value in pairs(list) do
        if constants[index] ~= value and value ~= placeholderUserdataConstant then
            return false
        end
    end
    
    return true
end

local function searchClosure(script, name, upvalueIndex, constants)
    for _i, v in pairs(getGc()) do
        local parentScript = rawget(getfenv(v), "script")

        if type(v) == "function" and 
            isLClosure(v) and 
            not isXClosure(v) and 
            (
                (script == nil and parentScript.Parent == nil) or script == parentScript
            ) 
            and pcall(getUpvalue, v, upvalueIndex)
        then
            if ((name and name ~= "Unnamed function") and getInfo(v).name == name) and matchConstants(v, constants) then
                return v
            elseif (not name or name == "Unnamed function") and matchConstants(v, constants) then
                return v
            end
        end
    end
end

aux.placeholderUserdataConstant = placeholderUserdataConstant
aux.searchClosure = searchClosure

return aux
