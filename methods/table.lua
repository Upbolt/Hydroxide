local methods = {}

local function tableToString(data, root, indents)
    local dataType = type(data)

    if dataType == "userdata" then
        return (typeof(data) == "Instance" and getInstancePath(data)) or userdataValue(data)
    elseif dataType == "string" then
        if #(data:gsub('%w', ''):gsub('%s', ''):gsub('%p', '')) > 0 then
            local success, result = pcall(toUnicode, data)
            return (success and result) or toString(data)
        else
            return ('"%s"'):format(data:gsub('"', '\\"'))
        end
    elseif dataType == "table" then
        indents = indents or 1
        root = root or data

        local head = '{\n'
        local elements = 0
        local indent = ('\t'):rep(indents)
        
        for i,v in pairs(data) do
            if i ~= root and v ~= root then
                head = head .. ("%s[%s] = %s,\n"):format(indent, tableToString(i, root, indents + 1), tableToString(v, root, indents + 1))
            else
                head = head .. ("%sOH_CYCLIC_PROTECTION,\n"):format(indent)
            end

            elements = elements + 1
        end
        
        if elements > 0 then
            return ("%s\n%s"):format(head:sub(1, -3), ('\t'):rep(indents - 1) .. '}')
        else
            return "{}"
        end
    end

    return tostring(data)
end

local function compareTables(x, y)
    for i, v in pairs(x) do
        if v ~= y[i] then
            return false
        end
    end

    return true
end

methods.tableToString = tableToString
methods.compareTables = compareTables
return methods