local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local USERDATA_TYPES = {
	["BrickColor"] = true,
	["TweenInfo"] = true,
	["Instance"] = true,
	["DateTime"] = true,
	["Vector3"] = true,
	["Vector2"] = true,
	["Region3"] = true,
	["CFrame"] = true,
	["Color3"] = true,
	["Random"] = true,
	["Faces"] = true,
	["UDim2"] = true,
	["UDim"] = true,
	["Rect"] = true,
	["Axes"] = true,
	["Ray"] = true,
	["RaycastParams"] = true,
	["PathWaypoint"] = true,
	["PhysicalProperties"] = true,
	["ColorSequence"] = true,
	["ColorSequenceKeypoint"] = true,
	["NumberRange"] = true,
	["NumberSequence"] = true,
	["NumberSequenceKeypoint"] = true
}

local methods = {}

function methods.getInstancePath(instance)
	local name = instance.Name
	local className = instance.ClassName
	local head = (#name > 0 and '.' .. name) or "['']"
	
	if not instance.Parent and instance ~= game then
		return head .. " --[[ PARENTED TO NIL OR DESTROYED ]]"
	end
	
	if instance == game then
		return "game"
	elseif instance == Workspace then
		return "workspace"
	else
		local _success, result = pcall(game.GetService, game, className)
		
		if result then
			head = ':GetService("' .. className .. '")'
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

function methods.userdataValue(data)
	local dataType = typeof(data)

	if dataType == "userdata" then
		return toString(data)
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

function methods.isUserdata(typeInput)
	return USERDATA_TYPES[typeInput]
end

return methods
