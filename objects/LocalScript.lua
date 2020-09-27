local LocalScript = {}
LocalScript.__index = LocalScript

function LocalScript.new(instance)
	local closure = getScriptClosure(instance)

	return setmetatable({
		Instance = instance,
		Environment = getSenv(instance),
		Constants = getConstants(closure),
		Protos = getProtos(closure),
	}, LocalScript)
end

return LocalScript
