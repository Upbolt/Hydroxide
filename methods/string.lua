local methods = {}

local function toString(value)
    local dataType = typeof(value)

    if dataType == "userdata" or dataType == "table" then
        local mt = getMetatable(value)
        local __tostring = mt and rawget(mt, "__tostring")

        if not mt or (mt and not __tostring) then 
            return tostring(value) 
        end

        rawset(mt, "__tostring", nil)
        
        value = tostring(value):gsub((dataType == "userdata" and "userdata: ") or "table: ", '')
        
        rawset(mt, "__tostring", __tostring)

        return value 
    elseif type(value) == "userdata" then
        return userdataValue(value)
    elseif dataType == "function" then
        local closureName = getInfo(value).name or ''
        return (closureName == '' and "Unnamed function") or closureName
    else
        return tostring(value)
    end
end

local gsubCharacters = {
    ["\""] = "\\\"",
    ["\\"] = "\\\\",
    ["\0"] = "\\0",
    ["\n"] = "\\n",
    ["\t"] = "\\t",
    ["\f"] = "\\f",
    ["\r"] = "\\r",
    ["\v"] = "\\v",
    ["\a"] = "\\a",
    ["\b"] = "\\b"
}

local function dataToString(data)
    local dataType = type(data)

    if dataType == "string" then
        return '"' .. data:gsub("[%c%z\\\"]", gsubCharacters) .. '"'
    elseif dataType == "table" then
        return tableToString(data)
    elseif dataType == "userdata" then
        if typeof(data) == "Instance" then
            return getInstancePath(data)
        end

        return userdataValue(data)
    end

    return tostring(data)
end

local function toUnicode(string)
    local codepoints = "utf8.char("
    
    for _i, v in utf8.codes(string) do
        codepoints = codepoints .. v .. ', '
    end
    
    return codepoints:sub(1, -3) .. ')'
end

methods.toString = toString
methods.dataToString = dataToString
methods.toUnicode = toUnicode
return methods
