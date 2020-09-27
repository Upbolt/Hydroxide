local ModuleScript = {}
ModuleScript.__index = ModuleScript

function ModuleScript.new(instance)
    local closure = getScriptClosure(instance)

    return setmetatable({
        Instance = instance,
        Constants = getConstants(closure),
        Protos = getProtos(closure),
        ReturnValue = require(instance)
    }, ModuleScript)
end

return ModuleScript
