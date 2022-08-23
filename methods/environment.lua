local client = game:GetService("Players").LocalPlayer
local playerScripts = client:FindFirstChildOfClass("PlayerScripts")
local control = playerScripts and playerScripts:FindFirstChild("Control Script")

local methods = {}

local function secureCall(closure, ...)
    local env = getfenv(1)
    local renv = getrenv()
    local results
    
    setfenv(1, setmetatable({ script = script }, {
        __index = renv
    }))

    results = (syn and { syn.secure_call(closure, control, ...) }) or { closure(...) }

    setfenv(1, env)

    return unpack(results)
end

methods.secureCall = secureCall
return methods
