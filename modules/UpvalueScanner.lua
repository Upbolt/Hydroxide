local UpvalueScanner = {}
local Upvalue = import("objects/Upvalue")

local requiredMethods = {
    getGc = true,
    getInfo = true,
    isXClosure = true,
    getUpvalue = true,
    setUpvalue = true,
    getUpvalues = true
}

local function compareUpvalue(query, upvalue)
    local upvalueType = type(upvalue)

    local stringCheck = upvalueType == "string" and (query == upvalue or upvalue:lower():find(query:lower()))
    local numberCheck = upvalueType == "number" and (tonumber(query) == upvalue or ("%.2f"):format(upvalue) == query)
    local userDataCheck = upvalueType == "userdata" and toString(upvalue) == query

    if upvalueType == "function" then
        local closureName = getInfo(upvalue).name
        return query == closureName or closureName:lower():find(query:lower())
    elseif UpvalueScanner.upvalueDeepSearch and upvalueType == "table" then
        for i,v in pairs(upvalue) do
            local indexType = type(i)

            if (indexType ~= "table" and indexType ~= "number" and type(v) ~= "table") and (compareUpvalue(query, i) or compareUpvalue(query, v)) then
                return true
            end
        end

        return false
    end

    return stringCheck or numberCheck or userDataCheck
end

local function scan(query)
    local upvalues = {}

    for i,closure in pairs(getGc()) do
        if type(closure) == "function" and not isXClosure(closure) and not upvalues[closure] then
            for index, value in pairs(getUpvalues(closure)) do
                if compareUpvalue(query, value) then
                    local storage = upvalues[closure]

                    if not storage then
                        upvalues[closure] = { [index] = Upvalue.new(closure, index, value) }
                    else
                        storage[index] = Upvalue.new(closure, index, value)
                    end
                end
            end
        end
    end

    return upvalues
end

UpvalueScanner.Scan = scan
UpvalueScanner.upvalueDeepSearch = false
UpvalueScanner.RequiredMethods = requiredMethods
return UpvalueScanner
