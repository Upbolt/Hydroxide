local UpvalueScanner = {}
local Closure = import("objects/Closure")
local Upvalue = import("objects/Upvalue")

local requiredMethods = {
    ["getGc"] = true,
    ["getInfo"] = true,
    ["isXClosure"] = true,
    ["getUpvalue"] = true,
    ["setUpvalue"] = true,
    ["getUpvalues"] = true
}

local function compareUpvalue(query, upvalue, ignore)
    local upvalueType = type(upvalue)

    local stringCheck = upvalueType == "string" and (query == upvalue or upvalue:lower():find(query:lower()))
    local numberCheck = not ignore and upvalueType == "number" and not isTableIndex and (tonumber(query) == upvalue or ("%.2f"):format(upvalue) == query)
    
    if upvalueType == "userdata" then
        if typeof(upvalueType) == "Instance" then
            local instanceName = upvalue.Name
            return (instanceName == query or instanceName:find(query))
        end

        return toString(upvalue) == query
    elseif upvalueType == "function" then
        local closureName = getInfo(upvalue).name or ''
        return query == closureName or closureName:lower():find(query:lower())
    end

    return stringCheck or numberCheck or userDataCheck
end

local function scan(query, deepSearch)
    local upvalues = {}

    for _i, closure in pairs(getGc()) do
        if type(closure) == "function" and not isXClosure(closure) and not upvalues[closure] then
            for index, value in pairs(getUpvalues(closure)) do
                local valueType = type(value)

                if valueType ~= "table" and compareUpvalue(query, value) then
                    local storage = upvalues[closure]

                    if not storage then
                        local newClosure = Closure.new(closure)
                        newClosure.Upvalues[index] = Upvalue.new(newClosure, index, value)
                        upvalues[closure] = newClosure
                    else
                        storage.Upvalues[index] = Upvalue.new(storage, index, value)
                    end
                elseif deepSearch and valueType == "table" then
                    local storage = upvalues[closure]
                    local table

                    for i, v in pairs(value) do
                        if (i ~= value and v ~= value) and (compareUpvalue(query, i, true) or compareUpvalue(query, v)) then
                            if not storage then
                                local newClosure = Closure.new(closure)
                                storage = newClosure
                                upvalues[closure] = newClosure
                            end

                            if not table then
                                table = Upvalue.new(storage, index, value)
                                table.Scanned = {}
                                storage.Upvalues[index] = table
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
UpvalueScanner.RequiredMethods = requiredMethods
return UpvalueScanner
