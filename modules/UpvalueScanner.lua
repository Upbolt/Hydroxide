local UpvalueScanner = {}
local Upvalue, TableUpvalue = import("objects/Upvalue")

local requiredMethods = {
    getGc = true,
    getInfo = true,
    isXClosure = true,
    getUpvalue = true,
    setUpvalue = true,
    getUpvalues = true
}

local function compareUpvalue(query, upvalue, ignore)
    local upvalueType = type(upvalue)

    local stringCheck = upvalueType == "string" and (query == upvalue or upvalue:lower():find(query:lower()))
    local numberCheck = upvalueType == "number" and not isTableIndex and (tonumber(query) == upvalue or ("%.2f"):format(upvalue) == query)
    
    if upvalueType == "userdata" then
        if typeof(upvalueType) == "Instance" then
            local instanceName = upvalue.Name
            return (instanceName == query or instanceName:find(query))
        end

        return toString(upvalue) == query
    elseif upvalueType == "function" then
        local closureName = getInfo(upvalue).name
        return query == closureName or closureName:lower():find(query:lower())
    end

    return stringCheck or numberCheck or userDataCheck
end

local function scan(query)
    local upvalues = {}

    for i,closure in pairs(getGc()) do
        if type(closure) == "function" and not isXClosure(closure) and not upvalues[closure] then
            for index, value in pairs(getUpvalues(closure)) do
                local valueType = type(value)

                if valueType ~= "table" and compareUpvalue(query, value) then
                    local upvalueType = type(value)
                    local upvalue = Upvalue.new(closure, index, value)
                    local storage = upvalues[closure]

                    if not storage then
                        upvalues[closure] = { [index] = upvalue }
                    else
                        storage[index] = upvalue
                    end
                elseif UpvalueScanner.UpvalueDeepSearch and valueType == "table" then
                    local storage = upvalues[closure]
                    local table

                    for i,v in pairs(value) do
                        if (i ~= value and v ~= value) and (compareUpvalue(query, i) or compareUpvalue(query, v)) then
                            if not storage then
                                upvalues[closure] = {}
                                storage = upvalues[closure]
                            end

                            if not table then
                                table = TableUpvalue.new(closure, index, value)
                                storage[index] = table
                            end

                            table.Scanned[i] = v
                        end
                    end
                end
            end
        end
    end

    return upvalues
end

UpvalueScanner.Scan = scan
UpvalueScanner.UpvalueDeepSearch = false
UpvalueScanner.RequiredMethods = requiredMethods
return UpvalueScanner
