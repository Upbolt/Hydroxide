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
        local closureName = getInfo(value).name
        return (closureName == '' and "Unnamed function") or closureName
    else
        return tostring(value)
    end
end

local toUnicode = function(string)
    local codepoints = "utf8.char("
    
    for _i, v in utf8.codes(string) do
        codepoints = codepoints .. v .. ', '
    end
    
    return codepoints:sub(1, -3) .. ')'
end

methods.toString = toString
methods.toUnicode = toUnicode
return methods