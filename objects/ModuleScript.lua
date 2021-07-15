local ModuleScript = {}

function ModuleScript.new(instance)
    local moduleScript = {}
    local closure = getScriptClosure(instance)

    moduleScript.Instance = instance
    moduleScript.Constants = getConstants(closure)
    moduleScript.Protos = getProtos(closure)
    --moduleScript.ReturnValue = require(instance) // causes detection

    return moduleScript
end

return ModuleScript
