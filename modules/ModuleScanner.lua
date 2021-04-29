local ModuleScanner = {}
local ModuleScript = import("objects/ModuleScript")

local requiredMethods = {
	["getMenv"] = true,
	["getProtos"] = true,
	["getConstants"] = true,
	["getScriptClosure"] = true,
	["getLoadedModules"] = true
}

local function scan(query)
	local modules = {}
	query = query or ""

	for _, module in pairs(getLoadedModules()) do
		if string.match(string.lower(module.Name), query) then
			modules[module] = ModuleScript.new(module)
		end
	end

	return modules
end

ModuleScanner.Scan = scan
ModuleScanner.RequiredMethods = requiredMethods
return ModuleScanner
