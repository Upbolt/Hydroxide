local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local ControlScript = PlayerScripts:FindFirstChild("Control Script")

local methods = {}

function methods.secureCall(closure, ...)
	local env = getfenv(1)
	local renv = getrenv()
	local results;
	
	setfenv(1, setmetatable({ ["script"] = script }, {
		__index = renv
	}))

	results = (syn and { syn.secure_call(closure, control, ...) }) or { closure(...) }

	setfenv(1, env)

	return unpack(results)
end

return methods
