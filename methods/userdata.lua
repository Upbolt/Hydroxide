local methods = {}

local players = game:GetService("Players")
local client = players.LocalPlayer

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
        elseif instance == client then
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
        return "aux.placeholderUserdataConstant"
    elseif dataType == "Instance" then
        return data.Name
    elseif dataType == "BrickColor" then
        return dataType .. ".new(\"" .. tostring(data) .. "\")"
    elseif
        dataType == "TweenInfo" or
        dataType == "Vector3" or
        dataType == "Vector2" or
        dataType == "CFrame" or
        dataType == "Color3" or
        dataType == "Random" or
        dataType == "Faces" or
        dataType == "UDim2" or
        dataType == "UDim" or
        dataType == "Rect" or
        dataType == "Axes" or
        dataType == "NumberRange" or
        dataType == "RaycastParams" or
        dataType == "PhysicalProperties"
    then
        return dataType .. ".new(" .. tostring(data) .. ")"
    elseif dataType == "DateTime" then
        return dataType .. ".now()"
    elseif dataType == "PathWaypoint" then
        local split = tostring(data):split('}, ')
        local vector = split[1]:gsub('{', "Vector3.new(")
        return dataType .. ".new(" .. vector .. "), " .. split[2] .. ')'
    elseif dataType == "Ray" or dataType == "Region3" then
        local split = tostring(data):split('}, ')
        local vprimary = split[1]:gsub('{', "Vector3.new(")
        local vsecondary = split[2]:gsub('{', "Vector3.new("):gsub('}', ')')
        return dataType .. ".new(" .. vprimary .. "), " .. vsecondary .. ')'
    elseif dataType == "ColorSequence" or dataType == "NumberSequence" then 
        return dataType .. ".new(" .. tableToString(data.Keypoints) .. ')'
    elseif dataType == "ColorSequenceKeypoint" then
        return "ColorSequenceKeypoint.new(" .. data.Time .. ", Color3.new(" .. tostring(data.Value) .. "))"
    elseif dataType == "NumberSequenceKeypoint" then
        local envelope = data.Envelope and data.Value .. ", " .. data.Envelope or data.Value
        return "NumberSequenceKeypoint.new(" .. data.Time .. ", " .. envelope .. ")"
    end

    return tostring(data)
end

local function isUserdata(type)
    return type == "BrickColor"
        or type == "TweenInfo"
        or type == "Instance"
        or type == "DateTime"
        or type == "Vector3" 
        or type == "Vector2"
        or type == "Region3"
        or type == "CFrame"
        or type == "Color3"
        or type == "Random"
        or type == "Faces"
        or type == "UDim2"
        or type == "UDim"
        or type == "Rect"
        or type == "Axes"
        or type == "Ray"
        or type == "RaycastParams"
        or type == "PathWaypoint"
        or type == "PhysicalProperties"
        or type == "ColorSequence"
        or type == "ColorSequenceKeypoint"
        or type == "NumberRange"
        or type == "NumberSequence"
        or type == "NumberSequenceKeypoint"
end

methods.isUserdata = isUserdata
methods.userdataValue = userdataValue
methods.getInstancePath = getInstancePath
return methods
