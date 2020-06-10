local UpvalueScanner = {}
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
    elseif UpvalueScsanner.upvalueDeepSearch and upvalueType == "table" then
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

    for i,v in pairs(getGc()) do
        if type(v) == "function" and not isXClosure(v) then
            for k, upvalue in pairs(getUpvalues(v)) do
                if compareUpvalue(query, upvalue) then
                    local closure = upvalues[v]

                    if not closure then
                        upvalues[v] = { [k] = upvalue }
                    else
                        closure[k] = upvalue
                    end
                end
            end
        end
    end

    return upvalues
end

UpvalueScanner.upvalueDeepSearch = false
UpvalueScanner.RequiredMethods = requiredMethods
UpvalueScanner.Scan = scan
return UpvalueScanner
