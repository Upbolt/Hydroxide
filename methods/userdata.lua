local methods = {}

local function getInstancePath(instance)
    local name = instance.Name
    local head = (#name > 0 and '.' .. name) or "['']"
    
    if not instance.Parent and instance ~= game then
        return head .. " --[[ PARENTED TO NIL OR DESTROYED ]]"
    end
    
    if instance == game then
        return "game"
    elseif instance == workspace then
        return "workspace"
    else
        local _success, result = pcall(game.GetService, game, instance.ClassName)
        
        if result then
            head = ':GetService("' .. instance.ClassName .. '")'
        elseif instance == game:GetService("Players").LocalPlayer then
            head = '.LocalPlayer' 
        else
            local nonAlphaNum = name:gsub('[%w_]', '')
            local noPunct = nonAlphaNum:gsub('[%s%p]', '')
            
            if tonumber(name:sub(1, 1)) or (#nonAlphaNum ~= 0 and #noPunct == 0) then
                head = '["' .. name:gsub('"', '\\"'):gsub('\\', '\\\\') .. '"]'
            elseif #nonAlphaNum ~= 0 and #noPunct > 0 then
                head = '[' .. toUnicode(name) .. ']'
            end
        end
    end
    
    return getInstancePath(instance.Parent) .. head
end

local function userdataValue(data)
    local dataType = typeof(data)

    if dataType == "userdata" then
        return toString(data)
    elseif dataType == "Instance" then
        return data.Name
    elseif 
        dataType == "Vector3" or
        dataType == "Vector2" or
        dataType == "CFrame" or
        dataType == "Color3" or
        dataType == "UDim2" or
        dataType == "UDim"
    then
        return dataType .. ".new(" .. tostring(data) .. ")"
    elseif dataType == "Ray" then
        local split = tostring(data):split('}, ')
        local origin = split[1]:gsub('{', "Vector3.new("):gsub('}', ')')
        local direction = split[2]:gsub('{', "Vector3.new("):gsub('}', ')')
        return "Ray.new(" .. origin .. "), " .. direction .. ')'
    elseif dataType == "ColorSequence" then
        return "ColorSequence.new(" .. tableToString(v.Keypoints) .. ')'
    elseif dataType == "ColorSequenceKeypoint" then
        return "ColorSequenceKeypoint.new(" .. data.Time .. ", Color3.new(" .. tostring(data.Value) .. "))"
    end

    return tostring(data)
end

local function isUserdata(type)
    return type == "Instance" 
        or type == "Vector3" 
        or type == "Vector2"
        or type == "CFrame"
        or type == "Color3"
        or type == "UDim2"
        or type == "UDim"
        or type == "Ray"
        or type == "ColorSequence"
        or type == "ColorSequenceKeypoint"
end

methods.isUserdata = isUserdata
methods.userdataValue = userdataValue
methods.getInstancePath = getInstancePath
return methods