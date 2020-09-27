local Closure = {}
Closure.__index = Closure

local closureCache = {}

function Closure.new(data)
	if closureCache[data] then
		return closureCache[data]
	end
    
	local name = getInfo(data).name or ''
    
	return setmetatable({
		Name = (name ~= '' and name) or "Unnamed function",
		Data = data,
		Environment = getfenv(data),

		Upvalues = {},
		Constants = {},

		TemporaryUpvalues = {},
		TemporaryConstants = {}
	}, Closure)
end

return Closure
