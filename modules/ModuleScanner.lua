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
    
    for _i, module in pairs(getLoadedModules()) do
        if module.Name:lower():find(query) then
            modules[module] = ModuleScript.new(module)
        end
    end

    return modules
end

ModuleScanner.Scan = scan
ModuleScanner.RequiredMethods = requiredMethods
return ModuleScanner